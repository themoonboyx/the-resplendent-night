public abstract class Entity {
  private boolean isRight = true;
  private int frame = 0;
  private State state = State.IDLE;
  private Type type;
  private float x;
  private float y;
  private Float min_x;
  private Float max_x;
  private float start_x;
  private float w;
  private float h;
  private float vel_x = 0;
  private float vel_y = 0;
  private HashMap<State, PImage[]> framesMap = new HashMap<>();
  private boolean hasGravity;
  private boolean inAir = true;
  
  public Entity(float x, Float y, Float min_x, Float max_x, float w, float h, String name, int size, Type type) {
    this.x = x;
    this.start_x = x;
    this.min_x = min_x;
    this.max_x = max_x;
    this.w = w;
    this.h = h;
    this.type = type;
    for (State s : getPossibleStates()) {
      PImage img = loadImage(name+"/"+s.getImgName());
      PImage[] frames = new PImage[img.width/size];
      for (int i = 0; i < frames.length; i++) {
        frames[i] = img.get(i*size, 0, size, img.height);
      }
      framesMap.put(s, frames);
    }
    hasGravity = true;
    if (Float.isNaN(y)) this.y = height-getImg().height-15;
    else this.y = y-h;
  }

  public Entity(float x, float y, int w, int h, String name, Type type) {
    this.x = x;
    this.start_x = x;
    this.min_x = Float.NaN;
    this.max_x = Float.NaN;
    this.y = y;
    this.w = w;
    this.h = h;
    this.type = type;
    hasGravity = false;
    for (State s : getPossibleStates()) {
      PImage img = loadImage(name+"/"+s.getImgName());
      PImage[] frames = new PImage[1];
      frames[0] = img.get(0, 0, w, h);
      framesMap.put(s, frames);
    }
  }

  public void advance() {
    frame++;

    x += isRight ? vel_x : -vel_x;
    if (hasGravity) {
      vel_y += gravity;
      y += vel_y;

      inAir = true;
      for (Entity e : currentRoom.getPlatforms()) {
        if (checkCollision(e)) {
          collide(e);
        }
      }
      if (inAir) {
        if (type != Type.PLAYER) state = State.JUMP;
        else {
          if (vel_y < -gravity*20.0) state = State.JUMP_DOWN;
          else if (vel_y < -gravity) state = State.JUMP;
          else state = State.JUMP_UP;
        }
      }
    }

    if (type == Type.PLAYER) {
      for (Entity e : currentRoom.getEnemies()) {
        if (checkCollision(e)) {
          damage();
        }
      }
    }
    
    if (!Float.isNaN(min_x)) {
      if (x < min_x) startVel(true);
    }
    if (!Float.isNaN(max_x)) {
      if (x + w > max_x) startVel(false);
    }

    if (isRight) image(getImg(), x-camera_x, y);
    else {
      pushMatrix();
      scale(-1, 1);
      image(getImg(), -x+camera_x-getImg().width, y);
      popMatrix();
    }
  }

  public PImage getImg() {
    return framesMap.get(state)[(frame/20)%framesMap.get(state).length];
  }
  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public float getWidth() {
    return w;
  }
  public float getHeight() {
    return h;
  }
  public State getState() {
    return state;
  }
  public Type getType() {
    return type;
  }

  public abstract float getRunVel();
  public abstract State[] getPossibleStates();

  public void stopVel() {
    vel_x = 0;
  }

  public void startVel(boolean right) {
    vel_x = getRunVel();
    isRight = right;
  }

  public void reset() {
    x = start_x;
    y = height-getImg().height-15;
    changeState(State.IDLE, true);
  }
  
  public void resetPos(int newID) {
    Connection entrance = rooms[newID].getConnection(currentRoom.getID());
    x = entrance.getX();
    if (entrance.getX() <= 0) x += entrance.getWidth();
    else x -= getImg().width;
    y = entrance.getY()+entrance.getHeight()-getImg().height;
  }

  public boolean checkCollision(Entity e) {
    if ((x + getImg().width/2.0 - w/2.0 < e.getX()+e.getWidth()) &&
      (x + w > e.getX()) &&
      (y + getImg().height - h < e.getY()+e.getHeight()) &&
      (y + getImg().height > e.getY())) {
      return true;
    }
    return false;
  }

  private void damage() {
    reset();
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
