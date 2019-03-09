package game;

import pathfinder.*;
import game.Protocol;
import tink.pure.Slice;

typedef Game = GameOf<Player>;

class GameOf<TPlayer:Player> implements Model {
  
  @:constant var id:String;
  @:observable var width:Int = @byDefault 0;
  @:computed var height:Int = Math.ceil(tiles.length / width);

  @:observable var running:Bool = false;
  @:constant var service:PlayerId->Action->Promise<Array<Reaction>> = @byDefault runLocally;

  @:observable private var tiles:Slice<Tile> = @byDefault [];
  @:observable var players:List<TPlayer> = @byDefault null;
  @:observable var units:List<Unit> = @byDefault null;

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

  #if server

  @:transition function addPlayer(p:TPlayer)
    return 
      if (running) new Error('illegal');
      else { players: players.append(p) }; 

  @:transition function disconnectPlayer(p:TPlayer)
    return { players: players.filter(keep -> keep.id != p.id )};

  @:transition function changePlayer(nu:TPlayer) {
    if (!running) {
      var players = players.toArray();
      for (i in 0...players.length)
        if (players[i].id == nu.id) {
          players[i] = nu;
          return { 
            players: List.fromArray(players),
          };
        }
    }
    return new Error('invalid');
  }

  @:transition function _startGame() {
    var tiles = [TileKind.TLand, TileKind.TLand, TileKind.TLand],
        size = 20,
        players = players.toArray();
    return @patch { 
      width: size,
      running: true,
      tiles: [
        for (s in 0...size * size)
          new Tile({ kind: tiles[Std.random(tiles.length)]})
      ],
      units: [
        new Unit({
          owner: players[0],
          id: new UnitId(),
          kind: Penguin1,
          status: {
            moved: false,
            delay: 0,
            hitpoints: 100,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 6,
          }
        }),
        new Unit({
          owner: players[1],
          id: new UnitId(),
          kind: Octopus1,
          status: {
            moved: false,
            delay: 0,
            hitpoints: 100,
            x: 10,
            y: 15,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 6,
          }
        })         
      ]
    }
  }
  public function startGame():GameInit {
    _startGame();
    return {
      width: width,
      tiles: [for (t in tiles) t.kind],
      units: [for (u in units) tink.Anon.merge(u.status, id = u.id, owner = u.owner.id, kind = u.kind)],
    }
  }

  #else
  @:transition private function startGame(init:GameInit) {
    var players = [for (p in players) p.id => p];
    return @patch {
      running: true,
      width: init.width,
      tiles: [for (t in init.tiles) new Tile({ kind: t })],
      units: [for (u in init.units) new Unit({ status: u, id: u.id, owner: players[u.owner], kind: u.kind })],
    };
  }

  @:transition private function updatePlayers(players:Array<TPlayer>) 
    return { players: List.fromArray(players) };
  #end

  @:computed @:skipCheck private var pathFinder:pathfinder.Pathfinder = new pathfinder.Pathfinder(this);

  @:computed var availableMoves:List<TileInfo> = switch nextUnit {
    case None: null;
    case Some(u): getTargetTilesFor(u);
  }

  function runLocally(player:PlayerId, action:Action):Promise<Array<Reaction>>
    return switch action {
      case Move(x, y):
        switch nextUnit {
          case Some(u) if (u.owner.id == player && !u.moved): 
            var ret:Promise<Array<Reaction>> = new Error('illegal');
            for (target in availableMoves)
              if (target.x == x && target.y == y) {
                if (target.available)
                  ret = [UnitUpdate(u.id, tink.Anon.merge(u.status, x = x, y = y, moved = true))];
                break;
              }
            ret;
          default: new Error('illegal move');
        }
      case Skip:
        switch nextUnit {
          case Some(u) if (u.owner.id == player): 
            if (u.moved)
              [UnitUpdate(u.id, tink.Anon.merge(u.status, moved = false, delay = u.delay + u.frequency / 2))];            
            else
              [UnitUpdate(u.id, tink.Anon.merge(u.status, moved = true))];
          default: new Error('illegal move');
        }      
    }

  function unitById(id) {
    for (u in units)
      if (u.id == id) return Some(u);
    return None;
  }
  static final console = 
    #if nodejs 
       js.Node.console;
    #else
      js.Browser.console;
    #end

  function apply(reactions:Array<Reaction>) {
    
    for (r in reactions) switch r {
      case UnitUpdate(id, to):
        switch unitById(id) {
          case None:
            console.error('unit not found $id');
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

  @:transition function moveTo(x:Int, y:Int, by:TPlayer) 
    return dispatch(by.id, Move(x, y)).next(_ -> @patch {});

  @:transition function skip(by:TPlayer) 
    return dispatch(by.id, Skip).next(_ -> @patch {});

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
        for (y in Std.int(Math.max(unit.y - unit.speed, 0))...Std.int(Math.min(unit.y + unit.speed + 1, height))) if(Math.abs(unit.x - x) + Math.abs(y - unit.y) <= unit.speed)
          { x: x, y: y, available: unit.canEnter(getTile(x, y).kind) && !units.exists(u -> u.x == x && u.y == y) &&
            pathFinder.createPath(origin, new Coordinate(x, y), (tileX, tileY)->unit.canEnter(getTile(tileX, tileY).kind), false, true, unit.speed) != null }
    ];
  }

}