FROM ubuntu:22.04


RUN apt update -y && apt install -y lua5.1 liblua5.1-dev build-essential wget git zip unzip
RUN git config --global url.https://github.com/.insteadOf git://github.com/
RUN wget https://download.konghq.com/gateway-3.x-ubuntu-bionic/pool/all/k/kong/kong_3.0.0_amd64.deb &&\
  apt install -y ./kong_3.0.0_amd64.deb


RUN wget https://luarocks.org/releases/luarocks-3.3.1.tar.gz &&\
  tar zxpf luarocks-3.3.1.tar.gz &&\
  cd luarocks-3.3.1 && ./configure --with-lua-include=/usr/include/lua5.1 &&\
  make && make install

WORKDIR /home/plugin

COPY Makefile .
COPY rockspec.template .
RUN make setup

RUN chmod -R a+rw /home/plugin
