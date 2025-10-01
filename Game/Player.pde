public class Player extends Entity {
  public Player() {
    super(width/2.0, 60, 72, "player", 72, Type.SAFE);
  }
  
  public float getRunVel() {return 3;}
  
  public State[] getPossibleStates() {return State.values();}
  public Entity[] getPossibleCollisions() {return new Entity[]{e1};}
}
