# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.app_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 200
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
    triggers = ["launch_template"]
  }
}

# Progressive Scale Up Policy - Add 1 instance
resource "aws_autoscaling_policy" "scale_up_one" {
  name                   = "${var.app_name}-scale-up-one"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 180
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Progressive Scale Up Policy - Add 2 instances  
resource "aws_autoscaling_policy" "scale_up_two" {
  name                   = "${var.app_name}-scale-up-two"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 180
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.app_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Moderate Traffic - Add 1 instance (800+ requests/minute)
resource "aws_cloudwatch_metric_alarm" "moderate_traffic" {
  alarm_name          = "${var.app_name}-moderate-traffic"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "800"

  dimensions = {
    LoadBalancerName = aws_elb.app_clb.name
  }

  alarm_description = "Add 1 instance when traffic is moderate (800+ requests/minute)"
  alarm_actions     = [aws_autoscaling_policy.scale_up_one.arn]
}

# High Traffic - Add 2 instances (1500+ requests/minute)
resource "aws_cloudwatch_metric_alarm" "high_traffic" {
  alarm_name          = "${var.app_name}-high-traffic"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1500"

  dimensions = {
    LoadBalancerName = aws_elb.app_clb.name
  }

  alarm_description = "Add 2 instances when traffic is high (1500+ requests/minute)"
  alarm_actions     = [aws_autoscaling_policy.scale_up_two.arn]
}

# Scale Down - Remove 1 instance
resource "aws_cloudwatch_metric_alarm" "low_traffic" {
  alarm_name          = "${var.app_name}-low-traffic"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "RequestCount"
  namespace           = "AWS/ELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "300"

  dimensions = {
    LoadBalancerName = aws_elb.app_clb.name
  }

  alarm_description = "Remove 1 instance when traffic is low (<300 requests/minute for 3 minutes)"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

# CPU-based Scaling - High CPU (Backup)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.app_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "Scale up when CPU utilization exceeds 30% for 2 periods"
  alarm_actions     = [aws_autoscaling_policy.scale_up_one.arn]
}

# CPU-based Scaling - Low CPU (Backup)
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.app_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

  alarm_description = "Scale down when CPU utilization is below 10% for 2 periods"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}