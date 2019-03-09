package client.service;

import haxe.Json;
import game.Protocol;

class Remote {
	
	static public function connect(url:String, player:Player, id:RoomId):Promise<GameConnection> {
		var svc = new WebSocketService(url);
		
		return @:privateAccess svc.connectWS().next(
			_ -> {
				function send(msg:ClientMessage)
					svc.connector.sendRaw(Json.stringify(msg));
				
				send(JoinRoom(id, player));

				var received = svc.connector.onRawMessage.map(function (raw:String):ServerMessage return Json.parse(raw));
				received.nextTime().next(
					msg -> switch msg {
						case RoomChanged(players):
							var game = new Game({ 
								id: id, 
								players: players, 
								service: (_, action) -> {
									send(GameAction(action));
									[];
								}
							});
							received.handle(function (msg) @:privateAccess switch msg {
								case RoomChanged(players):
									game.updatePlayers(players);
								case GameStarted(init):
									game.startGame(init);
								case GameReaction(reactions):
									game.apply(reactions);
								case Panic(error):
									js.Browser.console.error('server error: $error');
							});
							{ game: game, send: send };
						default:
							new Error('unexpected response');
					}
				);

			}
		).eager();
	}

}

typedef GameConnection = {
	final game:Game;
	final send:ClientMessage->Void;
}