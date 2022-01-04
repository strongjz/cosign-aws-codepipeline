resource "aws_ecr_repository" "ecr" {
  name                 = "golang_example_${var.name}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    env = var.name
  }
}

