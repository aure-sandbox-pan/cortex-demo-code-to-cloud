# EKS cluster for the demo. Uses the account's default VPC/subnets to keep
# the footprint small - this is a throwaway demo cluster, not prod.

# State migration for the "this"/"default" -> "cluster"/"nodes" rename
# (fixes yor_name showing up as literally "this" on live AWS resources) -
# without these, terraform treats the rename as destroy-old/create-new,
# which for aws_eks_cluster means destroying the whole cluster.
moved {
  from = aws_eks_cluster.this
  to   = aws_eks_cluster.cluster
}

moved {
  from = aws_eks_node_group.default
  to   = aws_eks_node_group.nodes
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# The CD role itself (created once by terraform-bootstrap/oidc.tf, outside
# this state) - referenced here to grant it EKS cluster access below.
data "aws_iam_role" "github_actions_cd" {
  name = "github-actions-cortex-demo-cd"
}

resource "aws_iam_role" "eks_cluster" {
  name = "cortex-demo-eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = {
    Name                 = "cortex-demo-eks-cluster-role"
    git_commit           = "c1508b81ef79681da9983b4e75c89922e819d57a"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-02 16:21:32"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    yor_name             = "eks_cluster"
    yor_trace            = "0afa247c-acbd-4a37-82d3-ae19c28b7ef8"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_nodes" {
  name = "cortex-demo-eks-nodes"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = {
    git_commit           = "c1508b81ef79681da9983b4e75c89922e819d57a"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-02 16:21:32"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    Name                 = "cortex-demo-eks-nodes-role"
    yor_name             = "eks_nodes"
    yor_trace            = "8e37d07c-63a8-4ba2-8187-c76bc3f3395a"
  }
}

resource "aws_iam_role_policy_attachment" "eks_nodes_worker" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_nodes_ecr" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = data.aws_subnets.default.ids
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  access_config {
    authentication_mode = "API"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
  tags = {
    git_commit           = "c1508b81ef79681da9983b4e75c89922e819d57a"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-02 16:21:32"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    Name                 = "cortex-demo-eks"
    yor_name             = "cluster"
    yor_trace            = "d1446f7d-0d3d-4f15-a6d9-ae55951c0ca3"
  }
}

# EKS managed node groups cap the IMDS hop limit at 1 by default, which
# blocks metadata access from inside pods (Docker's network namespace adds a
# hop). Cortex Cloud's admission-controller pod has no IRSA role bound to its
# service account, so it falls back to the node's instance-profile
# credentials via IMDS for its own AWS calls (e.g. resolving ECR image
# digests during admission review) - with hop limit 1 those calls never get
# credentials in time and the webhook trips its 10s timeout. Hop limit 2
# is the standard fix: one extra hop for the container network namespace,
# IMDSv2 (http_tokens = "required") stays enforced.
#
# checkov:skip=CKV_AWS_341: hop limit 2 is required (not just convenient)
# for this cluster - see justification above. IMDSv2 token requirement
# still bounds the exposure to a single extra network hop.
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "cortex-demo-eks-nodes-"

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # EKS's own managed launch config encrypts the root volume by default: a
  # custom launch template drops that implicit behavior and falls back to
  # EC2's default (unencrypted), which this account's
  # DenyEc2MountUnencryptedVolume SCP explicitly blocks at RunInstances time.
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted   = true
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cortex-demo-eks-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    git_commit           = "9edbd0d779e23fc9fc4a0d0145c737f4be3167f1"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-06 07:58:09"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    Name                 = "cortex-demo-eks-nodes-lt"
    yor_name             = "eks_nodes"
    yor_trace            = "5720daec-3ee1-446d-a853-9528637d2a61"
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "cortex-demo-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = data.aws_subnets.default.ids
  instance_types  = ["t3.medium"]

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_cni,
    aws_iam_role_policy_attachment.eks_nodes_ecr,
  ]
  tags = {
    git_commit           = "9edbd0d779e23fc9fc4a0d0145c737f4be3167f1"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-06 07:58:09"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    Name                 = "cortex-demo-eks-nodes"
    yor_name             = "nodes"
    yor_trace            = "7e423c6e-d358-48a0-a397-66695b23eafa"
  }
}

# Lets the GitHub Actions CD role (assumed via OIDC, see terraform-bootstrap/
# oidc.tf) run kubectl against this cluster in the deploy job.
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = data.aws_iam_role.github_actions_cd.arn
  tags = {
    git_commit           = "c1508b81ef79681da9983b4e75c89922e819d57a"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-02 16:21:32"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    Name                 = "cortex-demo-eks-access-github-actions"
    yor_name             = "github_actions"
    yor_trace            = "78ecaed3-552a-4b14-b377-27760e557197"
  }
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = data.aws_iam_role.github_actions_cd.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# Cortex Cloud's cross-account roles (created by the "Automated - Execute in
# AWS" CloudFormation stack during onboarding, see README prerequisite 4).
# Their name suffix is tenant-specific, so we discover them by prefix rather
# than hardcoding one tenant's exact role name - this keeps the grant working
# for any team/tenant that reuses this repo. Without an EKS access entry,
# Cortex Cloud's agentless Kubernetes Security scan fails with a 403 calling
# the EKS API (this cluster uses authentication_mode = "API", which requires
# an explicit access entry per principal). Resolves to an empty set (and
# creates nothing) if the CFN stack hasn't been created yet.
data "aws_iam_roles" "cortex_platform" {
  name_regex = "^CortexPlatform(Scanner)?Role-.*"
}

resource "aws_eks_access_entry" "cortex_platform" {
  for_each      = data.aws_iam_roles.cortex_platform.arns
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  tags = {
    git_commit           = "f84ab9615052225c38fe674e4be24fee6c6f57cc"
    git_file             = "terraform/eks.tf"
    git_last_modified_at = "2026-08-04 12:25:24"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    Name                 = "cortex-demo-eks-access-cortex-platform"
    yor_name             = "cortex_platform"
    yor_trace            = "61fc513e-73fe-43af-b85f-b78bd72a8ba8"
  }
}

resource "aws_eks_access_policy_association" "cortex_platform_view" {
  for_each      = data.aws_iam_roles.cortex_platform.arns
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}

output "eks_cluster_name" {
  value = aws_eks_cluster.cluster.name
}
