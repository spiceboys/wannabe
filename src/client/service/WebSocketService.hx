package client.service;

import haxe.Json;
import js.html.CloseEvent;
import js.html.Event;
import js.html.MessageEvent;
import js.html.WebSocket;

class WebSocketService {
	final url:String;

	var connector:WebSocketConnector;

	public function new(url:String)
		this.url = url;
	
	function connectWS():Promise<Noise>
		return Future.async(cb -> {
			connector = new WebSocketConnector(url);
			
			connector.onConnected.nextTime()
				.handle(() -> {
					trace('connector connected');
					cb(Success(Noise));
				});
			
			connector.onDisconnected.nextTime()
				.handle(res -> {
					trace('connector closed: code=${res.code} reason=${res.reason}');
					cb(Failure(new Error('Disconnected: code=${res.code} reason=${res.reason}')));
				});
			
			connector.onError.handle(error -> trace('connector error: $error'));
		});

	function call(route:String, ?data:Dynamic = null):Void 
		connector.send({call: route, data: data});

	function callAndListen(route:String, ?data:Dynamic = null):Promise<Dynamic>
		return Future.async(cb -> {
			connector.onMessage.nextTime(msg -> msg.call == '${route}Response')
				.handle(msg -> cb(msg.data));
			call(route, data);
		});
}

@:tink private class WebSocketConnector {
	@:signal var onConnected:Noise;
	@:signal var onDisconnected:{code:Int, reason:String};
	@:signal var onMessage:Dynamic;
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
			try {
				obj = Json.parse(e.data);
			}
			catch (err:Dynamic) {
				_onError.trigger("JSON parse error");
				return;
			}
			_onMessage.trigger(obj);
		}
	}
	
	public function send(obj:Dynamic) {
		if (ws.readyState == 1) ws.send(Json.stringify(obj));
		else _onError.trigger('WebSocket is not ready: readyState=${ws.readyState}');
	}
}
