# Terraform03 - 使用變數與 Locals 建立 EC2 Instance

本專案示範如何在 Terraform 中：
- 使用 variables 管理區域、金鑰、Subnet、憑證等動態參數
- 使用 locals 定義可重複使用的常數或計算值
- 建立一台 EC2 Instance
- 展現對 Terraform 變數、輸入參數與程式碼結構化的理解

## 專案結構
```
.
├── version.tf        # Terraform 與 Provider 版本管理
├── provider.tf       # AWS Provider 設定 (使用變數)
├── variable.tf       # 所有輸入變數宣告
├── terraform.tf      # EC2 instance 與 locals 定義
└── README.md
```

## version.tf - Terraform 與 Provider 設定
明確定義 Terraform CLI 與 AWS Provider 的版本，確保環境一致性。
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}
```

## provider.tf - 使用變數設定 AWS Provider
使用變數管理 access_key 與 secret_key，更安全且符合環境分離原則。
（實務上更推薦使用 AWS CLI、環境變數或 IAM Role）
```
provider "aws" {
  region     = "us-east-1"
  access_key = var.ak
  secret_key = var.sk
}
```

## variable.tf
此檔案宣告所有可由外部（如 terraform.tfvars 或 CI/CD Pipeline）輸入的參數，增加程式碼彈性與可重複性。
```
variable "region" {
  type        = string
  description = "region of the aws"
}

variable "ak" {
  type        = string
  description = "access_key"
}

variable "sk" {
  type        = string
  description = "secret_key"
}
variable "subnet_id" {
  type        = string
  description = "subnet_id"
}
```

## terraform.tfvars
設定變數值
```
region    = "us-east-1"
ak        = "AKIAZI2LHRVTAVWGVBOP"
sk        = "p3VmXiXXG1bytU99JBhQNCk0E0x6CX97MpiUftqZ"
subnet_id = "subnet-0719bb9859de06aba"
```

## terraform.tf
 - 如何使用 locals 使程式碼更乾淨
 - 如何用 var.* 讀取外部變數
 - 建立基本 EC2 instance
 - 
```
resource "aws_instance" "EC2" {
  ami             = "ami-00ca32bbc84273381"
  instance_type   = local.type
  key_name        = "maeve-ec2keypair-1a"
  subnet_id       = var.subnet_id
  vpc_security_group_ids = ["sg-0178cf3b07f16fb5d"]

  tags = {
    Name = local.name
  }
}

locals {
  name = "Hello2"
  type = "t3.micro"
}
```

## 執行 Terraform workflow
```
terraform init      # 初始化 provider plugins
terraform plan      # 預覽執行結果
terraform apply     # 建立 EC2 instance
terraform destroy   # 刪除資源
```
