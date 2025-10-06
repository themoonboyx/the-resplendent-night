// interactable objects within the game (player, enemies, platforms, entrances/exits)
public abstract class Entity {
  private boolean isRight = true; // is it currently looking to the right?
  private int frame = 0; // current frame in animation
  private State state = State.IDLE; // current movement state
  private Type type; // type of Entity
  private float x; // x pos in world
  private float y; // y pos in world
  private Float min_x; // minimum x pos (if this is NaN, then it doesn't have one)
  private Float max_x; // maximum x pos
  private float start_x; // starting x pos (for (re)loading a room)
  private float start_y; // starting y pos
  private float w; // width
  private float h; // height
  private float vel_x = 0; // x velocity
  private float vel_y = 0; // y velocity (note: +ve values mean go down, -ve values mean go up)
  private HashMap<State, PImage[]> framesMap = new HashMap<>(); // image animations for each state
  private boolean hasGravity; // whether Entity is affected by gravity
  private boolean inAir = true; // whether currently in air
  private boolean isChasing = false; // whether Entity chases the player

  // create new Entity (player and enemies use this version)
  public Entity(float x, Float y, Float min_x, Float max_x, float w, float h, String name, int size, Type type) {
    this.x = x;
    this.start_x = x;
    this.min_x = min_x;
    this.max_x = max_x;
    this.w = w;
    this.h = h;
    this.type = type;
    this.hasGravity = true;
    
    // load images for each state
    for (State s : getPossibleStates()) {
      PImage img = loadImage(name+"/"+s.getImgName());
      PImage[] frames = new PImage[img.width/size];
      for (int i = 0; i < frames.length; i++) {
        frames[i] = img.get(i*size, 0, size, img.height);
      }
      framesMap.put(s, frames);
    }
    
    if (Float.isNaN(y)) this.y = height-getImg().height-15; // if no starting y given, start at the bottom of the screen
    else this.y = y-h;
    this.start_y = this.y;
  }

  // create new Entity (platforms and connections use this)
  public Entity(float x, float y, int w, int h, String name, Type type) {
    this.x = x;
    this.start_x = x;
    this.min_x = Float.NaN;
    this.max_x = Float.NaN;
    this.y = y;
    this.start_y = y;
    this.w = w;
    this.h = h;
    this.type = type;
    this.hasGravity = false;
    
    // load image for each state
    for (State s : getPossibleStates()) {
      PImage img = loadImage(name+"/"+s.getImgName());
      PImage[] frames = new PImage[1];
      frames[0] = img.get(0, 0, w, h);
      framesMap.put(s, frames);
    }
  }

  // move and draw Entity
  public void advance() {
    frame++; // advance animations by one frame

    // if chasing player, set velocities based on where the player is
    if (isChasing) {
      vel_x = getRunVel();
      if (player.getX() < x) isRight = false;
      else if (player.getX() > x) isRight = true;
      else vel_x = 0;
      if (player.getY() < y) vel_y = getRunVel() * -1;
      else if (player.getY() > y) vel_y = getRunVel();
      else vel_y = 0;
    }
    
    // move horizontally and vertically
    x += isRight ? vel_x : -vel_x;
    if (hasGravity) vel_y += gravity;
    y += vel_y;
    
    // collide with platforms
    inAir = true;
    for (Entity e : currentRoom.getPlatforms()) {
      if (checkCollision(e)) {
        collide(e);
      }
    }
    
    // if jumping/falling, set state accordingly
    if (inAir && hasGravity) {
      if (type != Type.PLAYER) state = State.JUMP;
      else {
        if (vel_y < -gravity*20.0) state = State.JUMP_DOWN;
        else if (vel_y < -gravity) state = State.JUMP;
        else state = State.JUMP_UP;
      }
    }
    
    // collide with enemies if player
    if (type == Type.PLAYER) {
      for (Entity e : currentRoom.getEnemies()) {
        if (checkCollision(e)) {
          damage();
        }
      }
    }

    // if past the x boundaries (certain enemies have these), change velocity accordingly
    if (!Float.isNaN(min_x)) {
      if (x < min_x) startVel(true);
    }
    if (!Float.isNaN(max_x)) {
      if (x + w > max_x) startVel(false);
    }
    
    // draw Entity facing the correct direction
    if (isRight) image(getImg(), x-camera_x, y);
    else {
      pushMatrix();
      scale(-1, 1);
      image(getImg(), -x+camera_x-getImg().width, y);
      popMatrix();
    }
  }

  // get the current image in the animation that the Entity is up to
  public PImage getImg() {
    return framesMap.get(state)[(frame/20)%framesMap.get(state).length];
  }
  
  // getters
  public float getX() {return x;}
  public float getY() {return y;}
  public float getWidth() {return w;}
  public float getHeight() {return h;}
  public State getState() {return state;}
  public Type getType() {return type;}

  public abstract float getRunVel();
  public abstract State[] getPossibleStates();

  // setters
  public void setGravity(boolean hasGravity) {this.hasGravity = hasGravity;}
  public void setChasing(boolean chasing) {isChasing = chasing;}
  public void stopVel() {vel_x = 0;}

  // run in the direction specified
  public void startVel(boolean right) {
    vel_x = getRunVel();
    isRight = right;
  }
  
  // reset location within the room
  public void reset() {
    x = start_x;
    y = start_y;
    if (type != Type.ENEMY) changeState(State.IDLE, true);
    else changeState(State.RUN, false);
  }

  // enter new room
  public void enter(int newID) {
    Connection entrance = rooms[newID].getConnection(currentRoom.getID());
    x = entrance.getX();
    if (entrance.getX() <= 0) x += entrance.getWidth(); // if going forwards
    else x -= getImg().width; // if going backwards
    y = entrance.getY()+entrance.getHeight()-getImg().height;
  }

  // is current Entity colliding with e?
  public boolean checkCollision(Entity e) {
    if ((x + getImg().width/2.0 - w/2.0 < e.getX()+e.getWidth()) &&
      (x + w > e.getX()) &&
      (y + getImg().height - h < e.getY()+e.getHeight()) &&
      (y + getImg().height > e.getY())) {
      return true;
    }
    return false;
  }

  // reset the room if damaged
  private void damage() {
    reset();
    for (Entity e : currentRoom.getEnemies()) {
      e.reset();
    }
  }

  private void collide(Entity e) {
    y -= vel_y;
    if (checkCollision(e)) {
      y += vel_y;
      x += isRight ? -vel_x : vel_x;
    } else if (vel_y > 0) {
      y = e.getY() - getImg().height;
      vel_y = 0;
      inAir = false;
      if (vel_x != 0) state = State.RUN;
      else state = State.IDLE;
    } else {
      vel_y = 0;
      inAir = false;
    }
  }

  public void changeState(State newState) {
    changeState(newState, isRight);
  }

  public void changeState(State newState, boolean right) {
    isRight = right;
    switch(newState) {
    case IDLE:
      stopVel();
      break;
    case RUN:
      vel_x = getRunVel();
      break;
    }
    vel_y = newState.getVelY();
    state = newState;
  }
}
