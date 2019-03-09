package game;

enum Action {
  Move(x:Int, y:Int);
  Attack(x:Int, y:Int);
  Skip;
}