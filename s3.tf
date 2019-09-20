resource "aws_iam_role_policy" "vault_unseal_service_account" {
  policy = "${data.aws_iam_policy_document.s3_service_account.json}"
  role   = "${aws_iam_role.s3_service_account.name}"
}
data "aws_iam_policy_document" "s3_service_account" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = ["${aws_iam_openid_connect_provider.oidc_provider.arn}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:default:vault-unseal"
      ]
    }
  }
}

data "aws_iam_policy_document" "s3_service_account" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:Get*",
      "s3:List*",
    ]
  }
}

