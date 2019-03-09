package client;

import client.Css.make in css;

class GameView extends View {
  
  @:attribute var game:GameSession;
  @:computed var busy:Bool = game.isInTransition;

  @:computed var availableTiles:tink.pure.Mapping<Tile, Bool> = switch game.nextUnit {
    case Some(u) if (u.owner.id == game.self.id && !busy):
      if (u.moved)
        [for (target in game.units) if (game.canAttack(u, target))
          game.getTile(target.x, target.y) => true
        ];
      else
        [for (info in game.availableMoves)
          game.getTile(info.x, info.y) => info.available
        ];
    default: new Map();
  }

  static final PLAYER_COLORS = [
    '#fcbe1c', 
    '#59e334',
    '#f91ffc',
    '#dffc18',
  ];

  function getPlayerColor(p:PlayerId) {
    var players = game.players.toArray();
    for (i in 0...players.length)
      if (players[i].id == p)
        return PLAYER_COLORS[i];
    return '#888';
  }

  static final ROOT = css({
    position: 'relative',
  });

  static final GRID = css({
    listStyle: 'none',
    '& > *': {
      display: 'flex',
    }
  });

  static final ACTIONS = css({
    position: 'fixed',
    bottom: '10px',
    right: '10px',
    button: {
      padding: '1em'
    }
  });

  static final SCORE = css({
    position: 'fixed',
    top: '20px',
    left: '20px',
    right: '20px',
    zIndex: '1000',
    pointerEvents: 'none',
    display: 'flex',
    padding: '20px',
    justifyContent: 'space-around',
    background: 'rgba(0, 0, 0, .45)',
    color: 'white',
  });

  static final NOTIFICATIONS = css({
    position: 'fixed',
    bottom: '10px',
    left: '50%',
  });

  function render()
    return <div class={ROOT}>
      <ul class={GRID}>
        {for (y in 0...game.height)
          <li>
            {for (x in 0...game.width) <TileView x={x} y={y} {...this} />}
          </li>
        }
      </ul>
      {for (u in game.units)
        <UnitView 
          unit={u} 
          isCurrent={switch game.nextUnit {
            case Some(cur): cur == u;
            default: false;
          }} 
          key={u} 
          color={getPlayerColor(u.owner.id)} 
        />
      }
      {for (j in game.jewels)
        <JewelView jewel={j} />
      }
      <Isolated>
        <div class={SCORE}>
          {for (p in game.players)
            <div style={{ color: getPlayerColor(p.id) }}>{p.name}: {p.jewels}</div>
          }
        </div>
      </Isolated>
      <Isolated>
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
      </Isolated>
      <Isolated>
        <div class={NOTIFICATIONS}>
          {
            switch game.winner {
              case Some(winner): 
                if (winner.id == game.self.id) "You Rule!";
                else "You Suck! " + winner.name + " Rules!";
              case None:
                if (game.survivingPlayers.exists(p -> p.id == game.self.id)) "";
                else "You Suck!";
            }
          }
        </div>
      </Isolated>
    </div>
  ;
}