# CloudWatch Dashboard for monitoring
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # Widget 1: EC2 Instances Over Time (MAIN WIDGET - Shows scaling events)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ELB", "HealthyHostCount", "LoadBalancerName", "hellomvc-clb", { "label" : "EC2 Instances Count" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Instances - Scaling Events Over Time"
          period  = 60
          stat    = "Average"
        }
      },

      # Widget 2: Request Count (Shows what triggered scaling)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6

        properties = {
          metrics = [
            ["AWS/ELB", "RequestCount", "LoadBalancerName", "hellomvc-clb", { "label" : "Total Requests" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Request Count"
          period  = 60
          stat    = "Sum"
        }
      },

      # Widget 3: CPU Utilization (Performance during scaling)
      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", "hellomvc-asg", { "label" : "Average CPU %" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "CPU Utilization"
          period  = 60
          stat    = "Average"
        }
      }
    ]
  })
}