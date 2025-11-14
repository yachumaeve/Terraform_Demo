# VPC 模組
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "web-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  
  tags = {
    Environment = "production"
  }
}

# 安全組模組
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-sg"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}


# EC2 實例模組
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  count  = 2

  name          = "web-${count.index + 1}"
  instance_type = "t3.micro"

  subnet_id                   = module.vpc.private_subnets[count.index]
  vpc_security_group_ids     = [module.sg.security_group_id]
  associate_public_ip_address = false

  root_block_device = {
    volume_size = 20
    volume_type = "gp2"
  }

  ebs_volumes = {
    "/dev/sdf" = {
      size       = 20
      type  = "gp3"
      throughput = 200
      encrypted  = true
      tags = {
        MountPoint = "/dataB"
        name = "dataB"
      }
    },
    "/dev/sdg" = {
      size       = 40
      type  = "gp3"
      throughput = 200
      encrypted  = true
      tags = {
        MountPoint = "/dataC"
        name = "dataC"
      }
    }
  }


  user_data = <<-EOF
#!/bin/bash
# 安裝 nginx
yum install -y nginx

# 獲取內網 IP
PRIVATE_IP=\$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

# 寫入歡迎頁面
echo "<h1>Welcome! Server IP: \$PRIVATE_IP</h1>" > /usr/share/nginx/html/index.html

# 啟動 nginx
systemctl start nginx
systemctl enable nginx

# 掛載數據盤
mkfs -t ext4 /dev/xvdf
mkfs -t ext4 /dev/xvdg

mkdir -p /dataB /dataC

echo "/dev/xvdf /dataB ext4 defaults 0 0" >> /etc/fstab
echo "/dev/xvdg /dataC ext4 defaults 0 0" >> /etc/fstab

mount -a
EOF

  tags = {
    Environment = "production"
  }
}

# ALB 模組
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name               = "web-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.sg.security_group_id]

  target_groups = {
    instance = {
      name_prefix = "web-tg"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = [module.ec2_instance[0].id,module.ec2_instance[1].id]
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "instance"
      }
    }
  }
  depends_on = [ module.vpc, module.sg, module.ec2_instance ]
}

# RDS 模組
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine               = "mysql"
  engine_version       = "8.0"
  family              = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "webapp"
  username = "admin"
  password = "YourPwdShouldBe32CharactersLong!"
  port     = 3306

  multi_az               = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.sg.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 7
  skip_final_snapshot    = true

  create_db_parameter_group = true
  create_db_option_group   = true

  enabled_cloudwatch_logs_exports = ["audit", "general"]
}