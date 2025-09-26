Player player;
HashMap<String, Boolean> isKeyPressed = new HashMap<>(); // keeps track of which keys are being pressed
PImage background;
float camera_x = 0;
float camera_y = 0;

// states that the player can be in
enum State {
  IDLE(0, 0, "character"), RUN(3, 0, "character"), JUMP(Float.NaN, -12, "character");
  
  private float vel_x;
  private float vel_y;
  public String imgName;
  public PImage img;
  
  private State(float vel_x, float vel_y, String imgName) {
    this.vel_x = vel_x;
    this.vel_y = vel_y;
    this.imgName = "character/"+imgName+".png";
  }
  
  public float getVelX() {return vel_x;}
  public float getVelY() {return vel_y;}
}

void setup() {
  size(576, 576, P2D);
  background = loadImage("background/background0.2.png");
  for (State s : State.values()) {
    s.img = loadImage(s.imgName);
  }
  player = new Player();
  imageMode(CENTER);
  
  // add initial values to avoid glitches
  isKeyPressed.put("a", false);
  isKeyPressed.put("d", false);
  isKeyPressed.put("w", false);
  
  frameRate(60);
}

void draw() {
  if (player.getX()-camera_x > width*0.8) camera_x = player.getX()-width*0.8;
  if (player.getX()-camera_x < width*0.2) camera_x = player.getX()-width*0.2;
  
  float bg_x = floor(camera_x/background.width)*background.width+background.width/2.0-camera_x;
  image(background, bg_x, height/2.0);
  image(background, bg_x + background.width, height/2.0);
  
  player.advance(); // draw and move the player
}

// movement for player based on keyboard
void keyPressed() {
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, true);
  
  if (player.getState() == State.JUMP) { // if the player is jumping, keep jumping, but can move left and right
    if (keyS.equals("a")) player.changeVelX(State.RUN.getVelX(), false);
    if (keyS.equals("d")) player.changeVelX(State.RUN.getVelX(), true);
  } else {
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
}

void keyReleased() {
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, false);
  
  // if no left/right movement is being pressed, stop moving (horizontally)
  if (!isKeyPressed.get("a") && !isKeyPressed.get("d")) {
    if (player.getState() == State.JUMP) player.changeVelX(State.IDLE.getVelX());
    else player.changeState(State.IDLE);
  } else if (!isKeyPressed.get("a")) {
    player.changeVelX(State.RUN.getVelX(), true);
  } else if (!isKeyPressed.get("d")) {
    player.changeVelX(State.RUN.getVelX(), false);
  }
}
