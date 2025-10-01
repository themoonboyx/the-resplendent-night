public class GoopEnemy extends Entity {
  public GoopEnemy() {
    super(width/5.0, "enemies/goop", 90, Type.ENEMY);
    changeState(State.RUN);
  }
  
  public float getRunVel() {return 2;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE, State.RUN};}
  public Entity[] getPossibleCollisions() {return new Entity[]{};}
}
