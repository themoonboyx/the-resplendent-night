public class Room {
  float w;
  float h;
  Platform[] platforms;
  
  public Room(JSONObject room) {
    w = room.getInt("width");
    h = room.getInt("height");
    JSONArray platformData = room.getJSONArray("platforms");
    platforms = new Platform[platformData.size()];
    for (int i = 0; i < platformData.size(); i++) {
      platforms[i] = new Platform(platformData.getJSONObject(i));
    }
  }
  
  public void advance() {
    for (Platform p : platforms) {
      p.advance();
    }
  }
}
