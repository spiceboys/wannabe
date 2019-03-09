package game;

// import client.service.vo.ServerInfo;
import game.*;
import game.Unit;

typedef RoomId = String;

enum ClientMessage {
  JoinRoom(id:RoomId, player:Player);
  SetReady(isReady:Bool);
  GameAction(action:Action);
  Forfeit;
}

enum ServerMessage {
  RoomChanged(players:Array<Player>);
  GameStarted(init:GameInit);
  GameReaction(reactions:Array<Reaction>);
  Panic(error:String);
}

typedef GameInit = {
  final width:Int;
  final tiles:Array<TileKind>;
  final units:Array<UnitInit>;
}

typedef UnitInit = UnitStatus & {
  final id:UnitId;
  final kind:UnitKind;
  final owner:PlayerId;
}