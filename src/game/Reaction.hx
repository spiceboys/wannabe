package game;

import game.Unit;

enum Reaction {
  UnitUpdate(id:UnitId, to:UnitStatus);
  SpawnGem(id:UnitId, x:Int, y:Int);
  CollectGem(x:Int, y:Int);
}