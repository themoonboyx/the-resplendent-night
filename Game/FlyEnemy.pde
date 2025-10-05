public class FlyEnemy extends Entity {
  public FlyEnemy(JSONObject enemy) {
    super(enemy.getInt("x"), new Float(enemy.getInt("y")),  //<>//
      Float.NaN, Float.NaN, 
      81, 42, "enemies/fly", 81, Type.ENEMY);
    changeState(State.RUN);
    startVel(enemy.getBoolean("isRight"));
    setGravity(false);
    setChasing(true);
  }
  
  public float getRunVel() {return 1;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE, State.RUN};}
}
