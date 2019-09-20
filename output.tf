output "kubeconfig" {
  value = "${module.next-cluster.kubeconfig}"
}

output "aws-auth" {
  value = "${local.eks_configmap}"
}

output "vault_serviceaccount" {
  value = "${aws_iam_role.vault_unseal_service_account.arn}"
}
