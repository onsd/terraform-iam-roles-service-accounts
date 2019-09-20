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

  public_subnets = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]

  tags = "${local.tags}"
}
