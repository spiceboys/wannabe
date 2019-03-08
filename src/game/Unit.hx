package game;

class Unit implements Model {
  @:constant var owner:Player;
  @:observable var delay:Float;
  @:observable var hitpoints:Int;
  @:observable var x:Int;
  @:observable var y:Int;
  @:constant var canFly:Bool;
  @:constant var canSwim:Bool;
  @:observable var speed:Int;  
  @:observable var frequency:Float;  
  @:computed var alive:Bool = hitpoints > 0;
  
  public function canEnter(terrain:TileKind)
    return switch terrain {
      case TVoid: false;
      case TWater: canFly || canSwim;
      case TMountain: canFly;
      case TLand: true;
    }

  @:transition private function moveTo(x:Int, y:Int)
    return { x: x, y: y, delay: frequency + delay };
}
