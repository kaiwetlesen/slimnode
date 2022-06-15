ARG ALPINE_VER="latest"
FROM alpine:$ALPINE_VER AS build

RUN apk update && apk upgrade
RUN apk add make gcc g++ binutils python2 python3 linux-headers zlib zlib-dev\
  libretls libretls-dev libcrypto1.1 libssl1.1 openssl-dev musl-dev brotli\
  brotli-dev nghttp2-libs nghttp2-dev libuv libuv-dev c-ares c-ares-dev
RUN addgroup builder\
  && adduser -s /bin/sh -h /home/builder -G builder -D builder

USER builder:builder
WORKDIR /home/builder
# curl -LO https://nodejs.org/dist/latest-erbium/node-v12.22.12.tar.gz
# or find the latest source distribution of your choice
ARG NODE_VERSION
RUN if [ -z "${NODE_VERSION}" ]; then\
  echo 'Environment variable NODE_VERSION must be set' >&2 ;\
 fi
RUN test -n "${NODE_VERSION}"
COPY node-${NODE_VERSION}.tar.gz .

RUN tar xzf node-${NODE_VERSION}.tar.gz
WORKDIR /home/builder/node-${NODE_VERSION}
RUN BROTLIFLAGS=$( echo ${NODE_VERSION} | grep -qi v10 && echo '' || echo '--shared-brotli') &&\
  ./configure --prefix=/opt/node-${NODE_VERSION}\
    --without-dtrace\
    --without-etw\
    --without-inspector\
    --shared-libuv\
    --shared-nghttp2\
    --shared-openssl\
    --shared-zlib\
    $BROTLIFLAGS\
    --shared-cares
RUN export NCPUS=$(grep '^processor' /proc/cpuinfo | wc -l) && make -j $NCPUS -l $NCPUS

USER root:root
RUN make install
RUN strip /opt/node-${NODE_VERSION}/bin/node
ENV NODE_VERSION ${NODE_VERSION}
ENV PATH "/opt/node-${NODE_VERSION}/bin:$PATH"
RUN npm install --upgrade --global npm
RUN npm install --global corepack

USER builder:builder
WORKDIR /home/builder
COPY ./dietnode.sh .
RUN /home/builder/dietnode.sh\
  /opt/node-${NODE_VERSION}/lib/node_modules\
  /home/builder/node_modules_compressed

USER root:root
RUN rm -rf /opt/node-${NODE_VERSION}/lib/node_modules
RUN cp -r /home/builder/node_modules_compressed /opt/node-${NODE_VERSION}/lib/node_modules
RUN chown root:root /opt/node-${NODE_VERSION}/lib/node_modules
RUN find /opt/node-${NODE_VERSION}/bin -type l -exec readlink -f {} \; | xargs chmod 0755

ARG ALPINE_VER="latest"
FROM alpine:$ALPINE_VER AS runtime
ARG NODE_VERSION
ARG NODE_LTS_VER
RUN apk update && apk upgrade
RUN apk add libgc++ zlib libretls libcrypto1.1 libssl1.1 brotli nghttp2-libs libuv c-ares
COPY --from=build /opt/node-${NODE_VERSION} /opt/node-${NODE_VERSION}
RUN ln -s /opt/node-${NODE_VERSION} /opt/node
RUN if [ -n "${NODE_LTS_VER}" ]; then ln -s /opt/node-${NODE_VERSION} /opt/node-lts-${NODE_LTS_VER}; fi
ENV PATH "/opt/node/bin:$PATH"

CMD [ "/bin/sh" ]
