public abstract class Entity {
  private boolean isRight = true;
  private int frame = 0;
  private State state = State.IDLE;
  private Type type;
  private float x;
  private float y;
  private float vel_x = 0;
  private float vel_y = 0;
  private HashMap<State, PImage[]> framesMap = new HashMap<>();
  private int immunity = 0;
  private int health = 3;

  public Entity(float x, String name, int size, Type type) {
    this.x = x;
    this.type = type;
    for (State s : getPossibleStates()) {
      PImage img = loadImage(name+"/"+s.getImgName());
      PImage[] frames = new PImage[img.width/size];
      for (int i = 0; i < frames.length; i++) {
        frames[i] = img.get(i*size, 0, size, img.height);
      }
      framesMap.put(s, frames);
    }
    y = height-framesMap.get(state)[frame].height/2.0;
  }
  
  public Entity(float x, float y, int w, int h, String name, Type type) {
    this.x = x;
    this.y = y;
    this.type = type;
    for (State s : getPossibleStates()) {
      PImage img = loadImage(name+"/"+s.getImgName());
      PImage[] frames = new PImage[1];
      frames[0] = img.get(0, 0, w, h);
      framesMap.put(s, frames);
    }
  }

  public void advance() {
    frame++;
    immunity--;
    x += isRight ? vel_x : -vel_x;
    if (state == State.JUMP) {
      if (y + getImg().height/2.0 >= height && vel_y > 0) {
        if (vel_x == 0) changeState(State.IDLE);
        else changeState(State.RUN);
      } else {
        vel_y += gravity;
        y += vel_y;
      }
    }
    for (Entity e : getPossibleCollisions()) {
      if (immunity > 0) {
        if (checkCollision(e)) {
          if (e.getType() != type) {
            switch (e.getType()) {
              case ENEMY:
                damage();
                break;
              case BLOCK:
                collide(e);
            }
          }
        }
      }
    }
    if (isRight) image(getImg(), x-camera_x, y);
    else {
      pushMatrix();
      scale(-1, 1);
      image(getImg(), -x+camera_x, y);
      popMatrix();
    }
  }

  public PImage getImg() {return framesMap.get(state)[(frame/20)%framesMap.get(state).length];}
  public float getX() {return x;}
  public float getY() {return y;}
  public State getState() {return state;}
  public Type getType() {return type;}

  public abstract float getRunVel();
  public abstract State[] getPossibleStates();
  public abstract Entity[] getPossibleCollisions();

  public void stopVel() {
    vel_x = 0;
  }

  public void startVel(boolean right) {
    vel_x = getRunVel();
    isRight = right;
  }

  public boolean checkCollision(Entity e) {
    if ((x-getImg().width/2.0 < e.getX()+e.getImg().width/2.0) &&
      (x+getImg().width/2.0 > e.getX()-e.getImg().width/2.0) &&
      (y-getImg().height/2.0 < e.getY()+e.getImg().height/2.0) &&
      (y+getImg().height/2.0 > e.getY()-e.getImg().height/2.0)) {
      return true;
    }
    return false;
  }
  
  private void damage() {
    health--;
    if (health <= 0) {
      die();
      return;
    }
    immunity = 100;
  }
  
  private void die() {
    
  }
  
  private void collide(Entity e) {
    
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
