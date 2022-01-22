terraform {
  backend "s3" {
    bucket = "cosign-ecs-codepipeline"
    key    = "cosign-ecs-codepipeline/terraform_state"
    region = "us-west-2"
  }
}
