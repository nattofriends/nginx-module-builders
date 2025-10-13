ARG DISTRIB
ARG RELEASE

FROM ${DISTRIB}:${RELEASE}

ARG RELEASE

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get --no-install-recommends --no-install-suggests -y install \
    git wget ca-certificates curl openssl gnupg2 apt-transport-https \
    unzip make libpcre2-dev zlib1g-dev build-essential devscripts \
    debhelper quilt lsb-release libssl-dev lintian uuid-dev \
    cmake

ARG NGINX_VERSION
ARG NGINX_DEB_RELEASE=1
ARG MODULE_VERSION
ARG BROTLI_VERSION

WORKDIR /work
COPY placeholder ./ngx_brotli*/ /work/ngx_brotli/
RUN rm ngx_brotli/placeholder stat ngx_brotli/.git || git clone --branch ${MODULE_VERSION} --recurse-submodules --shallow-submodules https://github.com/google/ngx_brotli
RUN git -C ngx_brotli describe --tags HEAD | tr -d v | tee /tmp/module-version

WORKDIR /work/ngx_brotli/deps/brotli
RUN git checkout ${BROTLI_VERSION}
WORKDIR /work/ngx_brotli/deps/brotli/out
RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
    -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" \
    -DCMAKE_INSTALL_PREFIX=./installed .. && \
    cmake --build . --config Release --target brotlienc

WORKDIR /work
RUN wget -qO - https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xzf -
WORKDIR /work/nginx-${NGINX_VERSION}

COPY debian debian

RUN dch --create --controlmaint --package libnginx-mod-http-brotli \
    -v "$(cat /tmp/module-version)+brotli-${BROTLI_VERSION}-nginx-${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}" \
    --distribution ${RELEASE} "Release (module: $(cat /tmp/module-version); brotli: ${BROTLI_VERSION}; for nginx ${NGINX_VERSION}-${NGINX_DEB_RELEASE})"

RUN sed -i "s/{NGINX_VERSION}/${NGINX_VERSION}-${NGINX_DEB_RELEASE}~${RELEASE}/g" debian/control

RUN dpkg-buildpackage

RUN mkdir /dist && mv ../libnginx-mod-http-brotli_*.deb /dist/
RUN ls /dist
