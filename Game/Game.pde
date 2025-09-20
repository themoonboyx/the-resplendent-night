Player player;
HashMap<String, Boolean> isKeyPressed = new HashMap<>();

enum State {
  IDLE(0, 0), RUN(3, 0), JUMP(0, -3);
  
  private float vel_x;
  private float vel_y;
  
  private State(float vel_x, float vel_y) {
    this.vel_x = vel_x;
    this.vel_y = vel_y;
  }
  
  public float getVelX() {return vel_x;}
  public float getVelY() {return vel_y;}
}

void setup() {
  size(400, 400);
  player = new Player();
  isKeyPressed.put("a", false);
  isKeyPressed.put("d", false);
  isKeyPressed.put("w", false);
}

void draw() {
  background(100);
  player.advance();
}

void keyPressed() {
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, true);
  switch(keyS) {
    case "a":
      player.changeState(State.RUN, false);
      break;
    case "d":
      player.changeState(State.RUN, true);
      break;
    case "w":
      player.changeState(State.JUMP);
      break;
  }
}

void keyReleased() {
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, false);
  if (!isKeyPressed.get("a") && !isKeyPressed.get("d")) player.changeState(State.IDLE);
}
