REGISTRY ?= strongjz
NAME ?=cosign-aws
IMAGE ?= distroless-base
GOLANG_VERSION ?= 1.17.2
AWS_REGION ?= us-west-2
AWS_DEFAULT_REGION ?= us-west-2
REPO_INFO ?= $(shell git config --get remote.origin.url)
COMMIT_SHA ?= git-$(shell git rev-parse --short HEAD)
CODEBUILD_ROLE_NAME ?= "$(NAME)-codebuild"

export

aws_account:
	aws sts get-caller-identity --query Account --output text

docker_build:
	docker build -t $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION) .

ecr_auth:
	$(shell aws ecr get-login --no-include-email)

docker_push: ecr_auth docker_build
	docker push $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

ecr_scan:
	aws ecr start-image-scan --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

ecr_scan_findings:
	aws ecr describe-image-scan-findings --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

docker_run:
	docker run -it --rm $(shell aws sts get-caller-identity --query Account --output text).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

check:
	terraform -v  >/dev/null 2>&1 || echo "Terraform not installed" || exit 1 && \
	aws --version  >/dev/null 2>&1 || echo "AWS not installed" || exit 1 && \

tf_clean:
	cd terraform/ && \
	rm -rf .terraform \
	rm -rf plan.out

tf_init: 
	cd terraform/ && \
	terraform init

tf_get:
	cd terraform/ && \
	terraform get

tf_plan:
	cd terraform/ && \
	terraform plan -out=plan.out

tf_apply:
	cd terraform/ && \
	terraform apply -auto-approve

tf_destroy:
	cd terraform/ && \
	terraform destroy