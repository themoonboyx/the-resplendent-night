public class Player extends Entity {
  public Player() {
    super(width/3.0, Float.NaN, Float.NaN, 60, 72, "player", 72, Type.PLAYER);
  }
  
  public float getRunVel() {return 3;}
  
  public State[] getPossibleStates() {return State.values();}
}
