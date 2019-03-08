package client;

import coconut.Ui.hxx;

class Client {
  static function main() {
    Renderer.mount(
      document.body,
      hxx(<div>Hello, World!</div>)
    );
    testWS();
  }

  static function testWS() {
    new client.service.Remote("ws://localhost:2751", "Baby Spice")
      .connect()
      .handle(serverInfo -> {
        trace('connected, serverInfo=$serverInfo');
      });
  }
}