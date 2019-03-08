package client.service;

class Remote extends WebSocketService {
	final playerId:String;

	public function new(url:String, playerId:String) {
		super(url);
		this.playerId = playerId;
	}

	public function route(route:String, )

	public function connect():Promise<ServerInfo> {
		trace('Connecting: url=$url playerId=$playerId');
		return connectWS()
			.next(_ -> callAndListen("join", {playerId: playerId}));
	}
}
