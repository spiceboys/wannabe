package client;

import client.Css.make in css;

class LobbyView extends View {
  
  @:attribute var players:List<Player>;
  @:attribute var self:Player;
  @:attribute var setReady:Bool->Void;
  
  static var SELF = css({
    color: 'green',
  });

  function toggleReady()
    setReady(!self.ready);

  function renderReady(ready:Bool, onclick)
    return <div onclick={onclick}>
      <if {ready}>
        Ready
      <else>
        Not Ready
      </if>
    </div>
  ;

  function renderPlayer(p:Player, index:Int)
    return <li class={[SELF => p.id == self.id]}>
      <if {p.house != null}>
        <div>{p.name}</div>
        <div>{Std.string(p.house)}</div>
        {renderReady(p.ready, if (p.id == self.id) toggleReady else null)}
      <else>
        <div><i>Undecided</i></div>
        {renderReady(p.ready, null)}
      </if>
      <br />
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