ARG DISTRIB
ARG RELEASE

FROM ${DISTRIB}:${RELEASE}

ARG RELEASE

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get --no-install-recommends --no-install-suggests -y install \
    git wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre2-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev \
    libvips-dev

ARG NGINX_VERSION
ARG NGINX_DEB_RELEASE=1
ARG MODULE_VERSION

WORKDIR /work
RUN wget -qO - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xzf -

RUN git clone --depth=1 --branch ${MODULE_VERSION} https://github.com/nattofriends/nginx-module-vips-webp /work/ngx_http_vips_webp_module

COPY debian /work/nginx-${NGINX_VERSION}/debian

WORKDIR /work/nginx-${NGINX_VERSION}

RUN dch --create --controlmaint --package libnginx-mod-http-vips-webp \
    -v 1.0-nginx-${NGINX_VERSION}-${NGINX_DEB_RELEASE} \
    --distribution ${RELEASE} "Release (module: ${MODULE_VERSION}; for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-vips-webp_*.deb /dist/
RUN ls /dist
