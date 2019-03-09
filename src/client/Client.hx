package client;

import game.Protocol;

class Client {
  static function main() {
    var players:Array<Player> = [
      { id: new PlayerId(), name: 'Gene', color: 0xFFFF00 },
      { id: new PlayerId(), name: 'Hector', color: 0x000000 },
      { id: new PlayerId(), name: 'Arsen', color: 0x0000FF },
      { id: new PlayerId(), name: 'Juraj', color: 0x00FFFF },
    ];

    var size = 20;

    var tiles = [TileKind.TLand, TileKind.TLand, TileKind.TLand, TileKind.TLava];

    var game = new GameSession({
      self: players[0],
      game: new Game({
        width: size,
        players: players,
        units: [
          new Unit({
            owner: players[0],
            status: {
              delay: 0,
              hitpoints: 100,
              x: 10,
              y: 5,
              frequency: 1,
              canFly: false,
              canSwim: false,
              speed: 6,
            }
          }),
          new Unit({
            owner: players[0],
            status: {
              delay: 0,
              hitpoints: 100,
              x: 10,
              y: 15,
              frequency: .25,
              canFly: false,
              canSwim: false,
              speed: 6,
            }
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
        <LobbyView players={players} self={players[0].id} />
      )
    );

    // trace(Std.string(haxe.Json.parse(haxe.Json.stringify(JoinRoom('fo', { id: new PlayerId(), name: 'foobar', color: 0xFF00FF })))));
    
    testWS();
  }

  static function testWS() {
    final playerId = Std.string(Std.random(65536));
    new client.service.Remote("ws://localhost:2751", playerId)
      .connect()
      .handle(serverInfo -> {
        trace('connected, serverInfo=$serverInfo');
      });
  }
}