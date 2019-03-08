package game;

typedef UnitId = PlayerId;

typedef UnitStatus = {
  final x:Int;
  final y:Int;
  final hitpoints:Int;
  final delay:Float;
  final canFly:Bool;
  final canSwim:Bool;
  final speed:Int;  
  final frequency:Float;  
}

class Unit implements Model {
  
  @:constant var id:UnitId = new UnitId();
  @:constant var owner:Player;

  @:forward
  @:observable
  @:noCompletion
  var status:UnitStatus;
  
  @:computed var alive:Bool = hitpoints > 0;
  
  public function canEnter(terrain:TileKind)
    return switch terrain {
      case TVoid: false;
      case TWater: canFly || canSwim;
      case TMountain: canFly;
      case TLand: true;
    }

  @:transition private function update(status:UnitStatus)
    return { status: status };
}
