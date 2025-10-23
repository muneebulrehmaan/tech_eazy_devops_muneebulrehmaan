# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.app_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_ids
  load_balancers      = [aws_elb.app_clb.name]

  tag {
    key                 = "Name"
    value               = "${var.app_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Application"
    value               = var.app_name
    propagate_at_launch = true
  }

  # Instance refresh to ensure new instances get latest JAR
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}

# CloudWatch Alarm for scaling up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.app_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.app_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

# CloudWatch Alarm for scaling down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.app_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.app_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}