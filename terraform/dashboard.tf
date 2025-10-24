# CloudWatch Dashboard for monitoring
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Row 1: Auto Scaling Group Metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", "${var.app_name}-asg"],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", "${var.app_name}-asg"],
            ["AWS/AutoScaling", "GroupMinSize", "AutoScalingGroupName", "${var.app_name}-asg"],
            ["AWS/AutoScaling", "GroupMaxSize", "AutoScalingGroupName", "${var.app_name}-asg"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Auto Scaling Group - Instance Count"
          period  = 300
          stat    = "Average"
        }
      },

      # Row 2: EC2 CPU Utilization
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "${var.app_name}-asg"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 CPU Utilization (%)"
          period  = 300
          stat    = "Average"
        }
      },

      # Row 2: ELB Metrics
      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6

        properties = {
          metrics = [
            ["AWS/ELB", "RequestCount", "LoadBalancerName", "${var.app_name}-clb"],
            ["AWS/ELB", "HealthyHostCount", "LoadBalancerName", "${var.app_name}-clb"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ELB - Requests & Healthy Hosts"
          period  = 300
          stat    = "Sum"
        }
      },

      # Row 3: Scaling Activities
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupTotalInstances", "AutoScalingGroupName", "${var.app_name}-asg", { "label" : "Total Instances" }],
            [".", "GroupTerminatingInstances", ".", ".", { "label" : "Terminating" }],
            [".", "GroupPendingInstances", ".", ".", { "label" : "Pending" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Instance Lifecycle States"
          period  = 300
          stat    = "Average"
        }
      },

      # Row 4: Custom Metrics - Scale Up/Down Count
      {
        type   = "text"
        x      = 0
        y      = 18
        width  = 12
        height = 3

        properties = {
          markdown = "# Scaling Summary\n- **Scale Up Events**: Triggered when CPU > 70%\n- **Scale Down Events**: Triggered when CPU < 30%\n- **Instance Range**: ${var.min_size} to ${var.max_size} instances"
        }
      }
    ]
  })
}

# CloudWatch Alarms for scaling events tracking
resource "aws_cloudwatch_metric_alarm" "scale_up_events" {
  alarm_name          = "${var.app_name}-scale-up-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupTotalInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "2"
  alarm_description   = "Track when scale up events occur"
  alarm_actions       = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down_events" {
  alarm_name          = "${var.app_name}-scale-down-events"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupTotalInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "2"
  alarm_description   = "Track when scale down events occur"
  alarm_actions       = []

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}