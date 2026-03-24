---
applyTo: "src/**/*.py"
---

# Pyxel コーディング規約

本ファイルはPyxelを使用するPythonコードに適用される。

---

## 1. Appクラスパターン

Pyxelアプリケーションはクラスベースで実装する。

```python
import pyxel


class App:
    """ゲームアプリケーション。"""

    def __init__(self) -> None:
        pyxel.init(160, 120, title="Game Title")
        pyxel.load("assets/game.pyxres")
        # ゲーム状態の初期化
        self.player_x = 72
        self.player_y = 56
        pyxel.run(self.update, self.draw)

    def update(self) -> None:
        """フレーム更新処理。"""
        if pyxel.btnp(pyxel.KEY_Q):
            pyxel.quit()

    def draw(self) -> None:
        """描画処理。"""
        pyxel.cls(0)


App()
```

**必須ルール**:
- `__init__`で`pyxel.init()` → リソース読み込み → 状態初期化 → `pyxel.run()`の順
- `update()`と`draw()`はインスタンスメソッドとして定義
- モジュール末尾で`App()`を呼び出してエントリーポイントとする

---

## 2. ゲーム状態管理

ゲーム状態はインスタンス変数で管理する。グローバル変数は禁止。

```python
class App:
    def __init__(self) -> None:
        pyxel.init(160, 120)
        # 状態はインスタンス変数で管理
        self.score: int = 0
        self.player_x: float = 80.0
        self.player_y: float = 60.0
        self.is_game_over: bool = False
        pyxel.run(self.update, self.draw)
```

**命名規則**:

|対象|規則|例|
|---|---|---|
|座標|`x`, `y` または `対象_x`, `対象_y`|`player_x`, `enemy_y`|
|速度|`対象_dx`, `対象_dy` または `対象_speed`|`bullet_dx`, `player_speed`|
|フラグ|`is_状態`|`is_alive`, `is_game_over`|
|カウンター|`対象_count`|`frame_count`, `enemy_count`|
|リスト|複数形|`enemies`, `bullets`, `particles`|

---

## 3. シーン管理

複数シーン（タイトル、ゲーム、ゲームオーバー等）はメソッド分離パターンで管理する。

```python
class App:
    def __init__(self) -> None:
        pyxel.init(160, 120)
        self.scene = "title"
        pyxel.run(self.update, self.draw)

    def update(self) -> None:
        match self.scene:
            case "title":
                self.update_title()
            case "play":
                self.update_play()
            case "game_over":
                self.update_game_over()

    def draw(self) -> None:
        match self.scene:
            case "title":
                self.draw_title()
            case "play":
                self.draw_play()
            case "game_over":
                self.draw_game_over()

    def update_title(self) -> None:
        if pyxel.btnp(pyxel.KEY_RETURN):
            self.scene = "play"

    def draw_title(self) -> None:
        pyxel.cls(0)
        pyxel.text(50, 60, "PRESS ENTER", 7)

    # ... update_play, draw_play, update_game_over, draw_game_over
```

**規模が大きい場合**: シーンごとにクラスを分離し、`Scene`プロトコルで管理する。

---

## 4. リソース管理

|種別|配置先|形式|
|---|---|---|
|Pyxelリソースファイル|`assets/`|`.pyxres`|
|画像（PNG/GIF）|`assets/`|`.png`, `.gif`|
|TMXマップ|`assets/`|`.tmx`|

**ルール**:
- リソースファイルのパスはハードコーディングせず、定数で管理
- `pyxel.load()`は`__init__`内で1回のみ呼び出す

```python
RESOURCE_PATH = "assets/game.pyxres"

class App:
    def __init__(self) -> None:
        pyxel.init(160, 120)
        pyxel.load(RESOURCE_PATH)
        pyxel.run(self.update, self.draw)
```

---

## 5. 入力処理

|関数|用途|
|---|---|
|`pyxel.btn(key)`|押し続けている間（移動等）|
|`pyxel.btnp(key)`|押した瞬間（ジャンプ、決定）|
|`pyxel.btnr(key)`|離した瞬間|

**ルール**:
- 入力処理は`update()`内で行う（`draw()`内での入力処理は禁止）
- 複数キー対応時はリスト/辞書で管理

---

## 6. 描画ルール

- `draw()`の先頭で`pyxel.cls()`を呼んで画面クリア
- 描画順序は奥から手前（背景 → マップ → エンティティ → UI）
- カラー定数（0-15）はマジックナンバーを避け、意味のある名前で定義

```python
# 色定数例
COLOR_BG = 0       # 黒（背景）
COLOR_TEXT = 7      # 白（テキスト）
COLOR_PLAYER = 11   # 黄緑（プレイヤー）
```

---

## 7. ゲームロジックの分離（テスタビリティ）

Pyxel API（`pyxel.btn`, `pyxel.cls`等）に依存しない純粋ロジックを分離し、テスト可能にする。

```python
# src/game_logic.py - テスト可能な純粋関数
def move_player(x: float, y: float, dx: float, dy: float, width: int, height: int) -> tuple[float, float]:
    """プレイヤーの移動を計算する。画面内に収める。"""
    new_x = max(0.0, min(x + dx, float(width - 1)))
    new_y = max(0.0, min(y + dy, float(height - 1)))
    return new_x, new_y

def check_collision(x1: float, y1: float, w1: int, h1: int,
                    x2: float, y2: float, w2: int, h2: int) -> bool:
    """矩形同士の衝突判定。"""
    return x1 < x2 + w2 and x1 + w1 > x2 and y1 < y2 + h2 and y1 + h1 > y2
```

```python
# src/app.py - Appクラスはロジック関数を呼び出す
from game_logic import move_player

class App:
    def update(self) -> None:
        dx = 0.0
        dy = 0.0
        if pyxel.btn(pyxel.KEY_RIGHT):
            dx = 2.0
        if pyxel.btn(pyxel.KEY_LEFT):
            dx = -2.0
        self.player_x, self.player_y = move_player(
            self.player_x, self.player_y, dx, dy, pyxel.width, pyxel.height
        )
```

**テスト戦略**:

|対象|テスト方法|
|---|---|
|純粋ロジック（移動、衝突、スコア計算）|通常のユニットテスト|
|Pyxel API依存コード（描画、入力）|手動確認 or `headless=True`での統合テスト|

---

## 8. パフォーマンス考慮事項

- `update()`と`draw()`は毎フレーム呼ばれるため、重い処理を避ける
- リストの大量生成を避け、オブジェクトプールを検討する
- `pyxel.frame_count`をタイマー代わりに使用（`time.time()`は不要）

---

## 9. pyxel.init()のパラメーター指針

|パラメーター|デフォルト|指針|
|---|---|---|
|`width`, `height`|—|ゲーム設計に合わせて設定（典型: 128x128, 160x120, 256x256）|
|`title`|"Pyxel"|ゲーム名を設定|
|`fps`|30|固定。変更する場合はゲーム速度への影響を考慮|
|`quit_key`|KEY_ESCAPE|変更非推奨|
|`headless`|False|テスト時のみTrue|
