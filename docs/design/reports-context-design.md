# Reports Context（日報管理）詳細設計書

## 概要

本ドキュメントは、エイ・フォース勤怠管理アプリの日報管理ドメイン（Reports Context）の詳細設計を記載します。ドメイン駆動設計（DDD）に基づいて設計を行います。

## 目次

1. [ステップ0: 最上位のドメインの目的を設定](#ステップ0-最上位のドメインの目的を設定)
2. [ステップ1: ドメイン分析](#ステップ1-ドメイン分析)
3. [ステップ2: 境界づけられたコンテキストの特定](#ステップ2-境界づけられたコンテキストの特定)
4. [ステップ3: ドメインモデルの設計](#ステップ3-ドメインモデルの設計)
5. [ステップ4: ユースケースの定義](#ステップ4-ユースケースの定義)
6. [ステップ5: アプリケーションサービスの設計](#ステップ5-アプリケーションサービスの設計)
7. [ステップ6: リポジトリインターフェースの定義](#ステップ6-リポジトリインターフェースの定義)
8. [ステップ7: インフラストラクチャ層の設計](#ステップ7-インフラストラクチャ層の設計)
9. [ステップ8: 設計の検証](#ステップ8-設計の検証)

---

## ステップ0: 最上位のドメインの目的を設定

### Reports Context（日報管理）の目的

```markdown
# Reports Context（日報管理）の目的

## 目的
ユーザーが日々の業務記録を日報として必ず提出できるようにし、業務記録を残す習慣を確立する。また、日報提出によって勤怠管理（勤務時間などの記録）を実現する。

## ビジョン
- ユーザーがストレスなく日報を作成・提出できる（5分以内で作成可能）
- 日報提出が習慣化され、毎日の業務記録が確実に残る
- 日報提出によって勤怠管理（勤務時間などの記録）ができる
- 提出状況を可視化し、未提出を防ぐ
- （将来拡張）チーム全体で業務内容を共有し、協働を促進する
- （将来拡張）過去の日報を振り返り、業務改善につなげる

## 成功指標
- **日報提出率**: 90%以上（個人利用フェーズ）
- **日報作成時間**: 5分以内
- **日報提出の習慣化**: 連続提出日数の向上
- （将来拡張）チーム内での情報共有促進: 日報閲覧率の向上
- （将来拡張）業務改善への活用: 過去の日報を参照した改善提案の増加

## 制約条件
- **個人利用から段階的に展開**: まず個人利用で機能を検証
- **同じ日付の日報は1つだけ存在できる**: ビジネスルール（重複不可、ただし再提出は可能）
- **未来日付の日報は作成できない**: 過去または当日のみ
- **小規模チームでの開発・運用**: シンプルな設計を優先
- **MySQL（構造化データ）を使用**: 日報メタ情報はMySQLで管理

## 主要な価値提案（MVP）
1. **日々の業務記録を必ず提出できる**: 日報作成機能により、毎日の業務記録を確実に残す
2. **勤怠管理を実現できる**: 日報提出によって勤務時間などの記録ができる
3. **提出状況を可視化できる**: 提出済み/未提出を一目で確認し、未提出を防ぐ
4. **簡単に日報を作成できる**: 直感的なUIで5分以内に作成可能

## 将来拡張の価値提案
1. **チーム全体で業務内容を共有できる**: 公開範囲を設定して共有（将来拡張）
2. **過去の日報を検索・振り返りできる**: 日付範囲、キーワードで検索（将来拡張）
3. **業務の可視化と振り返りを促進する**: 過去の日報を活用した業務改善（将来拡張）
```

---

## ステップ1: ドメイン分析

### 1.1 ドメインの目的の確認

- ✅ **目的**: ユーザーが日々の業務記録を日報として必ず提出できるようにし、業務記録を残す習慣を確立する。また、日報提出によって勤怠管理（勤務時間などの記録）を実現する
- ✅ **ビジョン**: ストレスなく日報を作成・提出でき、日報提出が習慣化される。日報提出によって勤怠管理ができる
- ✅ **成功指標**: 日報提出率90%以上、作成時間5分以内、連続提出日数の向上

### 1.2 要件定義書の確認

#### 機能要件の整理方法

機能要件を整理する際は、以下の項目を明確にします：

1. **機能要件の一覧と分類**
   - MVPで実装する機能
   - 将来拡張する機能
   - 機能要件間の依存関係

2. **各機能要件の詳細**
   - 機能の目的（何をする機能か）
   - 入力（ユーザーが入力する情報）
   - 出力（システムが返す情報）
   - 処理フロー（どのような処理を行うか）
   - ビジネスルール（制約条件やバリデーション）

3. **受け入れ基準との対応付け**
   - どの機能要件がどの受け入れ基準に対応するか
   - 受け入れ基準の詳細な要件

4. **ユーザーストーリーとの対応付け**
   - どの機能要件がどのユーザーストーリーに対応するか
   - 優先順位と見積り

5. **ドメインの目的との整合性**
   - 各機能要件がドメインの目的にどう貢献するか

#### 機能要件（FR-002）の詳細整理

##### FR-002-1: 日報作成（MVP、P0）

**機能の目的:**
ユーザーが日々の業務内容を日報として作成・提出できるようにする。基本的な流れは「日報を作成して即座に提出する」こと。また、日報作成時に午前休・午後休の登録も同時に行えるようにする。補助的な機能として、途中で下書き保存することも可能とする。

**入力（必須項目）:**
- 日付（YYYY-MM-DD形式）
- 勤務開始時間（HH:mm形式、デフォルト: 9:30）
- 勤務終了時間（HH:mm形式、デフォルト: 18:00）
- 休憩時間（分単位、デフォルト: 60分）
- 作業内容（テキスト）
- 問題とその解決策（テキスト）
- 勤務地（デフォルト候補から選択、または手入力）

**入力（追加項目）:**
- 追加項目（見出しと記述項目のペア、複数指定可能）
  - 見出し（テキスト）
  - 記述項目（テキスト）

**入力（その他）:**
- 休日種別（全日休/午前休/午後休/なし）（任意、提出時に選択可能）
- 移動時間（分単位、任意）
- 遅刻情報（分単位、または理由、任意）
- 早退情報（分単位、または理由、任意）
- ステータス（下書き/提出済み）（提出時は「提出済み」、下書き保存時は「下書き」）

**出力:**
- 作成された日報の情報
- 登録された休日情報（午前休・午後休を選択した場合）
- 送信完了通知（提出時）

**処理フロー（基本: 日報作成・提出）:**
1. ユーザーが日報作成画面で情報を入力
   - **必須項目**:
     - 日付（デフォルト: 当日）
     - 勤務開始時間（デフォルト: 9:30）
     - 勤務終了時間（デフォルト: 18:00）
     - 休憩時間（デフォルト: 60分）
     - 作業内容
     - 問題とその解決策
     - 勤務地（デフォルト候補（飯田橋、自宅）から選択、または手入力）
   - **追加項目**（任意）:
     - 見出しと記述項目のペア（複数追加可能）
   - **その他**（任意）:
     - 休日種別の選択（全日休/午前休/午後休/なし）
     - 移動時間（分単位）
     - 遅刻情報（分単位、または理由）
     - 早退情報（分単位、または理由）
2. 日付のバリデーション（形式、重複チェック、未来日付チェック）
3. 勤務開始時間・勤務終了時間・休憩時間のバリデーション
4. 作業内容の必須チェック
5. 問題とその解決策の必須チェック
6. 勤務地のバリデーション（必須チェック）
7. **入力値の確認（日付・勤務時間の確認ダイアログ表示）**
   - 日付が当日から3日以上前の場合は警告を表示
   - 勤務開始時間が異常に早い（6:00以前）または遅い（12:00以降）場合は警告を表示
   - 勤務終了時間が異常に早い（9:00以前）または遅い（23:00以降）場合は警告を表示
   - 勤務時間が異常に短い（4時間未満）または長い（12時間超過）場合は警告を表示
8. 日報のステータスを「提出済み」に設定
9. 勤務時間を記録（勤務開始時間、勤務終了時間、休憩時間）
10. 移動時間、遅刻情報、早退情報を記録（入力された場合）
11. 日報をデータベースに保存
12. 休日種別が選択されている場合、休日情報を登録（Leave Context と連携）
13. 送信完了通知を表示

**処理フロー（補助: 下書き保存）:**
1. ユーザーが日報作成画面で情報を入力（必須項目が未入力でも可）
2. 日付のバリデーション（形式、重複チェック、未来日付チェック）
3. 入力済み項目のバリデーション（必須項目の完全性チェックは行わない）
4. 日報のステータスを「下書き」に設定
5. 日報をデータベースに保存
6. 下書き保存完了通知を表示

**処理フロー（下書きから提出）:**
1. ユーザーが下書きの日報を開く
2. 必須項目が未入力の場合は入力
3. 勤務終了時間を確認・修正（デフォルト: 18:00、または自動記録）
4. **提出時に追加情報を入力**（任意）:
   - 休日種別の選択（午前休/午後休/なし）
   - 移動時間（分単位）
   - 遅刻情報（分単位、または理由）
   - 早退情報（分単位、または理由）
5. **入力値の確認（日付・勤務時間の確認ダイアログ表示）**
   - 日付が当日から3日以上前の場合は警告を表示
   - 勤務開始時間が異常に早い（6:00以前）または遅い（12:00以降）場合は警告を表示
   - 勤務終了時間が異常に早い（9:00以前）または遅い（23:00以降）場合は警告を表示
   - 勤務時間が異常に短い（4時間未満）または長い（12時間超過）場合は警告を表示
6. 日報のステータスを「提出済み」に更新
7. 勤務時間を記録（勤務開始時間、勤務終了時間、休憩時間）
8. 移動時間、遅刻情報、早退情報を記録（入力された場合）
9. 日報をデータベースに保存
10. 休日種別が選択されている場合、休日情報を登録（Leave Context と連携）
11. 送信完了通知を表示

**ビジネスルール:**
- 同じ日付の日報は1つだけ存在できる（重複不可、ただし再提出は可能）
  - 新しい日報を作成する際は、同じ日付の日報が既に存在する場合はエラー
  - 既存の日報を編集・再提出することは可能（既存の日報を更新する操作）
  - **再提出時は、既に提出済みであることを確認ダイアログで明示し、ユーザーが承認した場合のみ再提出を実行**
  - **再提出時の通知メールには「再提出」という旨を明記**
- 未来日付の日報は作成できない（過去または当日のみ）
- 日付の形式はYYYY-MM-DD形式
- 無効な日付（存在しない日付等）は入力できない
- **必須項目**:
  - 日付: 必須
  - 勤務開始時間: 必須、HH:mm形式、デフォルト: 9:30
  - 勤務終了時間: 必須、HH:mm形式、デフォルト: 18:00
  - 休憩時間: 必須、分単位、デフォルト: 60分
  - 作業内容: 必須、テキスト
  - 問題とその解決策: 必須、テキスト
  - 勤務地: 必須、デフォルト候補（飯田橋、自宅）から選択、または手入力可能
- **追加項目**:
  - 見出しと記述項目のペア: 任意、複数追加可能
  - 見出し: テキスト、最大50文字
  - 記述項目: テキスト、最大1000文字
- **勤務時間の計算**:
  - 実働時間 = 勤務終了時間 - 勤務開始時間 - 休憩時間
  - 実働時間が4時間未満の場合は警告を表示
  - 実働時間が12時間超過の場合は警告を表示
- 勤務地はデフォルト候補（飯田橋、自宅）から選択、または手入力可能
- ユーザーは勤務地の候補を追加・編集できる
- 休日種別は任意項目（全日休/午前休/午後休/なしから選択）
- 午前休・午後休を選択した場合、休日情報が自動的に登録される
- 午前休・午後休の場合、勤務表には勤務時間（午後または午前の勤務時間）と休日の選択（午前休または午後休）の両方が出力される必要がある
- **遅刻情報（遅延情報）は勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）
- **早退情報は勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）
- **遅刻情報（遅延情報）は勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）
- **早退情報は勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）
- **基本的な流れ**: 日報を作成して即座に提出する
- **補助的な機能**: 途中で下書き保存することも可能（必須項目が未入力でも保存可能）
- 下書きの日報は後で提出できる
- **提出時に追加情報を入力可能**:
  - 休日種別（午前休/午後休/なし）を選択
  - 移動時間（分単位）を記録
  - 遅刻情報（遅延情報、分単位、または理由）を記録（勤務表出力に必要な情報）
  - 早退情報（分単位、または理由）を記録（勤務表出力に必要な情報）
- 提出時に勤務時間を記録する（勤務開始時間、勤務終了時間、休憩時間）
- 提出済みの日報は編集可能（勤務時間も再記録可能）
- **提出前に日付と勤務時間の確認を促す（確認ダイアログ）**
- **日付が当日から3日以上前の場合は警告を表示（入力ミスの可能性）**
- **勤務開始時間が異常に早い（6:00以前）または遅い（12:00以降）場合は警告を表示**
- **勤務終了時間が異常に早い（9:00以前）または遅い（23:00以降）場合は警告を表示**

**受け入れ基準:** AC-002-1

**ユーザーストーリー:** US-002-1（P0、5ポイント）

**ドメインの目的への貢献:**
- ✅ 業務記録を残す習慣を確立する
- ✅ 勤怠管理（勤務時間などの記録）を実現する
- ✅ 休日登録と日報作成を一括で行えるため、ユーザーの負担を軽減する

**UI設計の検討（下書き保存と提出の分離）:**

**基本方針**: 日報提出が基本、下書き保存は補助的な機能として提供する。

**パターン1: 2つのボタンを並べる（推奨）**
- **配置**: 画面下部に「送信」ボタン（プライマリ）と「下書き保存」ボタン（セカンダリ）を横並びに配置
- **デザイン**: 
  - 「送信」: プライマリボタン（強調色、塗りつぶし、大きく目立つ）
  - 「下書き保存」: セカンダリボタン（グレー系、アウトライン、小さめ）
- **動作**:
  - 「送信」: 必須項目のバリデーション + 異常値検証、確認ダイアログ表示、ステータスを「提出済み」に設定（基本の操作）
  - 「下書き保存」: 必須項目のバリデーションのみ（任意項目が未入力でも保存可能）、ステータスを「下書き」に設定（補助的な操作）
- **メリット**: 
  - 基本操作（送信）が明確で分かりやすい
  - 誤操作を防ぎやすい
  - 一般的なUIパターンでユーザーに馴染みがある
- **デメリット**: 
  - ボタンが2つ必要で画面スペースを消費

**パターン2: ドロップダウンボタン**
- **配置**: 1つのボタンにドロップダウンメニューを追加
- **デザイン**: 「保存」ボタンに下向き矢印アイコン、クリックで「下書き保存」と「送信」を選択
- **動作**: パターン1と同様
- **メリット**: 
  - 画面スペースを節約できる
  - 関連する操作をグループ化できる
- **デメリット**: 
  - 操作が1ステップ増える（クリック数が増える）
  - モバイルでは操作しづらい場合がある

**パターン3: チェックボックス + 送信ボタン**
- **配置**: 「下書きとして保存」チェックボックスと「送信」ボタン
- **デザイン**: 
  - チェックボックス: 「下書きとして保存」（デフォルト: チェックなし）
  - 送信ボタン: チェック状態に応じて動作を変更
- **動作**:
  - チェックあり: 下書き保存（必須項目のバリデーションのみ）
  - チェックなし: 送信（必須項目のバリデーション + 異常値検証、確認ダイアログ）
- **メリット**: 
  - 画面スペースを節約できる
  - 1つのボタンで済む
- **デメリット**: 
  - チェックボックスの意味が分かりづらい場合がある
  - 誤操作のリスクがある（チェック状態を忘れる）

**パターン4: 自動保存 + 明示的な送信ボタン**
- **配置**: 「送信」ボタンのみ、自動保存機能を追加
- **デザイン**: 「送信」ボタン、入力中に自動で下書き保存（数秒ごと、またはフィールド離脱時）
- **動作**:
  - 自動保存: 必須項目のバリデーションのみ、ステータスを「下書き」に設定
  - 「送信」ボタン: 必須項目のバリデーション + 異常値検証、確認ダイアログ、ステータスを「提出済み」に設定
- **メリット**: 
  - データ損失を防げる
  - 操作がシンプル（送信ボタンのみ）
  - ユーザーの負担が少ない
- **デメリット**: 
  - 自動保存のタイミングが分かりづらい場合がある
  - サーバー負荷が増える可能性がある
  - 下書き保存の意図が不明確

**パターン5: タブ/セクションで分ける**
- **配置**: 「下書き一覧」タブと「作成」タブを分ける
- **デザイン**: タブナビゲーションで「作成」「下書き一覧」「提出済み一覧」を切り替え
- **動作**: 
  - 「作成」タブ: 新規作成または編集、保存ボタンで下書き保存
  - 「下書き一覧」タブ: 下書きの一覧表示、各日報に「編集」「送信」ボタン
- **メリット**: 
  - 下書きと提出済みを明確に分離できる
  - 複数の下書きを管理しやすい
- **デメリット**: 
  - 画面遷移が必要で操作が複雑になる
  - モバイルではタブが小さくなりがち

**推奨パターン:**
- **MVP**: パターン1（2つのボタンを並べる）を推奨
  - 基本操作（送信）が明確で分かりやすい
  - 誤操作を防ぎやすい
  - 実装がシンプル
  - **重要**: 「送信」ボタンをプライマリとして強調し、「下書き保存」は補助的な機能として配置
- **将来拡張**: パターン4（自動保存）を追加検討
  - データ損失を防ぐ
  - ユーザー体験の向上
  - ただし、自動保存は補助的な機能として実装し、基本は「送信」ボタンによる提出

**考慮事項:**
- 午前休・午後休の登録は Leave Context と連携する必要がある
- 日報作成時に休日情報を登録することで、ユーザーの操作を簡素化する
- 休日登録と日報作成は同一トランザクションで処理するか、イベント駆動で連携するかを検討する必要がある
- **UI実装**: フロントエンドで実装（React/Vue等のコンポーネント）
- **バックエンド**: 下書き保存と提出で異なるエンドポイントを提供（`POST /reports` と `POST /reports/:id/submit`）

---

##### FR-002-2: 日報テンプレート編集（将来拡張、P2）

**機能の目的:**
ユーザーが日報テンプレートを編集し、効率的に日報を作成できるようにする。

**入力:**
- テンプレート内容（業務内容、成果、課題、翌日予定のテンプレート）

**出力:**
- 保存されたテンプレート情報

**処理フロー:**
1. ユーザーがテンプレート編集画面でテンプレートを編集
2. テンプレートをデータベースに保存
3. 次回の日報作成時にテンプレートを適用

**ビジネスルール:**
- テンプレートはユーザーごとに保存される
- 次回の日報作成時にテンプレートが自動適用される

**受け入れ基準:** AC-002-2

**ユーザーストーリー:** US-002-2（P2、将来拡張、3ポイント）

**備考:**
- MVPでは固定の基本テンプレートのみを実装
- テンプレート編集機能は将来の拡張機能として検討

---

##### FR-002-3: 日報履歴検索（将来拡張、P2）

**機能の目的:**
ユーザーが過去の日報を検索し、過去の業務内容を確認できるようにする。

**入力:**
- 日付範囲（開始日、終了日）
- キーワード（任意）

**出力:**
- 検索条件に一致する日報の一覧

**処理フロー:**
1. ユーザーが検索条件（日付範囲、キーワード）を指定
2. データベースから条件に一致する日報を検索
3. 検索結果を一覧表示

**ビジネスルール:**
- 日付範囲で検索可能
- キーワードで業務内容、成果、課題、翌日予定を検索可能
- 検索結果は日付の降順で表示

**受け入れ基準:** AC-002-3

**ユーザーストーリー:** US-002-3（P2、将来拡張、3ポイント）

**ドメインの目的への貢献:**
- ✅ （将来拡張）過去の日報を振り返り、業務改善につなげる

---

##### FR-002-4: 日報提出状況トラッキング（MVP、P1）

**機能の目的:**
ユーザーが日報の提出状況を確認し、未提出を防ぐようにする。

**入力:**
- 日付範囲（開始日、終了日）

**出力:**
- 提出済み/未提出の日付一覧
- 提出率（パーセンテージ）

**処理フロー:**
1. ユーザーが日付範囲を指定
2. 指定期間内の日報提出状況を集計
3. 提出済み/未提出の日付を一覧表示
4. 提出率を計算して表示

**ビジネスルール:**
- 提出済み: 日報が存在する日付
- 未提出: 日報が存在しない日付
- 提出率 = (提出済み日数 / 総日数) × 100

**受け入れ基準:** AC-002-4

**ユーザーストーリー:** US-002-4（P1、2ポイント）

**ドメインの目的への貢献:**
- ✅ 提出状況を可視化し、未提出を防ぐ
- ✅ 日報提出の習慣化を支援する

---

##### FR-002-8: 日報未提出の通知（MVP、P0）

**機能の目的:**
ユーザーが日報を未提出の場合、自動的に通知を送信することで、日報提出の習慣化を支援する。

**入力:**
- なし（定期実行で自動実行）

**出力:**
- 通知送信結果

**処理フロー:**
1. 定期実行（18:00と翌日9:30）で自動実行
2. 全ユーザーを取得
3. 各ユーザーについて、前日の日報提出状況を確認
4. 日報が未提出の場合、Leave Context の休日情報を確認
5. 全日休でない場合、Notification Context のサービスを呼び出して通知を送信

**ビジネスルール:**
- 定期実行: 18:00と翌日9:30に自動実行
- 対象日: 前日の日報
- 全日休の場合は通知を送信しない（日報提出不要のため）
- 午前休・午後休の場合は通知を送信する（日報提出が必要なため）
- 通知送信に失敗した場合はログに記録（通知は継続して送信）

**受け入れ基準:** AC-008-1（通知の一部）

**ユーザーストーリー:** US-002-1（日報作成機能の一部として実装）

**ドメインの目的への貢献:**
- ✅ 日報提出の習慣化を支援する
- ✅ 未提出を防ぐために通知を送信する

**考慮事項:**
- Notification Context のサービスを呼び出して通知を送信
- Leave Context の休日情報を参照して、全日休の場合は通知をスキップ
- 通知送信の実装詳細（メール、Slack、プッシュ通知など）は Notification Context が担当

---

##### FR-002-5: 勤務地選択（MVP、P0）

**機能の目的:**
ユーザーが日報作成時に勤務地を選択または手入力できるようにする。また、ユーザーが勤務地の候補を追加・編集できるようにする。

**入力:**
- 勤務地（デフォルト候補から選択、または手入力）
- 勤務地候補の追加・編集（設定画面）

**出力:**
- 選択または入力された勤務地
- 保存された勤務地候補一覧

**処理フロー（日報作成時）:**
1. ユーザーが日報作成時に勤務地を選択または手入力
   - デフォルト候補（飯田橋、自宅）から選択
   - または手入力で任意の勤務地を入力
2. 選択または入力された勤務地を日報に記録

**処理フロー（勤務地候補管理）:**
1. ユーザーが設定画面で勤務地候補を追加・編集
2. 勤務地候補をデータベースに保存（ユーザーごと）
3. 次回の日報作成時に候補として表示される

**ビジネスルール:**
- 勤務地は必須項目
- デフォルト候補: 飯田橋、自宅（全ユーザー共通）
- ユーザーは勤務地の候補を追加・編集できる（ユーザーごとに管理）
- 勤務地は候補から選択するか、手入力で任意の値を入力可能
- 手入力した勤務地は次回の候補として自動追加される（オプション）

**受け入れ基準:** AC-002-1（日報作成の一部）

**ユーザーストーリー:** US-002-1（日報作成機能の一部）

**ドメインの目的への貢献:**
- ✅ 勤怠管理（勤務地の記録）を実現する
- ✅ ユーザーが柔軟に勤務地を管理できる

---

##### FR-002-6: コメント機能（将来拡張）

**機能の目的:**
ユーザーが日報にコメントを追加できるようにする（将来拡張）。

**備考:**
- 現時点では要件定義書に記載されているが、MVPでは実装しない
- 将来の拡張機能として検討

---

##### FR-002-9: 下書きから提出（MVP、P1）

**機能の目的:**
ユーザーが下書き保存した日報を、後で提出できるようにする。補助的な機能として、途中で下書き保存した日報を完成させて提出する。

**入力:**
- 日報ID
- 退勤時間（HH:mm形式）

**出力:**
- 提出された日報の情報
- 送信完了通知

**処理フロー:**
1. ユーザーが下書きの日報を開く
2. 必須項目が未入力の場合は入力
3. 勤務終了時間を確認・修正（デフォルト: 18:00、または自動記録）
4. **入力値の確認（日付・勤務時間の確認ダイアログ表示）**
   - 日付が当日から3日以上前の場合は警告を表示
   - 勤務開始時間が異常に早い（6:00以前）または遅い（12:00以降）場合は警告を表示
   - 勤務終了時間が異常に早い（9:00以前）または遅い（23:00以降）場合は警告を表示
   - 勤務時間が異常に短い（4時間未満）または長い（12時間超過）場合は警告を表示
5. 日報のステータスを「提出済み」に更新
6. 勤務時間を記録（勤務開始時間、勤務終了時間、休憩時間）
7. 日報をデータベースに保存
8. 送信完了通知を表示

**ビジネスルール:**
- 下書きの日報のみ提出可能
- 提出済みの日報は再提出可能（勤務時間を再記録）
- 勤務終了時間は必須項目（提出時）
- 勤務終了時間の形式はHH:mm形式（例: 18:00）
- **提出前に日付と勤務時間の確認を促す（確認ダイアログ）**
- **異常な勤務時間の場合は警告を表示**

**受け入れ基準:** AC-002-1（日報作成の一部）

**ユーザーストーリー:** US-002-1（日報作成機能の一部）

**ドメインの目的への貢献:**
- ✅ 途中で下書き保存した日報を完成させて提出できる
- ✅ 補助的な機能として、ユーザーの柔軟な運用を支援する

---

##### FR-002-10: 日付・時間の入力ミス防止（MVP、P0）

**機能の目的:**
ユーザーが日付や退勤時間を間違えて登録してしまうことを防ぐため、入力値の確認機能を提供する。

**入力:**
- 日付（YYYY-MM-DD形式）
- 勤務開始時間（HH:mm形式）
- 勤務終了時間（HH:mm形式）
- 休憩時間（分単位）

**出力:**
- 確認ダイアログ（日付・勤務時間の表示）
- 警告メッセージ（異常値の場合）

**処理フロー:**
1. ユーザーが日報を提出しようとする
2. 日付と勤務時間の確認ダイアログを表示
   - 日付が当日から3日以上前の場合は警告を表示
   - 勤務開始時間が異常に早い（6:00以前）または遅い（12:00以降）場合は警告を表示
   - 勤務終了時間が異常に早い（9:00以前）または遅い（23:00以降）場合は警告を表示
   - 勤務時間が異常に短い（4時間未満）または長い（12時間超過）場合は警告を表示
3. ユーザーが確認して提出を承認
4. 日報を提出

**ビジネスルール:**
- 提出前に必ず確認ダイアログを表示
- 日付が当日から3日以上前の場合は警告を表示（入力ミスの可能性）
- 勤務開始時間が異常に早い（6:00以前）または遅い（12:00以降）場合は警告を表示（入力ミスの可能性）
- 勤務終了時間が異常に早い（9:00以前）または遅い（23:00以降）場合は警告を表示（入力ミスの可能性）
- 勤務時間が異常に短い（4時間未満）または長い（12時間超過）場合は警告を表示（入力ミスの可能性）
- 警告が表示されても提出は可能（ユーザーが意図的に入力した場合を考慮）
- 確認ダイアログで「キャンセル」を選択した場合は提出を中止

**受け入れ基準:** AC-002-1（日報作成の一部）

**ユーザーストーリー:** US-002-1（日報作成機能の一部）

**ドメインの目的への貢献:**
- ✅ 入力ミスを防ぎ、正確な業務記録を残す
- ✅ 勤怠管理の精度を向上させる

**考慮事項:**
- フロントエンドで確認ダイアログを実装
- バックエンドでも異常値の検証を行う（二重チェック）

---

##### FR-002-11: 日報の再提出（MVP、P0）

**機能の目的:**
ユーザーが間違えて提出してしまった日報を修正して再提出できるようにする。

**入力:**
- 日報ID
- 修正内容（作業内容、問題とその解決策、勤務地、勤務開始時間、勤務終了時間、休憩時間など）

**出力:**
- 再提出された日報の情報
- 送信完了通知

**処理フロー:**
1. ユーザーが提出済みの日報を編集
2. 修正内容を入力（日付、作業内容、問題とその解決策、勤務時間など）
3. **再提出前に確認ダイアログを表示**
   - **既に提出済みであることを明示**（「この日報は既に提出済みです。再提出を行いますか？」）
   - 日付・勤務時間の確認
   - 異常な勤務時間の場合は警告を表示
   - 日付が当日から3日以上前の場合は警告を表示
4. ユーザーが「再提出する」を承認
5. 日報を更新（修正内容を適用）
6. 勤務時間を再記録（変更された場合）
7. 提出日時を更新
8. 日報をデータベースに保存
9. **再提出通知を送信**（Notification Context と連携、メールに「再提出」の旨を表示）
10. 送信完了通知を表示

**ビジネスルール:**
- 提出済みの日報は編集可能
- **再提出前に必ず確認ダイアログを表示し、既に提出済みであることを明示**
- **再提出を承認した場合のみ、再提出処理を実行**
- 再提出時も勤務時間を再記録可能
- 再提出前に日付と勤務時間の確認を促す（確認ダイアログ）
- 異常な勤務時間の場合は警告を表示
- 日付が当日から3日以上前の場合は警告を表示
- 再提出回数に制限はない（何度でも修正可能）
- **再提出時の通知メールには「再提出」という旨を明記**

**受け入れ基準:** AC-002-1（日報作成の一部）

**ユーザーストーリー:** US-002-1（日報作成機能の一部）

**ドメインの目的への貢献:**
- ✅ 入力ミスを修正し、正確な業務記録を残す
- ✅ ユーザーの安心感を向上させる（間違えても修正できる）

**考慮事項:**
- 再提出の履歴を記録するかどうかは将来拡張として検討
- フロントエンドで確認ダイアログを実装（「既に提出済みです。再提出を行いますか？」を表示）
- バックエンドでも異常値の検証を行う（二重チェック）
- **Notification Context と連携して再提出通知を送信**
- **再提出時の通知メールには「再提出」という旨を明記**

---

##### FR-002-7: 午前休・午後休登録（MVP、P0）

**機能の目的:**
ユーザーが日報提出時に午前休・午後休を選択できるようにする。日報提出と同時に休日情報を登録することで、ユーザーの操作を簡素化する。

**入力:**
- 日付（YYYY-MM-DD形式）
- 休日種別（午前休/午後休/なし）

**出力:**
- 登録された休日情報

**処理フロー:**
1. ユーザーが日報提出時に休日種別を選択（午前休/午後休/なし）
2. 日報提出と同時に休日情報を登録（Leave Context と連携）
3. 休日情報がデータベースに保存される

**ビジネスルール:**
- 午前休・午後休は日報提出時に選択可能
- 全日休の場合は日報作成は不要（Leave Context で別途登録）
- 午前休・午後休を選択した場合、休日情報が自動的に登録される
- 午前休・午後休の場合、勤務表には勤務時間（午後または午前の勤務時間）と休日の選択（午前休または午後休）の両方が出力される必要がある
- **遅刻情報（遅延情報）は勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）
- **早退情報は勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）
- 下書き保存時には休日種別を選択する必要はない（提出時に選択可能）

**受け入れ基準:** AC-002-1（日報作成の一部）、AC-003-1（休日登録の一部）

**ユーザーストーリー:** US-002-1（日報作成機能の一部）

**ドメインの目的への貢献:**
- ✅ 勤怠管理（休日情報の記録）を実現する
- ✅ 日報作成と休日登録を一括で行えるため、ユーザーの負担を軽減する

**考慮事項:**
- Leave Context との連携が必要
- 日報作成と休日登録は同一トランザクションで処理するか、イベント駆動で連携するかを検討
- 午前休・午後休の場合、日報は提出する必要がある（全日休の場合は日報提出不要）

---

#### 機能要件の分類まとめ

| 機能要件 | 優先度 | 開発フェーズ | 見積り | 備考 |
|---------|--------|------------|--------|------|
| FR-002-1: 日報作成 | P0 | Phase 3（MVP） | 5ポイント | 必須機能（基本: 作成・提出、補助: 下書き保存、午前休・午後休登録含む） |
| FR-002-5: 勤務地選択 | P0 | Phase 3（MVP） | - | 日報作成の一部 |
| FR-002-7: 午前休・午後休登録 | P0 | Phase 3（MVP） | - | 日報作成の一部（Leave Context連携） |
| FR-002-10: 日付・時間の入力ミス防止 | P0 | Phase 3（MVP） | 2ポイント | 必須機能（確認ダイアログ、異常値検出） |
| FR-002-11: 日報の再提出 | P0 | Phase 3（MVP） | 2ポイント | 必須機能（修正・再提出） |
| FR-002-9: 下書きから提出 | P1 | Phase 3（MVP） | 1ポイント | 補助機能（下書きから提出） |
| FR-002-8: 日報未提出の通知 | P0 | Phase 3（MVP） | 3ポイント | 必須機能（Notification Context連携） |
| FR-002-4: 提出状況トラッキング | P1 | Phase 3（MVP） | 2ポイント | 必須機能 |
| FR-002-2: テンプレート編集 | P2 | 将来拡張 | 3ポイント | 拡張機能 |
| FR-002-3: 日報履歴検索 | P2 | 将来拡張 | 3ポイント | 拡張機能 |
| FR-002-6: コメント | - | 将来拡張 | - | 拡張機能 |

#### MVPで実装する機能

1. **FR-002-1: 日報作成**（P0、5ポイント）
   - 日報の基本情報を入力・提出（基本の操作）
   - 補助機能: 途中で下書き保存も可能
   - 午前休・午後休の登録も同時に行える

2. **FR-002-10: 日付・時間の入力ミス防止**（P0、2ポイント）
   - 提出前の確認ダイアログ
   - 異常値の検出と警告（日付が3日以上前、勤務時間の異常値）

3. **FR-002-11: 日報の再提出**（P0、2ポイント）
   - 提出済みの日報を修正して再提出
   - 再提出時の確認ダイアログ

4. **FR-002-8: 日報未提出の通知**（P0、3ポイント）
   - 定期実行（18:00と翌日9:30）で未提出を検知
   - Notification Context のサービスを呼び出して通知を送信

5. **FR-002-9: 下書きから提出**（P1、1ポイント）
   - 下書きの日報を完成させて提出（補助機能）

6. **FR-002-4: 日報提出状況トラッキング**（P1、2ポイント）
   - 提出済み/未提出の表示
   - 提出率の計算

#### 機能要件間の依存関係

```
FR-002-1（日報作成）
  ├─ FR-002-5（勤務地選択）: 日報作成の一部として実装
  ├─ FR-002-7（午前休・午後休登録）: 日報作成時に同時に登録可能（Leave Context連携）
  └─ FR-002-10（日付・時間の入力ミス防止）: 提出前の確認と異常値検出

FR-002-9（下書きから提出）
  ├─ FR-002-1（日報作成）: 下書きの日報を完成させて提出
  └─ FR-002-10（日付・時間の入力ミス防止）: 提出前の確認と異常値検出

FR-002-10（日付・時間の入力ミス防止）
  └─ FR-002-1（日報作成）: 提出時の確認機能

FR-002-11（日報の再提出）
  ├─ FR-002-1（日報作成）: 提出済みの日報を編集
  └─ FR-002-10（日付・時間の入力ミス防止）: 再提出前の確認と異常値検出

FR-002-8（日報未提出の通知）
  ├─ FR-002-1（日報作成）: 日報の存在とステータスを確認（提出済みステータスを確認）
  ├─ Leave Context: 休日情報を参照して全日休の場合は通知をスキップ
  └─ Notification Context: 通知送信の実装詳細を提供

FR-002-4（提出状況トラッキング）
  └─ FR-002-1（日報作成）: 日報の存在と提出済みステータスを確認

FR-002-2（テンプレート編集）: 日報作成時にテンプレートを適用（将来拡張）

FR-002-3（日報履歴検索）: 日報作成後に検索可能になる（将来拡張）
```

#### 受け入れ基準（AC-002-1〜AC-002-4）

**AC-002-1: 日報作成**
- 日付のバリデーション（形式、重複チェック、未来日付チェック）
- 日報の保存
- 送信完了通知
- 勤務地の記録

**AC-002-2: 日報テンプレート編集**（将来拡張）
- テンプレートの保存
- 次回作成時の適用

**AC-002-3: 日報履歴検索**
- 日付範囲での検索
- キーワードでの検索

**AC-002-4: 日報提出状況トラッキング**
- 提出済み/未提出の表示
- 提出率の計算

### 1.3 ユーザーストーリー

- **US-002-1**: 日報作成機能（P0、5ポイント）
- **US-002-2**: 日報テンプレート編集機能（P2、将来拡張）
- **US-002-3**: 日報履歴検索機能（P2、将来拡張、3ポイント）
- **US-002-4**: 日報提出状況トラッキング機能（P1、2ポイント）

### 1.4 主要な概念の抽出

#### エンティティ候補
- **Report（日報）**: 日報の本体
- **ReportTemplate（日報テンプレート）**: 日報のテンプレート（将来拡張）
- **WorkLocationCandidate（勤務地候補）**: ユーザーごとの勤務地候補（MVP）

#### 値オブジェクト候補
- **ReportDate（日報日付）**: 日付のバリデーションを含む
- **WorkStartTime（勤務開始時間）**: 勤務開始時間（HH:mm形式、デフォルト: 9:30）
- **WorkEndTime（勤務終了時間）**: 勤務終了時間（HH:mm形式、デフォルト: 18:00）
- **BreakTime（休憩時間）**: 休憩時間（分単位、デフォルト: 60分）
- **ReportContent（日報内容）**: 作業内容、問題とその解決策
- **AdditionalItem（追加項目）**: 見出しと記述項目のペア
- **WorkLocation（勤務地）**: 任意の文字列（デフォルト候補: 飯田橋、自宅）
- **TravelTime（移動時間）**: 分単位（任意、提出時に記録可能）
- **LateArrival（遅刻情報）**: 分数または理由（任意、提出時に記録可能）
- **EarlyLeave（早退情報）**: 分数または理由（任意、提出時に記録可能）
- **ReportId（日報ID）**: 日報の識別子
- **UserId（ユーザーID）**: 作成者の識別子

#### ビジネスルール
1. **同じ日付の日報は1つだけ存在できる**（重複不可、ただし再提出は可能）
   - 新しい日報を作成する際は、同じ日付の日報が既に存在する場合はエラー
   - 既存の日報を編集・再提出することは可能（既存の日報を更新する操作）
2. **未来日付の日報は作成できない**（過去または当日のみ）
3. **日付の形式はYYYY-MM-DD形式**
4. **無効な日付（存在しない日付等）は入力できない**
5. **日報は削除可能**（編集も可能）

---

## ステップ2: 境界づけられたコンテキストの特定

### 2.1 Reports Context の境界

**Reports Context に含まれるもの:**
- 日報の作成・更新・削除
- 日報作成時の午前休・午後休登録（Leave Context と連携）
- 日報の検索
- **日報の提出状況管理**（提出済み/未提出の判定、提出率の計算）
- **日報未提出の通知**（ビジネスロジック：未提出を検知して通知を送信する）
- 日報テンプレート管理（将来拡張）

**Reports Context に含まれないもの:**
- ユーザー認証・認可（Auth Context）
- 勤務表への反映（Attendance Context）
- 全日休の登録（Leave Context）
- **通知送信の実装詳細（Notification Context）**（メール送信、Slack送信などの技術的な実装は Notification Context の責務）

#### 設計判断の理由

**Q: 提出状況の管理は Reports Context に含めるべきか？**

**A: はい、含めるべきです。**

**理由:**
- 提出状況は日報の状態を管理するものなので、Reports Context の責務
- 提出済み/未提出の判定は、日報の存在有無に基づくため、Reports Context で管理するのが自然
- 提出率の計算も、日報データに基づくため、Reports Context の責務

**Q: 未提出の場合に通知する機能は Reports Context に含めるべきか？**

**A: はい、含めるべきです。**

**理由（ドメインの観点から）:**
- 日報管理ドメインの目的は「必ず提出すること」
- 未提出を検知して通知することは、「必ず提出する」というビジネスルールを実現するための手段
- 日報未提出の通知は、日報管理ドメインの責務として考えるべき
- 通知の送信方法（メール、Slack、プッシュ通知など）は技術的な実装詳細で、Notification Context が提供するインフラストラクチャ
- 機能で分類するのではなく、ドメインの責務で判断する

**連携方法（パターン1: アプリケーションサービスから直接呼び出し）:**

1. **Reports Context が定期実行（18:00と翌日9:30）で日報未提出を検知**
   - Reports Context のアプリケーションサービス（ReportService）が @Cron デコレータまたは AWS EventBridge + Lambda で定期実行
   - 全ユーザーに対して、前日の日報提出状況を確認

2. **Reports Context が Leave Context の休日情報を確認**
   - 全日休の場合は通知をスキップ
   - 午前休・午後休の場合は通知を送信（日報提出が必要なため）

3. **Reports Context が Notification Context のサービスを呼び出して通知を送信**
   - Reports Context のアプリケーションサービスが Notification Context のアプリケーションサービス（NotificationService）を直接呼び出し
   - 通知送信の実装詳細（メール送信、Slack送信など）は Notification Context が担当

**実装方針:**
- MVPではパターン1を採用（シンプルで実装しやすい、アプリケーションサービスから直接呼び出し）
- Reports Context が通知送信のビジネスロジックを管理し、Notification Context が技術的な実装を提供

### 2.2 他のコンテキストとの関係

#### Auth Context（認証・認可）
- **関係**: Reports Context は UserId を参照する
- **共有カーネル**: UserId

#### Attendance Context（勤務表管理）
- **関係**: 
  - 日報の勤務地情報を参照する可能性がある（将来拡張）
  - 日報の遅刻情報（遅延情報）を参照して勤務表に出力する（勤務表出力に必要な情報）
  - 日報の早退情報を参照して勤務表に出力する（勤務表出力に必要な情報）
  - 日報の移動時間を参照して勤務表に出力する可能性がある（将来拡張）
- **共有カーネル**: WorkLocation（勤務地）、LateArrival（遅刻情報）、EarlyLeave（早退情報）、TravelTime（移動時間）

#### Leave Context（休日登録）
- **関係**: 
  - 日報作成時に午前休・午後休を登録できる（Reports Context → Leave Context）
  - 日報未提出の通知時に休日情報を参照（全日休の場合は通知をスキップ）
- **共有カーネル**: DateRange（日付範囲）、LeaveType（休日種別）
- **連携方法**: 
  - 日報作成時に午前休・午後休を選択した場合、Leave Context に休日情報を登録
  - 同一トランザクションで処理するか、イベント駆動で連携するかを検討
  - 日報未提出の通知時に Leave Context のリポジトリを呼び出して休日情報を確認

#### Notification Context（通知）
- **関係**: 
  - 日報未提出時の通知送信の実装詳細を提供（Notification Context の責務）
  - 日報再提出時の通知送信の実装詳細を提供（Notification Context の責務）
  - 日報未提出の検知と通知送信のビジネスロジックは Reports Context が管理
  - 日報再提出の検知と通知送信のビジネスロジックは Reports Context が管理
- **連携方法（MVP）**: 
  - **日報未提出の通知**:
    - Reports Context が定期実行（18:00と翌日9:30）で日報未提出を検知
    - Reports Context が Leave Context の休日情報を参照し、全日休の場合は通知をスキップ
    - Reports Context が Notification Context のアプリケーションサービス（NotificationService）を直接呼び出し
    - Notification Context が通知送信の実装詳細（メール送信、Slack送信など）を担当
  - **日報再提出の通知**:
    - Reports Context が日報再提出時に Notification Context のアプリケーションサービス（NotificationService）を直接呼び出し
    - 通知メールには「再提出」という旨を明記（Notification Context が実装）
    - Notification Context が通知送信の実装詳細（メール送信、Slack送信など）を担当
- **責務の分離**: 
  - Reports Context: 日報未提出・再提出の検知と通知送信のビジネスロジック（いつ、誰に、何を通知するか）
  - Notification Context: 通知送信の技術的な実装（メール、Slack、プッシュ通知など）

---

## ステップ3: ドメインモデルの設計

### 3-1. エンティティの特定

#### Report（日報）エンティティ

**識別子**: ReportId（値オブジェクト）

**属性:**
- `id: ReportId` - 日報ID
- `userId: UserId` - 作成者ID
- `date: ReportDate` - 日報日付
- `workStartTime: WorkStartTime` - 勤務開始時間（デフォルト: 9:30）
- `workEndTime: WorkEndTime` - 勤務終了時間（デフォルト: 18:00）
- `breakTime: BreakTime` - 休憩時間（デフォルト: 60分）
- `content: ReportContent` - 日報内容（作業内容、問題とその解決策）
- `additionalItems: AdditionalItem[]` - 追加項目（見出しと記述項目のペア、複数可能）
- `workLocation: WorkLocation` - 勤務地
- `travelTime: TravelTime | null` - 移動時間（任意、提出時に記録可能）
- `lateArrival: LateArrival | null` - 遅刻情報（任意、提出時に記録可能）
- `earlyLeave: EarlyLeave | null` - 早退情報（任意、提出時に記録可能）
- `status: ReportStatus` - ステータス（下書き/提出済み）
- `createdAt: Date` - 作成日時
- `updatedAt: Date` - 更新日時
- `submittedAt: Date | null` - 提出日時

**ビジネスロジック:**
- `create()`: 日報を作成（バリデーション含む、デフォルトは下書き）
- `update()`: 日報を更新
- `submit()`: 日報を提出（ステータスを提出済みに更新）
- `calculateWorkTime()`: 実働時間を計算（勤務終了時間 - 勤務開始時間 - 休憩時間）
- `delete()`: 日報を削除

**不変条件:**
- 同じ日付の日報は1つだけ存在する（重複不可、ただし再提出は可能）
  - 新しい日報を作成する際は、同じ日付の日報が既に存在する場合はエラー
  - 既存の日報を編集・再提出することは可能（既存の日報を更新する操作）
- 未来日付の日報は作成できない
- 勤務終了時間は勤務開始時間より後である必要がある
- 実働時間は0分以上である必要がある

### 3-2. 値オブジェクトの特定

#### ReportId（日報ID）

```typescript
class ReportId {
  private readonly value: string;

  private constructor(value: string) {
    if (!value || value.trim().length === 0) {
      throw new Error('日報IDは必須です');
    }
    this.value = value;
  }

  public static create(value: string): ReportId {
    return new ReportId(value);
  }

  public static generate(): ReportId {
    return new ReportId(uuidv4());
  }

  public equals(other: ReportId): boolean {
    return this.value === other.value;
  }

  public getValue(): string {
    return this.value;
  }
}
```

#### ReportDate（日報日付）

```typescript
class ReportDate {
  private readonly value: Date;

  private constructor(date: Date) {
    // ビジネスルール: 未来日付は許可しない
    const today = new Date();
    today.setHours(23, 59, 59, 999);
    if (date > today) {
      throw new Error('未来日付の日報は作成できません');
    }

    // ビジネスルール: 無効な日付は許可しない
    if (isNaN(date.getTime())) {
      throw new Error('無効な日付です');
    }

    this.value = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  }

  public static create(date: Date | string): ReportDate {
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    return new ReportDate(dateObj);
  }

  public equals(other: ReportDate): boolean {
    return this.toDateString() === other.toDateString();
  }

  public toDate(): Date {
    return new Date(this.value);
  }

  public toDateString(): string {
    return this.value.toISOString().split('T')[0]; // YYYY-MM-DD形式
  }

  public isBefore(other: ReportDate): boolean {
    return this.value < other.value;
  }

  public isAfter(other: ReportDate): boolean {
    return this.value > other.value;
  }
}
```

#### WorkStartTime（勤務開始時間）

```typescript
class WorkStartTime {
  private readonly value: string; // HH:mm形式

  private constructor(value: string) {
    // バリデーション: HH:mm形式
    const timePattern = /^([01][0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timePattern.test(value)) {
      throw new Error('勤務開始時間はHH:mm形式で入力してください（例: 09:30）');
    }
    this.value = value;
  }

  public static create(value: string): WorkStartTime {
    return new WorkStartTime(value);
  }

  public static default(): WorkStartTime {
    return new WorkStartTime('09:30');
  }

  public static fromDate(date: Date): WorkStartTime {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return new WorkStartTime(`${hours}:${minutes}`);
  }

  public getValue(): string {
    return this.value;
  }

  public equals(other: WorkStartTime): boolean {
    return this.value === other.value;
  }

  public toDate(baseDate: Date): Date {
    const [hours, minutes] = this.value.split(':').map(Number);
    const date = new Date(baseDate);
    date.setHours(hours, minutes, 0, 0);
    return date;
  }
}
```

#### WorkEndTime（勤務終了時間）

```typescript
class WorkEndTime {
  private readonly value: string; // HH:mm形式

  private constructor(value: string) {
    // バリデーション: HH:mm形式
    const timePattern = /^([01][0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timePattern.test(value)) {
      throw new Error('勤務終了時間はHH:mm形式で入力してください（例: 18:00）');
    }
    this.value = value;
  }

  public static create(value: string): WorkEndTime {
    return new WorkEndTime(value);
  }

  public static default(): WorkEndTime {
    return new WorkEndTime('18:00');
  }

  public static fromDate(date: Date): WorkEndTime {
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return new WorkEndTime(`${hours}:${minutes}`);
  }

  public getValue(): string {
    return this.value;
  }

  public equals(other: WorkEndTime): boolean {
    return this.value === other.value;
  }

  public toDate(baseDate: Date): Date {
    const [hours, minutes] = this.value.split(':').map(Number);
    const date = new Date(baseDate);
    date.setHours(hours, minutes, 0, 0);
    return date;
  }

  // 勤務開始時間より後であることを確認
  public isAfter(startTime: WorkStartTime, baseDate: Date): boolean {
    const endDate = this.toDate(baseDate);
    const startDate = startTime.toDate(baseDate);
    return endDate > startDate;
  }
}
```

#### BreakTime（休憩時間）

```typescript
class BreakTime {
  private readonly value: number; // 分単位

  private constructor(value: number) {
    // バリデーション: 0分以上
    if (value < 0) {
      throw new Error('休憩時間は0分以上である必要があります');
    }

    // バリデーション: 最大値（例: 480分 = 8時間）
    if (value > 480) {
      throw new Error('休憩時間は480分（8時間）以内である必要があります');
    }

    this.value = value;
  }

  public static create(value: number): BreakTime {
    return new BreakTime(value);
  }

  public static default(): BreakTime {
    return new BreakTime(60); // デフォルト: 60分
  }

  public getValue(): number {
    return this.value;
  }

  public equals(other: BreakTime): boolean {
    return this.value === other.value;
  }

  // 時間単位で取得
  public toHours(): number {
    return this.value / 60;
  }
}
```

#### ReportContent（日報内容）

```typescript
class ReportContent {
  private readonly workContent: string;        // 作業内容
  private readonly problemAndSolution: string;  // 問題とその解決策

  private constructor(
    workContent: string,
    problemAndSolution: string
  ) {
    // バリデーション: 作業内容は必須
    if (!workContent || workContent.trim().length === 0) {
      throw new Error('作業内容は必須です');
    }

    // バリデーション: 問題とその解決策は必須
    if (!problemAndSolution || problemAndSolution.trim().length === 0) {
      throw new Error('問題とその解決策は必須です');
    }

    this.workContent = workContent.trim();
    this.problemAndSolution = problemAndSolution.trim();
  }

  public static create(
    workContent: string,
    problemAndSolution: string
  ): ReportContent {
    return new ReportContent(workContent, problemAndSolution);
  }

  public getWorkContent(): string {
    return this.workContent;
  }

  public getProblemAndSolution(): string {
    return this.problemAndSolution;
  }

  public update(
    workContent?: string,
    problemAndSolution?: string
  ): ReportContent {
    return new ReportContent(
      workContent ?? this.workContent,
      problemAndSolution ?? this.problemAndSolution
    );
  }
}
```

#### AdditionalItem（追加項目）

```typescript
class AdditionalItem {
  private readonly title: string;      // 見出し
  private readonly description: string; // 記述項目

  private constructor(title: string, description: string) {
    // バリデーション: 見出しは必須
    if (!title || title.trim().length === 0) {
      throw new Error('見出しは必須です');
    }

    // バリデーション: 見出しの最大長
    if (title.length > 50) {
      throw new Error('見出しは50文字以内で入力してください');
    }

    // バリデーション: 記述項目の最大長
    if (description.length > 1000) {
      throw new Error('記述項目は1000文字以内で入力してください');
    }

    this.title = title.trim();
    this.description = description.trim();
  }

  public static create(title: string, description: string): AdditionalItem {
    return new AdditionalItem(title, description);
  }

  public getTitle(): string {
    return this.title;
  }

  public getDescription(): string {
    return this.description;
  }

  public equals(other: AdditionalItem): boolean {
    return this.title === other.title && this.description === other.description;
  }
}
```

#### WorkLocation（勤務地）

```typescript
class WorkLocation {
  private readonly value: string;

  private constructor(value: string) {
    // バリデーション: 勤務地は必須
    if (!value || value.trim().length === 0) {
      throw new Error('勤務地は必須です');
    }

    // バリデーション: 最大長を制限（例: 50文字）
    if (value.length > 50) {
      throw new Error('勤務地は50文字以内で入力してください');
    }

    this.value = value.trim();
  }

  public static create(value: string): WorkLocation {
    return new WorkLocation(value);
  }

  public getValue(): string {
    return this.value;
  }

  public equals(other: WorkLocation): boolean {
    return this.value === other.value;
  }

  // デフォルト候補を取得（システム共通）
  public static getDefaultCandidates(): string[] {
    return ['飯田橋', '自宅'];
  }
}
```

**備考:**
- 勤務地は任意の文字列を受け入れる（固定の選択肢ではない）
- デフォルト候補（飯田橋、自宅）はシステム共通
- ユーザーは勤務地候補を追加・編集できる（WorkLocationCandidate エンティティで管理）

#### TravelTime（移動時間）

```typescript
class TravelTime {
  private readonly value: number; // 分単位

  private constructor(value: number) {
    // バリデーション: 0以上、480分（8時間）以下
    if (value < 0) {
      throw new Error('移動時間は0分以上で入力してください');
    }
    if (value > 480) {
      throw new Error('移動時間は480分（8時間）以下で入力してください');
    }
    this.value = value;
  }

  public static create(value: number): TravelTime {
    return new TravelTime(value);
  }

  public getValue(): number {
    return this.value;
  }

  public equals(other: TravelTime): boolean {
    return this.value === other.value;
  }

  public toHours(): number {
    return Math.round((this.value / 60) * 10) / 10; // 小数点第1位まで
  }
}
```

**備考:**
- 移動時間は任意項目（提出時に記録可能）
- 分単位で記録（例: 30分、60分）
- 最大480分（8時間）まで
- **勤務表出力の際に参照される可能性がある**（Attendance Context が参照、将来拡張）

#### LateArrival（遅刻情報）

```typescript
class LateArrival {
  private readonly minutes: number | null; // 遅刻した分数（分単位）
  private readonly reason: string | null;  // 遅刻理由

  private constructor(minutes: number | null, reason: string | null) {
    // バリデーション: 分数または理由のいずれかは必須
    if (minutes === null && (!reason || reason.trim().length === 0)) {
      throw new Error('遅刻情報は分数または理由のいずれかを入力してください');
    }

    // バリデーション: 分数が0以上、480分（8時間）以下
    if (minutes !== null) {
      if (minutes < 0) {
        throw new Error('遅刻分数は0分以上で入力してください');
      }
      if (minutes > 480) {
        throw new Error('遅刻分数は480分（8時間）以下で入力してください');
      }
    }

    // バリデーション: 理由の最大長
    if (reason && reason.length > 500) {
      throw new Error('遅刻理由は500文字以内で入力してください');
    }

    this.minutes = minutes;
    this.reason = reason ? reason.trim() : null;
  }

  public static create(minutes: number | null, reason: string | null): LateArrival {
    return new LateArrival(minutes, reason);
  }

  public static createByMinutes(minutes: number): LateArrival {
    return new LateArrival(minutes, null);
  }

  public static createByReason(reason: string): LateArrival {
    return new LateArrival(null, reason);
  }

  public getMinutes(): number | null {
    return this.minutes;
  }

  public getReason(): string | null {
    return this.reason;
  }

  public equals(other: LateArrival): boolean {
    return this.minutes === other.minutes && this.reason === other.reason;
  }
}
```

**備考:**
- 遅刻情報（遅延情報）は任意項目（提出時に記録可能）
- 分数（分単位）または理由のいずれかを入力可能
- 両方を入力することも可能
- **勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）

#### EarlyLeave（早退情報）

```typescript
class EarlyLeave {
  private readonly minutes: number | null; // 早退した分数（分単位）
  private readonly reason: string | null;  // 早退理由

  private constructor(minutes: number | null, reason: string | null) {
    // バリデーション: 分数または理由のいずれかは必須
    if (minutes === null && (!reason || reason.trim().length === 0)) {
      throw new Error('早退情報は分数または理由のいずれかを入力してください');
    }

    // バリデーション: 分数が0以上、480分（8時間）以下
    if (minutes !== null) {
      if (minutes < 0) {
        throw new Error('早退分数は0分以上で入力してください');
      }
      if (minutes > 480) {
        throw new Error('早退分数は480分（8時間）以下で入力してください');
      }
    }

    // バリデーション: 理由の最大長
    if (reason && reason.length > 500) {
      throw new Error('早退理由は500文字以内で入力してください');
    }

    this.minutes = minutes;
    this.reason = reason ? reason.trim() : null;
  }

  public static create(minutes: number | null, reason: string | null): EarlyLeave {
    return new EarlyLeave(minutes, reason);
  }

  public static createByMinutes(minutes: number): EarlyLeave {
    return new EarlyLeave(minutes, null);
  }

  public static createByReason(reason: string): EarlyLeave {
    return new EarlyLeave(null, reason);
  }

  public getMinutes(): number | null {
    return this.minutes;
  }

  public getReason(): string | null {
    return this.reason;
  }

  public equals(other: EarlyLeave): boolean {
    return this.minutes === other.minutes && this.reason === other.reason;
  }
}
```

**備考:**
- 早退情報は任意項目（提出時に記録可能）
- 分数（分単位）または理由のいずれかを入力可能
- 両方を入力することも可能
- **勤務表出力の際に必要な情報として保持される**（Attendance Context が参照）

#### ReportStatus（日報ステータス）

```typescript
class ReportStatus {
  private readonly value: 'draft' | 'submitted';

  private constructor(value: string) {
    if (value !== 'draft' && value !== 'submitted') {
      throw new Error(`無効なステータスです: ${value}`);
    }
    this.value = value as 'draft' | 'submitted';
  }

  public static draft(): ReportStatus {
    return new ReportStatus('draft');
  }

  public static submitted(): ReportStatus {
    return new ReportStatus('submitted');
  }

  public getValue(): 'draft' | 'submitted' {
    return this.value;
  }

  public isDraft(): boolean {
    return this.value === 'draft';
  }

  public isSubmitted(): boolean {
    return this.value === 'submitted';
  }

  public equals(other: ReportStatus): boolean {
    return this.value === other.value;
  }
}
```

**備考:**
- 下書き（draft）: 定時に作成された日報
- 提出済み（submitted）: 退勤時に提出された日報

#### UserId（ユーザーID）

```typescript
class UserId {
  private readonly value: string;

  private constructor(value: string) {
    if (!value || value.trim().length === 0) {
      throw new Error('ユーザーIDは必須です');
    }
    this.value = value;
  }

  public static create(value: string): UserId {
    return new UserId(value);
  }

  public equals(other: UserId): boolean {
    return this.value === other.value;
  }

  public getValue(): string {
    return this.value;
  }
}
```

### 3-3. 集約の設計

#### Report 集約

**集約ルート**: `Report`

**子エンティティ**: なし（現時点）

**不変条件:**
1. 同じ日付の日報は1つだけ存在する（同じuserId、同じdateの組み合わせ、重複不可、ただし再提出は可能）
   - 新しい日報を作成する際は、同じ日付の日報が既に存在する場合はエラー
   - 既存の日報を編集・再提出することは可能（既存の日報を更新する操作）
2. 未来日付の日報は作成できない
3. 勤務終了時間は勤務開始時間より後である必要がある
4. 実働時間は0分以上である必要がある

**Report エンティティの実装:**

```typescript
class Report {
  private id: ReportId;
  private userId: UserId;
  private date: ReportDate;
  private workStartTime: WorkStartTime;
  private workEndTime: WorkEndTime;
  private breakTime: BreakTime;
  private content: ReportContent;
  private additionalItems: AdditionalItem[];
  private workLocation: WorkLocation;
  private status: ReportStatus;
  private createdAt: Date;
  private updatedAt: Date;
  private submittedAt: Date | null;

  private constructor(
    id: ReportId,
    userId: UserId,
    date: ReportDate,
    workStartTime: WorkStartTime,
    workEndTime: WorkEndTime,
    breakTime: BreakTime,
    content: ReportContent,
    additionalItems: AdditionalItem[],
    workLocation: WorkLocation,
    status: ReportStatus,
    createdAt: Date,
    updatedAt: Date,
    submittedAt: Date | null
  ) {
    // 不変条件: 勤務終了時間は勤務開始時間より後である必要がある
    if (!workEndTime.isAfter(workStartTime, date.toDate())) {
      throw new Error('勤務終了時間は勤務開始時間より後である必要があります');
    }

    this.id = id;
    this.userId = userId;
    this.date = date;
    this.workStartTime = workStartTime;
    this.workEndTime = workEndTime;
    this.breakTime = breakTime;
    this.content = content;
    this.additionalItems = additionalItems;
    this.workLocation = workLocation;
    this.status = status;
    this.createdAt = createdAt;
    this.updatedAt = updatedAt;
    this.submittedAt = submittedAt;
  }

  // ファクトリメソッド: 新規作成（下書き）
  public static create(
    userId: UserId,
    date: ReportDate,
    workStartTime: WorkStartTime,
    workEndTime: WorkEndTime,
    breakTime: BreakTime,
    content: ReportContent,
    additionalItems: AdditionalItem[],
    workLocation: WorkLocation
  ): Report {
    const now = new Date();
    return new Report(
      ReportId.generate(),
      userId,
      date,
      workStartTime,
      workEndTime,
      breakTime,
      content,
      additionalItems,
      workLocation,
      ReportStatus.draft(), // デフォルトは下書き
      now,
      now,
      null // 提出日時は未記録
    );
  }

  // ファクトリメソッド: 再構築（リポジトリから復元時）
  public static reconstruct(
    id: ReportId,
    userId: UserId,
    date: ReportDate,
    workStartTime: WorkStartTime,
    workEndTime: WorkEndTime,
    breakTime: BreakTime,
    content: ReportContent,
    additionalItems: AdditionalItem[],
    workLocation: WorkLocation,
    status: ReportStatus,
    createdAt: Date,
    updatedAt: Date,
    submittedAt: Date | null
  ): Report {
    return new Report(
      id,
      userId,
      date,
      workStartTime,
      workEndTime,
      breakTime,
      content,
      additionalItems,
      workLocation,
      status,
      createdAt,
      updatedAt,
      submittedAt
    );
  }

  // ビジネスロジック: 日報の更新
  public update(
    content: ReportContent,
    workLocation?: WorkLocation,
    workStartTime?: WorkStartTime,
    workEndTime?: WorkEndTime,
    breakTime?: BreakTime,
    additionalItems?: AdditionalItem[]
  ): void {
    this.content = content;
    if (workLocation) {
      this.workLocation = workLocation;
    }
    if (workStartTime) {
      this.workStartTime = workStartTime;
    }
    if (workEndTime) {
      // 不変条件: 勤務終了時間は勤務開始時間より後である必要がある
      const startTime = workStartTime || this.workStartTime;
      if (!workEndTime.isAfter(startTime, this.date.toDate())) {
        throw new Error('勤務終了時間は勤務開始時間より後である必要があります');
      }
      this.workEndTime = workEndTime;
    }
    if (breakTime) {
      this.breakTime = breakTime;
    }
    if (additionalItems) {
      this.additionalItems = additionalItems;
    }
    this.updatedAt = new Date();
  }

  // ビジネスロジック: 日報を提出（ステータスを提出済みに更新）
  public submit(): void {
    this.status = ReportStatus.submitted();
    this.submittedAt = new Date();
    this.updatedAt = new Date();
  }

  // ビジネスロジック: 実働時間を計算
  public calculateWorkTime(): number {
    const startDate = this.workStartTime.toDate(this.date.toDate());
    const endDate = this.workEndTime.toDate(this.date.toDate());
    const totalMinutes = (endDate.getTime() - startDate.getTime()) / (1000 * 60);
    const workMinutes = totalMinutes - this.breakTime.getValue();
    return Math.max(0, workMinutes); // 0分以上を保証
  }

  // ゲッター
  public getId(): ReportId {
    return this.id;
  }

  public getUserId(): UserId {
    return this.userId;
  }

  public getDate(): ReportDate {
    return this.date;
  }

  public getContent(): ReportContent {
    return this.content;
  }

  public getWorkLocation(): WorkLocation {
    return this.workLocation;
  }

  public getStatus(): ReportStatus {
    return this.status;
  }

  public getWorkStartTime(): WorkStartTime {
    return this.workStartTime;
  }

  public getWorkEndTime(): WorkEndTime {
    return this.workEndTime;
  }

  public getBreakTime(): BreakTime {
    return this.breakTime;
  }

  public getAdditionalItems(): AdditionalItem[] {
    return this.additionalItems;
  }

  public getCreatedAt(): Date {
    return this.createdAt;
  }

  public getUpdatedAt(): Date {
    return this.updatedAt;
  }

  public getSubmittedAt(): Date | null {
    return this.submittedAt;
  }
}
```

### 3-4. ドメインサービスの特定

#### ReportSubmissionService（日報提出判定サービス）

複数のエンティティにまたがるロジックを扱う。

```typescript
class ReportSubmissionService {
  // 日報提出が必要かどうかを判定
  // （休日が登録されている場合は提出不要）
  public isSubmissionRequired(
    date: ReportDate,
    leaveDays: LeaveDay[] // Leave Context から取得
  ): boolean {
    // 休日が登録されている場合は提出不要
    const isLeaveDay = leaveDays.some(leave => 
      leave.contains(date)
    );
    return !isLeaveDay;
  }
}
```

---

## ステップ4: ユースケースの定義

### UC-001: 日報を作成する

**入力:**
- `userId: UserId`
- `date: Date`
- `businessContent: string`
- `achievements?: string`
- `challenges?: string`
- `nextDayPlan?: string`
- `workLocation: string`

**出力:**
- `reportId: ReportId`

**前提条件:**
- ユーザーがログインしている
- 同じ日付の日報が存在しない

**事後条件:**
- 新しい日報が作成される
- 日報がデータベースに保存される

**例外:**
- 同じ日付の日報が既に存在する場合: `DuplicateReportError`
- 未来日付の場合: `InvalidDateError`
- 無効な日付の場合: `InvalidDateError`

### UC-002: 日報を更新する

**入力:**
- `reportId: ReportId`
- `businessContent?: string`
- `achievements?: string`
- `challenges?: string`
- `nextDayPlan?: string`
- `workLocation?: string`

**出力:**
- `report: Report`

**前提条件:**
- ユーザーがログインしている
- 日報が存在する
- ユーザーが日報の所有者である

**事後条件:**
- 日報が更新される
- 更新された日報がデータベースに保存される

**例外:**
- 日報が存在しない場合: `ReportNotFoundError`
- ユーザーが所有者でない場合: `UnauthorizedError`

### UC-003: 日報を削除する

**入力:**
- `reportId: ReportId`
- `userId: UserId`

**出力:**
- なし

**前提条件:**
- ユーザーがログインしている
- 日報が存在する
- ユーザーが日報の所有者である

**事後条件:**
- 日報が削除される
- データベースから日報が削除される

**例外:**
- 日報が存在しない場合: `ReportNotFoundError`
- ユーザーが所有者でない場合: `UnauthorizedError`

### UC-004: 日報を検索する

**入力:**
- `userId: UserId`
- `startDate?: Date`
- `endDate?: Date`
- `keyword?: string`

**出力:**
- `reports: Report[]`

**前提条件:**
- ユーザーがログインしている

**事後条件:**
- 条件に一致する日報が返される

### UC-005: 日報提出状況を確認する

**入力:**
- `userId: UserId`
- `startDate: Date`
- `endDate: Date`

**出力:**
- `submissionStatus: SubmissionStatus`（提出済み/未提出のリスト、提出率）

**前提条件:**
- ユーザーがログインしている

**事後条件:**
- 提出状況が計算される

### UC-006: 日報未提出の通知を送信する

**入力:**
- なし（定期実行で自動実行）

**出力:**
- なし

**前提条件:**
- 定期実行が設定されている（18:00と翌日9:30）

**事後条件:**
- 未提出のユーザーに対して通知が送信される
- 全日休のユーザーには通知が送信されない

**処理フロー:**
1. 全ユーザーを取得
2. 各ユーザーについて、前日の日報提出状況を確認（提出済みステータスの日報が存在するか）
3. 日報が未提出の場合、Leave Context の休日情報を確認
4. 全日休でない場合、Notification Context のサービスを呼び出して通知を送信

**例外:**
- 通知送信に失敗した場合: ログに記録（通知は継続して送信）

### UC-007: 日報を提出する（退勤時）

**入力:**
- `reportId: ReportId`
- `clockOutTime: string`（HH:mm形式）

**出力:**
- `report: Report`
- `warnings: string[]`（警告メッセージの配列）

**前提条件:**
- ユーザーがログインしている
- 日報が存在する
- 日報のステータスが下書きである（または提出済みで再提出）
- ユーザーが日報の所有者である

**事後条件:**
- 日報のステータスが「提出済み」に更新される
- 退勤時間が記録される
- 提出日時が記録される
- 更新された日報がデータベースに保存される

**処理フロー:**
1. 日報を取得
2. 日付と退勤時間の異常値検証
   - 日付が当日から3日以上前の場合は警告を追加
   - 退勤時間が9:00以前の場合は警告を追加
   - 退勤時間が23:00以降の場合は警告を追加
3. 警告がある場合は警告メッセージを返す（提出は可能）
4. 日報を提出

**例外:**
- 日報が存在しない場合: `ReportNotFoundError`
- ユーザーが所有者でない場合: `UnauthorizedError`
- 日報が既に提出済みの場合: 退勤時間を再記録（再提出可能）

### UC-008: 日報を再提出する

**入力:**
- `reportId: ReportId`
- `businessContent?: string`
- `achievements?: string`
- `challenges?: string`
- `nextDayPlan?: string`
- `workLocation?: string`
- `clockOutTime?: string`（HH:mm形式）

**出力:**
- `report: Report`
- `warnings: string[]`（警告メッセージの配列）

**前提条件:**
- ユーザーがログインしている
- 日報が存在する
- 日報のステータスが提出済みである
- ユーザーが日報の所有者である

**事後条件:**
- 日報が更新される
- 退勤時間が再記録される（変更された場合）
- 提出日時が更新される
- 更新された日報がデータベースに保存される

**処理フロー:**
1. 日報を取得
2. 修正内容を適用
3. 日付と退勤時間の異常値検証
   - 日付が当日から3日以上前の場合は警告を追加
   - 退勤時間が9:00以前の場合は警告を追加
   - 退勤時間が23:00以降の場合は警告を追加
4. 警告がある場合は警告メッセージを返す（再提出は可能）
5. 日報を再提出

**例外:**
- 日報が存在しない場合: `ReportNotFoundError`
- ユーザーが所有者でない場合: `UnauthorizedError`

---

## ステップ5: アプリケーションサービスの設計

### ReportService（アプリケーションサービス）

```typescript
@Injectable()
export class ReportService {
  constructor(
    private readonly reportRepository: IReportRepository,
    private readonly reportSubmissionService: ReportSubmissionService,
    private readonly notificationService: NotificationService, // Notification Context のサービス
    private readonly leaveRepository: ILeaveRepository, // Leave Context のリポジトリ（休日情報確認用）
    private readonly userRepository: IUserRepository, // Auth Context のリポジトリ（全ユーザー取得用）
  ) {}

  // UC-001: 日報を作成する（下書き保存または提出）
  async createReport(dto: CreateReportDto): Promise<{ report: ReportDto; warnings: string[] }> {
    // 1. 値オブジェクトの作成
    const userId = UserId.create(dto.userId);
    const reportDate = ReportDate.create(dto.date);
    const workStartTime = dto.workStartTime 
      ? WorkStartTime.create(dto.workStartTime)
      : WorkStartTime.default();
    const workEndTime = dto.workEndTime
      ? WorkEndTime.create(dto.workEndTime)
      : WorkEndTime.default();
    const breakTime = dto.breakTime !== undefined
      ? BreakTime.create(dto.breakTime)
      : BreakTime.default();
    const content = ReportContent.create(
      dto.workContent,
      dto.problemAndSolution
    );
    const additionalItems = (dto.additionalItems || []).map(item =>
      AdditionalItem.create(item.title, item.description)
    );
    const workLocation = WorkLocation.create(dto.workLocation);

    // 2. ビジネスルールのチェック: 同じ日付の日報が存在しないか確認
    // 注意: 新しい日報を作成する際は、同じ日付の日報が既に存在する場合はエラー
    // 既存の日報を編集・再提出する場合は updateReport または resubmitReport を使用
    const existingReport = await this.reportRepository.findByDateAndUser(
      reportDate,
      userId
    );
    if (existingReport) {
      throw new DuplicateReportError('同じ日付の日報が既に存在します。既存の日報を編集する場合は更新機能を使用してください。');
    }

    // 3. ドメインオブジェクトの作成
    const report = Report.create(
      userId,
      reportDate,
      workStartTime,
      workEndTime,
      breakTime,
      content,
      additionalItems,
      workLocation
    );

    // 4. 提出の場合のみ異常値検証
    let warnings: string[] = [];
    if (dto.submit) {
      warnings = this.validateSubmission(report);
    }

    // 5. ステータスの設定
    if (dto.submit) {
      report.submit();
    }
    // 下書きの場合は既にdraftステータスで作成されている

    // 6. 永続化
    await this.reportRepository.save(report);

    // 7. DTOへの変換
    return {
      report: ReportDto.fromDomain(report),
      warnings,
    };
  }

  // UC-002: 日報を更新する
  async updateReport(
    reportId: string,
    userId: string,
    dto: UpdateReportDto & {
      workStartTime?: string;
      workEndTime?: string;
      breakTime?: number;
      additionalItems?: Array<{ title: string; description: string }>;
    }
  ): Promise<ReportDto> {
    // 1. 日報の取得
    const id = ReportId.create(reportId);
    const report = await this.reportRepository.findById(id);
    if (!report) {
      throw new ReportNotFoundError('日報が見つかりません');
    }

    // 2. 権限チェック
    const reportUserId = UserId.create(userId);
    if (!report.getUserId().equals(reportUserId)) {
      throw new UnauthorizedError('この日報を更新する権限がありません');
    }

    // 3. 値オブジェクトの作成
    const content = dto.workContent !== undefined || dto.problemAndSolution !== undefined
      ? report.getContent().update(
          dto.workContent,
          dto.problemAndSolution
        )
      : report.getContent();

    const workLocation = dto.workLocation
      ? WorkLocation.create(dto.workLocation)
      : undefined;

    const workStartTime = dto.workStartTime
      ? WorkStartTime.create(dto.workStartTime)
      : undefined;

    const workEndTime = dto.workEndTime
      ? WorkEndTime.create(dto.workEndTime)
      : undefined;

    const breakTime = dto.breakTime !== undefined
      ? BreakTime.create(dto.breakTime)
      : undefined;

    const additionalItems = dto.additionalItems
      ? dto.additionalItems.map(item => AdditionalItem.create(item.title, item.description))
      : undefined;

    // 4. 日報の更新
    report.update(
      content,
      workLocation,
      workStartTime,
      workEndTime,
      breakTime,
      additionalItems
    );

    // 5. 永続化
    await this.reportRepository.save(report);

    // 6. DTOへの変換
    return ReportDto.fromDomain(report);
  }

  // UC-003: 日報を削除する
  async deleteReport(reportId: string, userId: string): Promise<void> {
    // 1. 日報の取得
    const id = ReportId.create(reportId);
    const report = await this.reportRepository.findById(id);
    if (!report) {
      throw new ReportNotFoundError('日報が見つかりません');
    }

    // 2. 権限チェック
    const reportUserId = UserId.create(userId);
    if (!report.getUserId().equals(reportUserId)) {
      throw new UnauthorizedError('この日報を削除する権限がありません');
    }

    // 3. 削除
    await this.reportRepository.delete(id);
  }

  // UC-004: 日報を検索する
  async searchReports(dto: SearchReportsDto): Promise<ReportDto[]> {
    const userId = UserId.create(dto.userId);
    const startDate = dto.startDate ? ReportDate.create(dto.startDate) : undefined;
    const endDate = dto.endDate ? ReportDate.create(dto.endDate) : undefined;

    const reports = await this.reportRepository.findByUser(
      userId,
      startDate,
      endDate,
      dto.keyword
    );

    return reports.map(report => ReportDto.fromDomain(report));
  }

  // UC-007: 日報を提出する（下書きから提出）
  async submitReport(
    reportId: string,
    userId: string,
    dto?: { workEndTime?: string }
  ): Promise<{ report: ReportDto; warnings: string[] }> {
    // 1. 日報の取得
    const id = ReportId.create(reportId);
    const report = await this.reportRepository.findById(id);
    if (!report) {
      throw new ReportNotFoundError('日報が見つかりません');
    }

    // 2. 権限チェック
    const reportUserId = UserId.create(userId);
    if (!report.getUserId().equals(reportUserId)) {
      throw new UnauthorizedError('この日報を提出する権限がありません');
    }

    // 3. 勤務終了時間の更新（指定された場合）
    if (dto?.workEndTime) {
      const workEndTime = WorkEndTime.create(dto.workEndTime);
      report.update(
        report.getContent(),
        undefined,
        undefined,
        workEndTime,
        undefined,
        undefined
      );
    }

    // 4. 異常値検証
    const warnings = this.validateSubmission(report);

    // 5. 日報を提出
    report.submit();

    // 6. 永続化
    await this.reportRepository.save(report);

    // 7. DTOへの変換
    return {
      report: ReportDto.fromDomain(report),
      warnings,
    };
  }

  // UC-008: 日報を再提出する
  async resubmitReport(
    reportId: string,
    userId: string,
    dto: UpdateReportDto & { 
      workStartTime?: string;
      workEndTime?: string;
      breakTime?: number;
      additionalItems?: Array<{ title: string; description: string }>;
    }
  ): Promise<{ report: ReportDto; warnings: string[] }> {
    // 1. 日報の取得
    const id = ReportId.create(reportId);
    const report = await this.reportRepository.findById(id);
    if (!report) {
      throw new ReportNotFoundError('日報が見つかりません');
    }

    // 2. 権限チェック
    const reportUserId = UserId.create(userId);
    if (!report.getUserId().equals(reportUserId)) {
      throw new UnauthorizedError('この日報を再提出する権限がありません');
    }

    // 3. 日報が提出済みであることを確認
    // 注意: フロントエンドで確認ダイアログを表示し、「既に提出済みです。再提出を行いますか？」を確認
    // ユーザーが「再提出する」を承認した場合のみ、このメソッドが呼び出される
    if (report.getStatus().isDraft()) {
      throw new Error('下書きの日報は再提出できません。通常の提出機能を使用してください。');
    }

    // 4. 修正内容を適用
    if (dto.workContent !== undefined || dto.problemAndSolution !== undefined) {
      const content = report.getContent().update(
        dto.workContent,
        dto.problemAndSolution
      );
      report.update(content);
    }

    if (dto.workLocation) {
      const workLocation = WorkLocation.create(dto.workLocation);
      report.update(report.getContent(), workLocation);
    }

    // 5. 勤務時間の更新（変更された場合）
    const workStartTime = dto.workStartTime
      ? WorkStartTime.create(dto.workStartTime)
      : undefined;
    const workEndTime = dto.workEndTime
      ? WorkEndTime.create(dto.workEndTime)
      : undefined;
    const breakTime = dto.breakTime !== undefined
      ? BreakTime.create(dto.breakTime)
      : undefined;
    const additionalItems = dto.additionalItems
      ? dto.additionalItems.map(item => AdditionalItem.create(item.title, item.description))
      : undefined;

    if (workStartTime || workEndTime || breakTime || additionalItems) {
      report.update(
        report.getContent(),
        undefined,
        workStartTime,
        workEndTime,
        breakTime,
        additionalItems
      );
    }

    // 6. 異常値検証
    const warnings = this.validateSubmission(report);

    // 7. 日報を再提出
    report.submit();

    // 8. 永続化
    await this.reportRepository.save(report);

    // 9. 再提出通知を送信（Notification Context と連携）
    // メールに「再提出」という旨を明記
    try {
      await this.notificationService.sendReportResubmittedNotification(
        userId.getValue(),
        report.getDate().toDateString(),
        report.getId().getValue()
      );
    } catch (error) {
      // 通知送信に失敗した場合はログに記録（再提出処理は継続）
      console.error(`Failed to send resubmission notification to user ${userId.getValue()}:`, error);
    }

    // 10. DTOへの変換
    return {
      report: ReportDto.fromDomain(report),
      warnings,
    };
  }

  // 異常値検証（日付・勤務時間）
  private validateSubmission(report: Report): string[] {
    const warnings: string[] = [];
    const today = new Date();
    const reportDate = report.getDate().toDate();
    const daysDiff = Math.floor((today.getTime() - reportDate.getTime()) / (1000 * 60 * 60 * 24));

    // 日付が当日から3日以上前の場合は警告
    if (daysDiff >= 3) {
      warnings.push(`日付が${daysDiff}日前です。入力ミスの可能性があります。`);
    }

    // 勤務開始時間の異常値チェック
    const startTime = report.getWorkStartTime().toDate(reportDate);
    const startMinutes = startTime.getHours() * 60 + startTime.getMinutes();

    // 6:00以前の場合は警告
    if (startMinutes < 6 * 60) {
      warnings.push('勤務開始時間が6:00以前です。入力ミスの可能性があります。');
    }

    // 12:00以降の場合は警告
    if (startMinutes >= 12 * 60) {
      warnings.push('勤務開始時間が12:00以降です。入力ミスの可能性があります。');
    }

    // 勤務終了時間の異常値チェック
    const endTime = report.getWorkEndTime().toDate(reportDate);
    const endMinutes = endTime.getHours() * 60 + endTime.getMinutes();

    // 9:00以前の場合は警告
    if (endMinutes < 9 * 60) {
      warnings.push('勤務終了時間が9:00以前です。入力ミスの可能性があります。');
    }

    // 23:00以降の場合は警告
    if (endMinutes >= 23 * 60) {
      warnings.push('勤務終了時間が23:00以降です。入力ミスの可能性があります。');
    }

    // 実働時間の異常値チェック
    const workTime = report.calculateWorkTime();
    const workHours = workTime / 60;

    // 4時間未満の場合は警告
    if (workHours < 4) {
      warnings.push(`実働時間が${Math.round(workHours * 10) / 10}時間です。入力ミスの可能性があります。`);
    }

    // 12時間超過の場合は警告
    if (workHours > 12) {
      warnings.push(`実働時間が${Math.round(workHours * 10) / 10}時間です。入力ミスの可能性があります。`);
    }

    return warnings;
  }

  // UC-005: 日報提出状況を確認する
  async getSubmissionStatus(
    userId: string,
    startDate: Date,
    endDate: Date
  ): Promise<SubmissionStatusDto> {
    const reportUserId = UserId.create(userId);
    const start = ReportDate.create(startDate);
    const end = ReportDate.create(endDate);

    const reports = await this.reportRepository.findByUser(
      reportUserId,
      start,
      end
    );

    // 提出済み/未提出の計算（提出済みステータスの日報のみをカウント）
    const submittedDates = new Set(
      reports
        .filter(r => r.getStatus().isSubmitted())
        .map(r => r.getDate().toDateString())
    );

    // 日付範囲内のすべての日付を生成
    const allDates: Date[] = [];
    const current = new Date(startDate);
    while (current <= endDate) {
      allDates.push(new Date(current));
      current.setDate(current.getDate() + 1);
    }

    const submissionStatus = allDates.map(date => {
      const dateStr = date.toISOString().split('T')[0];
      return {
        date: dateStr,
        submitted: submittedDates.has(dateStr),
      };
    });

    const submittedCount = submissionStatus.filter(s => s.submitted).length;
    const totalCount = submissionStatus.length;
    const submissionRate = totalCount > 0 ? (submittedCount / totalCount) * 100 : 0;

    return {
      status: submissionStatus,
      submissionRate: Math.round(submissionRate * 100) / 100, // 小数点第2位まで
    };
  }

  // UC-006: 日報未提出の通知を送信する
  @Cron('0 18 * * *') // 18:00
  @Cron('30 9 * * *') // 翌日9:30
  async checkAndNotifyUnsubmittedReports(): Promise<void> {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const reportDate = ReportDate.create(yesterday);

    // 1. 全ユーザーを取得
    const users = await this.userRepository.findAll();

    for (const user of users) {
      const userId = UserId.create(user.id);

      // 2. 日報が存在し、提出済みかどうかを確認
      const report = await this.reportRepository.findByDateAndUser(
        reportDate,
        userId
      );

      // 日報が存在しない、または下書きの場合は未提出とみなす
      const isNotSubmitted = !report || report.getStatus().isDraft();

      if (isNotSubmitted) {
        // 3. 休日情報を確認（全日休の場合は通知しない）
        const leaveDays = await this.leaveRepository.findByUserAndDate(
          userId,
          reportDate
        );
        const isFullDayLeave = leaveDays.some(leave => 
          leave.isFullDayLeave() && leave.contains(reportDate)
        );

        if (!isFullDayLeave) {
          // 4. Notification Context のサービスを呼び出して通知を送信
          try {
            await this.notificationService.sendReportNotSubmittedNotification(
              userId.getValue(),
              reportDate.toDateString()
            );
          } catch (error) {
            // 通知送信に失敗した場合はログに記録（通知は継続して送信）
            console.error(`Failed to send notification to user ${userId.getValue()}:`, error);
          }
        }
      }
    }
  }
}
```

### DTO定義

```typescript
// CreateReportDto
export class CreateReportDto {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsDateString()
  @IsNotEmpty()
  date: string;

  @IsString()
  @Matches(/^([01][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: '勤務開始時間はHH:mm形式で入力してください（例: 09:30）',
  })
  @IsOptional()
  workStartTime?: string; // デフォルト: 9:30

  @IsString()
  @Matches(/^([01][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: '勤務終了時間はHH:mm形式で入力してください（例: 18:00）',
  })
  @IsOptional()
  workEndTime?: string; // デフォルト: 18:00

  @IsNumber()
  @Min(0)
  @Max(480)
  @IsOptional()
  breakTime?: number; // デフォルト: 60分

  @IsString()
  @IsNotEmpty()
  workContent: string; // 作業内容

  @IsString()
  @IsNotEmpty()
  problemAndSolution: string; // 問題とその解決策

  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => AdditionalItemDto)
  additionalItems?: AdditionalItemDto[]; // 追加項目

  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  workLocation: string;

  @IsBoolean()
  @IsOptional()
  submit?: boolean; // true: 提出、false/undefined: 下書き保存
}

// AdditionalItemDto
export class AdditionalItemDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  title: string; // 見出し

  @IsString()
  @MaxLength(1000)
  description: string; // 記述項目
}

// UpdateReportDto
export class UpdateReportDto {
  @IsString()
  @IsOptional()
  workContent?: string; // 作業内容

  @IsString()
  @IsOptional()
  problemAndSolution?: string; // 問題とその解決策

  @IsString()
  @Matches(/^([01][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: '勤務開始時間はHH:mm形式で入力してください（例: 09:30）',
  })
  @IsOptional()
  workStartTime?: string;

  @IsString()
  @Matches(/^([01][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: '勤務終了時間はHH:mm形式で入力してください（例: 18:00）',
  })
  @IsOptional()
  workEndTime?: string;

  @IsNumber()
  @Min(0)
  @Max(480)
  @IsOptional()
  breakTime?: number;

  @IsArray()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => AdditionalItemDto)
  additionalItems?: AdditionalItemDto[]; // 追加項目

  @IsString()
  @MaxLength(50)
  @IsOptional()
  workLocation?: string;
}

// SearchReportsDto
export class SearchReportsDto {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsDateString()
  @IsOptional()
  startDate?: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;

  @IsString()
  @IsOptional()
  keyword?: string;
}

// SubmitReportDto
export class SubmitReportDto {
  @IsString()
  @Matches(/^([01][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: '勤務終了時間はHH:mm形式で入力してください（例: 18:00）',
  })
  @IsOptional()
  workEndTime?: string; // 指定されない場合は既存の値をそのまま使用

  @IsString()
  @IsIn(['none', 'morning', 'afternoon'])
  @IsOptional()
  leaveType?: 'none' | 'morning' | 'afternoon'; // 休日種別（なし/午前休/午後休）

  @IsNumber()
  @Min(0)
  @Max(480)
  @IsOptional()
  travelTime?: number; // 移動時間（分単位）

  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => LateArrivalDto)
  lateArrival?: LateArrivalDto; // 遅刻情報

  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => EarlyLeaveDto)
  earlyLeave?: EarlyLeaveDto; // 早退情報
}

// LateArrivalDto
export class LateArrivalDto {
  @IsNumber()
  @Min(0)
  @Max(480)
  @IsOptional()
  minutes?: number; // 遅刻分数（分単位）

  @IsString()
  @MaxLength(500)
  @IsOptional()
  reason?: string; // 遅刻理由
}

// EarlyLeaveDto
export class EarlyLeaveDto {
  @IsNumber()
  @Min(0)
  @Max(480)
  @IsOptional()
  minutes?: number; // 早退分数（分単位）

  @IsString()
  @MaxLength(500)
  @IsOptional()
  reason?: string; // 早退理由
}

// ReportDto
export class ReportDto {
  id: string;
  userId: string;
  date: string;
  workStartTime: string;
  workEndTime: string;
  breakTime: number;
  workContent: string;
  problemAndSolution: string;
  additionalItems: Array<{ title: string; description: string }>;
  workLocation: string;
  travelTime: number | null;
  lateArrival: { minutes: number | null; reason: string | null } | null;
  earlyLeave: { minutes: number | null; reason: string | null } | null;
  status: 'draft' | 'submitted';
  createdAt: string;
  updatedAt: string;
  submittedAt: string | null;

  static fromDomain(report: Report): ReportDto {
    return {
      id: report.getId().getValue(),
      userId: report.getUserId().getValue(),
      date: report.getDate().toDateString(),
      workStartTime: report.getWorkStartTime().getValue(),
      workEndTime: report.getWorkEndTime().getValue(),
      breakTime: report.getBreakTime().getValue(),
      workContent: report.getContent().getWorkContent(),
      problemAndSolution: report.getContent().getProblemAndSolution(),
      additionalItems: report.getAdditionalItems().map(item => ({
        title: item.getTitle(),
        description: item.getDescription(),
      })),
      workLocation: report.getWorkLocation().getValue(),
      travelTime: report.getTravelTime()?.getValue() || null,
      lateArrival: report.getLateArrival() ? {
        minutes: report.getLateArrival().getMinutes(),
        reason: report.getLateArrival().getReason(),
      } : null,
      earlyLeave: report.getEarlyLeave() ? {
        minutes: report.getEarlyLeave().getMinutes(),
        reason: report.getEarlyLeave().getReason(),
      } : null,
      status: report.getStatus().getValue(),
      createdAt: report.getCreatedAt().toISOString(),
      updatedAt: report.getUpdatedAt().toISOString(),
      submittedAt: report.getSubmittedAt()?.toISOString() || null,
    };
  }
}

// SubmissionStatusDto
export class SubmissionStatusDto {
  status: Array<{
    date: string;
    submitted: boolean;
  }>;
  submissionRate: number;
}
```

---

## ステップ6: リポジトリインターフェースの定義

### IReportRepository（リポジトリインターフェース）

```typescript
// ドメイン層に定義
export interface IReportRepository {
  // 日報を保存
  save(report: Report): Promise<void>;

  // IDで日報を取得
  findById(id: ReportId): Promise<Report | null>;

  // 日付とユーザーで日報を取得（重複チェック用）
  findByDateAndUser(date: ReportDate, userId: UserId): Promise<Report | null>;

  // ユーザーの日報を検索
  findByUser(
    userId: UserId,
    startDate?: ReportDate,
    endDate?: ReportDate,
    keyword?: string
  ): Promise<Report[]>;

  // 日報を削除
  delete(id: ReportId): Promise<void>;
}
```

---

## ステップ7: インフラストラクチャ層の設計

### 7.1 データベース設計（MySQL）

#### reports テーブル

```sql
CREATE TABLE reports (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  date DATE NOT NULL,
  work_start_time VARCHAR(5) NOT NULL COMMENT 'HH:mm形式（例: 09:30）',
  work_end_time VARCHAR(5) NOT NULL COMMENT 'HH:mm形式（例: 18:00）',
  break_time INT NOT NULL COMMENT '分単位（例: 60）',
  work_content TEXT NOT NULL COMMENT '作業内容',
  problem_and_solution TEXT NOT NULL COMMENT '問題とその解決策',
  additional_items JSON COMMENT '追加項目（見出しと記述項目のペアの配列）',
  work_location VARCHAR(50) NOT NULL,
  travel_time INT COMMENT '移動時間（分単位）',
  late_arrival_minutes INT COMMENT '遅刻分数（分単位）',
  late_arrival_reason VARCHAR(500) COMMENT '遅刻理由',
  early_leave_minutes INT COMMENT '早退分数（分単位）',
  early_leave_reason VARCHAR(500) COMMENT '早退理由',
  status VARCHAR(20) NOT NULL DEFAULT 'draft' COMMENT 'draft: 下書き, submitted: 提出済み',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  submitted_at DATETIME COMMENT '提出日時',
  INDEX idx_user_date (user_id, date),
  INDEX idx_user_created (user_id, created_at),
  INDEX idx_user_status (user_id, status),
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE KEY unique_user_date (user_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### work_location_candidates テーブル

```sql
CREATE TABLE work_location_candidates (
  id VARCHAR(36) PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  location VARCHAR(50) NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  INDEX idx_user (user_id),
  UNIQUE KEY uk_user_location (user_id, location),
  FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**備考:**
- デフォルト候補（飯田橋、自宅）はシステム共通のため、テーブルには保存しない
- ユーザーが追加した勤務地候補のみをテーブルに保存
- 表示順序（display_order）で候補の並び順を管理

### 7.2 リポジトリ実装（TypeORM）

```typescript
// ReportEntity (TypeORM)
@Entity('reports')
export class ReportEntity {
  @PrimaryColumn('varchar', { length: 36 })
  id: string;

  @Column('varchar', { length: 36 })
  userId: string;

  @Column('date')
  date: Date;

  @Column('text')
  businessContent: string;

  @Column('text', { nullable: true })
  achievements: string | null;

  @Column('text', { nullable: true })
  challenges: string | null;

  @Column('text', { nullable: true })
  nextDayPlan: string | null;

  @Column('varchar', { length: 20 })
  workLocation: string;

  @Column('varchar', { length: 20, default: 'draft' })
  status: 'draft' | 'submitted';

  @Column('varchar', { length: 5, nullable: true })
  clockOutTime: string | null;

  @Column('datetime')
  createdAt: Date;

  @Column('datetime')
  updatedAt: Date;

  @Column('datetime', { nullable: true })
  submittedAt: Date | null;

  // ドメインオブジェクトへの変換
  toDomain(): Report {
    return Report.reconstruct(
      ReportId.create(this.id),
      UserId.create(this.userId),
      ReportDate.create(this.date),
      ReportContent.create(
        this.businessContent,
        this.achievements || undefined,
        this.challenges || undefined,
        this.nextDayPlan || undefined
      ),
      WorkLocation.create(this.workLocation),
      this.status === 'draft' ? ReportStatus.draft() : ReportStatus.submitted(),
      this.clockOutTime ? ClockOutTime.create(this.clockOutTime) : null,
      this.createdAt,
      this.updatedAt,
      this.submittedAt
    );
  }

  // ドメインオブジェクトからの変換
  static fromDomain(report: Report): ReportEntity {
    const entity = new ReportEntity();
    entity.id = report.getId().getValue();
    entity.userId = report.getUserId().getValue();
    entity.date = report.getDate().toDate();
    entity.businessContent = report.getContent().getBusinessContent();
    entity.achievements = report.getContent().getAchievements() || null;
    entity.challenges = report.getContent().getChallenges() || null;
    entity.nextDayPlan = report.getContent().getNextDayPlan() || null;
    entity.workLocation = report.getWorkLocation().getValue();
    entity.status = report.getStatus().getValue();
    entity.clockOutTime = report.getClockOutTime()?.getValue() || null;
    entity.createdAt = report.getCreatedAt();
    entity.updatedAt = report.getUpdatedAt();
    entity.submittedAt = report.getSubmittedAt() || null;
    return entity;
  }
}

// ReportRepository (実装)
@Injectable()
export class ReportRepository implements IReportRepository {
  constructor(
    @InjectRepository(ReportEntity)
    private readonly typeOrmRepository: Repository<ReportEntity>,
  ) {}

  async save(report: Report): Promise<void> {
    const entity = ReportEntity.fromDomain(report);
    await this.typeOrmRepository.save(entity);
  }

  async findById(id: ReportId): Promise<Report | null> {
    const entity = await this.typeOrmRepository.findOne({
      where: { id: id.getValue() },
    });
    return entity ? entity.toDomain() : null;
  }

  async findByDateAndUser(
    date: ReportDate,
    userId: UserId
  ): Promise<Report | null> {
    const entity = await this.typeOrmRepository.findOne({
      where: {
        date: date.toDate(),
        userId: userId.getValue(),
      },
    });
    return entity ? entity.toDomain() : null;
  }

  async findByUser(
    userId: UserId,
    startDate?: ReportDate,
    endDate?: ReportDate,
    keyword?: string
  ): Promise<Report[]> {
    const queryBuilder = this.typeOrmRepository
      .createQueryBuilder('report')
      .where('report.userId = :userId', { userId: userId.getValue() });

    if (startDate) {
      queryBuilder.andWhere('report.date >= :startDate', {
        startDate: startDate.toDate(),
      });
    }

    if (endDate) {
      queryBuilder.andWhere('report.date <= :endDate', {
        endDate: endDate.toDate(),
      });
    }

    if (keyword) {
      queryBuilder.andWhere(
        '(report.businessContent LIKE :keyword OR report.achievements LIKE :keyword OR report.challenges LIKE :keyword OR report.nextDayPlan LIKE :keyword)',
        { keyword: `%${keyword}%` }
      );
    }

    queryBuilder.orderBy('report.date', 'DESC');

    const entities = await queryBuilder.getMany();
    return entities.map(entity => entity.toDomain());
  }

  async delete(id: ReportId): Promise<void> {
    await this.typeOrmRepository.delete(id.getValue());
  }
}
```

### 7.3 コントローラー（プレゼンテーション層）

```typescript
@Controller('reports')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async createReport(
    @Body() dto: CreateReportDto,
    @Request() req: any
  ): Promise<ReportDto> {
    // 認証済みユーザーのIDを使用
    dto.userId = req.user.id;
    return await this.reportService.createReport(dto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  async updateReport(
    @Param('id') id: string,
    @Body() dto: UpdateReportDto,
    @Request() req: any
  ): Promise<ReportDto> {
    return await this.reportService.updateReport(id, req.user.id, dto);
  }

  @Post(':id/submit')
  @UseGuards(JwtAuthGuard)
  async submitReport(
    @Param('id') id: string,
    @Body() dto: SubmitReportDto,
    @Request() req: any
  ): Promise<{ report: ReportDto; warnings: string[] }> {
    return await this.reportService.submitReport(id, req.user.id, dto.clockOutTime);
  }

  @Post(':id/resubmit')
  @UseGuards(JwtAuthGuard)
  async resubmitReport(
    @Param('id') id: string,
    @Body() dto: UpdateReportDto & { clockOutTime?: string },
    @Request() req: any
  ): Promise<{ report: ReportDto; warnings: string[] }> {
    return await this.reportService.resubmitReport(id, req.user.id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async deleteReport(
    @Param('id') id: string,
    @Request() req: any
  ): Promise<void> {
    return await this.reportService.deleteReport(id, req.user.id);
  }

  @Get('search')
  @UseGuards(JwtAuthGuard)
  async searchReports(
    @Query() dto: SearchReportsDto,
    @Request() req: any
  ): Promise<ReportDto[]> {
    dto.userId = req.user.id;
    return await this.reportService.searchReports(dto);
  }

  @Get('submission-status')
  @UseGuards(JwtAuthGuard)
  async getSubmissionStatus(
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
    @Request() req: any
  ): Promise<SubmissionStatusDto> {
    return await this.reportService.getSubmissionStatus(
      req.user.id,
      new Date(startDate),
      new Date(endDate)
    );
  }
}
```

---

## ステップ8: 設計の検証

### 8.1 ドメインの目的との整合性確認

- ✅ **目的**: ユーザーが日々の業務記録を日報として必ず提出できるようにし、業務記録を残す習慣を確立する。また、日報提出によって勤怠管理（勤務時間などの記録）を実現する
  - 日報作成機能で業務記録を定時に下書きとして作成できる ✅
  - 退勤時提出機能で退勤時間を記録し、日報を提出できる ✅
  - 日付・時間の入力ミス防止機能で入力ミスを防ぎ、正確な業務記録を残せる ✅
  - 日報の再提出機能で間違えて提出した日報を修正できる ✅
  - 日報提出によって勤怠管理（勤務時間などの記録）ができる ✅
  - 提出状況トラッキングで提出状況を可視化し、未提出を防ぐ ✅
  - 日報未提出の通知機能で未提出を検知して通知を送信し、習慣化を支援する ✅
  - 日報提出の習慣化を支援する機能が実装されている ✅

- ✅ **ビジョン**: ストレスなく日報を作成・提出でき、日報提出が習慣化される。日報提出によって勤怠管理ができる
  - シンプルなUI設計で実現可能 ✅
  - 必須項目を最小限に ✅
  - 提出状況の可視化で習慣化を支援 ✅
  - 勤怠管理の記録機能が実装されている ✅

- ✅ **成功指標**: 日報提出率90%以上、作成時間5分以内、連続提出日数の向上
  - 提出状況トラッキング機能で提出率を測定できる ✅
  - シンプルな設計で作成時間を短縮できる ✅
  - 提出状況の可視化で連続提出日数を追跡できる ✅

### 8.2 要件との整合性確認

- ✅ **AC-002-1: 日報作成**
  - 日付のバリデーション（形式、重複チェック、未来日付チェック） ✅
  - 日報の保存 ✅
  - 送信完了通知（コントローラーで実装） ✅
  - 勤務地の記録 ✅

- ✅ **AC-002-3: 日報履歴検索**（将来拡張、P2）
  - 日付範囲での検索 ✅（将来拡張）
  - キーワードでの検索 ✅（将来拡張）

- ✅ **AC-002-4: 日報提出状況トラッキング**
  - 提出済み/未提出の表示 ✅
  - 提出率の計算 ✅

- ✅ **AC-008-1: 日報未提出アラート**
  - 指定時刻（18:00と翌日9:30）に通知が送信される ✅
  - ユーザーに通知が届く ✅
  - 通知内容が適切である ✅
  - 休日が登録されている場合（全日休など）は通知を送信しない ✅
  - 午前休・午後休の場合は通知を送信する ✅
  - 休日登録情報を参照して、通知送信の判定を行う ✅

### 8.3 ビジネスルールの実装確認

- ✅ 同じ日付の日報は1つだけ存在できる（`findByDateAndUser`でチェック、重複不可、ただし再提出は可能） ✅
  - 新しい日報を作成する際は、同じ日付の日報が既に存在する場合はエラー
  - 既存の日報を編集・再提出することは可能（`updateReport`、`resubmitReport`を使用）
- ✅ 未来日付の日報は作成できない（`ReportDate`でバリデーション） ✅
- ✅ 日付の形式はYYYY-MM-DD形式（`ReportDate`で管理） ✅
- ✅ 無効な日付は入力できない（`ReportDate`でバリデーション） ✅

### 8.4 設計の一貫性確認

- ✅ レイヤードアーキテクチャの遵守 ✅
- ✅ ドメイン層の独立性（他の層に依存しない） ✅
- ✅ 値オブジェクトの不変性 ✅
- ✅ 集約の不変条件の実装 ✅

---

## 実装の優先順位

### Phase 3（MVP - コア機能）

1. **US-002-1: 日報作成機能**（P0、5ポイント）
   - Report エンティティの実装
   - 値オブジェクトの実装
   - ReportService の実装
   - ReportRepository の実装
   - ReportController の実装

2. **FR-002-9: 退勤時提出機能**（P0、2ポイント）
   - ReportService に提出メソッド（submitReport）を実装
   - 退勤時間を記録する機能を実装
   - コントローラーに提出エンドポイントを追加

3. **FR-002-10: 日付・時間の入力ミス防止機能**（P0、2ポイント）
   - 異常値検証メソッド（validateSubmission）を実装
   - 日付が3日以上前の場合の警告
   - 退勤時間が9:00以前/23:00以降の場合の警告
   - フロントエンドで確認ダイアログを実装

4. **FR-002-11: 日報の再提出機能**（P0、2ポイント）
   - ReportService に再提出メソッド（resubmitReport）を実装
   - 提出済みの日報を修正して再提出
   - コントローラーに再提出エンドポイントを追加

5. **FR-002-8: 日報未提出の通知機能**（P0、3ポイント）
   - ReportService に定期実行メソッド（checkAndNotifyUnsubmittedReports）を実装
   - Notification Context のサービスを呼び出す連携を実装
   - Leave Context の休日情報を参照する連携を実装
   - @Cron デコレータまたは AWS EventBridge + Lambda で定期実行を設定

4. **US-002-4: 日報提出状況トラッキング機能**（P1、2ポイント）
   - 提出状況計算機能の実装

### 将来拡張（Phase 5以降）

- **US-002-2: 日報テンプレート編集機能**（P2、3ポイント）
- **US-002-3: 日報履歴検索機能**（P2、3ポイント）
- コメント機能
- チーム共有機能

---

## 次のステップ

1. **実装の開始**
   - ドメイン層（エンティティ、値オブジェクト）の実装
   - アプリケーション層（サービス、DTO）の実装
   - インフラストラクチャ層（リポジトリ、エンティティ）の実装
   - プレゼンテーション層（コントローラー）の実装

2. **テストの作成**
   - ドメインロジックのユニットテスト
   - アプリケーションサービスの統合テスト
   - コントローラーのE2Eテスト

3. **設計の継続的な改善**
   - 実装を通じて設計を改善
   - ドメインエキスパートとの対話を継続

---

※ 本ドキュメントは設計の初期版です。実装を進めながら随時更新してください。

