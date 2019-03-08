package server;

import server.Server.RouteHandler;

class Root {
  final d:RootDependencies;

  public function new(d:RootDependencies) {
    this.d = d;

    d.route("join", (data:{playerId:String}) -> {
      return {
        buildDate: Server.BUILD_DATE,
        hash: Server.HASH,
        players: []
      };
    });
  }
}

typedef RootDependencies = {
  route:String->RouteHandler->Void
}