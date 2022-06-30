FROM ekidd/rust-musl-builder@sha256:f9dcff1c3ec683e2ccdd3c9c1771d12590b7c4d64505bac89aa8e552a038aeaf AS builder

RUN git clone https://github.com/wachikun/yaskkserv2.git .

RUN cargo build --release

RUN strip /home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2 \
&& strip /home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2_make_dictionary

ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.L.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.jinmei.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.fullname.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/zipcode.tar.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.geo.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.propernoun.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.station.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.law.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.assoc.gz /tmp/
ADD --chown=rust:rust https://skk-dev.github.io/dict/SKK-JISYO.edict.tar.gz /tmp/
ADD --chown=rust:rust https://raw.githubusercontent.com/uasi/skk-emoji-jisyo/master/SKK-JISYO.emoji.utf8 /tmp/SKK-JISYO.emoji

WORKDIR /tmp

RUN sh -c "for tgz in *.tar.gz; do tar zxvf \$tgz ; done && rm *.tar.gz && gunzip *.gz"

RUN sh -c "/home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2_make_dictionary --dictionary-filename=dictionary.yaskkserv2 ./**/SKK-JISYO.*"

FROM alpine:3.13

COPY --from=builder /home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2 /tmp/dictionary.yaskkserv2 /tmp/edict_doc.html /

COPY ./entrypoint.sh /

EXPOSE 1178

ENTRYPOINT ["/entrypoint.sh"]
