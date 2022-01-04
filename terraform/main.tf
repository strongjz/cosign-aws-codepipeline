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

resource "aws_kms_key" "cosign" {
  description             = "Cosign Key"
  deletion_window_in_days = 10
  tags = {}
}

resource "aws_kms_alias" "a" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.cosign.key_id
}