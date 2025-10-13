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

COPY placeholder ./ngx_http_vips_webp_module*/ /work/ngx_http_vips_webp_module/
RUN rm ngx_http_vips_webp_module/placeholder; stat ngx_http_vips_webp_module/.git || git clone --branch ${MODULE_VERSION} https://github.com/nattofriends/nginx-module-vips-webp /work/ngx_http_vips_webp_module
RUN git -C ngx_http_vips_webp_module describe --tags HEAD | tr -d v | tee /tmp/module-version

COPY debian /work/nginx-${NGINX_VERSION}/debian

WORKDIR /work/nginx-${NGINX_VERSION}

RUN dch --create --controlmaint --package libnginx-mod-http-vips-webp \
    -v $(cat /tmp/module-version)-nginx-${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE} \
    --distribution ${RELEASE} "Release (module: $(cat /tmp/module-version); for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-vips-webp_*.deb /dist/
RUN ls /dist
