.PHONY: build build-all push push-all run stop clean info login help

# Configuration
POSTGRES_BRANCH ?= REL_18_STABLE
IMAGE_NAME ?= job
PLATFORMS ?= linux/amd64,linux/arm64
REGISTRY ?=
#docker.io
USERNAME ?=

# Derived
FULL_IMAGE = $(if $(USERNAME),$(REGISTRY)/$(USERNAME)/$(IMAGE_NAME),$(IMAGE_NAME))

help:
	@echo "PostgreSQL 18 Docker Build System (with pre-loaded JOB data)"
	@echo ""
	@echo "Usage:"
	@echo "  make build                    Build for current platform"
	@echo "  make build POSTGRES_BRANCH=REL_18_STABLE"
	@echo "  make build-all                Build for all platforms (amd64, arm64)"
	@echo "  make push USERNAME=youruser   Push multiplatform image to registry"
	@echo "  make run                      Run PostgreSQL container"
	@echo "  make stop                     Stop PostgreSQL container"
	@echo "  make clean                    Remove image and build cache"
	@echo "  make info                     Show image build info"
	@echo ""
	@echo "Variables:"
	@echo "  POSTGRES_BRANCH  Git branch to build (default: REL_18_STABLE)"
	@echo "  IMAGE_NAME       Image name (default: postgres18-build)"
	@echo "  USERNAME         Docker Hub username for push"
	@echo "  PLATFORMS        Target platforms (default: linux/amd64,linux/arm64)"

# Build for current platform only
build:
	DOCKER_BUILDKIT=1 docker build \
		--build-arg POSTGRES_BRANCH=$(POSTGRES_BRANCH) \
		-t $(IMAGE_NAME):$(POSTGRES_BRANCH) \
		.

# Build for multiple platforms (requires buildx)
build-all: setup-buildx
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg POSTGRES_BRANCH=$(POSTGRES_BRANCH) \
		-t $(IMAGE_NAME):$(POSTGRES_BRANCH) \
		-t $(IMAGE_NAME):latest \
		--load \
		.

# Setup buildx builder if needed
setup-buildx:
	@docker buildx inspect multiplatform >/dev/null 2>&1 || \
		docker buildx create --name multiplatform --use

# Push multiplatform image to registry
push: setup-buildx
ifndef USERNAME
	$(error USERNAME is required. Usage: make push USERNAME=youruser)
endif
	docker buildx build \
		--platform $(PLATFORMS) \
		--build-arg POSTGRES_BRANCH=$(POSTGRES_BRANCH) \
		-t $(FULL_IMAGE):$(POSTGRES_BRANCH) \
		--push \
		.

# Run container (JOB data is pre-loaded in the image)
run:
	docker run -d \
		--name $(IMAGE_NAME) \
		-p 5432:5432 \
		$(IMAGE_NAME):$(POSTGRES_BRANCH)

# Stop and remove container
stop:
	docker stop $(IMAGE_NAME) 2>/dev/null || true
	docker rm $(IMAGE_NAME) 2>/dev/null || true

# Show build info from image
info:
	@docker run --rm $(IMAGE_NAME):latest cat /usr/local/pgsql/pg_build_info 2>/dev/null || \
		echo "Image not built yet. Run 'make build' first."
	@echo ""
	@docker run --rm $(IMAGE_NAME):latest postgres --version 2>/dev/null || true

# Login to registry
login:
ifndef USERNAME
	$(error USERNAME is required. Usage: make login USERNAME=youruser)
endif
	docker login -u $(USERNAME)

# Clean up
clean: stop
	docker rmi $(IMAGE_NAME):latest $(IMAGE_NAME):$(POSTGRES_BRANCH) 2>/dev/null || true
	docker builder prune --filter type=exec.cachemount -f
