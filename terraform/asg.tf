############################################
# Auto Scaling Group
############################################
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.app_bucket_name}-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.app_server_lt.id
    version = "$Latest"
  }

  load_balancers            = [aws_elb.app_clb.name]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.app_bucket_name}-AppServer"
    propagate_at_launch = true
  }
}

############################################
# Scale Out Policy and Alarm
############################################
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.app_bucket_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name          = "${var.app_bucket_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale out if average CPU > 70% for 2 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}
############################################
# Scale In Policy and Alarm
############################################
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.app_bucket_name}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name          = "${var.app_bucket_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale in if average CPU < 30% for 2 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_cloudwatch_dashboard" "asg_dashboard" {
  dashboard_name = "${var.app_bucket_name}-asg-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric",
        x      = 0,
        y      = 0,
        width  = 12,
        height = 6,
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", aws_autoscaling_group.app_asg.name],
            [".", "GroupTotalInstances", ".", "."],
            [".", "GroupPendingInstances", ".", "."]
          ],
          period = 60,
          stat   = "Average",
          region = var.aws_region,
          title  = "Auto Scaling Instance Activity"
        }
      }
    ]
  })
}
