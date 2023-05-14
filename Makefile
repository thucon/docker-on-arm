include version

APP_DOCKER_FILE   = dockerfile.app
APP_REGISTRY      = thucon/docker-app-on-arm
APP_TAG           = $(APP_REGISTRY):$(VERSION)

SERVICE_DOCKER_FILE   = dockerfile.service
SERVICE_REGISTRY      = thucon/docker-service-on-arm
SERVICE_TAG           = $(SERVICE_REGISTRY):$(VERSION)

SERVICE_CONTAINER_NAME  = api-server

PLATFORM      = linux/amd64,linux/arm64
#PLATFORM      = linux/arm64
#PLATFORM      = linux/amd64

.PHONY: clean all

###################
# STANDARD COMMANDS
###################
all: build

build:
	docker build --no-cache -t $(APP_REGISTRY) -f $(APP_DOCKER_FILE) .
	docker build --no-cache -t $(SERVICE_REGISTRY) -f $(SERVICE_DOCKER_FILE) .
	docker tag $(APP_REGISTRY) $(APP_TAG)
	docker tag $(SERVICE_REGISTRY) $(SERVICE_TAG)

clean:
	docker rmi -f $(APP_REGISTRY)
	docker rmi -f $(APP_TAG)
	docker rmi -f $(SERVICE_REGISTRY)
	docker rmi -f $(SERVICE_TAG)

push:
	docker push $(APP_REGISTRY)
	docker push $(APP_TAG)
	docker push $(SERVICE_REGISTRY)
	docker push $(SERVICE_TAG)

run-app:
	docker run --rm $(APP_REGISTRY)

run-service:
	docker run \
        -d \
        -p 8080:5000 \
        --restart always \
        --name $(SERVICE_CONTAINER_NAME) \
        $(SERVICE_REGISTRY)

stop-service:
	docker stop $(SERVICE_CONTAINER_NAME)
	docker rm --force $(SERVICE_CONTAINER_NAME)

###################
# CROSS COMPILE
###################

# https://github.com/docker/buildx/issues/495
buildx:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multibuilder-app --platform=${PLATFORM} --driver docker-container --use
	docker buildx inspect --bootstrap
	docker buildx build --platform=${PLATFORM} --push -t $(APP_REGISTRY) -t ${APP_TAG} -f $(APP_DOCKER_FILE) .

	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multibuilder-service --platform=${PLATFORM} --driver docker-container --use
	docker buildx inspect --bootstrap
	docker buildx build --platform=${PLATFORM} --push -t $(SERVICE_REGISTRY) -t ${SERVICE_TAG} -f $(SERVICE_DOCKER_FILE) .

cleanx:
	docker buildx rm -f multibuilder-app
	docker buildx rm -f multibuilder-service


