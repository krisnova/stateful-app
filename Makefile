ifndef VERBOSE
	MAKEFLAGS += --silent
endif

TARGET = stateful-app
GOTARGET = github.com/kubicorn/$(TARGET)
REGISTRY ?= krisnova
IMAGE = $(REGISTRY)/$(TARGET)
DIR := ${CURDIR}
DOCKER ?= docker

GIT_VERSION ?= $(shell git describe --always --dirty)
IMAGE_VERSION ?= $(shell git describe --always --dirty)
IMAGE_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD | sed 's/\///g')
GIT_REF = $(shell git rev-parse --short=8 --verify HEAD)

FMT_PKGS=$(shell go list -f {{.Dir}} ./... | grep -v vendor | tail -n +2)

default: compile

all: compile install

push: ## Push to the docker registry
	$(DOCKER) push $(REGISTRY)/$(TARGET):$(GIT_REF)
	$(DOCKER) push $(REGISTRY)/$(TARGET):latest

clean: ## Clean the docker images
	rm -f $(TARGET)
	$(DOCKER) rmi $(REGISTRY)/$(TARGET) || true

container: ## Build the docker container
	$(DOCKER) build \
		-t $(REGISTRY)/$(TARGET):$(IMAGE_VERSION) \
		-t $(REGISTRY)/$(TARGET):$(IMAGE_BRANCH) \
		-t $(REGISTRY)/$(TARGET):$(GIT_REF) \
	    -t $(REGISTRY)/$(TARGET):latest \
		.

run: ## Run the program
	$(DOCKER) run $(REGISTRY)/$(TARGET):$(IMAGE_VERSION)


compile: ## Compile the binary into bin/stateful-app
	go build -o bin/state_app main.go

install: ## Install the app
	./scripts/install.sh


update-headers: ## Update the headers in the repository. Required for all new files.
	./scripts/headers.sh

gofmt: install-tools ## Go fmt your code
	echo "Fixing format of go files..."; \
	for package in $(FMT_PKGS); \
	do \
		gofmt -w $$package ; \
		goimports -l -w $$package ; \
	done

check-headers: ## Check if the headers are valid. This is ran in CI.
	./scripts/check-header.sh

.PHONY: check-code
check-code: install-tools ## Run code checks
	PKGS="${FMT_PKGS}" GOFMT="gofmt" GOLINT="golint" ./scripts/ci-checks.sh

.PHONY: help
help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install-tools
install-tools:
	GOIMPORTS_CMD=$(shell command -v goimports 2> /dev/null)
ifndef GOIMPORTS_CMD
	go get golang.org/x/tools/cmd/goimports
endif
	GOLINT_CMD=$(shell command -v golint 2> /dev/null)
ifndef GOLINT_CMD
	go get github.com/golang/lint/golint
endif