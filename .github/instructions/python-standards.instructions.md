---
applyTo: "src/**/*.py"
---

# Pythonコーディング規約

本ファイルは本番Pythonコード（PoC除外）に適用される。

---

## 1. 命名規則

|対象|規則|例|
|---|---|---|
|ファイル/ディレクトリー|snake_case|data_loader.py|
|クラス|PascalCase|UserService|
|関数/変数|snake_case|get_user|
|定数|UPPER_SNAKE|MAX_RETRY|
|プライベート|先頭`_`|_normalize|
|例外|PascalCase + Error|InvalidStateError|

---

## 2. import規約

**必須ルール**:
- import文はモジュールのトップレベルに配置（ruff PLC0415準拠）
- 関数/メソッド内でのimportは原則禁止
- テストファイルも例外なくトップレベルimportを使用

**許容される例外**:
- 循環import回避の局所的import（コメントで理由明記）
- 遅延ロードが必須な重量級モジュール（コメントで理由明記）

```python
# NG: 関数内import
def test_example() -> None:
    import pytest  # PLC0415違反
    from module import func
    ...

# OK: トップレベルimport
import pytest
from module import func

def test_example() -> None:
    ...
```

---

## 3. 型付け規約

|ケース|推奨型|
|---|---|
|可変シーケンス|`list[T]`|
|不変シーケンス|`tuple[T, ...]`|
|オプション|`T \| None`|
|辞書|`dict[str, T]`|

- **型ヒント必須**: `src/`配下の公開関数/メソッドは型注釈 + Docstring（概要/引数/戻り値/例外）
- `Any`乱用禁止（必要時は`# type: ignore[理由]`でTODO化）

---

## 4. Docstring（Google形式）

```python
def process(data: list[int]) -> int:
    """データを処理して合計を返す。

    Args:
        data: 処理対象の整数リスト（空不可）

    Returns:
        合計値

    Raises:
        ValueError: dataが空の場合
    """
```

---

## 5. エラーメッセージ

フォーマット: 問題 + 期待値/実際値 + 解決策（任意）

```python
# NG: "Invalid input"
# OK: "Expected positive integer, got -3"

try:
    raw = json.loads(text)
except json.JSONDecodeError as e:
    raise ConfigLoadError(f"Invalid JSON: {path} ({e.msg})") from e
```

---

## 6. アンカーコメント

|タグ|用途|
|---|---|
|AIDEV-NOTE|背景/意図|
|AIDEV-TODO|未実装/改善|
|AIDEV-QUESTION|検討事項|

---

## 7. パフォーマンス測定

### 7.1 トリガー

- 高コスト処理（体感>50ms）追加/変更時
- O(n^2)懸念処理

### 7.2 ツール

|名称|用途|
|---|---|
|`@profile`|cProfile集計|
|`@timeit`|軽量計測|
|`Timer`|任意ブロック計測|

### 7.3 レポート形式

```
measured 42.6ms avg (n=5, stdev 1.1ms)
比較: 前版 +13.2%
```

---

## 8. 実装フロー

1. 要求チェックリスト化
2. Protocol/インターフェース定義
3. 失敗するテスト追加（Red）→ テスト実行で失敗確認
4. 最小実装（Green）+ ログ挿入 → テスト実行で成功確認
5. リファクタ（重複除去）→ テスト実行で回帰なし確認
6. 解消可能な`AIDEV-TODO`を対応
7. 仕様適合性確認（要求チェックリスト全項目照合）
8. ドキュメント更新（仕様変更時: README / docs / API仕様）
9. `make check-all`実行
10. PR作成（WHY/WHAT/EVIDENCE）

---

## 9. 段階的実装とAIDEV-TODO

現タスクで実装困難な部分は`AIDEV-TODO`コメントで後続タスクに委譲する。実装可能タイミングを必ず明記すること。

**対象範囲**:
- 実装コード: 依存未解決の機能
- テストコード: モック未準備の統合テスト、リファクタ後の修正が必要なテスト

**フォーマット**: `# AIDEV-TODO: [実装可能タイミング] 内容`

**実装可能タイミングの例**:
- `[ユニットテスト完了後]`: 基礎テストが揃った段階
- `[統合テスト環境構築後]`: 外部依存の接続が可能になった段階
- `[リファクタリング完了後]`: 構造変更後のテスト修正
- `[依存モジュール実装後]`: 他モジュールの完成待ち
- `[性能測定完了後]`: 計測結果を受けた最適化

**コード例**:
```python
# 実装コード
def fetch_user_data(user_id: int) -> dict:
    # AIDEV-TODO: [統合テスト環境構築後] 実際のDB接続を実装
    return {"id": user_id, "name": "mock"}

# テストコード
def test_fetch_user_integration() -> None:
    # AIDEV-TODO: [DB環境構築後] 実データでの統合テストを実装
    pass

def test_legacy_method() -> None:
    # AIDEV-TODO: [リファクタリング完了後] 新インターフェースに合わせて修正
    assert legacy_method() == expected
```

---

## 10. サンプルファイル作成

外部ファイル読み込みロジック実装時は、動作確認用のサンプルファイルも作成する:

- 設定ファイル: `config/config.example.yaml`（実際の値はダミー）
- 環境変数: `.env.example`（キー名のみ、値は空またはダミー）
