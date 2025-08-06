FROM kong/kong-gateway:3.7.1.2-amazonlinux-2023 AS lua_builder

USER root
WORKDIR /

RUN yum -y install tar-2:1.34-1.amzn2023.0.4 git-2.40.1-1.amzn2023.0.3 openssl-devel-1:3.0.8-1.amzn2023.0.12 make-1:4.3-5.amzn2023.0.2 && yum -y clean all

COPY . /
RUN make rockspec \
  && luarocks make --pack-binary-rock --only-server https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/daab2726276e3282dc347b89a42a5107c3500567 \
  && mkdir -p /build/plugin \
  && find . -name *.rock -exec cp {} /build/plugin \;

FROM kong/kong-gateway:3.7.1.2-amazonlinux-2023

USER root

RUN yum -y install git-2.40.1-1.amzn2023.0.3 && yum -y clean all

WORKDIR /
COPY --from=lua_builder  /build/plugin/* /
RUN find . -name *.rock -exec luarocks install ./{} --only-server https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/daab2726276e3282dc347b89a42a5107c3500567 \;

USER kong
