// a room/level with associated platforms and enemies
public class Room {
  private int id; // room number
  private boolean isUnlocked = false; // whether it is selectable in the menu
  private float w; // width
  private float h; // height
  private HashMap<Integer, Connection> connections = new HashMap<>(); // corresponding Connection for each connected room id
  private Entity[] enemies; // enemies in the room
  private Platform[] platforms; // platforms in the room
  
  // create Room from json data
  public Room(JSONObject room) {
    id = room.getInt("id");
    w = room.getInt("width");
    h = room.getInt("height");
    
    // load connections
    JSONArray connData = room.getJSONArray("connections");
    for (int i = 0; i < connData.size(); i++) {
      connections.put(connData.getJSONObject(i).getInt("id"), new Connection(connData.getJSONObject(i)));
    }
    
    // load enemies
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
    
    // load platforms
    JSONArray platformData = room.getJSONArray("platforms");
    platforms = new Platform[platformData.size()];
    for (int i = 0; i < platformData.size(); i++) {
      platforms[i] = new Platform(platformData.getJSONObject(i));
    }
  }
  
  // draw and move all enemies and platforms in the room
  public void advance() {
    for (Platform p : platforms) {
      p.advance();
    }
    for (Entity e : enemies) {
      e.advance();
    }
  }
  
  // getters
  public int getID() {return id;}
  public boolean getIsUnlocked() {return isUnlocked;}
  public float getWidth() {return w;}
  public float getHeight() {return h;}
  public Platform[] getPlatforms() {return platforms;}
  public Entity[] getEnemies() {return enemies;}
  
  // get associated connection from connID
  public Connection getConnection(int connID) {return connections.get(connID);}
  
  // make Room selectable in the menu
  public void unlock() {
    isUnlocked = true;
  }
  
  // check if the player is in any of the Connections and return the corresponding room id if so
  public int checkExits() {
    for (Integer connID : connections.keySet()) {
      if (player.checkCollision(connections.get(connID))) return connID;
    }
    return id;
  }
}
