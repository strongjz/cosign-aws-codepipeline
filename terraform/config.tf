terraform {
  backend "s3" {
    bucket = "cosign_aws_codepipeline"
    key    = "cosign_aws_codepipeline/terraform_state"
    region = "us-west-2"
  }
}
