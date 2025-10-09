SUBDIRS := libnginx-mod-http-brotli-builder libnginx-mod-http-vips-webp-builder libnginx-mod-http-vts-builder libnginx-mod-http-zstd-builder

.PHONY: build
build:
	for dir in $(SUBDIRS); do $(MAKE) -C $${dir} build; done

.PHONY: clean
clean:
	for dir in $(SUBDIRS); do $(MAKE) -C $${dir} clean; done
