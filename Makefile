VERSION    ?= 1.3.4
IMAGE_NAME ?= bilderlings/jobber

build:
	docker build \
		--build-arg JOBBER_VERSION=$(VERSION) \
		-t $(IMAGE_NAME):$(VERSION) .
	cd jobber-tools  && docker build \
		--build-arg JOBBER_VERSION=$(VERSION) \
		--build-arg FROM_IMAGE=$(IMAGE_NAME) \
		-t $(IMAGE_NAME):tools-$(VERSION) .
	cd jobber-docker && docker build \
		--build-arg JOBBER_VERSION=$(VERSION) \
		--build-arg FROM_IMAGE=$(IMAGE_NAME) \
		-t $(IMAGE_NAME):docker-$(VERSION) .

	docker tag $(IMAGE_NAME):$(VERSION) $(IMAGE_NAME):latest
.PHONY: build

test:
	docker build \
		--build-arg JOBBER_VERSION=$(VERSION) \
		-t $(IMAGE_NAME):$(VERSION) .
	docker run \
		-e JOB_NAME1=test \
		-e JOB_TIME1='*/5 * * * *' \
		-e JOB_COMMAND1='echo test' \
		$(IMAGE_NAME):$(VERSION)

push:
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):tools-$(VERSION)
	docker push $(IMAGE_NAME):docker-$(VERSION)
	docker push $(IMAGE_NAME):latest
.PHONY: push
