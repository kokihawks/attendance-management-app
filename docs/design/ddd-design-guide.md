# ドメイン駆動設計（DDD）設計ガイド

## 概要

本ドキュメントは、エイ・フォース勤怠管理アプリの開発において、ドメイン駆動設計（Domain-Driven Design, DDD）に基づいて設計を行うための手順とベストプラクティスを説明します。

## 目次

1. [DDDの基本概念](#1-dddの基本概念)
2. [設計手順（ステップバイステップ）](#2-設計手順ステップバイステップ)
3. [各ステップの詳細](#3-各ステップの詳細)
   - [ステップ0: 最上位のドメインの目的を設定](#ステップ0-最上位のドメインの目的を設定)
   - [ステップ1: ドメイン分析](#ステップ1-ドメイン分析)
   - [ステップ2: 境界づけられたコンテキストの特定](#ステップ2-境界づけられたコンテキストbounded-contextの特定)
   - [ステップ3: ドメインモデルの設計](#ステップ3-ドメインモデルの設計)
   - [ステップ4〜8: 実装と検証](#ステップ4-ユースケースの定義)
4. [Nest.jsでの実装パターン](#4-nestjsでの実装パターン)
5. [ベストプラクティス](#5-ベストプラクティス)
6. [このプロジェクトへの適用例](#6-このプロジェクトへの適用例)

---

## 1. DDDの基本概念

### 1.1 主要な用語

| 用語 | 説明 |
|------|------|
| **ドメイン** | ビジネスの問題領域（例: 勤怠管理、日報管理） |
| **ドメインモデル** | ドメインの概念を表現するモデル |
| **エンティティ** | 一意の識別子を持つオブジェクト（例: User, Report） |
| **値オブジェクト** | 識別子を持たず、値によって識別されるオブジェクト（例: Email, DateRange） |
| **集約（Aggregate）** | 整合性の境界を持つエンティティのグループ |
| **集約ルート** | 集約の外部からアクセスする際の唯一のエントリーポイント |
| **リポジトリ** | 集約の永続化を担当するインターフェース |
| **ドメインサービス** | 単一のエンティティに属さないビジネスロジック |
| **ユースケース** | アプリケーションの具体的な操作（例: 日報を作成する） |
| **アプリケーションサービス** | ユースケースを実現するサービス層 |

### 1.2 レイヤードアーキテクチャ

```
┌─────────────────────────────────────┐
│   Presentation Layer (Controller)   │  ← API エンドポイント、DTO変換
├─────────────────────────────────────┤
│  Application Layer (Service)        │  ← ユースケース実装、トランザクション管理
├─────────────────────────────────────┤
│     Domain Layer (Core)            │  ← エンティティ、値オブジェクト、ドメインサービス
├─────────────────────────────────────┤
│  Infrastructure Layer (Repository) │  ← データアクセス、外部サービス連携
└─────────────────────────────────────┘
```

---

## 2. 設計手順（ステップバイステップ）

### 全体フロー

```
0. 最上位のドメインの目的を設定
   ↓
1. ドメイン分析
   ↓
2. 境界づけられたコンテキスト（Bounded Context）の特定
   ↓
3. ドメインモデルの設計
   ├─ 3-1. エンティティの特定
   ├─ 3-2. 値オブジェクトの特定
   ├─ 3-3. 集約の設計
   └─ 3-4. ドメインサービスの特定
   ↓
4. ユースケースの定義
   ↓
5. アプリケーションサービスの設計
   ↓
6. リポジトリインターフェースの定義
   ↓
7. インフラストラクチャ層の実装
   ↓
8. 設計の検証とリファクタリング
```

---

## 3. 各ステップの詳細

### ステップ0: 最上位のドメインの目的を設定

#### 目的
ドメイン全体の目的、ビジョン、価値提案を明確にし、その後の設計判断の指針とする。

#### なぜ重要か
- **設計の一貫性**: すべての設計判断がドメインの目的に沿っていることを保証
- **優先順位の明確化**: 機能の優先順位を判断する基準となる
- **チームの共通理解**: 開発チーム全体でドメインの目的を共有
- **技術的負債の回避**: 目的から外れた実装を早期に発見

#### 作業内容

1. **ドメインの目的を定義**
   - このドメインが解決する問題は何か？
   - このドメインが提供する価値は何か？
   - このドメインが達成すべき目標は何か？

2. **ドメインのビジョンを定義**
   - 理想的な状態はどのようなものか？
   - ユーザーにとっての理想的な体験は何か？

3. **成功指標を定義**
   - ドメインの目的が達成されたと判断する基準は何か？
   - どのような指標で成功を測るか？

4. **制約条件を明確化**
   - 技術的制約
   - ビジネス制約
   - 法的・規制上の制約

#### このプロジェクトでの例

##### 全体ドメイン: 勤怠管理

**目的:**
日報作成や勤務表記入などの日常業務を一元化し、情報共有と業務効率の向上を実現する。

**ビジョン:**
- ユーザーがストレスなく日常業務を記録・管理できる
- チーム全体で情報を共有し、協働を促進する
- データを活用して業務改善につなげる

**成功指標:**
- 日報・勤務表の提出率向上
- 業務時間の削減
- 情報共有の促進

**制約条件:**
- 個人利用から段階的に展開（スモールスタート）
- 小規模チームでの開発・運用
- AWS環境での運用

##### 各サブドメインの目的例

**Reports Context（日報管理）の目的:**
ユーザーが日々の業務内容を記録し、チームと共有することで、業務の可視化と振り返りを促進する。

**Attendance Context（勤務表管理）の目的:**
ユーザーが勤務時間を正確に記録し、月次で集計・提出することで、勤怠管理の効率化を実現する。

**Leave Context（休日登録）の目的:**
ユーザーが休日を登録し、自動的に勤務表に反映することで、休日管理の手間を削減する。

#### 成果物

- **ドメイン目的書**: 各ドメインの目的、ビジョン、成功指標を記載したドキュメント
- **制約条件一覧**: 技術的・ビジネス的な制約条件のリスト

#### テンプレート

```markdown
# [ドメイン名] の目的

## 目的
[このドメインが解決する問題と提供する価値]

## ビジョン
[理想的な状態とユーザー体験]

## 成功指標
- [指標1]: [目標値]
- [指標2]: [目標値]

## 制約条件
- [制約1]: [説明]
- [制約2]: [説明]

## 主要な価値提案
1. [価値提案1]
2. [価値提案2]
```

---

### ステップ1: ドメイン分析

#### 目的
ビジネス要件から、ドメインの概念とルールを理解する。**ステップ0で設定したドメインの目的を常に参照しながら進める。**

#### 作業内容

1. **ドメインの目的を確認**
   - ステップ0で設定したドメインの目的を確認
   - 各設計判断が目的に沿っているか検証

2. **要件定義書の確認**
   - [プロダクト要件定義書](../requirements/product-requirements.md)を確認
   - [受け入れ基準](../requirements/acceptance-criteria.md)を確認
   - [プロダクトバックログ](../requirements/product-backlog.md)を確認
   - **要件がドメインの目的に合致しているか確認**

3. **ドメインエキスパートとの対話（可能な場合）**
   - ビジネスルールの確認
   - 用語の統一（ユビキタス言語の確立）
   - **ドメインの目的について合意を得る**

4. **ドメインの特定**
   - 主要なドメインをリストアップ
   - 各ドメインの責務を明確化
   - **各ドメインが全体の目的にどう貢献するか確認**

#### このプロジェクトでの例

```
主要ドメイン:
- 認証・認可（Auth）
- 日報管理（Reports）
- 勤務表管理（Attendance）
- 休日登録（Leave）
- アイデア共有（Ideas）
- スケジュール集約（Schedule）
- 通知（Notification）
```

#### 成果物
- ドメイン一覧
- 各ドメインの責務定義

---

### ステップ2: 境界づけられたコンテキスト（Bounded Context）の特定

#### 目的
ドメインを独立したコンテキストに分割し、各コンテキストの境界を明確にする。

#### 作業内容

1. **コンテキストの分割**
   - 各ドメインを独立したコンテキストとして扱う
   - コンテキスト間の関係を整理

2. **共有カーネルの特定**
   - 複数のコンテキストで共有する概念（例: User, DateRange）

3. **コンテキストマップの作成**
   - コンテキスト間の関係を図示

#### このプロジェクトでの例

```
Bounded Context:
- Auth Context（認証・認可）
- Reports Context（日報管理）
- Attendance Context（勤務表管理）
- Leave Context（休日登録）
- Ideas Context（アイデア共有）
- Schedule Context（スケジュール集約）
- Notification Context（通知）

共有カーネル:
- User（ユーザー）
- DateRange（日付範囲）
- Email（メールアドレス）
```

#### 成果物
- コンテキストマップ
- 共有カーネル定義

---

### ステップ3: ドメインモデルの設計

#### 3-1. エンティティの特定

##### 目的
一意の識別子を持つドメインオブジェクトを特定する。

##### 判断基準
- 識別子（ID）を持つ
- ライフサイクルがある（作成、更新、削除）
- 状態が変わる可能性がある

##### 作業内容

1. **名詞の抽出**
   - 要件定義書から名詞を抽出
   - ビジネス上重要な概念を特定

2. **エンティティの定義**
   - 識別子の定義
   - 属性の定義
   - ビジネスルールの定義

##### このプロジェクトでの例（Reports Context）

```typescript
// エンティティ: Report（日報）
class Report {
  private id: ReportId;           // 識別子（値オブジェクト）
  private userId: UserId;         // 作成者ID
  private date: ReportDate;       // 日付（値オブジェクト）
  private content: ReportContent; // 内容（値オブジェクト）
  private workLocation: WorkLocation; // 勤務地（値オブジェクト）
  private createdAt: Date;
  private updatedAt: Date;

  // ビジネスルール: 同じ日付の日報は重複できない
  public static create(
    userId: UserId,
    date: ReportDate,
    content: ReportContent,
    workLocation: WorkLocation
  ): Report {
    // バリデーションロジック
    return new Report(...);
  }

  // ビジネスロジック: 日報の更新
  public update(content: ReportContent): void {
    this.content = content;
    this.updatedAt = new Date();
  }
}
```

##### 成果物
- エンティティ一覧
- 各エンティティの属性とメソッド定義

---

#### 3-2. 値オブジェクトの特定

##### 目的
識別子を持たず、値によって識別されるオブジェクトを特定する。

##### 判断基準
- 識別子を持たない
- 不変（Immutable）
- 値の等価性で比較される
- 自己完結した意味を持つ

##### 作業内容

1. **値オブジェクトの候補を特定**
   - エンティティの属性から値オブジェクトを抽出
   - ビジネスルールが含まれる属性を値オブジェクト化

2. **値オブジェクトの設計**
   - 不変性の保証
   - バリデーションロジックの実装

##### このプロジェクトでの例

```typescript
// 値オブジェクト: ReportDate（日報日付）
class ReportDate {
  private readonly value: Date;

  private constructor(date: Date) {
    // ビジネスルール: 未来日付は許可しない
    if (date > new Date()) {
      throw new Error('未来日付の日報は作成できません');
    }
    this.value = date;
  }

  public static create(date: Date): ReportDate {
    return new ReportDate(date);
  }

  public equals(other: ReportDate): boolean {
    return this.value.getTime() === other.value.getTime();
  }

  public toDate(): Date {
    return new Date(this.value);
  }
}

// 値オブジェクト: WorkLocation（勤務地）
class WorkLocation {
  private readonly value: '飯田橋' | '客先常駐' | '自宅' | 'その他';

  private constructor(value: string) {
    if (!['飯田橋', '客先常駐', '自宅', 'その他'].includes(value)) {
      throw new Error('無効な勤務地です');
    }
    this.value = value as any;
  }

  public static create(value: string): WorkLocation {
    return new WorkLocation(value);
  }

  public getValue(): string {
    return this.value;
  }
}
```

##### 成果物
- 値オブジェクト一覧
- 各値オブジェクトのバリデーションルール

---

#### 3-3. 集約の設計

##### 目的
整合性の境界を持つエンティティのグループを設計する。

##### 判断基準
- トランザクションの境界
- 整合性を保つ必要があるエンティティのグループ
- 外部からは集約ルートのみを経由してアクセス

##### 作業内容

1. **集約の特定**
   - 関連するエンティティをグループ化
   - 整合性の境界を決定

2. **集約ルートの特定**
   - 集約の外部からアクセスする際のエントリーポイント

3. **不変条件の定義**
   - 集約内で常に満たすべき条件

##### このプロジェクトでの例（Reports Context）

```typescript
// 集約ルート: Report（日報）
class Report {
  private id: ReportId;
  private userId: UserId;
  private date: ReportDate;
  private content: ReportContent;
  private workLocation: WorkLocation;
  private comments: Comment[]; // 子エンティティ

  // 不変条件: 同じ日付の日報は1つだけ存在する
  // 不変条件: コメントは削除のみ可能（編集不可）

  public addComment(comment: Comment): void {
    this.comments.push(comment);
  }

  public removeComment(commentId: CommentId): void {
    this.comments = this.comments.filter(c => !c.id.equals(commentId));
  }
}
```

##### 成果物
- 集約一覧
- 各集約の不変条件
- 集約ルートの定義

---

#### 3-4. ドメインサービスの特定

##### 目的
単一のエンティティに属さないビジネスロジックを特定する。

##### 判断基準
- 複数のエンティティにまたがるロジック
- エンティティに配置すると不自然なロジック
- ステートレスな操作

##### 作業内容

1. **ドメインサービスの候補を特定**
   - エンティティに配置できないロジックを抽出

2. **ドメインサービスの設計**
   - ステートレスなメソッドとして実装

##### このプロジェクトでの例

```typescript
// ドメインサービス: ReportSubmissionService
class ReportSubmissionService {
  // 複数のエンティティにまたがるロジック: 日報提出状況の判定
  public isSubmissionRequired(
    date: ReportDate,
    leaveDays: LeaveDay[]
  ): boolean {
    // 休日が登録されている場合は提出不要
    const isLeaveDay = leaveDays.some(leave => 
      leave.contains(date)
    );
    return !isLeaveDay;
  }
}
```

##### 成果物
- ドメインサービス一覧
- 各ドメインサービスの責務定義

---

### ステップ4: ユースケースの定義

#### 目的
アプリケーションが提供する具体的な操作を定義する。

#### 作業内容

1. **ユースケースの抽出**
   - [受け入れ基準](../requirements/acceptance-criteria.md)から抽出
   - [プロダクトバックログ](../requirements/product-backlog.md)から抽出

2. **ユースケースの記述**
   - 入力（Input）
   - 出力（Output）
   - 前提条件（Preconditions）
   - 事後条件（Postconditions）

#### このプロジェクトでの例

```
ユースケース: 日報を作成する

入力:
- userId: UserId
- date: Date
- content: ReportContent
- workLocation: WorkLocation

出力:
- reportId: ReportId

前提条件:
- ユーザーがログインしている
- 同じ日付の日報が存在しない

事後条件:
- 新しい日報が作成される
- 日報がデータベースに保存される
```

#### 成果物
- ユースケース一覧
- 各ユースケースの詳細定義

---

### ステップ5: アプリケーションサービスの設計

#### 目的
ユースケースを実現するサービス層を設計する。

#### 作業内容

1. **アプリケーションサービスの定義**
   - 各ユースケースに対応するメソッドを定義
   - トランザクション管理
   - ドメインオブジェクトの協調

2. **DTOの定義**
   - 入力DTO（Request DTO）
   - 出力DTO（Response DTO）

#### このプロジェクトでの例（Nest.js）

```typescript
// アプリケーションサービス: ReportService
@Injectable()
export class ReportService {
  constructor(
    private readonly reportRepository: IReportRepository,
    private readonly leaveRepository: ILeaveRepository,
    private readonly reportSubmissionService: ReportSubmissionService,
  ) {}

  // ユースケース: 日報を作成する
  async createReport(dto: CreateReportDto): Promise<ReportDto> {
    // 1. ドメインオブジェクトの作成
    const reportDate = ReportDate.create(new Date(dto.date));
    const content = ReportContent.create(dto.content);
    const workLocation = WorkLocation.create(dto.workLocation);

    // 2. ビジネスルールのチェック
    const existingReport = await this.reportRepository.findByDateAndUser(
      reportDate,
      dto.userId
    );
    if (existingReport) {
      throw new DuplicateReportError('同じ日付の日報が既に存在します');
    }

    // 3. ドメインオブジェクトの作成
    const report = Report.create(
      dto.userId,
      reportDate,
      content,
      workLocation
    );

    // 4. 永続化
    await this.reportRepository.save(report);

    // 5. DTOへの変換
    return ReportDto.fromDomain(report);
  }
}
```

#### 成果物
- アプリケーションサービス一覧
- 各サービスのメソッド定義
- DTO定義

---

### ステップ6: リポジトリインターフェースの定義

#### 目的
集約の永続化を担当するインターフェースを定義する。

#### 作業内容

1. **リポジトリインターフェースの定義**
   - ドメイン層にインターフェースを定義
   - 集約ルートを操作するメソッドを定義

2. **クエリメソッドの定義**
   - 必要な検索条件を定義

#### このプロジェクトでの例

```typescript
// リポジトリインターフェース（ドメイン層）
export interface IReportRepository {
  save(report: Report): Promise<void>;
  findById(id: ReportId): Promise<Report | null>;
  findByDateAndUser(date: ReportDate, userId: UserId): Promise<Report | null>;
  findByUser(userId: UserId, startDate: Date, endDate: Date): Promise<Report[]>;
  delete(id: ReportId): Promise<void>;
}
```

#### 成果物
- リポジトリインターフェース一覧
- 各インターフェースのメソッド定義

---

### ステップ7: インフラストラクチャ層の実装

#### 目的
リポジトリインターフェースの実装と外部サービス連携を実装する。

#### 作業内容

1. **リポジトリの実装**
   - TypeORM/Prisma を使用した実装
   - ドメインオブジェクトとDBエンティティの変換

2. **外部サービス連携の実装**
   - Adapter パターンで実装
   - インターフェースに依存

#### このプロジェクトでの例（Nest.js + TypeORM）

```typescript
// リポジトリ実装（インフラストラクチャ層）
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

  // ... 他のメソッド
}
```

#### 成果物
- リポジトリ実装
- 外部サービス連携実装

---

### ステップ8: 設計の検証とリファクタリング

#### 目的
設計が要件を満たしているか検証し、必要に応じてリファクタリングする。

#### 作業内容

1. **設計レビュー**
   - **ドメインの目的に沿っているか**（ステップ0で設定した目的を参照）
   - ドメインモデルが要件を反映しているか
   - ビジネスルールが正しく実装されているか
   - 設計判断が一貫しているか

2. **テストの作成**
   - ドメインロジックのユニットテスト
   - アプリケーションサービスの統合テスト

3. **リファクタリング**
   - 設計の改善
   - コードの整理

#### 成果物
- テストコード
- リファクタリング後の設計

---

## 4. Nest.jsでの実装パターン

### 4.1 ディレクトリ構造

```
apps/backend/src/
├── modules/
│   └── reports/
│       ├── domain/                    # ドメイン層
│       │   ├── entities/
│       │   │   └── report.entity.ts
│       │   ├── value-objects/
│       │   │   ├── report-date.vo.ts
│       │   │   └── work-location.vo.ts
│       │   ├── services/
│       │   │   └── report-submission.service.ts
│       │   └── repositories/
│       │       └── report.repository.interface.ts
│       ├── application/               # アプリケーション層
│       │   ├── services/
│       │   │   └── report.service.ts
│       │   └── dto/
│       │       ├── create-report.dto.ts
│       │       └── report.dto.ts
│       ├── infrastructure/           # インフラストラクチャ層
│       │   ├── repositories/
│       │   │   └── report.repository.ts
│       │   └── entities/
│       │       └── report.entity.ts (TypeORM)
│       └── presentation/             # プレゼンテーション層
│           ├── controllers/
│           │   └── report.controller.ts
│           └── validators/
│               └── create-report.validator.ts
│       └── reports.module.ts
```

### 4.2 依存関係の方向

```
Presentation → Application → Domain ← Infrastructure
```

- **Domain層**: 他の層に依存しない（最下層）
- **Application層**: Domain層にのみ依存
- **Infrastructure層**: Domain層にのみ依存（インターフェースを実装）
- **Presentation層**: Application層とDomain層に依存

### 4.3 モジュールの構成

```typescript
// reports.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([ReportEntity])],
  controllers: [ReportController],
  providers: [
    // アプリケーションサービス
    ReportService,
    // ドメインサービス
    ReportSubmissionService,
    // リポジトリ実装
    {
      provide: 'IReportRepository',
      useClass: ReportRepository,
    },
  ],
  exports: [ReportService],
})
export class ReportsModule {}
```

---

## 5. ベストプラクティス

### 5.0 ドメインの目的設定

- ✅ **最初に目的を設定**: 詳細設計に入る前に、必ずドメインの目的を明確にする
- ✅ **目的を常に参照**: 各設計判断の際に、目的に沿っているか確認する
- ✅ **目的を文書化**: ドメインの目的、ビジョン、成功指標をドキュメント化する
- ✅ **目的の見直し**: 定期的に目的を見直し、必要に応じて更新する
- ✅ **チームで共有**: 開発チーム全体でドメインの目的を共有し、共通理解を深める

### 5.1 ドメインモデルの設計

- ✅ **エンティティは薄く保つ**: ビジネスロジックのみを含める
- ✅ **値オブジェクトを積極的に使用**: プリミティブ型の代わりに値オブジェクトを使用
- ✅ **不変性を保つ**: 値オブジェクトは不変（Immutable）にする
- ✅ **集約は小さく保つ**: 1つの集約に含めるエンティティは最小限に
- ✅ **不変条件を明確に**: 集約の不変条件をドキュメント化

### 5.2 アプリケーションサービスの設計

- ✅ **トランザクション境界を明確に**: 1つのユースケース = 1つのトランザクション
- ✅ **ドメインロジックをアプリケーションサービスに書かない**: ドメインロジックはドメイン層に
- ✅ **DTO変換を明確に**: ドメインオブジェクトとDTOの変換を明確に分離

### 5.3 リポジトリの設計

- ✅ **インターフェースはドメイン層に**: リポジトリインターフェースはドメイン層に定義
- ✅ **実装はインフラストラクチャ層に**: リポジトリ実装はインフラストラクチャ層に
- ✅ **集約ルートのみを操作**: リポジトリは集約ルートのみを操作

### 5.4 テスト戦略

- ✅ **ドメインロジックのユニットテスト**: エンティティ、値オブジェクト、ドメインサービスのテスト
- ✅ **アプリケーションサービスの統合テスト**: ユースケースのテスト
- ✅ **モックの使用**: リポジトリはモックを使用してテスト

---

## 6. このプロジェクトへの適用例

### 6.1 Reports Context（日報管理）の設計例

#### ステップ0: 最上位のドメインの目的を設定

**Reports Context（日報管理）の目的:**

```markdown
# Reports Context（日報管理）の目的

## 目的
ユーザーが日々の業務内容を記録し、チームと共有することで、業務の可視化と振り返りを促進する。

## ビジョン
- ユーザーがストレスなく日報を作成できる
- チーム全体で業務内容を共有し、協働を促進する
- 過去の日報を振り返り、業務改善につなげる

## 成功指標
- 日報提出率: 90%以上
- 日報作成時間: 5分以内
- チーム内での情報共有促進

## 制約条件
- 個人利用から段階的に展開
- 同じ日付の日報は1つだけ存在できる
- 未来日付の日報は作成できない

## 主要な価値提案
1. 日々の業務内容を簡単に記録できる
2. チーム全体で業務内容を共有できる
3. 過去の日報を検索・振り返りできる
```

#### ステップ1: ドメイン分析

**主要な概念:**
- 日報（Report）
- 日報日付（ReportDate）
- 日報内容（ReportContent）
- 勤務地（WorkLocation）
- コメント（Comment）

**ビジネスルール:**
- 同じ日付の日報は1つだけ存在できる
- 未来日付の日報は作成できない
- 日報は削除のみ可能（編集は可能）

#### ステップ2: エンティティと値オブジェクトの特定

**エンティティ:**
- `Report`（日報）
- `Comment`（コメント）

**値オブジェクト:**
- `ReportId`（日報ID）
- `ReportDate`（日報日付）
- `ReportContent`（日報内容）
- `WorkLocation`（勤務地）
- `UserId`（ユーザーID）

#### ステップ3: 集約の設計

**集約:**
- `Report`（集約ルート）
  - `Comment[]`（子エンティティ）

**不変条件:**
- 同じ日付の日報は1つだけ存在する
- コメントは削除のみ可能

#### ステップ4: ユースケースの定義

1. 日報を作成する
2. 日報を更新する
3. 日報を削除する
4. 日報を検索する
5. コメントを追加する
6. コメントを削除する

#### ステップ5: アプリケーションサービスの設計

```typescript
@Injectable()
export class ReportService {
  async createReport(dto: CreateReportDto): Promise<ReportDto> { ... }
  async updateReport(id: string, dto: UpdateReportDto): Promise<ReportDto> { ... }
  async deleteReport(id: string): Promise<void> { ... }
  async searchReports(dto: SearchReportsDto): Promise<ReportDto[]> { ... }
  async addComment(reportId: string, dto: AddCommentDto): Promise<CommentDto> { ... }
  async removeComment(reportId: string, commentId: string): Promise<void> { ... }
}
```

### 6.2 設計の進め方

1. **最上位のドメインの目的を設定**: まず全体ドメインの目的を設定（ステップ0）
2. **1つのコンテキストから開始**: まず Reports Context から設計を開始
   - ステップ0: Reports Context の目的を設定
   - ステップ1〜8: 詳細設計を進める
3. **段階的に拡張**: 他のコンテキストも同様の手順で設計
   - 各コンテキストごとにステップ0から開始
4. **共有カーネルの整理**: 複数のコンテキストで使用する概念を共有カーネルとして整理
5. **目的の見直し**: 定期的にドメインの目的を見直し、必要に応じて更新

---

## 7. 参考資料

- [Eric Evans - Domain-Driven Design](https://www.domainlanguage.com/ddd/)
- [Vaughn Vernon - Implementing Domain-Driven Design](https://vaughnvernon.com/implementing-domain-driven-design/)
- [Nest.js Documentation](https://docs.nestjs.com/)

---

## 8. 次のステップ

1. **最上位のドメインの目的を設定**
   - 全体ドメイン（勤怠管理）の目的を設定（ステップ0）
   - ドメイン目的書を作成

2. **Reports Context の設計を開始**
   - ステップ0: Reports Context の目的を設定
   - ステップ1〜8を順番に実行
   - 設計ドキュメントを作成
   - 実装を開始

3. **他のコンテキストの設計**
   - 各コンテキストごとにステップ0から開始
   - Attendance Context
   - Leave Context
   - Auth Context
   - など

4. **設計の継続的な改善**
   - 実装を通じて設計を改善
   - ドメインエキスパートとの対話を継続
   - 定期的にドメインの目的を見直し

---

※ 本ドキュメントは設計の初期ガイドです。実装を進めながら随時更新してください。

