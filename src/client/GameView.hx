package client;

import client.Css.make in css;

class GameView extends View {
  
  @:attribute var game:GameSession;
  @:computed var availableTiles:Map<Tile, Bool> = switch game.nextUnit {
    case Some(u) if (u.owner.id == game.self.id):
      [for (info in game.availableMoves)
        game.getTile(info.x, info.y) => info.available
      ];
    default: new Map();
  }

  static var GRID = css({
    listStyle: 'none',
    '& > *': {
      display: 'flex',
    }
  });

  static var TILE = css({
    width: '90px',
    height: '60px',
    outlineOffset: '-2px',
    flexGrow: '0',
    flexShrink: '0',
    position: 'relative',
  });

  static var LAVA_MIDDLE = TILE.add(css({
    backgroundImage: 'url(../assets/lava_middle.png)',
  }));

  static var LAVA_TOP = TILE.add(css({
    backgroundImage: 'url(../assets/lava_top.png)',
  }));

  static var LAVA_BOTTOM = TILE.add(css({
    backgroundImage: 'url(../assets/lava_bottom.png)',
  }));

  static var LAVA_CELL = TILE.add(css({
    backgroundImage: 'url(../assets/lava_cell.png)',
  }));    

  static var LAND1 = TILE.add(css({
    backgroundImage: 'url(../assets/dark_grass.png)',
  }));

  static var LAND2 = TILE.add(css({
    backgroundImage: 'url(../assets/light_grass.png)',
  }));

  static var MOUNTAIN = TILE.add(css({
    background: '#444',
  }));

  static var VOID = TILE.add(css({
    background: 'black',
  }));

  static var UNIT = css({
    position: 'absolute',
    bottom: '0px',
  });

  static var ROBOT_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/robot_1.png)',
    width: '73px',
    height: '142px',
  }));

  static var ROBOT_2 = UNIT.add(css({
    backgroundImage: 'url(../assets/robot_2.png)',
    width: '85px',
    height: '112px',
  }));

  static var ROBOT_3 = UNIT.add(css({
    backgroundImage: 'url(../assets/robot_3.png)',
    width: '90px',
    height: '147px',
  }));

  static var OCTOPUS_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/octopus_1.png)',
    width: '99px',
    height: '136px',
  }));

  static var OCTOPUS_2 = UNIT.add(css({
    backgroundImage: 'url(../assets/octopus_2.png)',
    width: '93px',
    height: '125px',
  }));

  static var OCTOPUS_3 = UNIT.add(css({
    backgroundImage: 'url(../assets/octopus_3.png)',
    width: '88px',
    height: '122px',
  }));

  static var PENGUIN_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_1.png)',
    width: '77px',
    height: '100px',
  }));

  static var PENGUIN_2 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_2.png)',
    width: '116px',
    height: '100px',
  }));

  static var PENGUIN_3 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_3.png)',
    width: '97px',
    height: '108px',
  }));

  static var AVAILABLE = css({
    outline: '2px solid lime'
  });

  static var UNAVAILABLE = css({
    outline: '2px solid red'
  });

  function showAvailability(t:Tile):ClassName
    return 
      if (availableTiles.exists(t))
        if (availableTiles[t]) AVAILABLE;
        else UNAVAILABLE;
      else null;

  function renderTile(x, y) {
    var t = game.getTile(x, y);
    
    return 
      <div 
        class={
          showAvailability(t).add(
            switch t.kind {
              case TLava: 
                function getKind(delta)
                  return game.getTile(x, y + delta).kind;
                switch [getKind(-1), getKind(1)] {
                  case [TLava | TVoid, TLava | TVoid]: LAVA_MIDDLE;
                  case [_, TLava | TVoid]: LAVA_TOP;
                  case [TLava | TVoid, _]: LAVA_BOTTOM;
                  case _: LAVA_CELL;
                }
              case TMountain: MOUNTAIN;
              case TLand: 
                if ((x + y) % 2 == 0) LAND1 else LAND2;
              case TVoid: VOID;
            }
          )
        }
        onclick={
          if (availableTiles[t]) game.moveTo(x, y)
        }
      >
        <div class={
          switch game.getUnit(x, y) {
            case None: null;
            case Some(v): switch v.kind {
              case Robot1: ROBOT_1;
              case Robot2: ROBOT_2;
              case Robot3: ROBOT_3;
              case Octopus1: OCTOPUS_1;
              case Octopus2: OCTOPUS_2;
              case Octopus3: OCTOPUS_3;
              case Penguin1: PENGUIN_1;
              case Penguin2: PENGUIN_2;
              case Penguin3: PENGUIN_3;
            }
        }}></div>
      </div>;
  }

  function render()
    return <div>
      <ul class={GRID}>
        {for (y in 0...game.height)
          <li>
            {for (x in 0...game.width) renderTile(x, y)}
          </li>
        }
      </ul>
    </div>
  ;
}