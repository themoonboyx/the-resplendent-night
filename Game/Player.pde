class Player {
  private PImage img;
  private boolean isRight = true;
  private State state = State.IDLE;
  private float x = 0;
  private float y = 400-96;
  private float vel_x = 0;
  private float vel_y = 0;
  
  Player() {
    img = loadImage("character/character.png");
  }
  
  public void advance() {
    x += isRight ? vel_x : -vel_x;
    if (state == State.JUMP) {
      if (y + 96 >= height && vel_y > 0) {
        if (vel_x == 0) changeState(State.IDLE);
        else changeState(State.RUN);
      } else {
        vel_y += 0.1;
        y += vel_y;
      }
    }
    image(img, x, y);
  }
  
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
