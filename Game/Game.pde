public Player player;
public Room[] rooms;
public Room currentRoom;
public HashMap<String, Boolean> isKeyPressed = new HashMap<>(); // keeps track of which keys are being pressed
public PImage background;
public PImage heart;
public float camera_x = 0;
public float camera_y = 0;
public float gravity = 0.5;
public JSONObject json;

// states that the player can be in
public enum State {
  IDLE(0, "idle"), RUN(0, "run"), JUMP(-12, "jump");
  
  private float vel_y;
  private String imgName;
  
  private State(float vel_y, String imgName) {
    this.vel_y = vel_y;
    this.imgName = imgName+".png";
  }
  
  public float getVelY() {return vel_y;}
  public String getImgName() {return imgName;}
}

public enum Type {SAFE, ENEMY, BLOCK};

public void setup() {
  size(576, 576, P2D);
  background = loadImage("background/background0.2.png");
  heart = loadImage("UI/heart.png");
  loadData();
  currentRoom = rooms[0];
  player = new Player();
  
  // add initial values to avoid glitches
  isKeyPressed.put("a", false);
  isKeyPressed.put("d", false);
  isKeyPressed.put("w", false);
  
  frameRate(60);
}

public void draw() {
  if (player.getX() >= currentRoom.getWidth()) enterRoom(currentRoom.getNext());
  
  camera_x = player.getX() - width/2.0 + player.getImg().width/2.0;
  if (camera_x < 0) camera_x = 0;
  else if (camera_x > currentRoom.getWidth() - width) camera_x = currentRoom.getWidth() - width;
  
  float bg_x = floor(camera_x/background.width)*background.width-camera_x;
  image(background, bg_x, 0);
  image(background, bg_x + background.width, 0);
  
  currentRoom.advance();
  player.advance(); // draw and move the player
  drawUI();
}

// movement for player based on keyboard
public void keyPressed() {
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, true);
  
  if (player.getState() == State.JUMP) { // if the player is jumping, keep jumping, but can move left and right
    if (keyS.equals("a")) player.startVel(false); //<>//
    if (keyS.equals("d")) player.startVel(true);
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

public void keyReleased() {
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, false);
  
  // if no left/right movement is being pressed, stop moving (horizontally)
  if (!isKeyPressed.get("a") && !isKeyPressed.get("d")) {
    if (player.getState() == State.JUMP) player.stopVel();
    else player.changeState(State.IDLE);
  } else if (!isKeyPressed.get("a")) {
    player.startVel(true);
  } else if (!isKeyPressed.get("d")) {
    player.startVel(false);
  }
}

public void loadData() {
  json = loadJSONObject("rooms.json");
  JSONArray roomData = json.getJSONArray("rooms");
  rooms = new Room[roomData.size()];
  
  for (int i = 0; i < roomData.size(); i++) {
    rooms[i] = new Room(roomData.getJSONObject(i), i);
  }
}

public void drawUI() {
  for (int i = 0; i < player.getHealth(); i++) {
    image(heart, 18+i*heart.width*1.25, 18);
  }
}

public void enterRoom(Room newRoom) {
  currentRoom = newRoom;
}
