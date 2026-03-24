---
applyTo: "tests/**/*.py"
---

# テストでのフィクスチャと一時ファイル管理

本ファイルはテストコード（PoC除外）に適用される。

---

## 1. 一時ファイル・ディレクトリ管理

**必須ルール**:
- テストで一時ファイルやディレクトリが必要な場合、**必ず pytest の `tmp_path` フィクスチャを使用**
- 固定パス（`Path("tmp_test_*")` など）の使用は**禁止**

**理由**:
- pytest-xdist による並列実行時の競合を防止
- テスト間の完全な隔離を保証
- 自動クリーンアップによる副作用排除

---

## 2. 実装パターン

```python
# ❌ 禁止: 固定パスの使用
class TestExample:
    def setup_method(self):
        self.tmp_dir = Path("tmp_test")
        self.tmp_dir.mkdir(exist_ok=True)

    def teardown_method(self):
        shutil.rmtree(self.tmp_dir)

    def test_something(self):
        file_path = self.tmp_dir / "test.txt"
        ...

# ✅ 推奨: tmp_path フィクスチャの使用
class TestExample:
    def test_something(self, tmp_path: Path) -> None:
        """テストケース。

        Args:
            tmp_path: pytest提供の一時ディレクトリ（テスト固有）
        """
        file_path = tmp_path / "test.txt"
        ...

    def _create_test_file(self, tmp_path: Path, content: str) -> Path:
        """テスト用ファイルを作成するヘルパーメソッド。

        Args:
            tmp_path: pytest提供の一時ディレクトリ
            content: ファイル内容

        Returns:
            作成したファイルのパス
        """
        file_path = tmp_path / "test.txt"
        file_path.write_text(content, encoding="utf-8")
        return file_path
```

---

## 3. ヘルパーメソッドでの使用

- クラス内のヘルパーメソッドも `tmp_path` を引数で受け取る設計にする
- `setup_method` / `teardown_method` は不要（pytest が自動管理）

---

## 4. 利点

- **並列実行安全**: 各テストが独立した一時ディレクトリを取得
- **自動クリーンアップ**: テスト終了後に pytest が自動削除
- **競合回避**: ファイル上書きやレース条件が発生しない
- **CI/CD対応**: pytest-xdist での並列実行が安定

---

## 5. フィクスチャ配置

- テストフィクスチャは `tests/fixtures/` に配置
- 共通フィクスチャは `tests/conftest.py` で定義
