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

  public function new() {}
  
  final rooms:Map<String, Room> = [];

  function getRoom(id:String):Room
    return
      if (rooms.exists(id)) rooms[id];
      else {
        trace('[room-$id] Room created');
        final routes = new Map<String, RouteHandler>();
        final players = new State(List.fromArray([]));
        final room:Room = {
          id: id,
          isRunning: false,
          routes: routes,
          players: players,
          root: new Root({
            route: (route, handler) -> routes[route] = handler,
            players: players.observe()
          })
        };
        rooms[id] = room;
      }

  public function run() {
    final wss = new js.npm.ws.Server({port: port});
    wss.on("connection", (ws:WebSocket) -> {
      trace("WebSocket connected");
      var room:Room = null;
      var player:Player = null;

      function call(route:String, ?data:Dynamic = null)
        ws.send(Json.stringify({call: route, data: data}), _ -> {});
      
      function respond(route:String, ?data:Dynamic = null)
        call('${route}Response', data);
      
      function disconnect(terminate:Bool = false) {
        if (player != null) {
          trace('[room-${room.id}] Player left: ${player.id}');
          room.players.set(room.players.value.filter(p -> p.id != player.id));
          room.routes["leave"](player, null);
          if (room.players.value.length == 0) rooms.remove(room.id);
          room = null;
          player = null;
        }
        if (terminate) ws.terminate();
      }
      
      ws.on("message", json -> {
        final msg = Json.parse(json), route = msg.call;

        if (route == "join") {
          room = getRoom(msg.data.roomId);
          if (room.isRunning)
            return respond(route, Failure(new Error("Cannot join an already running game")));
          final playerId = msg.data.playerId;
          if (room.players.value.exists(p -> p.id == playerId))
            return respond(route, Failure(new Error('Player already connected: $playerId')));
          
          player = {
            id: playerId,
            connection: {
              call: call,
              disconnect: () -> disconnect(true)
            }
          };
          room.players.set(room.players.value.prepend(player));
          trace('[room-${room.id}] Player joined: ${player.id}');
        }

        if (!room.routes.exists(route))
          return respond(route, Failure(new Error('Not implemented')));
        
        final res = room.routes[route](player, msg.data);
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

typedef Room = {
  final id:String;
  final isRunning:Bool;
  final routes:Map<String, RouteHandler>;
  final players:State<List<Player>>;
  final root:Root;
}