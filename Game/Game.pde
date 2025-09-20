Player player;

void setup() {
  size(400, 400);
  player = new Player();
}

void draw() {
  background(255);
  player.advance();
}

void keyPressed() {
  String keyS = key + "";
  switch(keyS.toLowerCase()) {
    case "a":
      player.changeState(false);
      break;
    case "d":
      player.changeState(true);
      break;
  }
}
