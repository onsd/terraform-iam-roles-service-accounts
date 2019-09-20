module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.15.0"

  cidr                 = "10.20.0.0/16"
  azs                  = "${data.aws_availability_zones.available.names}"
  enable_dns_hostnames = true
  enable_dhcp_options  = false
  name                 = "next-cluster-vpc"

  public_subnet_tags = {
    "kubernetes.io/cluster/next-cluster" = "shared"
    "kubernetes.io/role/elb"             = "1"
  }

  public_subnets  = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnets = ["10.20.5.0/24", "10.20.6.0/24", "10.20.7.0/24"]

  #database_subnets = ["10.20.104.0/24","10.20.105.0/24","10.20.106.0/24"]
  #elasticache_subnets = ["10.20.107.0/24","10.20.108.0/24","10.20.109.0/24"]

  tags = "${local.tags}"
}
