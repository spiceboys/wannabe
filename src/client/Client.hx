package client;

import coconut.Ui.hxx;

class Client {
  static function main() {
    Renderer.mount(
      document.body,
      hxx(<div>Hello, World!</div>)
    );
  }
}