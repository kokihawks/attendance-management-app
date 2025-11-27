# OpenSpec Project: Attendance Management App

## Summary
- **プロダクト名**: エイ・フォース勤怠管理アプリ
- **目的**: 日報提出と勤務表管理を一体化し、勤怠データを正確かつ迅速に提出できるようにする
- **主要利用者**: 社員・契約社員・マネージャー

## Mission & Success Metrics
- ユーザーが「当日中に日報提出」を習慣化できる
- 勤務表出力に必要な情報（勤務時間、休暇、遅刻/早退、移動時間）が日報から欠けずに取得できる
- 未提出や異常値に対する検知と通知で管理コストを削減する

## Scope
- Phase 2–3 の MVP で必要となる要件（FR-001〜FR-004, FR-008）
- Reports / Attendance / Leave / Notification 各コンテキスト間の連携仕様
- 仕様化された機能は `docs/requirements/product-backlog.md` および `docs/design/*` にトレーサブルであること

## Out of Scope（現時点）
- P2 以降の拡張機能（例: 日報履歴検索、テンプレート編集、コメント機能）
- エンタープライズ統合（SSO、外部ワークフロー連携 など）
- モバイル専用 UI

## Guiding Principles
1. **日報提出が最優先**: ドラフト保存は補助。UI・API も提出パスを主とする
2. **単一情報源**: 勤怠関連データは日報→Attendance Context に流す
3. **安全性**: 日付・時間のバリデーションと確認ダイアログを設計段階で定義する
4. **通知は外部 Context に委譲**: Notification Context へ明確な契約を持つ

## Bounded Contexts
- **Auth**: User と Role を管理し、他 Context が `UserId` を参照できるようにする
- **Reports**: 日報（Report）エンティティを中心に、勤務時間・休暇・遅刻/早退を記録
- **Attendance**: 勤務表集計。Reports から遅刻/早退や移動時間を参照する
- **Leave**: 午前休・午後休・全日休の登録と連携
- **Notification**: 日報未提出や再提出通知を送信

## Stakeholders
- Product Owner / Business Admin
- Engineering（Backend, Frontend, Infrastructure）
- Users（社員・マネージャー）

## References
- [`docs/requirements/product-backlog.md`](../requirements/product-backlog.md)
- [`docs/requirements/acceptance-criteria.md`](../requirements/acceptance-criteria.md)
- [`docs/design/reports-context-design.md`](../design/reports-context-design.md)
- [`docs/design/ddd-design-guide.md`](../design/ddd-design-guide.md)

## Change History
- 2025-11-27: 初期 OpenSpec プロジェクト定義を作成（バージョン 1）

