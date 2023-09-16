output "rainy_load_balancer_url" {
  value = aws_elb.rainy_evening.dns_name
}