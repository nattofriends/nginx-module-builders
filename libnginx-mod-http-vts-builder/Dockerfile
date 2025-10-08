ARG DISTRIB
ARG RELEASE

FROM ${DISTRIB}:${RELEASE}

ARG RELEASE

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get --no-install-recommends --no-install-suggests -y install \
    git wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre3-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev

ARG NGINX_VERSION
ARG NGINX_DEB_RELEASE=1
ARG MODULE_VERSION

ENV PACKAGE_VERSION=${MODULE_VERSION}+nginx-${NGINX_VERSION}~${RELEASE}

# Build the module
WORKDIR /work

RUN git clone --branch v${MODULE_VERSION} https://github.com/vozlt/nginx-module-vts ngx_http_vhost_traffic_status_module

RUN wget -qO - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xzf -
WORKDIR /work/nginx-${NGINX_VERSION}

COPY debian debian

RUN dch --create --controlmaint --package libnginx-mod-http-vts \
    -v ${PACKAGE_VERSION} --distribution ${RELEASE} "Release (module: ${MODULE_VERSION}; for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-vts_*.deb /dist/
