# Classic Load Balancer - Without S3 logs (using CloudWatch instead)
resource "aws_elb" "app_clb" {
  name            = "${var.app_name}-clb"
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.clb_sg.id]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/hello" # or /actuator/health for Spring Boot
    interval            = 30
  }

  # Enable CloudWatch metrics for ELB
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name        = "${var.app_name}-clb"
    Environment = var.environment
  }
}