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
* KMS - Asymmetric key used for cosign key signing

Create an S3 bucket for Terraform remote state storage, this will have to be unique. 

`aws s3 mb s3://cosign-aws-codepipeline`

Create the terraform plan 

`make tf_plan`

Apply the changes 

`make tf_apply`

Push this code repo to the AWS Codecommit repo by creating a new remote

`git remote add aws $AWS_CODE_COMMIT_REPO`

`git push aws main`

This should kick off the codepipeline and codebuild Terraform creates

