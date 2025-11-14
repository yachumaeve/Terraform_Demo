# 題目指定透過公有倉庫創建vpc, alb, ec2
# VPC网段为10.0.0.0/16，VSwithc网段为10.0.0.0/24、10.0.1.0/24


module "sg" {
  source = "./modules/sg"
  vpc_id = var.vpc_id
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  count = 2
  name = "web-${count.index+1}"
  
  instance_type = "t2.xlarge"
  key_name      = "user1"
  monitoring    = true
#   subnet_id     = module.vpc.private_subnets[count.index]
  subnet_id     = var.private_subnet_id[count.index]
  vpc_security_group_ids = [module.sg.sg_id]

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
  tags = {
    Name = "web-${count.index+1}"
  }
  depends_on = [module.sg]
  user_data = local.user_data
}

locals {
  user_data = <<EOF
#!/bin/bash
mkfs.ext4 /dev/sdf && mkdir -p /dataB && /bin/mount /dev/sdf /dataB
echo `blkid /dev/sdf | awk '{print $2}' | sed 's/\"//g'` /dataB ext4 defaults 0 0 >> /etc/fstab
mkfs.ext4 /dev/sdg && mkdir -p /dataC && /bin/mount /dev/sdg /dataC
echo `blkid /dev/sdg | awk '{print $2}' | sed 's/\"//g'` /dataC ext4 defaults 0 0 >> /etc/fstab

#安装nginx
yum install -y nginx
private_ip=`curl http://100.100.100.200/latest/meta-data/private-ipv4`
sed -i "1i$private_ip" /usr/share/nginx/html/index.html
systemctl start nginx
EOF
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "web-alb"
  vpc_id = var.vpc_id
  subnets = [var.public_subnets_id[0], var.public_subnets_id[1]]
  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  target_groups = {
    ex-instance1 = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = module.ec2_instance[0].id
    },
    ex-instance2 = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = module.ec2_instance[1].id
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
  depends_on = [module.sg, module.ec2_instance]
}


module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.xlarge"
  allocated_storage = 5
  publicly_accessible  = false

  db_name  = "demodb"
  username = "user"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.sg.sg_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  create_db_subnet_group = true
#   subnet_ids             = [module.vpc.private_ip[0], module.vpc.private_ip[1]]
  subnet_ids = [var.private_subnet_id[0], var.private_subnet_id[1]]
  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"
  option_group_name = null

  # Database Deletion Protection
  deletion_protection = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
