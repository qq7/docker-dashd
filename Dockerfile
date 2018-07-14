FROM alpine:3.8

ENV DASH_VERSION=0.12.3.2

RUN addgroup -g 1000 dashd \
  && adduser -u 1000 -G dashd -s /bin/sh -D dashd \
  && apk add --no-cache \
    boost \
    boost-program_options \
    openssl \
    libevent \
    binutils \
    zeromq \
  && apk add --no-cache --virtual /.build-deps \
    autoconf \
    automake \
    boost-dev \
    build-base \
    openssl-dev \
    libevent-dev \
    libtool \
    zeromq-dev \
  && wget -O dashd.tar.gz https://github.com/dashpay/dash/releases/download/v${DASH_VERSION}/dashcore-${DASH_VERSION}.tar.gz \ 
  && mkdir -p /usr/local/src \
  && tar xvf dashd.tar.gz -C /usr/local/src \
  && rm dashd.tar.gz \
  && mv /usr/local/src/dashcore-* /usr/local/src/dash \
  && cd /usr/local/src/dash \
  && ./autogen.sh \
  && ./configure \
    --disable-shared \
    --disable-static \
    --disable-wallet \
    --disable-tests \
    --disable-bench \
    --with-utils \
    --without-libs \
    --without-gui \
  && make -j$(nproc) \
  && strip -o /home/dashd/dashd src/dashd \
  && chown dashd /home/dashd/dash* \
  && rm -rf /usr/local/src/dash \
  && apk del /.build-deps

USER dashd
ENTRYPOINT ["/home/dashd/dashd"]
