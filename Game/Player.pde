class Player {
  PImage img;
  float x = 0;
  float y = 400-96;
  float vel_x = 0;
  float vel_y = 0;
  
  Player() {
    img = loadImage("character/character.png");
  }
  
  void advance() {
    x += vel_x;
    y += vel_y;
    image(img, x, y);
  }
}
