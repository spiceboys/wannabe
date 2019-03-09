package client.service;

import haxe.Json;
import game.Protocol;

class Remote {
	
	static public function connect(url:String, player:Player, id:RoomId):Promise<Game> {
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
							var game = new Game({ id: id, players: players });
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
							game;
						default:
							new Error('unexpected response');
					}
				);

			}
		).eager();

	}
	// final player:Player;
	
	// public function new(url:String, player, id:RoomId) {
	// 	super(url);
	// 	this.player = player;
	// }

}
#if false
class Remote extends WebSocketService {
	final playerId:String;
	final when:RemoteSignals;

	public function new(url:String, playerId:String) {
		super(url);
		this.playerId = playerId;
		when = {
			starting: createSignal("starting")
		};
	}

	public function connect():Promise<ServerInfo> {
		trace('Connecting: url=$url playerId=$playerId');
		return connectWS()
			.next(_ -> callAndListen("join", {roomId: 1, playerId: playerId}));
	}

	public function setReadiness(value:Bool):Void
		call("setReadiness", value);
}

typedef RemoteSignals = {
	final starting:Signal<Noise>;
}
#end