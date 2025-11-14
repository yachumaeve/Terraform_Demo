output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "ec2_private_ips" {
  description = "Private IPs of EC2 instances"
  value       = module.ec2_instance[*].private_ip
}

output "rds_endpoint" {
  description = "The RDS endpoint"
  value       = module.db.db_instance_endpoint
}