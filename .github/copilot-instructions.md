---
applyTo: "**"
---

# AI開発ガイドライン（Python 3.12+ / Pyxel）

本ファイルは最重要ルール（Hard Rules）のみを記載。詳細は各 instructions ファイルを参照。
本プロジェクトは [Pyxel](https://github.com/kitao/pyxel)（レトロゲームエンジン）を使用する。

---

## Hard Rules（必ず守ること）

### ログ・例外

- **PII/秘密情報のログ出力禁止**
- **例外ログは `exc_info=True`** で出力
- **広域 `except Exception:` 禁止**（特定例外で捕捉）

### コード品質

- **型注釈必須**: `src/`配下の公開関数/メソッドは型ヒント + Docstring
- **テスト増殖禁止**: 同型テストが3本目になったら集約（parametrize等）
- **依存追加は `uv add` / `uv add --dev` のみ**

### 出力前セルフチェック

- `make check-all` 成功を確認してからPR作成
- 禁止語を使用しない: best / optimal / faster / always / never / perfect

---

## 詳細ルール参照

各詳細は以下の instructions ファイルを参照:

| ファイル | 内容 |
|---------|------|
| [00-hard-rules.instructions.md](../.github/instructions/00-hard-rules.instructions.md) | Git規則、ディレクトリ構成、開発環境 |
| [python-standards.instructions.md](../.github/instructions/python-standards.instructions.md) | 命名規則、import、型付け、Docstring、エラーメッセージ |
| [logging.instructions.md](../.github/instructions/logging.instructions.md) | ロギング設計、レベル選択、実装パターン |
| [config-secrets.instructions.md](../.github/instructions/config-secrets.instructions.md) | 設定/シークレット管理、Config駆動型設計 |
| [tests-tdd.instructions.md](../.github/instructions/tests-tdd.instructions.md) | TDD、テスト命名、仕様駆動、モック方針 |
| [tests-fixtures-and-tmp_path.instructions.md](../.github/instructions/tests-fixtures-and-tmp_path.instructions.md) | tmp_path必須、フィクスチャ設計 |
| [quality-gates.instructions.md](../.github/instructions/quality-gates.instructions.md) | 品質ゲートチェックリスト、PR前確認 |
| [pyxel-standards.instructions.md](../.github/instructions/pyxel-standards.instructions.md) | Pyxel Appクラス設計、シーン管理、リソース管理、テスト戦略 |

---

## 出力スタイル（AI回答用）

- 言語: 日本語（コード/識別子は英語）
- 構造: 見出し + 箇条書き（冗長段落禁止）
- 推奨語彙: measured / documented / approximately / typically
