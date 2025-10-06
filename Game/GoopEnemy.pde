// ground based enemy that moves from left to right
public class GoopEnemy extends Entity {
  public GoopEnemy(JSONObject enemy) { // create from dimensions specified in json file
    super(enemy.getInt("x"), new Float(enemy.getInt("y")), 
      new Float(enemy.getInt("min_x")), new Float(enemy.getInt("max_x")), 
      90, 54, "enemies/goop", 90, Type.ENEMY);
      
    // it is always moving
    changeState(State.RUN);
    startVel(enemy.getBoolean("isRight"));
  }
  
  // medium speed
  public float getRunVel() {return 2;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE, State.RUN, State.JUMP};}
}
