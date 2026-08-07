resource "aws_ecr_repository" "app" {
  name                 = var.github_repo
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    git_commit           = "c1508b81ef79681da9983b4e75c89922e819d57a"
    git_file             = "terraform/ecr.tf"
    git_last_modified_at = "2026-08-02 16:21:32"
    git_last_modified_by = "agrivet@paloaltonetworks.com"
    git_modifiers        = "agrivet"
    git_org              = "aure-sandbox-pan"
    git_repo             = "cortex-demo-code-to-cloud"
    yor_name             = "app"
    yor_trace            = "288894f7-7b97-4b3b-af57-a1774721a138"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
