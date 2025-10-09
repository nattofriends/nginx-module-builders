SUBDIRS := libnginx-mod-http-brotli-builder libnginx-mod-http-vips-webp-builder libnginx-mod-http-vts-builder libnginx-mod-http-zstd-builder

.PHONY: all
all: $(SUBDIRS)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ build
