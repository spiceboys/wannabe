package game;

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

  @:computed var availableMoves:List<TileInfo> = switch nextUnit {
    case None: null;
    case Some(u): getTargetTilesFor(u);
  }

  @:transition function moveTo(x:Int, y:Int, by:Player) {
    switch nextUnit {
      case Some(u) if (u.owner == by):
        for (target in availableMoves)
          if (target.x == x && target.y == y) {
            if (target.available)
              return @:privateAccess u.moveTo(x, y).next(_ -> @patch {});
            break;
          }
      default: 
    }
    return new Error('illegal');
  }

  public function getUnit(x:Int, y:Int)
    return units.first(u -> u.alive && u.x == x && u.y == y);

  public function getTile(x:Int, y:Int) 
    return switch tiles[y * width + x] {
      case null: Tile.NONE;
      case v: v;
    }

  public function getTargetTilesFor(unit:Unit):List<TileInfo>
    return [
      for (x in unit.x - 1...unit.x + 2)
        for (y in unit.y - 1...unit.y + 2)
          { x: x, y: y, available: x == unit.x || y == unit.y }
    ];
}