# Terraform04 – 使用公有模組構建 VPC、EC2、ALB、RDS 完整架構
本專案透過 Terraform 官方公有模組（terraform-aws-modules） 建立一套標準三層架構：
 - VPC 與 subnet
 - Security Group
 - EC2 Web 伺服器（2 台）
 - Application Load Balancer (ALB)
 - RDS MySQL 資料庫
 - EBS 掛載 + Nginx 自動安裝（user_data）

此專案展示了如何用 Terraform Modules 建立可擴展、可維護的 AWS 架構，同時整合 Compute、Network、Database 與自動化初始化腳本。

## 專案架構
```
.
├── main.tf            # 所有 AWS Modules 使用與架構邏輯
├── variable.tf        # 參數化輸入變數
├── terraform.tfvars   # 實際環境參數
├── output.tf          # 輸出重要資訊 (ALB ID、EC2 IP)
├── modules/
│   └── sg/            # 自訂安全組模組
└── README.md
```
## version.tf and provider.tf (略...)

## main.tf — 主要架構定義

1. 定義 Security Group Module
```
module "sg" {
  source = "./modules/sg"
  vpc_id = var.vpc_id
}
```
2. EC2 Module（兩台 Web Server）
使用 count = 2 自動建立兩台，使用官方模組掛載多顆 EBS，自動安裝 Nginx
```
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  count   = 2
  name    = "web-${count.index+1}"
  
  instance_type = "t2.xlarge"
  key_name      = "user1"
  monitoring    = true
  subnet_id     = var.private_subnet_id[count.index]
  vpc_security_group_ids = [module.sg.sg_id]

  ebs_volumes = {
    "/dev/sdf" = { ... }
    "/dev/sdg" = { ... }
  }

  tags = {
    Name = "web-${count.index+1}"
  }

  depends_on = [module.sg]
  user_data  = local.user_data
}
```
3. user_data — 自動掛載 EBS + 安裝 Nginx
```
locals {
  user_data = <<EOF
#!/bin/bash
mkfs.ext4 /dev/sdf && mkdir -p /dataB && /bin/mount /dev/sdf /dataB
echo `blkid /dev/sdf | awk '{print $2}' | sed 's/\"//g'` /dataB ext4 defaults 0 0 >> /etc/fstab
mkfs.ext4 /dev/sdg && mkdir -p /dataC && /bin/mount /dev/sdg /dataC
echo `blkid /dev/sdg | awk '{print $2}' | sed 's/\"//g'` /dataC ext4 defaults 0 0 >> /etc/fstab

yum install -y nginx
private_ip=`curl http://100.100.100.200/latest/meta-data/private-ipv4`
sed -i "1i$private_ip" /usr/share/nginx/html/index.html
systemctl start nginx
EOF
}
```

4. ALB Module
建立 ALB，設定 ingress/egress、Listener redirect 和 兩個 Target Groups，指向兩台 EC2

```
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "web-alb"
  vpc_id  = var.vpc_id
  subnets = [var.public_subnets_id[0], var.public_subnets_id[1]]

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
      target_id = module.ec2_instance[0].id
      protocol  = "HTTP"
      port      = 80
    }
    ex-instance2 = {
      target_id = module.ec2_instance[1].id
      protocol  = "HTTP"
      port      = 80
    }
  }

  depends_on = [module.sg, module.ec2_instance]
}
```
5. RDS Module
使用官方模組快速建立 MySQL：
```
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "demodb"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.xlarge"
  allocated_storage = 5
  publicly_accessible = false

  username = "user"
  db_name  = "demodb"
  port     = "3306"

  vpc_security_group_ids = [module.sg.sg_id]
  subnet_ids = [var.private_subnet_id[0], var.private_subnet_id[1]]

  deletion_protection = true

  parameters = [
    { name = "character_set_client", value = "utf8mb4" },
    { name = "character_set_server", value = "utf8mb4" }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
      option_settings = [
        { name = "SERVER_AUDIT_EVENTS", value = "CONNECT" },
        { name = "SERVER_AUDIT_FILE_ROTATIONS", value = "37" },
      ]
    }
  ]
}
```
## output.tf - 輸出結果
```
output "alb_id" {
  value = module.alb.id
}

output "ec2-1_private_ip" {
  value = module.ec2_instance[0].private_ip
}

output "ec2-2_private_ip" {
  value = module.ec2_instance[1].private_ip
}
```
## terraform.tfvars - 實際環境參數
```
ak        = "AKIAZI2LHRVTAVWGVBOP"
sk        = "p3VmXiXXG1bytU99JBhQNCk0E0x6CX97MpiUftqZ"
vpc_id    = "vpc-024732791d1f594df"
private_subnet_id = [ "subnet-06095cf777be79aed", "subnet-0dad1d5068af2aae6" ]
public_subnets_id = [ "subnet-086047f7bf6c2c069", "subnet-0a45727ff0bc3eec2" ]
```
## variable.tf - 變數定義
```

variable "ak" {
  type        = string
  description = "access_key"
}

variable "sk" {
  type        = string
  description = "secret_key"
}

variable "vpc_id" {
  type = string
  description = "the ID of the VPC "
}

variable "private_subnet_id" {
  type = list(string)
}

variable "public_subnets_id" {
  type = list(string)
}

```

### Terraform 執行流程
```
terraform init
terraform plan
terraform apply
terraform destroy
```
