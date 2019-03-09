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

  public function canAttack(attacker:Unit, target:Unit, withObstacles = false) {
    var retVal = attacker != target && attacker.owner != target.owner && 
      Math.pow(attacker.y - target.y, 2) + Math.pow(attacker.x - target.x, 2) <= Math.pow(attacker.status.range, 2) * 2;

    if (retVal && withObstacles) {}

    return retVal;
  }

  public function computeDamage(attacker:Unit, target:Unit)
    return 1;

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
      units: getChosenUnits(players),
    }
  }

  function getChosenUnits(players:Array<TPlayer>)
    return [for (p in players) for (u in getHouseUnits(p)) u];

  function getHouseUnits(player:Player)
    return switch player.house {
      case HOctopus: [
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Octopus1,
          status: {
            range: 2,
            moved: false,
            delay: 0,
            hitpoints: 15,
            maxHitpoints: 15,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 3,
          }
        }),
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Octopus2,
          status: {
            range: 1,
            moved: false,
            delay: 0,
            hitpoints: 15,
            maxHitpoints: 15,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 2,
          }
        }),
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Octopus3,
          status: {
            range: 3,
            moved: false,
            delay: 0,
            hitpoints: 15,
            maxHitpoints: 15,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 2,
          }
        }),
      ];
      case HRobot: [
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Robot1,
          status: {
            range: 4,
            moved: false,
            delay: 0,
            hitpoints: 10,
            maxHitpoints: 10,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 5,
          }
        }),
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Robot2,
          status: {
            range: 2,
            moved: false,
            delay: 0,
            hitpoints: 12,
            maxHitpoints: 12,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 3,
          }
        }),
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Robot3,
          status: {
            range: 4,
            moved: false,
            delay: 0,
            hitpoints: 11,
            maxHitpoints: 11,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 2,
          }
        }),
      ];
      case HPenguin: [
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Penguin1,
          status: {
            range: 1,
            moved: false,
            delay: 0,
            hitpoints: 14,
            maxHitpoints: 14,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 4,
          }
        }),
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Penguin2,
          status: {
            range: 5,
            moved: false,
            delay: 0,
            hitpoints: 11,
            maxHitpoints: 11,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 2,
          }
        }),
        new Unit({
          owner: player,
          id: new UnitId(),
          kind: Penguin3,
          status: {
            range: 3,
            moved: false,
            delay: 0,
            hitpoints: 12,
            maxHitpoints: 12,
            x: 10,
            y: 5,
            frequency: 1,
            canFly: false,
            canSwim: false,
            speed: 3,
          }
        }),
      ];
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

  @:computed @:skipCheck private var pathFinder:Pathfinder = {
    tiles;
    new Pathfinder(this);
  }

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

      case Attack(x, y):
        switch nextUnit {
          case Some(u) if (u.owner.id == player): 
            switch getUnit(x, y) {
              case Some(target) if (canAttack(u, target)):
                [
                  UnitUpdate(u.id, tink.Anon.merge(u.status, moved = false, delay = u.delay + u.frequency)),
                  UnitUpdate(target.id, tink.Anon.merge(target.status, hitpoints = target.hitpoints - computeDamage(u, target)))
                ];
              default:
                new Error('illegal');
            }
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

  @:transition function attack(x:Int, y:Int, by:TPlayer)
    return dispatch(by.id, Attack(x, y)).next(_ -> @patch {});

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