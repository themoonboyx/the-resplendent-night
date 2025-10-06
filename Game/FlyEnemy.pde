// fly-like enemy that chases player
public class FlyEnemy extends Entity {
  public FlyEnemy(JSONObject enemy) { // create from dimensions specified in json file
    super(enemy.getInt("x"), new Float(enemy.getInt("y")),  //<>//
      Float.NaN, Float.NaN, 
      81, 42, "enemies/fly", 81, Type.ENEMY);
    
    // it is always moving and chasing towards the player
    changeState(State.RUN);
    startVel(enemy.getBoolean("isRight"));
    setGravity(false);
    setChasing(true);
  }
  
  // it is fairly slow
  public float getRunVel() {return 1;}
  
  public State[] getPossibleStates() {return new State[]{State.IDLE, State.RUN};}
}
