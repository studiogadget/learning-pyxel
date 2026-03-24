import pyxel


class App:
    def __init__(self) -> None:
        pyxel.init(160, 120)
        # self.x = 0
        self.x = 160
        pyxel.run(self.update, self.draw)

    def update(self) -> None:
        # if pyxel.btnp(pyxel.KEY_Q):
        #     pyxel.quit()

        # self.x = (self.x + 1) % pyxel.width

        self.x = (self.x - 1) % pyxel.width

    def draw(self) -> None:
        pyxel.cls(0)
        # pyxel.rect(self.x, 10, 20, 20, 11)

        # pyxel.rect(self.x, 0, 8, 8, 9)

        pyxel.rect(self.x, 7, 5, 8, 6)


App()
