public class FlyEnemy extends Entity {
  public FlyEnemy(JSONObject enemy) {
    super(enemy.getInt("x"), new Float(enemy.getInt("y")),  //<>//
      new Float(enemy.getInt("min_x")), new Float(enemy.getInt("max_x")), 
      81, 42, "enemies/fly", 81, Type.ENEMY);
    changeState(State.RUN);
    startVel(enemy.getBoolean("isRight"));
    setGravity(false);
  }
  
  public float getRunVel() {return 2;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE, State.RUN, State.JUMP};}
}
