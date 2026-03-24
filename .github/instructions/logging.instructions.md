---
applyTo: "src/**/*.py"
---

# ロギング規約

本ファイルは本番Pythonコード（PoC除外）に適用される。

---

## 1. 必須ルール

- モジュール冒頭: `logger = get_logger(__name__, module="...")`
- 出力箇所: 開始/終了/主要分岐/失敗
- 失敗時: `exc_info=True`
- **PII/秘密情報は出力禁止**（マスク: `masked_value`）

---

## 2. レベル選択

|レベル|用途|
|---|---|
|DEBUG|内部状態トレース|
|INFO|主要イベント（ユーザー作成等）|
|WARNING|回復可能異常（リトライ中）|
|ERROR|機能失敗|
|CRITICAL|継続不能|

---

## 3. 実装パターン

```python
from project_name.utils.logging_config import get_logger, log_context

logger = get_logger(__name__, module="payment")

def charge(user_id: int, amount: int) -> None:
    logger.debug("Start charge", user_id=user_id, amount=amount)
    try:
        # 処理
    except GatewayTimeout:
        logger.error("Gateway timeout", user_id=user_id, exc_info=True)
        raise
    logger.info("Charge completed", user_id=user_id)

# コンテキストバインド
with log_context(request_id=req_id, user_id=uid):
    logger.info("Process started")
```

---

## 4. 構造化ログのポイント

- 外部境界/主要分岐/失敗で DEBUG/INFO/ERROR を出力
- キーワード引数で構造化データを渡す
- メッセージは簡潔に、詳細はキーワード引数で
