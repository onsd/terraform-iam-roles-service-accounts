provider "aws" {
  region = "ap-northeast-1"
}


data "aws_availability_zones" "available" {}

locals {
  tags = {
    Terraform   = "true"
    Environment = "Cluster"
  }
  cluster_name    = "next-cluster"
  cluster_version = "1.13"
}
