package game;

import pathfinder.*;

class Game implements Model {
  
  @:constant var width:Int;
  @:computed var height:Int = Math.ceil(tiles.length / width);

  @:constant var service:PlayerId->Action->Promise<Array<Reaction>> = runLocally;

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

  @:computed var availableMoves:List<TileInfo> = switch nextUnit {
    case None: null;
    case Some(u): getTargetTilesFor(u);
  }

  function runLocally(player:PlayerId, action:Action):Promise<Array<Reaction>>
    return switch action {
      case Move(x, y):
        switch nextUnit {
          case Some(u) if (u.owner.id == player): 
            var ret:Promise<Array<Reaction>> = new Error('illegal');
            for (target in availableMoves)
              if (target.x == x && target.y == y) {
                if (target.available)
                  ret = [UnitUpdate(u.id, tink.Anon.merge(u.status, x = x, y = y, delay = u.delay + u.frequency))];
                break;
              }          
            ret;
          default: new Error('illegal move');
        }
    }

  function unitById(id) {
    for (u in units)
      if (u.id == id) return Some(u);
    return None;
  }

  function apply(reactions:Array<Reaction>) {
    for (r in reactions) switch r {
      case UnitUpdate(id, to):
        switch unitById(id) {
          case None: //TODO: panic or something
          case Some(u):
            @:privateAccess u.update(to);
        }
    }
    return reactions;
  } 

  public function dispatch(p:PlayerId, action:Action) {
    var ret = service(p, action);
    ret.handle(@do switch _ {
      case Success(updates): apply(updates);
      case Failure(e): //TODO: panic or something
    });
    return ret;
  }

  @:transition function moveTo(x:Int, y:Int, by:Player) 
    return dispatch(by.id, Move(x, y)).next(_ -> @patch {});

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
      for (x in unit.x - unit.speed...unit.x + unit.speed + 1)
        for (y in unit.y - unit.speed...unit.y + unit.speed + 1) if(Math.abs(unit.x - x) + Math.abs(y - unit.y) <= unit.speed)
          { x: x, y: y, available: unit.canEnter(getTile(x, y).kind) && !units.exists(u -> u.x == x && u.y == y) &&
            pathFinder.createPath(origin, new Coordinate(x, y), (tileX, tileY)->unit.canEnter(getTile(tileX, tileY).kind), false, true, unit.speed) != null }
    ];
  }
}