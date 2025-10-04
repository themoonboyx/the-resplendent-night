public class GoopEnemy extends Entity {
  public GoopEnemy(JSONObject enemy) {
    super(enemy.getInt("x"), 90, 54, "enemies/goop", 90, Type.ENEMY);
    changeState(State.RUN);
  }
  
  public float getRunVel() {return 2;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE, State.RUN, State.JUMP};}
}
