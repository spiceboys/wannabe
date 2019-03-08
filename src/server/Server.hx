package server;

import haxe.Json;
import haxe.ds.Map;
import js.npm.ws.WebSocket;

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
  
  final players:Map<String, WebSocket>;
  final routes:Map<String, RouteHandler>;
  final root:Root;

  public function new() {
    players = [];
    routes = [];
    root = new Root({
      route: (route, handler) -> routes[route] = handler
    });
  }

  public function run() {
    final wss = new js.npm.ws.Server({port: port});
    wss.on("connection", (ws:WebSocket) -> {
      ws.on("message", json -> {
        final msg = Json.parse(json), route = msg.call;
        if (routes.exists(route)) {
          final res = routes[route](msg.data);
          if (res != null)
            res.handle(data -> ws.send(Json.stringify({call: '${route}Response', data: data}), _ -> {}));
        }
        else trace('Unhandled message: $msg');
      });

      ws.on("close", (code, reason) -> {
        trace('Disconnected: code=${code} reason=${reason}');
        // TODO: Handle disconnection
      });
    });
  }
}

typedef RouteHandler = Dynamic->Null<Promise<Dynamic>>;