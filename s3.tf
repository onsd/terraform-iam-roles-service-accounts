locals {
  serviceaccount = <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-sa
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: "${aws_iam_role.s3_service_account.arn}"
EOF
}

resource "aws_iam_role_policy" "s3_service_account" {
  policy = "${data.aws_iam_policy_document.s3.json}"
  role   = "${aws_iam_role.s3_service_account.name}"
}

resource "aws_iam_role" "s3_service_account" {
  assume_role_policy = "${data.aws_iam_policy_document.s3_service_account.json}"
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
        "system:serviceaccount:default:s3-sa"
      ]
    }
  }
}

resource "aws_iam_policy" "s3" {
  name   = "s3_read_only"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:*",
    ]
  }
}



resource "aws_s3_bucket" "bucket" {
  bucket = "terraform-bucket-test-hello-hello"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
