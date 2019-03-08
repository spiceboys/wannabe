package game;

abstract PlayerId(String) from String to String {
  public function new()
    this = [for (i in 0...100) Std.random(10)].join('');
}