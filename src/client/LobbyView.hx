package client;

import client.Css.make in css;

class LobbyView extends View {
  
  @:attribute var players:List<Player>;
  @:attribute var self:PlayerId;
  
  @:computed var isAdmin:Bool = switch players.first() {
    case Some(p): p.id == self;
    default: false;
  }

  static var ADMIN = css({
    background: 'red',
  });
  static var SELF = css({
    border: 'green',
  });

  function renderPlayer(p:Player, index:Int) 
    return <li class={[ADMIN => index == 0, SELF => p.id == self]}>
      {p.name}
    </li>
  ;

  function render() {
    var players = players.toArray();
    return <div>
      <ul>
        {for (i in 0...players.length) renderPlayer(players[i], i)}
      </ul>
    </div>;
  }
}