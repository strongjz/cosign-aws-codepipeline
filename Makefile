NAME ?=cosign-aws
IMAGE ?= distroless-base
VERSION ?= 0.0.3
GOLANG_VERSION ?= 1.17.2
AWS_REGION ?= us-west-2
AWS_DEFAULT_REGION ?= us-west-2
REPO_INFO ?= $(shell git config --get remote.origin.url)
COMMIT_SHA ?= git-$(shell git rev-parse --short HEAD)
COSIGN_ROLE_NAME ?= "$(NAME)-codebuild"
ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text)
AWS_SDK_LOAD_CONFIG="true"

export

.PHONY: aws_account
aws_account:
	$(ACCOUNT_ID)

docker_multiarch_build:
	 docker buildx build \
 	--push \
    --platform linux/amd64,linux/arm64 -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION) .

docker_build:
	 docker build -t $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION) .

.SILENT: ecr_auth
ecr_auth:
	docker login --username AWS -p $(shell aws ecr get-login-password --region $(AWS_REGION) ) $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

docker_push:
	docker push $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

ecr_scan:
	aws ecr start-image-scan --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

ecr_scan_findings:
	aws ecr describe-image-scan-findings --repository-name $(IMAGE) --image-id imageTag=$(VERSION)

docker_run:
	docker run -it --platform $(PLATFORM) --rm $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

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

sign: ecr_auth
	cosign sign --key awskms:///alias/$(NAME) $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

key_gen:
	cosign generate-key-pair --kms awskms:///alias/$(NAME) $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

verify: ecr_auth
	cosign verify --key cosign.pub $(ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(IMAGE):$(VERSION)

