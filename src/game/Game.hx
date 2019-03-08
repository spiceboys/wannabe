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

  public function getUnit(x:Int, y:Int)
    return units.first(u -> u.alive && u.x == x && u.y == y);

  public function getTile(x:Int, y:Int) 
    return switch tiles[y * width + x] {
      case null: Tile.NONE;
      case v: v;
    }
}