// a platform in a room
public class Platform extends Entity {
  public Platform(JSONObject platform) { // create from dimensions specified in json file
    super(platform.getInt("x"), platform.getInt("y"), 
      platform.getInt("width"), platform.getInt("height"), 
      "platforms", Type.BLOCK);
  }
  
  // doesn't move
  public float getRunVel() {return 0;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE};}
}
