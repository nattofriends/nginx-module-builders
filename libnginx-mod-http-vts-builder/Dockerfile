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

# Build the module
WORKDIR /work

COPY placeholder ./ngx_http_vhost_traffic_status_module*/ /work/ngx_http_vhost_traffic_status_module/
RUN rm ngx_http_vhost_traffic_status_module/placeholder; stat ngx_http_vhost_traffic_status_module/.git || git clone --branch v${MODULE_VERSION} https://github.com/vozlt/nginx-module-vts ngx_http_vhost_traffic_status_module
RUN git -C ngx_http_vhost_traffic_status_module describe --tags HEAD | tr -d v | tee /tmp/module-version

RUN wget -qO - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xzf -
WORKDIR /work/nginx-${NGINX_VERSION}

COPY debian debian

RUN dch --create --controlmaint --package libnginx-mod-http-vts \
    -v $(cat /tmp/module-version)-nginx-${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE} \
    --distribution ${RELEASE} "Release (module: $(cat /tmp/module-version); for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-vts_*.deb /dist/
