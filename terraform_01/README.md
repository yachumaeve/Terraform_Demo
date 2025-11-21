# Terraform 01 - 創建S3 Bucket

#### 什麼是Provider 
Provider為各個雲公司提供與雲資源交互的後端驅動，不同的基礎設施提供商都需要提供一個Provider來實現對自家基礎設施的統一管理。
由於每間雲公司提供的Provider使用方式不同，我們可以透過Terraform官網上提供的API來使用，例如AWS：
https://registry.terraform.io/providers/hashicorp/aws/latest

1. 定義Provider
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
2. 配置Provider
  ```
  provider "aws" {
    region = "us-east-1" --> 指定使用區域
  }
  ```
3. 配置資源
  ```
  resource "aws_s3_bucket" "myS3Bucket" {
    bucket = "maeve0818mys3bucket2" --> 設定好Bucket Name
  }
  ```
