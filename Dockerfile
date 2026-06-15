ARG KONG_IMAGE=kong/kong-gateway:3.14-amazonlinux-2023

# Stage 1: builder — gera o .rock
FROM ${KONG_IMAGE} AS builder
USER root
WORKDIR /work

RUN yum -y install tar-2:1.34-1.amzn2023.0.4 git-2.50.1-1.amzn2023.0.1 openssl-devel-1:3.5.5-1.amzn2023.0.3 make-1:4.3-5.amzn2023.0.2 && yum -y clean all

COPY . .
RUN make rockspec \
    && luarocks make --pack-binary-rock --deps-mode=none

# Stage 2: export — apenas o .rock
FROM scratch AS export
COPY --from=builder /work/*.rock /

# Stage 3: runtime — preserva o uso atual do Dockerfile
FROM ${KONG_IMAGE} AS runtime
USER root

RUN yum -y install git-2.50.1-1.amzn2023.0.1 unzip-6.0-68.amzn2023.0.1 && yum -y clean all

WORKDIR /work
COPY --from=builder /work/*.rock /tmp/
RUN luarocks install /tmp/*.rock

USER kong
