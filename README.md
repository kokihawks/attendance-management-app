# エイ・フォース勤怠管理アプリ

日報作成や勤務表記入などの日常業務を一元化し、情報共有と業務効率の向上を実現する勤怠管理アプリケーション。

## 開発環境のセットアップ

本リポジトリは **Dev Container** と **Docker Compose** を前提に開発環境を構築します。  
どちらも `@docs/design/architecture.md` の構成（Next.js / Nest.js / MySQL / MongoDB / Redis）を前提にしています。

### 1. Dev Container

1. 必要条件
   - Docker Desktop などのコンテナランタイム
   - VS Code / Cursor + Dev Containers 拡張機能
2. リポジトリを開き「Reopen in Container」を選択
3. 初回起動後、各アプリ配下で依存関係をインストール
   ```bash
   cd apps/backend && pnpm install
   cd apps/frontend && pnpm install
   ```

Dev Container 起動時に MySQL / MongoDB / Redis も自動で立ち上がります。  
主要ポートは `3000`(Next.js), `4000`(Nest.js), `3306`(MySQL), `27017`(MongoDB), `6379`(Redis) をフォワード済みです。

### 2. Docker Compose のみで起動する場合

`infrastructure/docker/docker-compose.yml` を利用してサービスをまとめて起動できます。

```bash
# 依存サービスを起動
docker compose -f infrastructure/docker/docker-compose.yml up -d mysql mongo redis

# アプリケーションを起動
docker compose -f infrastructure/docker/docker-compose.yml up frontend backend
```

| サービス   | ポート | 備考                                   |
|------------|--------|----------------------------------------|
| frontend   | 3000   | `NEXT_PUBLIC_API_BASE_URL` は `4000` を参照 |
| backend    | 4000   | Nest.js (watch モード)                 |
| mysql      | 3306   | `app_user` / `app_password`, DB: `attendance` |
| mongo      | 27017  | 初期 DB `attendance`                   |
| redis      | 6379   | BullMQ / キャッシュ想定                |

初回は `apps/frontend` / `apps/backend` それぞれで `pnpm install` を実行してください。
