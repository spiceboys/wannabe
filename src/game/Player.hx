package game;

class Player implements Model {
  @:constant var id:PlayerId = new PlayerId();
  @:constant var name:String;
  @:constant var color:Int;
}