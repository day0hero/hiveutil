.PHONY: build run aws-deprovision

IMAGE_REPO ?= quay.io/validatedpatterns
IMAGE_NAME ?= hive
IMAGE_TAG ?= latest
CONTAINER_ENGINE ?= podman

# AWS deprovision variables
CLUSTER ?=
REGION ?= us-west-1
DOMAIN ?= aws.validatedpatterns.io
AWS_CREDS_DIR ?= $(HOME)/.aws

.PHONY: help
# No need to add a comment here as help is described in common/
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^(\s|[a-zA-Z_0-9-])+:.*?##/ { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: build
build:	## Build the Container Image
	$(CONTAINER_ENGINE) build -t $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) -f Containerfile .

.PHONY: push
push:	## Push the image to quay
	$(CONTAINER_ENGINE) push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: aws-deprovision
aws-deprovision: ## make aws-deprovision CLUSTER=test REGION=us-west2
ifndef CLUSTER
	$(error CLUSTER is required. Usage: make aws-deprovision CLUSTER=mycluster REGION=us-west-2)
endif
	$(CONTAINER_ENGINE) run --rm \
		--userns=keep-id \
		--user $(shell id -u) \
		-v $(AWS_CREDS_DIR):/home/hive/.aws:ro,Z \
		$(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) \
		aws-tag-deprovision \
		--region $(REGION) \
		--cluster-domain $(CLUSTER).$(DOMAIN) \
		--creds-dir /home/hive/.aws \
		kubernetes.io/cluster/$(CLUSTER)=owned
