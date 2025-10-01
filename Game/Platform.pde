public class Platform extends Entity {
  public Platform(JSONObject platform) {
    super(platform.getInt("x"), platform.getInt("y"), 
      platform.getInt("width"), platform.getInt("height"), 
      "platforms", Type.BLOCK);
  }
  
  public float getRunVel() {return 0;}
  public State[] getPossibleStates() {return new State[]{State.IDLE};}
  public Entity[] getPossibleCollisions() {return new Entity[]{};}
}
