FROM --platform=$BUILDPLATFORM rust:1.74 AS builder

ENV RUSTFLAGS="-C strip=symbols"

RUN apt-get update -y && apt-get install python3-pip -y && pip3 install --break-system-packages cargo-zigbuild

RUN git clone https://github.com/wachikun/yaskkserv2.git /app
WORKDIR /app
RUN git checkout $(git describe --tags --abbrev=0)
RUN cargo remove reqwest
RUN cargo add reqwest --no-default-features --features rustls-tls --features blocking

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo zigbuild --release && \
    mv target/release/yaskkserv2_make_dictionary /usr/local/bin/yaskkserv2_make_dictionary

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
  "linux/arm64") echo aarch64-unknown-linux-musl > /rust_target.txt ;; \
  "linux/amd64") echo x86_64-unknown-linux-musl > /rust_target.txt ;; \
  *) exit 1 ;; \
  esac
RUN rustup target add $(cat /rust_target.txt)
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo zigbuild --release --target $(cat /rust_target.txt) && \
    cp target/$(cat /rust_target.txt)/release/yaskkserv2 /usr/local/bin/yaskkserv2

ADD https://skk-dev.github.io/dict/SKK-JISYO.L.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.jinmei.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.fullname.gz /tmp/
ADD https://skk-dev.github.io/dict/zipcode.tar.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.geo.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.propernoun.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.station.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.law.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.assoc.gz /tmp/
ADD https://skk-dev.github.io/dict/SKK-JISYO.edict.tar.gz /tmp/
ADD https://raw.githubusercontent.com/uasi/skk-emoji-jisyo/master/SKK-JISYO.emoji.utf8 /tmp/SKK-JISYO.emoji

WORKDIR /tmp

RUN sh -c "for tgz in *.tar.gz; do tar zxvf \$tgz ; done && rm *.tar.gz && gunzip *.gz"

RUN sh -c "/usr/local/bin/yaskkserv2_make_dictionary --utf8 --dictionary-filename=dictionary.yaskkserv2 ./**/SKK-JISYO.*"

FROM alpine:3.19

COPY --from=builder /usr/local/bin/yaskkserv2 /tmp/dictionary.yaskkserv2 /tmp/edict_doc.html /

COPY --chmod=755 <<EOF /entrypoint.sh
#!/usr/bin/env sh

syslogd

/yaskkserv2 --no-daemonize --midashi-utf8 /dictionary.yaskkserv2 &
tail -f /var/log/messages
EOF

EXPOSE 1178

ENTRYPOINT ["/entrypoint.sh"]
