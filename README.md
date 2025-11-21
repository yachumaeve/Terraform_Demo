# Terraform_Demo

使用 Terraform 在 AWS 上逐步打造完整雲端架構，此專案內容包含 5 個循序漸進的 Terraform 專案（Terraform01～Terraform05），展示從建立單一 EC2，到使用公有模組打造多層式 AWS 架構的完整學習與實作過程。每個專案都遵循 IaC（Infrastructure as Code）最佳實務，並逐步引入：

- Provider 與版本管理
- 變數、locals、tfvars
- 官方 Terraform module 使用
- EC2、ALB、RDS、VPC 建置
- 自動化 user_data 初始化腳本
- EBS 掛載、掛載點管理
- 私有與公有子網分層架構
  
## 專案總覽 Summary

| 專案              | 重點內容                               | 使用服務 / 特性                                |
| --------------- | ---------------------------------- | ---------------------------------------- |
| **Terraform01** | 基礎 provider 與單一 S3 Bucket 建置             | S3、Provider 基本設定                        |
| **Terraform02** | 基礎 provider 與單一 EC2 建置             | EC2、Provider 基本設定                        |
| **Terraform03** | 使用 variables、locals 將架構參數化         | Variables、Locals、EC2、Security Group      |
| **Terraform04** | 使用公有模組架構 Web 雲端服務（ALB + EC2 + RDS） | ALB、EC2、RDS、SG、user_data、EBS、Modules     |
| **Terraform05** | 使用官方 VPC 模組建立具有公有/私有子網的完整 VPC      | VPC、Subnet、Route Table、NAT GW、VPN GW、IGW |

## 我的 Terraform 學習筆記：
1. 透過EC2使用Terraform進行部署 : https://hackmd.io/@Maeve/SyfqGHgFge
2. 使用Variable 和Locals : https://hackmd.io/@Maeve/ByYleqZFle
3. Terraform 模塊與參數傳遞 : https://hackmd.io/@Maeve/SkK0q3MFll
4. Terraform plan 的重要性 : https://hackmd.io/@Maeve/ryRXJZQFxx
