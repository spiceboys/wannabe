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
    width: '87px',
    height: '169px',
  }));

  static var OCTOPUS_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/unit_2.png)',
    width: '190px',
    height: '172px',
  }));

  static var PENGUIN_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_1.png)',
    width: '77px',
    height: '100px',
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
              case Octopus1: OCTOPUS_1;
              case Penguin1: PENGUIN_1;
              case _: UNIT;
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