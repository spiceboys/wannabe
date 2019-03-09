package game;

typedef UnitStatus = {
  final x:Int;
  final y:Int;
  final hitpoints:Int;
  final delay:Float;
  final canFly:Bool;
  final canSwim:Bool;
  final speed:Int;  
  final frequency:Float; 
  final moved:Bool;
}

enum UnitKind {
  Robot1;
  Robot2;
  Robot3;
  Octopus1;
  Octopus2;
  Octopus3;
  Penguin1;
  Penguin2;
  Penguin3;
}

class Unit implements Model {
  
  @:constant var id:UnitId;
  @:constant var owner:Player;
  @:constant var kind:UnitKind;

  @:forward
  @:observable
  @:noCompletion
  var status:UnitStatus;
  
  @:computed var alive:Bool = hitpoints > 0;
  
  public function canEnter(terrain:TileKind)
    return switch terrain {
      case TVoid: false;
      case TLava: canFly || canSwim;
      case TMountain: canFly;
      case TLand: true;
    }

  @:transition private function update(status:UnitStatus)
    return { status: status };
}
