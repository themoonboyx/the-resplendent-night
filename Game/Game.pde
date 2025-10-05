public Player player;
public Room[] rooms;
public Room currentRoom;
public GameState gameState = GameState.TITLE;
public HashMap<String, Boolean> isKeyPressed = new HashMap<>(); // keeps track of which keys are being pressed
public HashMap<GameState, PImage> backgrounds = new HashMap<>();
public PImage[] level = new PImage[3];
public float camera_x = 0;
public float camera_y = 0;
public float gravity = 0.5;
public JSONObject json;

// states that the player can be in
public enum State {
  IDLE(0, "idle", false), RUN(0, "run", false), JUMP_UP(-12, "jump-", true), JUMP(0, "jump", true), JUMP_DOWN(0, "jump+", true);
  
  private float vel_y;
  private String imgName;
  private boolean inAir;
  
  private State(float vel_y, String imgName, boolean inAir) {
    this.vel_y = vel_y;
    this.imgName = imgName+".png";
    this.inAir = inAir;
  }
  
  public float getVelY() {return vel_y;}
  public String getImgName() {return imgName;}
  public boolean isInAir() {return inAir;}
}

public enum Type {PLAYER, ENEMY, BLOCK};

public enum GameState {
  TITLE("titleScreen"), SELECT("selectScreen"), PLAYING("background");
  
  private String imgName;
  
  private GameState(String folder) {
    this.imgName = folder+"/background.png";
  }
  
  public String getImgName() {return imgName;}
}

public void setup() {
  size(576, 576, P2D);
  textSize(30);
  for (GameState gs : GameState.values()) {
    backgrounds.put(gs, loadImage(gs.getImgName()));
  }
  
  PImage l = loadImage("selectScreen/level.png");
  for (int i = 0; i < level.length; i++) {
    level[i] = l.get(i*l.width/level.length, 0, l.width/level.length, l.height);
  }
  player = new Player();
  loadData();
  currentRoom = null;
  
  // add initial values to avoid glitches
  isKeyPressed.put("a", false);
  isKeyPressed.put("d", false);
  isKeyPressed.put("w", false);
  
  frameRate(60);
}

public void draw() {
  switch(gameState) {
    case TITLE:
    drawTitle();
    break;
    case SELECT:
    drawSelect();
    break;
    case PLAYING:
    drawPlaying();
    break;
  }
}

public void drawTitle() {
  gameState = GameState.SELECT;
  image(backgrounds.get(GameState.TITLE), 0, 0);
}

public void drawSelect() {
  image(backgrounds.get(GameState.SELECT), 0, 0);
  currentRoom = null;
  for (int i = 0; i < rooms.length; i++) {
    float x = (1.25*(i%4)+1)*level[0].width;
    float y = level[0].height*(1+(i/4)*1.25);
    if (!rooms[i].getIsUnlocked()) image(level[2], x, y);
    else {
      if (mouseX >= x && mouseX <= x+level[0].width &&
      mouseY >= y && mouseY <= y+level[0].height) {
      currentRoom = rooms[i];
      image(level[1], x, y);
      } else image(level[0], x, y);
    
      text(i+1, x+0.5*level[0].width-8.0, y+0.5*level[0].height+8.0);
    }
  }
}

public void drawPlaying() {
  int exit = currentRoom.checkExits();
  if (exit == -1) {
    gameState = GameState.TITLE;
    return;
  }
  if (rooms[exit] != currentRoom) enterRoom(exit);
  
  camera_x = player.getX() - width/2.0 + player.getImg().width/2.0;
  if (camera_x < 0) camera_x = 0;
  else if (camera_x > currentRoom.getWidth() - width) camera_x = currentRoom.getWidth() - width;
  
  PImage background = backgrounds.get(gameState);
  float bg_x = floor(camera_x/background.width)*background.width-camera_x;
  image(background, bg_x, 0);
  image(background, bg_x + background.width, 0);
  
  currentRoom.advance();
  player.advance(); // draw and move the player
  drawUI();
}

// movement for player based on keyboard
public void keyPressed() {
  if (key == '\\') { // DELETE LATER! for debugging
    for (Room room : rooms) {
      room.unlock();
    }
  }
  if (gameState != GameState.PLAYING) return;
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, true);
  
  if (player.getState().isInAir()) { // if the player is jumping, keep jumping, but can move left and right
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
        player.changeState(State.JUMP_UP);
        break;
    }
  }
}

public void keyReleased() {
  if (gameState != GameState.PLAYING) return;
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, false);
  
  // if no left/right movement is being pressed, stop moving (horizontally)
  if (!isKeyPressed.get("a") && !isKeyPressed.get("d")) {
    if (player.getState().isInAir()) player.stopVel();
    else player.changeState(State.IDLE);
  } else if (!isKeyPressed.get("a")) {
    player.startVel(true);
  } else if (!isKeyPressed.get("d")) {
    player.startVel(false);
  }
}

public void mouseClicked() {
  if (gameState != GameState.SELECT || currentRoom == null) return;
  player.reset();
  gameState = GameState.PLAYING;
}

public void loadData() {
  json = loadJSONObject("rooms.json");
  JSONArray roomData = json.getJSONArray("rooms");
  rooms = new Room[roomData.size()];
  
  for (int i = 0; i < roomData.size(); i++) {
    rooms[i] = new Room(roomData.getJSONObject(i));
  }
  
  rooms[0].unlock();
}

public void drawUI() {
}

public void enterRoom(int newID) {
  player.resetPos(newID);
  currentRoom = rooms[newID];
  currentRoom.unlock();
}
