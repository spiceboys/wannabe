package game;

abstract PlayerId(String) from String to String {
  public function new()
    this = [for (i in 0...10) Std.random(10)].join('');
}