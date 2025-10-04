public class Room {
  private float w;
  private float h;
  private Platform[] platforms;
  private int id;
  
  public Room(JSONObject room, int id) {
    w = room.getInt("width");
    h = room.getInt("height");
    JSONArray platformData = room.getJSONArray("platforms");
    platforms = new Platform[platformData.size()];
    for (int i = 0; i < platformData.size(); i++) {
      platforms[i] = new Platform(platformData.getJSONObject(i));
    }
    this.id = id;
  }
  
  public void advance() {
    for (Platform p : platforms) {
      p.advance();
    }
  }
  
  public float getWidth() {return w;}
  public float getHeight() {return h;}
  public Platform[] getPlatforms() {return platforms;}
  public Room getNext() {return rooms[id+1];}
}
