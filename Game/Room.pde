public class Room {
  private int id;
  private boolean isUnlocked = false;
  private float w;
  private float h;
  private HashMap<Integer, Connection> connections = new HashMap<>();
  private Entity[] enemies;
  private Platform[] platforms;
  
  public Room(JSONObject room) {
    id = room.getInt("id");
    w = room.getInt("width");
    h = room.getInt("height");
    
    JSONArray connData = room.getJSONArray("connections");
    for (int i = 0; i < connData.size(); i++) {
      connections.put(connData.getJSONObject(i).getInt("id"), new Connection(connData.getJSONObject(i)));
    }
    
    JSONArray enemyData = room.getJSONArray("enemies");
    enemies = new Entity[enemyData.size()];
    for (int i = 0; i < enemyData.size(); i++) {
      switch(enemyData.getJSONObject(i).getString("name")) {
        case "goop":
        enemies[i] = new GoopEnemy(enemyData.getJSONObject(i));
        break;
        case "fly":
        enemies[i] = new FlyEnemy(enemyData.getJSONObject(i));
        break;
      }
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
    for (Entity e : enemies) {
      e.advance();
    }
  }
  
  public int getID() {return id;}
  public boolean getIsUnlocked() {return isUnlocked;}
  public float getWidth() {return w;}
  public float getHeight() {return h;}
  public Platform[] getPlatforms() {return platforms;}
  public Entity[] getEnemies() {return enemies;}
  
  public Connection getConnection(int connID) {return connections.get(connID);}
  
  public void unlock() {
    isUnlocked = true;
  }
  
  public int checkExits() {
    for (Integer connID : connections.keySet()) {
      if (player.checkCollision(connections.get(connID))) return connID;
    }
    return id;
  }
}
