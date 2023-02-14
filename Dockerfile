FROM --platform=$BUILDPLATFORM rust:1.67 AS builder

RUn apt update -y && apt install python3-pip -y && pip3 install cargo-zigbuild

RUN git clone https://github.com/wachikun/yaskkserv2.git /app -b 0.1.3 --depth 1

WORKDIR /app

RUN cargo build --release --target x86_64-unknown-linux-musl

RUN mv target/x86_64-unknown-linux-musl/release/yaskkserv2_make_dictionary /usr/local/bin/yaskkserv2_make_dictionary

ARG TARGETPLATFORM
RUN case "$TARGETPLATFORM" in \
  "linux/arm64") echo aarch64-unknown-linux-musl > /rust_target.txt ;; \
  "linux/amd64") echo x86_64-unknown-linux-musl > /rust_target.txt ;; \
  *) exit 1 ;; \
  esac

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    # cargo install が使えないので、代わりに手動でコピーする
    cargo zigbuild --release --target $(cat /rust_target.txt) && \
    cp target/$(cat /rust_target.txt)/release/yaskkserv2 /usr/local/bin/yaskkserv2

RUN strip /usr/local/bin/yaskkserv2

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

FROM gcr.io/distroless/static-debian11:nonroot

COPY --from=builder /usr/local/bin/yaskkserv2 /tmp/dictionary.yaskkserv2 /tmp/edict_doc.html /

COPY ./entrypoint.sh /

EXPOSE 1178

ENTRYPOINT ["/entrypoint.sh"]
