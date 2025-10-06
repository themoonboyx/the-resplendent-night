public Player player; // player character
public Room[] rooms; // playable rooms/levels
public Room currentRoom; // room the player is in
public Room selectedRoom = null; // the level the mouse is currently hovering over on the selection/pause screen
public GameState gameState = GameState.SELECT; // the current game state (will render different things based on this)
public HashMap<String, Boolean> isKeyPressed = new HashMap<>(); // keeps track of which keys are being pressed
public HashMap<GameState, PImage> backgrounds = new HashMap<>(); // the background to display in different states
public PImage[] level = new PImage[3]; // level select images (unselected, selected, locked)
public PImage[] pausePlay = new PImage[4]; // pause/play button images (unselected and selected)
public float pause_x = 18; // x pos of pause/play button
public float pause_y = 18; // y pos of pause/play button
public float camera_x = 0; // x position in the game world of the left of the screen
public float camera_y = 0; // y position of top of the screen
public float gravity = 0.5; // acceleration rate of things with gravity when midair
public JSONObject json; // contains information about each room

// states that Entities can be in
public enum State {
  IDLE(0, "idle", false), RUN(0, "run", false), JUMP_UP(-12, "jump-", true), JUMP(0, "jump", true), JUMP_DOWN(0, "jump+", true);
  
  private float vel_y; // default starting y velocity of state
  private String imgName; // name of image to load for state
  private boolean inAir; // whether the Entity is in the air
  
  private State(float vel_y, String imgName, boolean inAir) {
    this.vel_y = vel_y;
    this.imgName = imgName+".png";
    this.inAir = inAir;
  }
  
  public float getVelY() {return vel_y;}
  public String getImgName() {return imgName;}
  public boolean isInAir() {return inAir;}
}

// different types of Entity
public enum Type {PLAYER, ENEMY, BLOCK};

// current state of the game
public enum GameState {
  SELECT("selectScreen"), PLAYING("background"), PAUSE("pauseScreen");
  
  private String imgName; // name of the image to load
  
  private GameState(String folder) {
    this.imgName = folder+"/background.png";
  }
  
  public String getImgName() {return imgName;}
}

// runs at start
public void setup() {
  // set sizes
  size(576, 576, P2D);
  textSize(30);
  
  // load images
  for (GameState gs : GameState.values()) {
    backgrounds.put(gs, loadImage(gs.getImgName()));
  }
  PImage l = loadImage("UI/level.png");
  for (int i = 0; i < level.length; i++) {
    level[i] = l.get(i*l.width/level.length, 0, l.width/level.length, l.height);
  }
  PImage p = loadImage("UI/pausePlay.png");
  for (int i = 0; i < pausePlay.length; i++) {
    pausePlay[i] = p.get(i*p.width/pausePlay.length, 0, p.width/pausePlay.length, p.height);
  }
  
  // create rooms and player
  player = new Player();
  loadData();
  currentRoom = null;
  
  // add initial values to avoid glitches
  isKeyPressed.put("a", false);
  isKeyPressed.put("d", false);
  isKeyPressed.put("w", false);
  
  frameRate(60);
}

// draws different things based on gameState
public void draw() {
  switch(gameState) {
    case SELECT:
    drawSelect();
    break;
    case PLAYING:
    drawPlaying();
    break;
    case PAUSE:
    drawPause();
    break;
  }
}

// draw the level select menu
public void drawSelect() {
  image(backgrounds.get(GameState.SELECT), 0, 0);
  text("SELECT LEVEL", width/3.0, 50);
  drawLevels();
}

// draw the main game
public void drawPlaying() {
  // check if the player is in an exit and the next room should be entered
  int exit = currentRoom.checkExits();
  if (exit == -1) { // go back to menu, the game has been completed
    gameState = GameState.SELECT;
    return;
  }
  if (rooms[exit] != currentRoom) enterRoom(exit);
  
  // move camera to follow player but stop when the room's walls are visible
  camera_x = player.getX() - width/2.0 + player.getImg().width/2.0;
  if (camera_x < 0) camera_x = 0;
  else if (camera_x > currentRoom.getWidth() - width) camera_x = currentRoom.getWidth() - width;
  
  // draw background endlessly
  PImage background = backgrounds.get(gameState);
  float bg_x = floor(camera_x/background.width)*background.width-camera_x;
  image(background, bg_x, 0);
  image(background, bg_x + background.width, 0);
  
  // draw and move all Entities (player, enemies, platforms) in room
  currentRoom.advance();
  player.advance();
  
  // draw pause/play button
  drawUI();
}

// draw pause menu
public void drawPause() {
  drawLevels();
  drawUI();
}

// draw levels for selecting
public void drawLevels() {
  selectedRoom = null;
  for (int i = 0; i < rooms.length; i++) {
    // the top left of each level button
    float x = ((i%4)+0.5)*width/5.0 + 0.5*(width/5.0-level[0].width);
    float y = level[0].height*(1+(i/4)*1.25);
    
    if (!rooms[i].getIsUnlocked()) {
      image(level[2], x, y); // if not unlocked, it can't be selected so draw a locked image
    } else {
      if (mouseX >= x && mouseX <= x+level[0].width &&
        mouseY >= y && mouseY <= y+level[0].height) { // if the mouse is within the image borders, select it and draw selected image
        selectedRoom = rooms[i];
        image(level[1], x, y);
      } else image(level[0], x, y); // draw unselected image
    
      text(i+1, x+0.5*level[0].width-8.0, y+0.5*level[0].height+8.0); // write level number in the centre
    }
  }
  // instructions
  text("Use WASD to move, select level with mouse", 16, ((rooms.length/4)*1.25+2.5)*level[0].height);
}

// movement for player based on keyboard
public void keyPressed() {
  if (gameState != GameState.PLAYING) return;
  
  // log the key as currently being pressed
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, true);
  
  if (player.getState().isInAir()) { // if the player is jumping, keep jumping, but can move left and right (can't jump again)
    if (keyS.equals("a")) player.startVel(false); // left //<>//
    if (keyS.equals("d")) player.startVel(true); // right
  } else {
    switch(keyS) {
      case "a": // run left
        player.changeState(State.RUN, false);
        break;
      case "d": // run right
        player.changeState(State.RUN, true);
        break;
      case "w": // jump
        player.changeState(State.JUMP_UP);
        break;
    }
  }
}

// movement for player based on keyboard
public void keyReleased() {
  if (gameState != GameState.PLAYING) return;
  
  // log the key as not currently pressed
  String keyS = key + "";
  keyS = keyS.toLowerCase();
  isKeyPressed.put(keyS, false);
  
  if (!isKeyPressed.get("a") && !isKeyPressed.get("d")) { // if no left/right movement is being pressed, stop moving (horizontally)
    if (player.getState().isInAir()) player.stopVel();
    else player.changeState(State.IDLE);
  } else if (!isKeyPressed.get("a")) { // otherwise, move in the direction being pressed
    player.startVel(true);
  } else if (!isKeyPressed.get("d")) {
    player.startVel(false);
  }
}

// level selection and pausing
public void mouseClicked() {
  // check if user is clicking the pause/play button and react
  if (gameState == GameState.PLAYING || gameState == GameState.PAUSE) {
    if (mouseX >= pause_x && mouseX <= pause_x+pausePlay[0].width &&
      mouseY >= pause_y && mouseY <= pause_y+pausePlay[0].height) {
      if (gameState == GameState.PLAYING) { // if currently playing, pause
        image(backgrounds.get(GameState.PAUSE), 0, 0);
        gameState = GameState.PAUSE;
      } else { // if currently paused, play
        gameState = GameState.PLAYING;
      }
      return;
    }
  }
  
  // check if user is clicking a level and start that level
  if ((gameState == GameState.PAUSE || gameState == GameState.SELECT) && selectedRoom != null) {
    currentRoom = selectedRoom;
    player.reset();
    for (Entity e : currentRoom.getEnemies()) {
      e.reset();
    }
    gameState = GameState.PLAYING;
  }
}

// load json data for rooms
public void loadData() {
  json = loadJSONObject("rooms.json");
  JSONArray roomData = json.getJSONArray("rooms");
  
  // create a room for each room in json data
  rooms = new Room[roomData.size()];
  for (int i = 0; i < roomData.size(); i++) {
    rooms[i] = new Room(roomData.getJSONObject(i));
  }
  
  rooms[0].unlock(); // the first room always starts unlocked
}

// draw UI (the pause/play button)
public void drawUI() {
  if (mouseX >= pause_x && mouseX <= pause_x+pausePlay[0].width &&
      mouseY >= pause_y && mouseY <= pause_y+pausePlay[0].height) { // if mouse is over it, draw the lighter version
      if (gameState == GameState.PLAYING) image(pausePlay[1], pause_x, pause_y); // pause button
      else image(pausePlay[3], pause_x, pause_y); // play button
  } else {
    if (gameState == GameState.PLAYING) image(pausePlay[0], pause_x, pause_y); // pause button
    else image(pausePlay[2], pause_x, pause_y); // play button
  }
}

// enter specified room
public void enterRoom(int newID) {
  player.enter(newID);
  currentRoom = rooms[newID];
  currentRoom.unlock();
  for (Entity e : currentRoom.getEnemies()) {
    e.reset();
  }
}
