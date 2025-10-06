// the player character
public class Player extends Entity {
  public Player() { // player will always have the same dimensions
    super(75, Float.NaN, Float.NaN, Float.NaN, 60, 72, "player", 72, Type.PLAYER);
  }
  
  // fairly fast
  public float getRunVel() {return 3;}
  
  // has animations for all possible states
  public State[] getPossibleStates() {return State.values();}
}
