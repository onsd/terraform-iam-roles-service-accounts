provider "aws" {
  region = "ap-northeast-1"
}


data "aws_availability_zones" "available" {}

locals {
  tags = {
    Terraform   = "true"
    Environment = "Cluster"
  }

  # iam_path = ?
  cluster_name    = "next-cluster"
  cluster_version = "1.13" # 最新は1.15 1.12で固定??
}
