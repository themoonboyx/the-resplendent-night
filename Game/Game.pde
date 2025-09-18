Player player;

void setup() {
  size(400, 400);
  player = new Player();
}

void draw() {
  background(255);
  player.advance();
}
