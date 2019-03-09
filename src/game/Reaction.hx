package game;

import game.Unit;

enum Reaction {
  UnitUpdate(id:UnitId, to:UnitStatus);
  SpawnGem(unit:Unit);
  CollectGem(x:Int, y:Int);
}