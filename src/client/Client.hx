package client;

class DummyPlayer implements Player {
  @:constant var name:String;
  @:constant var color:Int;
}

class Client {
  static function main() {
    var players:Array<Player> = [
      new DummyPlayer({ name: 'Gene', color: 0xFFFF00 }),
      new DummyPlayer({ name: 'Hector', color: 0x000000 }),
      new DummyPlayer({ name: 'Arsen', color: 0x0000FF }),
      new DummyPlayer({ name: 'Juraj', color: 0x00FFFF }),
    ];

    var size = 20;

    var tiles = [TileKind.TLand, TileKind.TLand, TileKind.TLand, TileKind.TWater, TileKind.TMountain];

    var game = new GameSession({
      self: players[0],
      game: new Game({
        width: size,
        players: players,
        units: [
          new Unit({
            owner: players[0],
            delay: 0,
            hitpoints: 100,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 6,
          }),
          new Unit({
            owner: players[0],
            delay: 0,
            hitpoints: 100,
            x: 10,
            y: 15,
            frequency: .25,
            canFly: false,
            canSwim: false,
            speed: 6,
          })          
        ],
        tiles: [
          for (s in 0...size * size)
            new Tile({ kind: tiles[Std.random(tiles.length)]})
        ],
      })
    });
    Renderer.mount(
      document.body,
      coconut.Ui.hxx(
        <GameView game={game} />
      )
    );
  }
}