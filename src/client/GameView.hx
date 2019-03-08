package client;

import client.Css.make in css;

class GameView extends View {
  
  @:attribute var game:GameSession;
  @:computed var availableTiles:Map<Tile, Bool> = switch game.nextUnit {
    case None: new Map();
    case Some(_):
      [for (info in game.availableMoves)
        game.getTile(info.x, info.y) => info.available
      ];
  }
  
  static var TILE = css({
    width: '20px',
    height: '20px',
    outlineOffset: '-2px',
  });

  static var WATER = TILE.add(css({
    background: 'blue',
  }));

  static var LAND = TILE.add(css({
    background: 'green',
  }));

  static var MOUNTAIN = TILE.add(css({
    background: '#444',
  }));

  static var VOID = TILE.add(css({
    background: 'black',
  }));

  static var TABLE = css({
    borderSpacing: '0',
  });

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
      <td 
        class={
          showAvailability(t).add(
            switch t.kind {
              case TWater: WATER;
              case TMountain: MOUNTAIN;
              case TLand: LAND;
              case TVoid: VOID;
            }
          )
        }
        onclick={
          if (availableTiles[t]) game.moveTo(x, y)
        }
      >
        {switch game.getUnit(x, y) {
          case None: null;
          case Some(_): 'X';
        }}
      </td>;
  }

  function render()
    return <div>
      <table class={TABLE}>
        {for (y in 0...game.height)
          <tr>
            {for (x in 0...game.width) renderTile(x, y)}
          </tr>
        }
      </table>
    </div>
  ;
}