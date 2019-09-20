locals {
  eks_configmap = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
}

module "next-cluster" {
  source  = "terraform-aws-modules/eks/aws" #https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/6.0.0
  version = "6.0.0"

  cluster_name                    = "${local.cluster_name}"
  cluster_version                 = "${local.cluster_version}"
  cluster_endpoint_private_access = true
  manage_aws_auth                 = false
  subnets                         = "${module.vpc.public_subnets}"
  vpc_id                          = "${module.vpc.vpc_id}"

  worker_groups = []

  write_aws_auth_config = false
  write_kubeconfig      = false
  tags                  = "${local.tags}"
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # CA thumbprint
  url             = "${module.next-cluster.cluster_oidc_issuer_url}"
}
