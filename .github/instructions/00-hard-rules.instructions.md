---
applyTo: "**"
---

# 最重要ルール（Hard Rules）

本ファイルは全ファイルに適用される最上位ルールである。

---

## 1. 必ず守ること（DO）

- **KentBeck式TDD必須**: 機能追加/変更は先にテスト(Red) -> 実装(Green) -> リファクタ(Refactor)
- **品質チェック**: `make check-all` で format -> lint -> typecheck -> test を実行
- **依存追加**: `uv add`（本番）/ `uv add --dev`（開発）のみ使用
- **最小差分**: 1PR=1目的、目的外変更は別PRへ分離
- **PRにWHY/WHAT/EVIDENCE明示**: 変更理由と根拠を記載
- **出力言語**: 日本語（コード/識別子は英語）

---

## 2. 禁止事項（DON'T）

- テスト無しで機能/仕様を変更
- secrets/トークン/APIキー/PIIを平文記載
- 広域`except Exception:`の安易な使用（特定例外で捕捉）
- 不明確な仕様を推測で実装（1回だけ明確化質問可）
- 根拠のない性能/品質数値の捏造
- **禁止語（成果物への出力）**: best / optimal / faster / always / never / perfect

---

## 3. Git規則

### 3.1 ブランチ命名

形式: `<prefix>/<kebab-case>` （50文字以内、英数字+ハイフンのみ）

|prefix|用途|
|---|---|
|feature/|新機能|
|fix/|バグ修正|
|refactor/|リファクタ|
|docs/|ドキュメント|
|test/|テスト|
|chore/|依存更新等|
|perf/|性能改善|

### 3.2 コミットメッセージ

形式: `<type>(<scope>): <summary>` （72桁以内）

```
feat(api): add project list endpoint

WHY: users need filtered project retrieval
WHAT: new /projects endpoint with pagination
```

type: feat / fix / refactor / docs / test / chore / perf / ci / build / security

### 3.3 PR規約

- PR本文先頭: `.github/PULL_REQUEST_TEMPLATE/default.md`の内容を必ず記載
- 1PR = 1目的
- 差分: 400行以内（テスト除く）
- 必須要素: 目的 / 変更概要 / テスト / 影響範囲
- マージ: Squash Merge推奨

### 3.4 PRチェックリスト

- [ ] `make check-all` 成功
- [ ] テスト追加/修正済み
- [ ] ログ/例外方針順守
- [ ] 破壊的変更なし or BREAKING明記
- [ ] WHY/WHAT/EVIDENCE記載

### 3.5 リリースタグ

形式: `vMAJOR.MINOR.PATCH`（セマンティックバージョニング）

---

## 4. 変更理由マッピング

|変更種別|受理条件|拒否例|
|---|---|---|
|機能追加|要求明確 + テスト追加|テスト欠如|
|バグ修正|再現手順 + 失敗テスト|再現不明|
|リファクタ|重複削減 + 仕様不変|機能混在|
|性能改善|measured改善>=10%|未測定|
|依存追加|代替比較 + ライセンス記載|標準で十分|

---

## 5. ディレクトリ構成

### 5.1 プロジェクト構成

```
src/          # 実装コード（編集対象）
assets/        # Pyxelリソース（.pyxres、画像等）
tests/         # プロジェクトテスト（編集対象）
docs/          # ドキュメント
```

---

## 6. 開発環境

- パッケージ管理: `uv`（`uv run`でPythonコマンド実行）
- 依存追加: `uv add` / `uv add --dev`
- 品質チェック: `make check-all`
- ヘルプ: `make help`

---

## 7. 出力スタイル（AI回答用）

- 言語: 日本語（簡潔/具体）
- 構造: 見出し + 箇条書き（冗長段落禁止）
- 変更提案: 要約 -> 箇条書き -> 理由 -> 次アクション
- 推奨語彙: measured / documented / approximately / typically
- 差分提示: パッチ or 対象行特定（最小）
