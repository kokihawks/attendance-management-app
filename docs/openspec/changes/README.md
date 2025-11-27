# OpenSpec Changes ガイド

`changes/` ディレクトリには、機能追加やリファクタリングなど「設計判断を伴う変更提案」を配置します。提案 1 件につき 1 ディレクトリを作成し、その配下に `proposal.md` を置きます。

## 作成手順

1. ブランチを切る
2. ディレクトリを作成  
   `docs/openspec/changes/<proposal-slug>/`
3. `proposal-template.md` をコピーして `proposal.md` として配置
4. 内容を記述し、PR でレビュー

## 命名規則

- **proposal-slug**: `yyyyMMdd-short-title`（例: `20251127-clock-out-validation`）
- **ファイル**: 原則 `proposal.md` のみ。必要なら図や補助資料を追加してよいが、相対パスで参照する

## ステータス管理

`proposal.md` 冒頭に以下のようなメタデータを置きます：

```
Status: Draft | In Review | Accepted | Rejected | Superseded
Owner: @github-handle
Updated: 2025-11-27
Related: FR-002-10, AC-002-1
```

## レビュー観点

- 問題提起と動機が明確か
- 影響範囲（システム / チーム / ドキュメント）が列挙されているか
- Acceptance Criteria や計測方法が定義されているか
- 他の OpenSpec や設計ドキュメントと矛盾していないか

## テンプレート

共通の書き方は `proposal-template.md` を参照してください。

