# EKS node
resource "aws_iam_role" "eks-node" {
  name = "eks-node-iam-role"

  assume_role_policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "Principal": {
        "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
    }
]
}
POLICY
}

# policies for worker-node-role
# "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", 
# "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", 
# "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" 
resource "aws_iam_role_policy_attachment" "eks-worker-node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "eks-cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_role_policy_attachment" "ecr-ro" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-node.name}"
}

resource "aws_iam_instance_profile" "eks-node-profile" {
  name = "eks-node-instance-profile"
  role = "${aws_iam_role.eks-node.name}"
}
