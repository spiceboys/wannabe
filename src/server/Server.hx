package server;

import haxe.Json;
import haxe.ds.Map;
import js.npm.ws.WebSocket;
import game.Protocol;

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
        final room = new game.Game.GameOf<Player>({
          id: id,
        });
        rooms[id] = room;
      }

  public function run() {
    final wss = new js.npm.ws.Server({port: port});
    wss.on("connection", (ws:WebSocket) -> {
      trace("WebSocket connected");

      var room:Room = null;
      var player:Player = null;

      function respond(r:ServerMessage)
        ws.send(Json.stringify(r), _ -> {});

      function disconnect(terminate:Bool = false) {
        if (player != null) {
          trace('[room-${room.id}] Player left: ${player.id}');
          room.disconnectPlayer(player);
          if (room.players.length == 0) rooms.remove(room.id);
          room = null;
          player = null;
        }
        if (terminate) ws.terminate();
      }    

      function broadcast(msg)
        for (p in room.players)
          p.send(msg);

      function report<T>(p:Promise<T>):Future<T>
        return p.recover(function (e) {
          respond(Panic(e.message));
          return cast Future.NEVER;
        }).eager();      

      function roomChanged() {
        broadcast(RoomChanged(room.players.toArray()));

        if (!room.running && room.players.count(p -> p.ready) == room.players.length && room.players.length > 1) {
          broadcast(GameStarted(room.startGame()));
        }

      }
      
      ws.on("close", (code, reason) -> {
        trace('WebSocket disconnected: code=${code} reason=${reason}');
        disconnect();
      });

      ws.on("message", function (json) {
        final msg:ClientMessage = Json.parse(json);
        if (room == null)
          switch msg {
            case JoinRoom(id, init):
              room = getRoom(id);
              player = tink.Anon.merge(init, disconnect = disconnect.bind(true), send = respond);
              report(room.addPlayer(player)).handle(roomChanged);
            default: 
              respond(Panic('must join room before any other action'));
              disconnect(true);
          }
        else switch msg {
          case JoinRoom(_):
            respond(Panic('already joined a room'));
          case SetReady(ready):
            player = tink.Anon.merge(player, ready = ready);
            report(room.changePlayer(player)).handle(roomChanged);
          case Forfeit:
            disconnect(true);
            roomChanged();
          case GameAction(action):
            report(room.dispatch(player.id, action))
              .handle(function (reactions) {
                for (p in room.players)
                  p.send(GameReaction(reactions));
              });
        }
      });
    });
  }
}

typedef Room = game.Game.GameOf<Player>;

typedef Player = game.Player & {
  function send(msg:game.Protocol.ServerMessage):Void;
  function disconnect():Void;
}