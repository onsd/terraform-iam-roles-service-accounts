output "kubeconfig" {
  value = "${module.next-cluster.kubeconfig}"
}

output "aws-auth" {
  value = "${local.eks_configmap}"
}

output "s3_serviceaccount" {
  value = "${local.serviceaccount}"
}
