class Player {
  PImage img;
  boolean isRight = true;
  State state = State.IDLE;
  float x = 0;
  float y = 400-96;
  float vel_x = 0;
  float vel_y = 0;
  
  Player() {
    img = loadImage("character/character.png");
  }
  
  void advance() {
    x += vel_x;
    if (state == State.JUMP) {
      vel_y += 0.1;
      y += vel_y;
    }
    image(img, x, y);
  }
  
  void changeState(State newState) {
    changeState(newState, isRight);
  }
  
  void changeState(State newState, boolean right) {
    isRight = right;
    if (state == State.JUMP) return;
    vel_x = newState.getVelX();
    vel_y = newState.getVelY();
    if (!isRight) vel_x *= -1;
    state = newState;
  }
}
