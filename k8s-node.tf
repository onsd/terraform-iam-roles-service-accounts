resource "aws_autoscaling_group" "eks-node" {
  name_prefix           = "${local.cluster_name}-nodes-"
  desired_capacity      = 2
  max_size              = 2
  min_size              = 1
  force_delete          = false
  vpc_zone_identifier   = "${module.vpc.public_subnets}"
  protect_from_scale_in = false
  suspended_processes   = ["AZRebalance"] # AZ rebalance

  launch_template {
    id      = "${aws_launch_template.eks_node.id}"
    version = "$Latest"
  }

  tags = [
    {
      key                 = "Terraform"
      value               = "True"
      propagate_at_launch = false
    },
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = ["desired_capacity"]
  }
}

resource "aws_launch_template" "eks_node" {
  name_prefix = "${local.cluster_name}-node-"

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = ["${module.next-cluster.worker_security_group_id}"]
  }

  iam_instance_profile {
    name = "${aws_iam_instance_profile.eks-node-profile.name}"
  }

  image_id      = "${data.aws_ami.eks-node.image_id}"
  instance_type = "t2.medium"
  user_data     = "${base64encode(data.template_file.eks-node.rendered)}"

  monitoring {
    enabled = false
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name                                 = "${local.cluster_name}-nodes"
      "kubernetes.io/cluster/next-cluster" = "owned"
      Environment                          = "Cluster"
    }
  }

  tags = "${local.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "eks-node" {
  name_prefix = "${local.cluster_name}-node-"
  role        = "${aws_iam_role.eks-node.id}"

}

data "aws_ami" "eks-node" {
  filter {
    name   = "image-id"
    values = ["ami-0a67c71d2ab43d36f"] # Amaozn EKS optimized AMI for Tokyo region
  }

  most_recent = true
  owners      = ["602401143452"] # Owner ID of AWS EKS team
}

data "template_file" "eks-node" {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"

  vars = {
    cluster_name        = "${local.cluster_name}"
    endpoint            = "${module.next-cluster.cluster_endpoint}"
    cluster_auth_base64 = "${module.next-cluster.cluster_certificate_authority_data}"
    pre_userdata        = ""
    additional_userdata = ""
    kubelet_extra_args  = ""
  }
}
