FROM debian:stretch

RUN apt-get update

RUN apt-get install -y \
  lua5.1 \
  liblua5.1-0-dev \
  luarocks \
  git \
  libssl1.0-dev \
  make

ADD Makefile .
RUN make setup

ADD kong-plugin-template-transformer-*.rockspec .
