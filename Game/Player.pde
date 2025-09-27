class Player {
  private boolean isRight = true;
  private int frame = 0;
  private State state = State.IDLE;
  private float x;
  private float y;
  private float vel_x = 0;
  private float vel_y = 0;
  
  Player() {
    x = width/2.0;
    y = height-state.frames[0].height/2.0;
  }
  
  public void advance() {
    frame++;
    x += isRight ? vel_x : -vel_x;
    if (state == State.JUMP) {
      if (y + state.frames[0].height/2.0 >= height && vel_y > 0) {
        if (vel_x == 0) changeState(State.IDLE);
        else changeState(State.RUN);
      } else {
        vel_y += 0.5;
        y += vel_y;
      }
    }
    if (isRight) image(state.frames[(frame/20)%state.frames.length], x-camera_x, y);
    else {
      pushMatrix();
      scale(-1, 1);
      image(state.frames[(frame/20)%state.frames.length], -x+camera_x, y);
      popMatrix();
    }
  }
  
  public float getX() {return x;}
  
  public State getState() {return state;}
  
  public void changeVelX(float vx) {changeVelX(vx, isRight);}
  
  public void changeVelX(float vx, boolean right) {
    vel_x = vx;
    isRight = right;
  }
  
  public void changeState(State newState) {
    changeState(newState, isRight);
  }
  
  public void changeState(State newState, boolean right) {
    isRight = right;
    if (!Float.isNaN(newState.getVelX())) vel_x = newState.getVelX();
    vel_y = newState.getVelY();
    state = newState;
  }
}
