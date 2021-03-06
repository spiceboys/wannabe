package client.service;

import haxe.Json;
import js.html.*;
import tink.state.*;

class WebSocketService {
	final url:String;
	final routes:Map<String, Dynamic->Void>;

	final _isConnected:State<Bool> = new State(false);

	public var isConnected(get, never):Observable<Bool>;
	function get_isConnected() return _isConnected.observe();

	public var connector(default, null):WebSocketConnector;

	public function new(url:String) {
		this.url = url;
		routes = [];
	}
	
	function connectWS():Promise<Noise>
		return Future.async(cb -> {
			connector = new WebSocketConnector(url);
			
			connector.onConnected.nextTime()
				.handle(() -> {
					trace('connector connected');
					_isConnected.set(true);
					cb(Success(Noise));
				});
			
			connector.onDisconnected.nextTime()
				.handle(res -> {
					trace('connector closed: code=${res.code} reason=${res.reason}');
					_isConnected.set(false);
					cb(Failure(new Error('Disconnected: code=${res.code} reason=${res.reason}')));
				});
			
			connector.onError.handle(error -> trace('connector error: $error'));
		});
}

@:tink private class WebSocketConnector {
	@:signal var onConnected:Noise;
	@:signal var onDisconnected:{code:Int, reason:String};
	@:signal var onRawMessage:String;
	@:signal var onError:String;
	
	@:forward(url, close)
	var ws:WebSocket;
	
	public function new(url:String) {
		ws = new WebSocket(url);
		ws.onopen = () -> _onConnected.trigger(Noise);
		ws.onclose = (e:CloseEvent) -> _onDisconnected.trigger({code: e.code, reason: e.reason});
		ws.onerror = (e:Event) -> _onError.trigger("WebSocket error");
		ws.onmessage = (e:MessageEvent) -> {
			var obj:Dynamic;
			_onRawMessage.trigger(e.data);
		}
	}

	public function sendRaw(msg:String) {
		if (ws.readyState == 1) ws.send(msg);
		else _onError.trigger('WebSocket is not ready: readyState=${ws.readyState}');
	}

	public function send(obj:Dynamic) {
		sendRaw(Json.stringify(obj));
	}
}
