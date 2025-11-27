# OpenSpec ガイド

`docs/openspec/` は、仕様駆動型開発（Specification-Driven Development, SDD）を支えるためのエリアです。OpenSpec に沿って変更提案を文章化し、レビューを経て実装に落とし込むことで、要件の抜け漏れを防ぎます。

## セットアップ

1. Node.js 20.19 以上を用意
2. OpenSpec CLI をインストール
   ```bash
   npm install -g @fission-ai/openspec@latest
   ```
3. 以降はリポジトリ直下で OpenSpec コマンドを実行できます

## ディレクトリ構成

```
docs/
  openspec/
    project.md          # プロダクト全体の目的とガードレール
    README.md           # このガイド
    changes/            # 変更提案を格納する場所
      README.md         # 投稿ルール
      proposal-template.md
      <proposal>/       # 1提案=1ディレクトリ
        proposal.md     # 実際の提案ドキュメント
```

## ワークフロー

1. **提案作成**
   - `docs/openspec/changes/README.md` を読み、`proposal-template.md` をコピーして `<proposal>` ディレクトリを作成
   - 可能であれば `npx @fission-ai/openspec new "<Title>"` や Copilot の `/openspec-proposal` コマンドで自動生成
2. **レビュー**
   - Pull Request 上で提案をレビュー
   - 承認後、対応する実装チケットを作成
3. **実装 & トレーサビリティ**
   - コミットや PR から該当 proposal へのリンクを貼る
   - 仕様に変更が生じた場合は proposal を更新または Supersede する

## 推奨運用

- **Scope を明確に**: 「この提案では何をしないか」を必ず記載
- **関連資料を紐付け**: `docs/design/` や `docs/requirements/` の該当箇所を References に列挙
- **Status を管理**: Draft / In Review / Accepted / Rejected などを proposal 冒頭に記載し、最新状態を保つ

OpenSpec ドキュメントはコードと同様にレビュー対象です。仕様が固まってから実装に着手することで、リワークを減らし、チーム全体の認識を合わせましょう。

