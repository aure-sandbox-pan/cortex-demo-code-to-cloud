# GitHub Actions OIDC federation: lets .github/workflows/cd.yml assume an AWS
# role without any long-lived access keys stored as GitHub secrets.

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Scoped to pushes/dispatches on main only - not the whole repo, not other
    # branches. StringLike (not StringEquals) because GitHub appends
    # "@<owner_id>"/"@<repo_id>" suffixes to this claim once an org or repo
    # has been renamed/transferred at least once - the trailing "*" absorbs
    # that optional suffix while still requiring the literal org/repo names
    # as a prefix.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}*/${var.github_repo}*:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_actions_cd" {
  name               = "github-actions-cortex-demo-cd"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
}

data "aws_iam_policy_document" "github_actions_permissions" {
  statement {
    sid       = "TerraformState"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn, "${aws_s3_bucket.tfstate.arn}/*"]
  }

  # The app bucket name isn't known until the first apply (random suffix),
  # so this is scoped by naming convention instead of a literal ARN.
  statement {
    sid       = "AppBuckets"
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::cortex-demo-*", "arn:aws:s3:::cortex-demo-*/*"]
  }

  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "EcrRepo"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:PutImageScanningConfiguration",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:TagResource",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.github_repo}"]
  }

  # terraform/eks.tf provisions the cluster itself via this role - scoped by
  # region/account (cluster name is fixed but not known until first apply
  # writes it, so this covers create + all subsequent lifecycle calls).
  statement {
    sid    = "EksManage"
    effect = "Allow"
    actions = [
      "eks:CreateCluster",
      "eks:DeleteCluster",
      "eks:DescribeCluster",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
      "eks:TagResource",
      "eks:ListTagsForResource",
      "eks:CreateNodegroup",
      "eks:DeleteNodegroup",
      "eks:DescribeNodegroup",
      "eks:UpdateNodegroupConfig",
      "eks:CreateAccessEntry",
      "eks:DeleteAccessEntry",
      "eks:DescribeAccessEntry",
      "eks:AssociateAccessPolicy",
      "eks:DisassociateAccessPolicy",
      "eks:ListAssociatedAccessPolicies",
    ]
    resources = [
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/*",
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:nodegroup/*/*/*",
      "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:access-entry/*/*/*",
    ]
  }

  # Default VPC/subnet lookups for the EKS network config.
  statement {
    sid       = "Ec2ReadOnly"
    effect    = "Allow"
    actions   = ["ec2:DescribeVpcs", "ec2:DescribeSubnets", "ec2:DescribeAvailabilityZones"]
    resources = ["*"]
  }

  # Creates + attaches the two service roles EKS needs (cluster role, node
  # role) and passes them to the eks.amazonaws.com / ec2.amazonaws.com
  # services. Scoped by name to the two roles terraform/eks.tf defines, not
  # to all of IAM - this role cannot create or pass arbitrary roles.
  statement {
    sid    = "EksServiceRoles"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cortex-demo-eks-cluster",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cortex-demo-eks-nodes",
    ]
  }

  statement {
    sid     = "PassEksServiceRoles"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cortex-demo-eks-cluster",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cortex-demo-eks-nodes",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }

  # So the CD role itself shows up with cluster-admin access once
  # aws_eks_access_entry grants it (needed to read its own role ARN/name).
  statement {
    sid       = "SelfRoleLookup"
    effect    = "Allow"
    actions   = ["iam:GetRole"]
    resources = [aws_iam_role.github_actions_cd.arn]
  }

  # Needed for the app bucket's aws:kms default encryption (AWS-managed key).
  statement {
    sid       = "KmsForS3"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_cd" {
  name   = "github-actions-cortex-demo-cd-permissions"
  role   = aws_iam_role.github_actions_cd.id
  policy = data.aws_iam_policy_document.github_actions_permissions.json
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_cd.arn
}
