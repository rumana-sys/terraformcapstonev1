output "alb_arn" {
  value = aws_lb.frontend_alb.arn
}

output "frontend_alb_sg_id" {
  value = aws_security_group.frontend_alb_sg.id
}

#Added by rumana
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.frontend_alb.dns_name
}
