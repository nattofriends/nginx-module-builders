ARG DISTRIB
ARG RELEASE

FROM ${DISTRIB}:${RELEASE}

ARG RELEASE

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get --no-install-recommends --no-install-suggests -y install \
    git wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre2-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev \
    libzstd-dev

ARG NGINX_VERSION
ARG NGINX_DEB_RELEASE=1
ARG MODULE_VERSION
ARG ZSTD_VERSION

WORKDIR /work

COPY placeholder ./ngx_http_zstd_module*/ /work/ngx_http_zstd_module/
RUN rm ngx_http_zstd_module/placeholder; stat ngx_http_zstd_module/.git || git clone --branch ${MODULE_VERSION} https://github.com/myguard-labs/nginx-zstd-module ngx_http_zstd_module

RUN git -C ngx_http_zstd_module describe --tags HEAD | tee /tmp/module-version

RUN wget -qO - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xzf -
WORKDIR /work/nginx-${NGINX_VERSION}

COPY debian debian

RUN dch --create --controlmaint --package libnginx-mod-http-zstd \
    -v $(cat /tmp/module-version)+nginx-${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE} \
    --distribution ${RELEASE} "Release (module: $(cat /tmp/module-version); for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-zstd_*.deb /dist/
RUN ls /dist
