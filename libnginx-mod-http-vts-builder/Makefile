NGINX_VERSION ?= $(shell curl -s https://nginx.org/en/CHANGES | grep -m1 -Po "(\d+\.)+\d+")
MODULE_VERSION ?= 0.2.4

DISTRIB ?= $(shell . /etc/os-release; echo $$ID)
RELEASE ?= $(shell . /etc/os-release; echo $$VERSION_CODENAME)

BUILD_IMAGE ?= libnginx-mod-http-vts-builder

dist:
	mkdir -p dist

build: dist
	BUILDKIT_PROGRESS=plain docker build --network=host \
		-t $(BUILD_IMAGE) \
		--build-arg DISTRIB=$(DISTRIB) \
		--build-arg RELEASE=$(RELEASE) \
		--build-arg NGINX_VERSION=$(NGINX_VERSION) \
		--build-arg MODULE_VERSION=$(MODULE_VERSION) \
		.
	docker run $(BUILD_IMAGE) ls /dist
	mkdir -p dist/$(DISTRIB)-$(RELEASE)
	docker cp $$(docker ps -l -q):/dist/. dist/$(DISTRIB)-$(RELEASE)
	docker rm $$(docker ps -l -q)

clean:
	rm -rf dist/
	docker rmi $(BUILD_IMAGE)
