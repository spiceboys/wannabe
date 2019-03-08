package client;

import client.Css.make in css;
import tink.domspec.ClassName;

class GameView extends View {
  
  @:attribute var game:GameSession;
  
  static var TILE = css({
    width: '20px',
    height: '20px',
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

  function renderTile(t:Tile)
    return 
      <td 
        class={switch t.kind {
          case TWater: WATER;
          case TMountain: MOUNTAIN;
          case TLand: LAND;
          case TVoid: VOID;
        }
      }>
        
      </td>;

  function render()
    return <div>
      <table class={TABLE}>
        {for (y in 0...game.height)
          <tr>
            {for (x in 0...game.width) renderTile(game.getTile(x, y))}
          </tr>
        }
      </table>
    </div>
  ;
}