# yaskkserv2-docker

[yaskkserv2](https://github.com/wachikun/yaskkserv2) のDockerイメージです。

定期的にCIを回してその時のmasterブランチのHEADから取ってきたソースコードを元にビルドしてます。

個人的に使うためのイメージなので使用は自己責任でお願いします。

## 起動

```bash
docker pull ghcr.io/gamoutatsumi/yaskkserv2:latest
docker run -d --init --restart=unless-stopped -p 127.0.0.1:1178:1178 --name yaskkserv2 ghcr.io/gamoutatsumi/yaskkserv2:latest
```

## 辞書

入っている辞書は以下の通りです。

### [skk-dev](https://skk-dev.github.io/dict)

- SKK-JISYO.L
- SKK-JISYO.jinmei
- SKK-JISYO.fullname
- zipcode
- SKK-JISYO.geo
- SKK-JISYO.propernoun
- SKK-JISYO.station
- SKK-JISYO.law
- SKK-JISYO.assoc
- SKK-JISYO.edict[^1]

### その他

- [SKK-JISYO.emoji.utf8](https://github.com/uasi/skk-emoji-jisyo)[^2]

## ライセンス

`Dockerfile` と `entrypoint.sh` には [MITライセンス](./LICENSE) が適用されます。

[^1]: [ライセンス条項](./edict_doc.html)
[^2]: 手元のクライアントの都合でeuc-jpモードにしているためそのままでは使えません。
