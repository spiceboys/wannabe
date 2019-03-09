package server;

class Root {
  final d:RootDependencies;

  public function new(d:RootDependencies) {
    this.d = d;

    d.route("join", (player:Player, data:{roomId:String, playerId:String}) -> {
      for (p in d.players.value)
        if (p.id != player.id)
          p.connection.call("playerJoined", {playerId: player.id});

      return {
        buildDate: Server.BUILD_DATE,
        hash: Server.HASH,
        roomId: data.roomId,
        players: [for (p in d.players.value) p.id]
      };
    });

    d.route("leave", (player:Player, _) -> {
      for (p in d.players.value)
        if (p.id != player.id)
          p.connection.call("playerLeft", {playerId: player.id});
      return null;
    });

    
  }
}

typedef Player = {
  final id:String;
  final connection:PlayerConnection;
}

typedef PlayerConnection = {
  final call:String->?Dynamic->Void;
  final disconnect:Void->Void;
}

typedef RouteHandler = Player->Dynamic->Null<Promise<Dynamic>>;

typedef RootDependencies = {
  final route:String->RouteHandler->Void;
  final players:Observable<List<Player>>;
}