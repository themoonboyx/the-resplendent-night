public class Room {
  private int id;
  private float w;
  private float h;
  private HashMap<Integer, Connection> connections = new HashMap<>();
  private Platform[] platforms;
  
  public Room(JSONObject room) {
    id = room.getInt("id");
    w = room.getInt("width");
    h = room.getInt("height");
    
    JSONArray connData = room.getJSONArray("connections");
    for (int i = 0; i < connData.size(); i++) {
      connections.put(connData.getJSONObject(i).getInt("id"), new Connection(connData.getJSONObject(i)));
    }
    
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
  
  public int getID() {return id;}
  public float getWidth() {return w;}
  public float getHeight() {return h;}
  public Platform[] getPlatforms() {return platforms;}
  public Connection getConnection(int connID) {return connections.get(connID);}
  
  public int checkExits() {
    for (Integer connID : connections.keySet()) {
      if (player.checkCollision(connections.get(connID))) return connID;
    }
    return id;
  }
}
