// entrance/exit connecting a room to another
public class Connection extends Entity {
  public Connection(JSONObject conn) { // create from dimensions specified in json file
    super(conn.getInt("x"), conn.getInt("y"), 
      conn.getInt("width"), conn.getInt("height"),
      "connections", Type.BLOCK);
  }
  
  // doesn't move
  public float getRunVel() {return 0;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE};}
}
