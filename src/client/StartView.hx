package client;

import client.Css.make in css;
import game.House;

class StartView extends View {
  
  @:attribute var setPlayerDetails:String->House->Void;
  
  static function randomizer<T>(a:Array<T>)
    return function () return a[Std.random(a.length)];
  
  static final randomHouse = randomizer(haxe.EnumTools.createAll(House));
  static final firstName = randomizer(['Emma', 'Olivia', 'Ava', 'Isabella', 'Sophia', 'Mia', 'Charlotte', 'Amelia', 'Evelyn', 'Abigail', 'Harper', 'Emily', 'Elizabeth', 'Avery', 'Sofia', 'Ella', 'Madison', 'Scarlett', 'Victoria', 'Aria', 'Grace', 'Chloe', 'Camila', 'Penelope', 'Riley', 'Layla', 'Lillian', 'Nora', 'Zoey', 'Mila', 'Aubrey', 'Hannah', 'Lily', 'Addison', 'Eleanor', 'Natalie', 'Luna', 'Savannah', 'Brooklyn', 'Leah', 'Zoe', 'Stella', 'Hazel', 'Ellie', 'Paisley', 'Audrey', 'Skylar', 'Violet']);
  static final lastName = randomizer(['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez', 'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez', 'King', 'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter', 'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards', 'Collins', 'Stewart', 'Sanchez', 'Morris', 'Rogers', 'Reed', 'Cook', 'Morgan', 'Bell', 'Murphy', 'Bailey', 'Rivera', 'Cooper', 'Richardson', 'Cox', 'Howard', 'Ward', 'Torres', 'Peterson', 'Gray', 'Ramirez', 'James', 'Watson', 'Brooks', 'Kelly', 'Sanders', 'Price', 'Bennett', 'Wood', 'Barnes', 'Ross', 'Henderson', 'Coleman', 'Jenkins', 'Perry', 'Powell', 'Long', 'Patterson', 'Hughes', 'Flores', 'Washington', 'Butler', 'Simmons', 'Foster', 'Gonzales', 'Bryant', 'Alexander', 'Russell', 'Griffin', 'Diaz', 'Hayes']);
  static final randomName = () -> '${firstName()} ${lastName()}';

  @:state var house:House = randomHouse();
  @:state var name:String = randomName();
  @:ref var nameInput:js.html.InputElement;

  static var SELECTED = css({
    fontWeight: 'bold',
    transform: "scale(1.2, 1.2)"
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

  static var INPUT = css({
    marginTop: "40px",
    fontSize: "35px"
  });

  static var H1 = css({
    color: "#f1f1f1",
    fontSize: "70px"
  });

  static var PAGE = css({
    backgroundColor: "#92c16f",
    height: "100vh",
    textAlign: "center",
    padding: "50px"
  });
  
  static var UL = css({
    display: "flex",
    justifyContent: "space-evenly",
    marginTop: "80px"
  });
  
  static var DESC = css({
    margin: "40px 0",
    color: "#f1f1f1",
    fontSize: "80px"
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

  function renderHouse(h:House) {
    final cls = switch h {
      case HRobot: ROBOT;
      case HOctopus: OCTOPUS;
      case HPenguin: PENGUIN;
    }
    
    final stringVal = switch h {
      case HRobot: "robot";
      case HOctopus: "octopus";
      case HPenguin: "penguin";
    }


    return
      <li class={[cls => true, SELECTED => h == house]} onclick={house = h}>
        <img src={"./assets/select_" + stringVal + ".png"}/>
      </li>
    ;
  }
  function renderDescription() {
    return switch(house) {
      case HRobot: "House of Robots";
      case HOctopus: "House of Octopuses";
      case HPenguin: "House of Penguins";
    }
  }
  function isValidInput()
    return house != null && name.length >= 3;

  function render() {
    return <div class={[PAGE]}>
      <h1 class={[H1]}>CHOOSE YOUR HOUSE AND NAME:</h1>
      <form onsubmit={{ event.preventDefault(); setPlayerDetails(name, house); }}>
        <input class={INPUT} ref={nameInput} value={name} oninput={name = event.src.value} placeholder="Player Name" />
        <ul class={UL}>
          {for (h in [HRobot, HOctopus, HPenguin]) renderHouse(h)}
        </ul>
        <div class={DESC}>
          {renderDescription()}
        </div>
        <button class={BTN} disabled={!isValidInput()}>Start</button>
      </form>
    </div>;
  }
}