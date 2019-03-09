package client;

import client.Css.make in css;

class GameView extends View {
  
  @:attribute var game:GameSession;
  @:computed var busy:Bool = game.isInTransition;

  @:computed var availableTiles:Map<Tile, Bool> = switch game.nextUnit {
    case Some(u) if (u.owner.id == game.self.id && !busy && !u.moved):
      [for (info in game.availableMoves)
        game.getTile(info.x, info.y) => info.available
      ];
    default: new Map();
  }

  static var ROOT = css({
    position: 'relative',
  });

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
      </div>;
  }

  static var ACTIONS = css({
    position: 'fixed',
    bottom: '10px',
    right: '10px',
    button: {
      padding: '1em'
    }
  });

  function render()
    return <div class={ROOT}>
      <ul class={GRID}>
        {for (y in 0...game.height)
          <li>
            {for (x in 0...game.width) renderTile(x, y)}
          </li>
        }
      </ul>
      {for (u in game.units)
        <UnitView unit={u} />
      }
      <div class={ACTIONS}>
        {
          if (game.isMyTurn)
            <button onclick={game.skip()}>{
              switch game.nextUnit {
                case Some({ moved: false }): 'Skip Move';
                default: 'Skip Attack';
              }
            }</button>
        }
      </div>
    </div>
  ;
}