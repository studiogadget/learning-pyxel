---
applyTo: "src/**/*.py"
---

# 設定とシークレット管理

本ファイルは本番Pythonコード（PoC除外）に適用される。

---

## 1. 分離原則

|種別|管理方法|例|
|---|---|---|
|秘密情報|環境変数|APIキー/トークン/パスワード/DB認証情報|
|一般設定|設定ファイル|ホスト名/ポート/タイムアウト/ログレベル|

---

## 2. 環境変数ルール

- 開発環境: `.env`ファイル（必ず`.gitignore`に追加）
- 本番環境: シークレットマネージャー（AWS Secrets Manager / Azure Key Vault 等）
- 起動時に必須環境変数を検証（欠落時は明示的エラーで停止）

---

## 3. 設定ファイルルール

- 配置: `config/config.yaml` または `config/settings.toml`
- バージョン管理: リポジトリに含める（秘密情報は含めない）
- サンプル提供: `config/config.example.yaml`をリポジトリに配置

---

## 4. 実装パターン

```python
import os
from pathlib import Path
import yaml

# 必須環境変数の検証
def validate_env() -> None:
    required = ["API_KEY", "DB_PASSWORD"]
    missing = [k for k in required if not os.getenv(k)]
    if missing:
        raise EnvironmentError(f"Missing required env vars: {', '.join(missing)}")

# 設定ファイルの読み込み
def load_config(path: Path = Path("config/config.yaml")) -> dict:
    if not path.exists():
        raise FileNotFoundError(f"Config file not found: {path}")
    with path.open() as f:
        return yaml.safe_load(f)

# 起動時の初期化
validate_env()
config = load_config()
api_key = os.environ["API_KEY"]  # 環境変数から取得
timeout = config["api"]["timeout"]  # 設定ファイルから取得
```

---

## 5. Config駆動型設計パターン

設定値をハードコーディングせず、常に`config`パラメータから取得する統一パターン。

**原則**:
- **必須パラメータ**: `config` を関数引数に必須で含める（`config: dict[str, Any]`）
- **明示的引数廃止**: 設定値を個別パラメータにしない（config から抽出）
- **ネスト対応**: `config.get("section", {}).get("key", default)` で安全に取得
- **型変換明示**: `float()`, `int()` で型を明示的に変換（バリデーション兼ねる）
- **バリデーション**: 必須パラメータ欠損時は `ValueError` で明示的エラー
- **デフォルト値**: `.get()` の第2引数で実装、コード内ハードコード禁止

**実装パターン**:

```python
def process_data(
    self,
    data: dict[str, Any],
    config: dict[str, Any],  # 必須パラメータ
) -> list[str]:
    """データ処理.

    Args:
        data: 処理対象データ
        config: 処理設定
            - processing.threshold: 閾値（デフォルト10）
            - processing.max_items: 最大処理件数（デフォルト100）

    Raises:
        ValueError: 不正な設定値の場合
    """
    # config から値を取得（ネストされた辞書を安全に取得）
    processing_config = config.get("processing", {})
    threshold = processing_config.get("threshold", 10)
    max_items = processing_config.get("max_items", 100)

    # バリデーション: パラメータ整合性チェック
    if threshold < 0:
        raise ValueError(
            f"Expected threshold >= 0, got {threshold}. "
            f"Check config.processing.threshold in config.yaml."
        )

    logger.debug(
        "Start process_data",
        threshold=threshold,
        max_items=max_items,
    )
    # ... 処理
```

**テスト時の config 定義**:

```python
# テストヘッダで共通config定義
DEFAULT_CONFIG = {
    "processing": {
        "threshold": 10,
        "max_items": 100,
    }
}

def test_example(self) -> None:
    # カスタム config で個別動作テスト
    custom_config = {
        "processing": {
            "threshold": 5,
            "max_items": 50,
        }
    }
    result = processor.process_data(data, config=custom_config)
```

**理由**:
- config.yaml の値と実装を同期可能
- テスト時に設定値を柔軟に変更可能
- ハードコーディング排除で保守性向上
- 呼び出し元で設定値読み込み処理を一元化
