# Terraform02 – 使用 Terraform 建立 EC2 Instance

本專案示範如何使用 Terraform 定義 AWS Provider、設定基本資源，並以基礎的 IaC（Infrastructure as Code）方式部署一台 EC2 虛擬機器。
重點在於透過模組化檔案結構與清楚的 Provider、Resource 定義，展現對 Terraform workflow 與 AWS 基礎架構的理解。

## 專案架構 
```
.
├── provider.tf        # 設定 AWS Provider
├── version.tf         # 定義 Terraform 與 Provider 版本需求
├── terraform.tf       # 建立 EC2 資源
└── README.md
```

## version.tf — Provider 版本定義
定義Provider - 此檔案定義所需的 Terraform CLI 版本與 AWS Provider 版本，確保程式碼在一致的版本環境中執行，避免在不同環境出現相容性問題。
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
## provider.tf - 設定 AWS Provider
設定 AWS Provider 並指定部署區域（Region）。
(注意：實務上不應將 access_key / secret_key 放在程式碼中，建議使用：AWS CLI (aws configure),environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY), IAM Role（最推薦）
```
provider "aws" {
    region = "us-east-1"
  #   access_key = "AKIAZI2LHRVTAVWGVBOP"
  #   secret_key = "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"
}
```
## terraform.tf
此檔案示範如何建立一台最基本的 EC2 instance，包括：
- AMI 與 instance type
- Key Pair
- Subnet
- Security Group
- Tags
  
```
resource "aws_instance" "EC2" {
  ami           = "ami-00ca32bbc84273381"
  instance_type = "t3.micro"
  key_name = "maeve-ec2keypair-1a"
  subnet_id = "subnet-0719bb9859de06aba"
  security_groups = ["sg-0178cf3b07f16fb5d"]
  
  tags = {
    Name = "HelloWorld"
  }
}
```
## 執行方式
```
terraform init      # 初始化 provider plugins
terraform plan      # 預覽即將建立的資源
terraform apply     # 實際建立 EC2 instance
terraform destroy   # 刪除資源
```
