import pyxel


class App:
    def __init__(self) -> None:
        pyxel.init(160, 120)
        self.x = 75
        self.y = 55
        pyxel.run(self.update, self.draw)

    def update(self) -> None:
        if pyxel.btnp(pyxel.KEY_Q):
            pyxel.quit()

        if pyxel.btn(pyxel.KEY_LEFT):
            self.x -= 1

        # if pyxel.btn(pyxel.KEY_RIGHT):
        #     self.x += 1

        # if pyxel.btn(pyxel.KEY_UP):
        #     self.y -= 1

        # if pyxel.btn(pyxel.KEY_DOWN):
        #     self.y += 1

        # if pyxel.btnp(pyxel.KEY_LEFT, hold=1, repeat=1):
        #     self.x -= 1

        if pyxel.btnp(pyxel.KEY_RIGHT, hold=20, repeat=1):
            self.x += 1

        if pyxel.btnp(pyxel.KEY_UP, hold=10, repeat=5):
            self.y -= 1

        if pyxel.btnp(pyxel.KEY_DOWN, hold=10, repeat=5):
            self.y += 1

    def draw(self) -> None:
        pyxel.cls(0)
        pyxel.rect(self.x, self.y, 10, 10, 6)


App()
