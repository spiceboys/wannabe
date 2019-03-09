package client;

import client.Css.make in css;

class TileView extends View {
  @:attribute var x:Int;  
  @:attribute var y:Int;  
  @:attribute var game:GameSession;
  @:attribute var availableTiles:tink.pure.Mapping<Tile, Bool>;
  function render() {
    
    var t = game.getTile(x, y);

    function handleClick() {
      if (availableTiles[t]) 
        switch game.nextUnit {
          case Some({ moved: false }): 
            game.moveTo(x, y).handle(function (o) switch o {
              case Success(_):
                haxe.Timer.delay(function () {
                  if (Lambda.count(availableTiles) == 0) game.skip();
                }, 100);
              default:
            });
          default: 
            game.attack(x, y);
        }    
    }

    return 
      <div 
        class={
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
            case TRock: ROCK;
            case TLand: 
              if ((x + y) % 2 == 0) LAND1 else LAND2;
            case TVoid: VOID;
          }
        }
        onclick={handleClick}
      >
        {
          if (availableTiles.exists(t))
            if (availableTiles[t]) <div class={AVAILABLE} />
            else <div class={UNAVAILABLE} />
          else null
        }
      </div>;
  }  

  static var TILE = css({
    width: '90px',
    height: '60px',
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
    backgroundImage: 'url(../assets/stone_1.png)',
  }));

  static var ROCK = TILE.add(css({
    background: '#444',
    backgroundImage: 'url(../assets/stone_2.png)',
  }));

  static var VOID = TILE.add(css({
    background: 'black',
  }));

  static var HIGHLIGHT = css({
    position: 'absolute',
    top: '0',
    bottom: '0',
    left: '0',
    right: '0',
    border: '2px solid black',
    borderStyle: 'dashed',
  });

  static var AVAILABLE = HIGHLIGHT.add(css({
    cursor: 'pointer',
    backgroundColor: 'rgba(0, 200, 0, 0.25)',
    borderColor: 'rgba(0, 255, 0, 0.45)',
  }));

  static var UNAVAILABLE = HIGHLIGHT.add(css({
    cursor: 'not-allowed',
    backgroundColor: 'rgb(200, 0, 0, 0.25)',
    borderColor: 'rgba(255, 0, 0, 0.45)',
  }));

}