public class Connection extends Entity {
  public Connection(JSONObject conn) {
    super(conn.getInt("x"), conn.getInt("y"), 
      conn.getInt("width"), conn.getInt("height"),
      "connections", Type.BLOCK);
  }
  
  public float getRunVel() {return 0;}
  public State[] getPossibleStates() {return new State[]{State.IDLE};}
  public Entity[] getPossibleCollisions() {return new Entity[]{};}
}
