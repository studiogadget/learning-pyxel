<!-- I want to review in Japanese. -->
<!-- Review rules for AI -->

<details>
<summary>Review rules for AI</summary>

### お願い

- Pull Request Overview、Reviewed Changes、コメントはすべて必ず日本語で書いてください

### レビュー対象と範囲

- 次の観点でコード品質の改善提案を行ってください
  - 設定ファイルの適切な利用（パラメータのハードコーディングなく、設定ファイルから読み込んだ値を使用しているか。呼び出し元で設定値が渡されている場合も含む）
  - ロジックの正確性
  - セキュリティー上の問題
  - パフォーマンスの最適化
  - データ競合の可能性
  - 一貫性の維持
  - クラス名、メソッド名、フィールド名に表記ゆれが無いこと
  - エラーハンドリング
  - 保守性の向上
  - モジュール性の確保
  - コードの複雑性軽減
  - 最適化の可能性
  - ベストプラクティス(DRY, SOLID, KISS)の適用
- 重大な問題（例：テスト失敗、脆弱性、O(n²) 以上のボトルネック）に絞ってレビューしてください
- 次についてはコメントしないでください
  - `db/**`, `**/*.lock`
  - 自動生成されたコード（l10n, freezedなど）
  - レビュー結果ファイル（`docs/code-review/code-review-result-PR<PR番号>.md`）

</details>
<!-- Review rules for AI -->
<!-- I want to review in Japanese. -->
