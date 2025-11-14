output "alb_id" {
  value = module.alb.id
}

output "ec2-1_private_ip" {
  value = module.ec2_instance[0].private_ip
}

output "ec2-2_private_ip" {
  value = module.ec2_instance[1].private_ip
}