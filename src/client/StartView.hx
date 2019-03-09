package client;

import client.Css.make in css;
import game.House;

class StartView extends View {
  
  @:attribute var setPlayerDetails:String->House->Void;
  
  @:state var house:House = null;
  @:state var name:String = "";
  @:ref var nameInput:js.html.InputElement;

  static var SELECTED = css({
    fontWeight: 'bold'
  });

  static var ROBOT = css({
    color: 'red',
  });

  static var OCTOPUS = css({
    color: 'purple',
  });

  static var PENGUIN = css({
    color: 'blue',
  });

  function renderHouse(h:House) {
    final cls = switch h {
      case HRobot: ROBOT;
      case HOctopus: OCTOPUS;
      case HPenguin: PENGUIN;
    }
    return
      <li class={[cls => true, SELECTED => h == house]} onclick={house = h}>
        {Std.string(h)}
      </li>
    ;
  }

  function isValidInput()
    return house != null && name.length >= 3;

  function render() {
    return <div>
      <form onsubmit={{ event.preventDefault(); setPlayerDetails(name, house); }}>
        <input ref={nameInput} value={name} oninput={name = event.src.value} placeholder="Player Name" />
        <ul>
          {for (h in [HRobot, HOctopus, HPenguin]) renderHouse(h)}
        </ul>
        <button disabled={!isValidInput()}>Start</button>
      </form>
    </div>;
  }
}