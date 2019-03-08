package game;

interface Unit extends Model {
  var owner:Player;
  var delay:Float;
  var alive:Bool;
  var x:Int;
  var y:Int;
  var canFly:Bool;
  var canSwim:Bool;
  var speed:Int;
}