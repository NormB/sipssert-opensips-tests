# OpenSIPS image for the NATS SIPssert sets (nats, event_nats, cachedb_nats,
# nats_consumer): the core, the SIP / MI / usrloc / clusterer / TLS modules
# the scenarios load and the five NATS modules, against libnats (the
# version scripts/build/install_libnats.sh pins) built with TLS.
# Built by build.sh from a git archive of an OpenSIPS tree (src.tar).
FROM debian:trixie-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential bison flex pkg-config cmake wget ca-certificates \
        libssl-dev libcurl4-openssl-dev libpcre2-dev libxml2-dev \
        libncurses-dev libmicrohttpd-dev libjson-c-dev \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /src
ADD src.tar /src
RUN LIBNATS_TLS=ON sh scripts/build/install_libnats.sh
RUN make -j1 app && make -j1 modules modules="modules/sl modules/tm modules/rr \
        modules/maxfwd modules/signaling modules/textops modules/sipmsgops \
        modules/proto_tcp modules/mi_fifo modules/mi_http modules/httpd \
        modules/usrloc modules/registrar modules/json modules/event_route \
        modules/dialog modules/cachedb_local modules/cfgutils \
        modules/tls_mgm modules/tls_openssl \
        modules-contrib/nats modules-contrib/event_nats \
        modules-contrib/cachedb_nats modules-contrib/cachedb_nats_fts \
        modules-contrib/nats_consumer" \
    && mkdir -p /out/lib/opensips/modules /out/sbin \
    && install -m755 opensips /out/sbin/ \
    && find modules modules-contrib -maxdepth 2 -name '*.so' \
        -exec install -m755 {} /out/lib/opensips/modules/ \;
# usrloc full-sharing-cachedb needs the clusterer (a layer of its own, so
# the build above stays cached)
RUN make -j1 modules modules="modules/clusterer modules/proto_bin modules/mi_datagram" \
    && install -m755 modules/clusterer/clusterer.so modules/proto_bin/proto_bin.so \
        modules/mi_datagram/mi_datagram.so /out/lib/opensips/modules/
FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
        libssl3 libcurl4 libpcre2-8-0 libxml2 libmicrohttpd12t64 libjson-c5 \
        ca-certificates netbase procps \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/lib/libnats.so* /usr/local/lib/
COPY --from=builder /out/sbin/opensips /usr/sbin/opensips
COPY --from=builder /out/lib/opensips /usr/lib/x86_64-linux-gnu/opensips
RUN ldconfig && mkdir -p /etc/opensips /run/opensips
# nats_dl dlopen()s the dev name "libnats.so": put it on the default path
RUN ln -sf /usr/local/lib/libnats.so.3.14 /usr/lib/x86_64-linux-gnu/libnats.so
# SIPssert mounts the scenario directory at /etc/opensips
ENTRYPOINT ["/usr/sbin/opensips", "-F", "-f", "/etc/opensips/opensips.cfg"]
