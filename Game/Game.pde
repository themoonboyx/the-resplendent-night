PImage img;

void setup() {
  size(400, 400);
  img = loadImage("character/character.png");
}

void draw() {
  background(0);
  image(img, 0, 0);
}
