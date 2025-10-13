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

# Build zstd
WORKDIR /work
RUN git clone --depth=1 --branch ${ZSTD_VERSION} https://github.com/facebook/zstd
RUN git -C zstd describe --tags HEAD | tee /tmp/zstd-version
WORKDIR /work/zstd/lib
ENV CFLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections"
RUN make -j4 lib-mt

# Build the module
WORKDIR /work

COPY ngx_http_zstd_module* /work/ngx_http_zstd_module
RUN stat ngx_http_zstd_module || git clone --branch ${MODULE_VERSION} https://github.com/HanadaLee/ngx_http_zstd_module ngx_http_zstd_module

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
