package client.service;

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