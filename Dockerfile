FROM ekidd/rust-musl-builder:latest AS builder

RUN git clone https://github.com/wachikun/yaskkserv2.git .

RUN cargo build --release

RUN strip /home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2 \
&& strip /home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2_make_dictionary

ADD http://openlab.jp/skk/dic/SKK-JISYO.L.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.jinmei.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.fullname.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.geo.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.propernoun.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.station.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.law.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.assoc.gz /tmp
ADD http://openlab.jp/skk/dic/SKK-JISYO.edict.tar.gz /tmp
ADD https://raw.githubusercontent.com/uasi/skk-emoji-jisyo/master/SKK-JISYO.emoji.utf8 /tmp/SKK-JISYO.emoji

WORKDIR /tmp

RUN gunzip *.gz && rm *.gz

RUN sh -c "/home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2_make_dictionary --utf8 --dictionary-filename=dictionary.yaskkserv2 SKK-JISYO.*"

FROM scratch

COPY --from=builder /home/rust/src/target/x86_64-unknown-linux-musl/release/yaskkserv2 /tmp/dictionary.yaskkserv2 /tmp/edict_doc.txt /

ENTRYPOINT ["yaskkserv2", "--no-daemonize", "./dictionary.yaskkserv2"]
