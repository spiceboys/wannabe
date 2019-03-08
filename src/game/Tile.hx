package game;

class Tile implements Model {
  @:constant var kind:TileKind; 
  static public final NONE = new Tile({ kind: TVoid });
}