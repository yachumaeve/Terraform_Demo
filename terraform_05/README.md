# Terraform05 - 使用官方 VPC Module 建立多子網與 NAT Gateway 的 VPC

本專案使用 Terraform 官方公有模組 terraform-aws-modules/vpc/aws 建立一個具備：
 - 私有子網（Private Subnets）
 - 公有子網（Public Subnets）
 - NAT Gateway
 - VPN Gateway
   
## 專案結構
```
.
├── main.tf        # VPC 模組宣告與子網結構
├── provider.tf    # Terraform 與 AWS Provider 設定
└── README.md
```

## provider.tf - Terraform 與 AWS Provider 設定
定義 AWS provider 版本與 Region（實務上不應將 access_key / secret_key 寫入程式碼，建議使用 IAM Role 或環境變數）
```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIAZI2LHRVTAVWGVBOP"
  secret_key = "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"
}

```

## main.tf - 使用 terraform-aws-modules/vpc 建立 VPC
- 建立 VPC CIDR
- 自動建立多個 public/private 子網
- 自動建立 route tables、IGW、NAT Gateway、VPN Gateway
- 支援 AZ 分布（高可用架構）
  
```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test"
  cidr = "172.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b"]
  private_subnets = ["172.0.0.0/24", "172.0.1.0/24"]
  public_subnets  = ["172.0.101.0/24", "172.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
```

## 執行 Terraform Workflow
```
terraform init      # 下載 VPC module 與 AWS Provider
terraform plan      # 檢查架構配置
terraform apply     # 建立完整 VPC
terraform destroy   # 清除資源
```

