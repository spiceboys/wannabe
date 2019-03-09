package client;

class GameSession implements Model {
  @:forward
  @:constant private var game:Game;
  @:constant var self:Player;
  @:computed var isMyTurn:Bool = switch nextUnit {
    case None: false;
    case Some(u): u.owner.id == self.id;
  }

  public function moveTo(x:Int, y:Int)
    return game.moveTo(x, y, self);

  public function skip()
    return game.skip(self);

  public function attack(x:Int, y:Int)
    return game.attack(x, y, self);

}