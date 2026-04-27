ARG DISTRIB
ARG RELEASE

FROM ${DISTRIB}:${RELEASE}

ARG RELEASE

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get --no-install-recommends --no-install-suggests -y install \
    git wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre2-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev

ARG NGINX_VERSION
ARG NGINX_DEB_RELEASE=1
ARG MODULE_VERSION
ARG ZSTD_VERSION

# Build zstd with PGO
WORKDIR /work
RUN git clone --depth=1 --branch ${ZSTD_VERSION} https://github.com/facebook/zstd
RUN git -C zstd describe --tags HEAD | tee /tmp/zstd-version
WORKDIR /work/zstd
RUN set -ex; \
    BASE_CFLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections"; \
    BASE_LDFLAGS="-Wl,--gc-sections"; \
    PGO_HASH="pgo"; \
    # 1. Use upstream's official PGO target for high-quality training \
    make -C programs -j$(nproc) zstd-pgo \
        HASH_DIR=${PGO_HASH} CC=gcc \
        MOREFLAGS="${BASE_CFLAGS} ${BASE_LDFLAGS}"; \
    # 2. Sync profiles to the library directory's static obj path \
    # This allows lib/Makefile to find the training data from the CLI build. \
    mkdir -p lib/obj/${PGO_HASH}/static; \
    cp programs/obj/${PGO_HASH}/*.gcda lib/obj/${PGO_HASH}/static/ || true; \
    # Also sync to the dynamic path for the shared library build \
    mkdir -p lib/obj/${PGO_HASH}/dynamic; \
    cp programs/obj/${PGO_HASH}/*.gcda lib/obj/${PGO_HASH}/dynamic/ || true; \
    # 3. Build the library using upstream's object list (keeps us in sync) \
    # We use the same 'ignore' flags as upstream's zstd-pgo target \
    PROF_USE_FLAGS="-fprofile-use -fprofile-dir=. -Wno-error=missing-profile -Wno-error=coverage-mismatch"; \
    make -C lib -j$(nproc) lib-mt \
        HASH_DIR=${PGO_HASH} \
        MOREFLAGS="${BASE_CFLAGS} ${BASE_LDFLAGS} ${PROF_USE_FLAGS}"; \
    find . -name "*.gcda" -delete

# Build the module
WORKDIR /work

COPY placeholder ./ngx_http_zstd_module*/ /work/ngx_http_zstd_module/
RUN rm ngx_http_zstd_module/placeholder; stat ngx_http_zstd_module/.git || git clone --branch ${MODULE_VERSION} https://github.com/HanadaLee/ngx_http_zstd_module ngx_http_zstd_module

RUN git -C ngx_http_zstd_module describe --tags HEAD | tee /tmp/module-version

RUN wget -qO - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xzf -
WORKDIR /work/nginx-${NGINX_VERSION}

COPY debian debian

RUN dch --create --controlmaint --package libnginx-mod-http-zstd \
    -v $(cat /tmp/module-version)+zstd-$(cat /tmp/zstd-version)-nginx-${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE} \
    --distribution ${RELEASE} "Release (module: $(cat /tmp/module-version); zstd: $(cat /tmp/zstd-version); for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

ENV ZSTD_INC=/work/zstd/lib ZSTD_LIB=/work/zstd/lib
RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-zstd_*.deb /dist/
RUN ls /dist
