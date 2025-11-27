# Docker 設定

`docker-compose.yml` は Next.js / Nest.js / MySQL / MongoDB / Redis をまとめて起動するローカル開発向けの構成です。

## 使い方

```bash
# 依存サービスのみ起動
docker compose -f infrastructure/docker/docker-compose.yml up -d mysql mongo redis

# アプリケーションも含めて起動
docker compose -f infrastructure/docker/docker-compose.yml up frontend backend
```

各アプリケーションのソースはボリュームとしてマウントされるため、ホスト側での編集が即座にコンテナへ反映されます。コンテナ内で `pnpm install` を実行すると `node_modules` は匿名ボリュームに格納され、ホスト側のパーミッション問題を避けられます。*** End Patch} to=functions.apply_patch code_input=*** Begin Patch
