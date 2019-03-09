package client;

import client.Css.make in css;

using StringTools;

class UnitView extends View {
  @:attribute var unit:Unit;
  @:attribute var color:Int = 0x00AA00;
  function getClass()
    return switch unit.kind {
      case Robot1: ROBOT_1;
      case Robot2: ROBOT_2;
      case Robot3: ROBOT_3;
      case Octopus1: OCTOPUS_1;
      case Octopus2: OCTOPUS_2;
      case Octopus3: OCTOPUS_3;
      case Penguin1: PENGUIN_1;
      case Penguin2: PENGUIN_2;
      case Penguin3: PENGUIN_3;
    }

  @:computed var transform:String = 'translate(${unit.x * 90}px, ${unit.y * 60}px)';

  function render()
    return <div class={getClass()} style={{ transform: transform }}>
      <div class={HEALTHBAR} style={{ background: '#' + color.hex(6) }}>
        <div style={{ height: '100%', width: 100 * (1 - unit.hitpoints / unit.maxHitpoints) + '%'}} />
      </div>
    </div>;

  static var HEALTHBAR = css({
    width: '80px',
    height: '8px',
    position: 'relative',
    top: '-20px',
    boxShadow: '1px 1px 3px 1px black',
    '&>div': {
      background: 'rgba(0, 0, 0, 0.4)',
    }
  });

  static var UNIT = css({
    position: 'absolute',
    pointerEvents: 'none',
    left: '0px',
    transition: 'all .35s',
  });

  static var ROBOT_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/robot_1.png)',
    width: '73px',
    height: '142px',
    top: '-82px',
  }));

  static var ROBOT_2 = UNIT.add(css({
    backgroundImage: 'url(../assets/robot_2.png)',
    width: '85px',
    height: '112px',
    top: '-52px',
  }));

  static var ROBOT_3 = UNIT.add(css({
    backgroundImage: 'url(../assets/robot_3.png)',
    width: '90px',
    height: '147px',
    top: '-87px',
  }));

  static var OCTOPUS_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/octopus_1.png)',
    width: '99px',
    height: '136px',
    top: '-76px',
  }));


  static var OCTOPUS_2 = UNIT.add(css({
    backgroundImage: 'url(../assets/octopus_2.png)',
    width: '93px',
    height: '125px',
    top: '-65px',
  }));

  static var OCTOPUS_3 = UNIT.add(css({
    backgroundImage: 'url(../assets/octopus_3.png)',
    width: '88px',
    height: '122px',
    top: '-62px',
  }));

  static var PENGUIN_1 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_1.png)',
    width: '77px',
    height: '100px',
    top: '-60px',
  }));

  static var PENGUIN_2 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_2.png)',
    width: '116px',
    height: '100px',
    top: '-40px'
  }));

  static var PENGUIN_3 = UNIT.add(css({
    backgroundImage: 'url(../assets/penguin_3.png)',
    width: '97px',
    height: '108px',
    top: '-48px',
  }));    
}