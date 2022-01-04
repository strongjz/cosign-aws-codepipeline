terraform {
  backend "s3" {
    bucket = "cosign-aws-codepipeline"
    key    = "cosign-aws-codepipeline/terraform_state"
    region = "us-west-2"
  }
}
