package game;

import game.Unit;

enum Reaction {
  UnitUpdate(id:UnitId, to:UnitStatus);
  SpawnGem(id:UnitId, x:Int, y:Int);
  CollectGem(playerId:String, x:Int, y:Int);
}