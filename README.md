# cosign-aws-codepipeline

This repo is an example of using AWS Codepipeline and CodeBuild to sign and verify a docker image with Sigstore's 
cosign.

Terraform creates all the AWS Resources necessary to run the Codepipeline.

* Codepipeline
  * S3 Bucket
  * IAM Role
  * IAM Role Policy
* AWS Codecommit Repo
* CodeBuild Project
  * IAM Role
  * S3 Bucket
  * Cloudwatch Log Group and Steam
* ECR - Container Repository
* KMS - Asymetric key used for cosign key signing
