package client;

import client.Css.make in css;

class LobbyView extends View {
  
  @:attribute var players:List<Player>;
  @:attribute var self:Player;
  @:attribute var setReady:Bool->Void;
  
  static var SELF = css({
    color: 'green',
  });

  static var H1 = css({
    color: "#f1f1f1",
    fontSize: "70px"
  });

  static var PAGE = css({
    fontSize: '50px',
    backgroundColor: "#92c16f",
    height: "100vh",
    textAlign: "center",
    padding: "50px",
    color: "#f1f1f1"
  });

  static var PLAYER = css({
    margin: "50px"
  });
  
  static var IMG = css({
    height: "300px"
  });

  static var LIST = css({
    display: 'flex',
    justifyContent: "space-evenly",
    listStyle: "none"
  });

  static var BTN = css({
    fontSize: "50px",
    width: "300px",
    height: "80px",
    backgroundColor: "#86e923",
    borderStyle: "none",
    borderBottom: "10px solid #60bc03",
    color: "#f1f1f1",
    cursor: "pointer"
  });

  function toggleReady()
    setReady(!self.ready);

  function renderReady(ready:Bool, onclick) {
    var txt = (ready) ? "READY" : "NOT READY";
    
    return <div onclick={onclick}>
      <if {onclick != null}>
        <button class={BTN}>{txt}</button>
      <else>
        {txt}
      </if>
    </div>
  ;
  }

  function renderPlayer(p:Player, index:Int)
    return <li class={[SELF => p.id == self.id]}>
      <if {p.house != null}>
        <div>{p.name}</div>
        <div>
          <img class={[IMG]} src={"./assets/lobby_" + Std.string(p.house).toLowerCase().substring(1) + ".png"} />
        </div>
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
    return <div class={[PAGE]}>
      <h1>GET READY!</h1>
      <ul class={LIST}>
        {for (i in 0...players.length) renderPlayer(players[i], i)}
      </ul>
    </div>;
  }
}