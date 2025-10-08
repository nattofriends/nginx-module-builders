SUBDIRS := libnginx-mod-http-brotli-builder libnginx-mod-http-vips-webp-builder libnginx-mod-http-vts-builder libnginx-mod-http-zstd-builder

$(info $(SUBDIRS))

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ build
