variable "github_org" {
  description = "GitHub org or user that owns the demo repo"
  type        = string
  default     = "aure-sandbox-pan"
}

variable "github_repo" {
  description = "GitHub repo name"
  type        = string
  default     = "cortex-demo-code-to-cloud"
}

variable "aws_region" {
  description = "AWS region for the demo environment"
  type        = string
  default     = "eu-west-1"
}
