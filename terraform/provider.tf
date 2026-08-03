terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Partial config on purpose: bucket/key/region are supplied at `terraform
  # init` time via -backend-config, both by scripts/bootstrap.sh (local) and
  # .github/workflows/cd.yml (CI), so no AWS account ID is hardcoded here.
  backend "s3" {
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region

  # Applied to every resource that supports tagging, so this demo's
  # resources are identifiable (and filterable by "Tags") once discovered
  # by Cortex Cloud - separate from the tag Cortex applies to its own
  # onboarding infrastructure, which doesn't touch pre-existing resources.
  default_tags {
    tags = {
      Project = "cortex-demo-code-to-cloud"
    }
  }
}
