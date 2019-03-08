package game;

import pathfinder.*;

class Game implements Model {
  
  @:constant var width:Int;
  @:computed var height:Int = Math.ceil(tiles.length / width);

  @:constant private var tiles:tink.pure.Slice<Tile>;
  @:constant var players:List<Player>;
  @:observable var units:List<Unit>;
  @:computed var nextUnit:Option<Unit> = {

    var ret = None,
        delay = Math.POSITIVE_INFINITY;

    for (u in units)
      if (u.alive && u.delay < delay) {
        delay = u.delay;
        ret = Some(u);
      }

    return ret;
  }    

  @:computed @:skipCheck private var pathFinder:pathfinder.Pathfinder = new pathfinder.Pathfinder(this);

  public function getUnit(x:Int, y:Int)
    return units.first(u -> u.alive && u.x == x && u.y == y);

  public function getTile(x:Int, y:Int) 
    return switch tiles[y * width + x] {
      case null: Tile.NONE;
      case v: v;
    }

  public function getTargetTilesFor(unit:Unit):List<TileInfo> {
    var origin = new Coordinate(unit.x, unit.y);
    return [
      for (x in Std.int(Math.max(unit.x - unit.speed, 0))...Std.int(Math.min(unit.x + unit.speed + 1, width)))
        for (y in Std.int(Math.max(unit.y - unit.speed, 0))...Std.int(Math.min(unit.y + unit.speed + 1, height)))
          { x: x, y: y, available: unit.canEnter(getTile(x, y).kind) && !(unit.x == x && unit.y == y) && 
            pathFinder.createPath(origin, new Coordinate(x, y), (tileX, tileY)->unit.canEnter(getTile(tileX, tileY).kind), unit.speed) != null }
    ];
  }
}