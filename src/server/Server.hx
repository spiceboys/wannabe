package server;

import haxe.Json;
import haxe.ds.Map;
import js.npm.ws.WebSocket;
import server.Root;

class Server {
  static public final BUILD_DATE = server.util.Macro.getBuildDate();
  static public final HASH = server.util.Macro.getGitSha().substr(0, 8);

  static final port = 2751;

  static function main() {
    process.chdir(__dirname);
    trace('server version $BUILD_DATE compiled on $BUILD_DATE');
    trace('listening on port $port');
    new Server().run();
  }
  
  final routes:Map<String, RouteHandler>;
  final players:State<List<Player>>;
  final root:Root;

  public function new() {
    routes = [];
    players = new State(List.fromArray([]));

    root = new Root({
      route: (route, handler) -> routes[route] = handler,
      players: players.observe()
    });
  }

  public function run() {
    final wss = new js.npm.ws.Server({port: port});
    wss.on("connection", (ws:WebSocket) -> {
      trace("WebSocket connected");
      var player:Player = null;

      function call(route:String, ?data:Dynamic = null)
        ws.send(Json.stringify({call: route, data: data}), _ -> {});
      
      function respond(route:String, ?data:Dynamic = null)
        call('${route}Response', data);
      
      function disconnect(terminate:Bool = false) {
        if (player != null) {
          trace('Player left: ${player.id}');
          players.set(players.value.filter(p -> p.id != player.id));
          if (routes.exists("leave")) routes["leave"](player, null);
        }
        if (terminate) ws.terminate();
      }
      
      ws.on("message", json -> {
        final msg = Json.parse(json), route = msg.call;

        if (route == "join") {
          final playerId = msg.data.playerId;
          if (players.value.exists(p -> p.id == playerId))
            return respond(route, Failure(new Error('Player already connected: $playerId')));
          
          player = {
            id: playerId,
            connection: {
              call: call,
              disconnect: () -> disconnect(true)
            }
          };
          players.set(players.value.prepend(player));
          trace('Player joined: ${player.id}');
        }

        if (!routes.exists(route))
          return respond(route, Failure(new Error('Not implemented')));
        
        final res = routes[route](player, msg.data);
        if (res != null)
          res.handle(data -> respond(route, data));
      });

      ws.on("close", (code, reason) -> {
        trace('WebSocket disconnected: code=${code} reason=${reason}');
        disconnect();
      });
    });
  }
}