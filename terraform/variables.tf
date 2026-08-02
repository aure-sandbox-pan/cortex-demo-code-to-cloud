variable "aws_region" {
  description = "AWS region for the demo environment"
  type        = string
  default     = "eu-west-1"
}

variable "eks_cluster_name" {
  description = "Name of the demo EKS cluster"
  type        = string
  default     = "cortex-demo-eks"
}

variable "github_repo" {
  description = "GitHub repo name - also used as the ECR repository name (must match terraform-bootstrap's github_repo, which scopes the CD role's ECR permissions to this name)"
  type        = string
  default     = "cortex-demo-code-to-cloud"
}
