package client;

import client.Css.make in css;

using StringTools;

class JewelView extends View {
  @:attribute var jewel:Jewel;
  function getClass()
    return switch jewel.kind {
      case Red: RED;
      case Blue: BLUE;
      case Yellow: YELLOW;
      case Purple: PURPLE;
    }

  @:computed var transform:String = 'translate(${jewel.x * 90}px, ${jewel.y * 60}px)';

  function render()
    return <div class={getClass()} style={transform}>
    </div>;

  static var JEWEL = css({
    position: 'absolute',
    pointerEvents: 'none',
    left: '0px',
    transition: 'all .35s',
  });

  static var RED = JEWEL.add(css({
    backgroundImage: 'url(../assets/jewel.png)',
    width: '94px',
    height: '120px',
    top: '-60px',
  }));

  static var BLUE = JEWEL.add(css({
    backgroundImage: 'url(../assets/jewel_blue.png)',
    width: '81px',
    height: '67px',
    top: '-7px',
  }));

  static var YELLOW = JEWEL.add(css({
    backgroundImage: 'url(../assets/jewel_yellow.png)',
    width: '75px',
    height: '60px',
    top: '0',
  }));

  static var PURPLE = JEWEL.add(css({
    backgroundImage: 'url(../assets/jewel_purple.png)',
    width: '70px',
    height: '71px',
    top: '-11px',
  }));
}