public class Galaxy{
  public ArrayList<Particle> particles = new ArrayList();
  public HashMap<String, Integer> color_1 = new HashMap();
  int particle_limit, max_size;
  HashMap<Integer, Boolean> selected_particles = new HashMap();
  HashMap<String, Integer> color_2 = new HashMap();
  float yoffset, xoffset = 0;
  boolean base_particle;
  
  public Galaxy(int val){
    this.color_2.put("r", 65);
    this.color_2.put("g", 8);
    this.color_2.put("b", 102);
     
    if (val == 0){
     this.color_1.put("r", 255);
     this.color_1.put("g", 255);
     this.color_1.put("b", 255);
     particle_limit = 4000;
     max_size = 80;
     base_particle = true;
     xoffset = 0;
     yoffset = 0;
    }
    if (val == 1) {
      this.color_1.put("r", 58);
     this.color_1.put("g", 102);
     this.color_1.put("b", 8);
     particle_limit = 200;
     max_size = 70;
     yoffset = height / 2;
     xoffset = width / 2;
     base_particle = false;
    }
    if (val == 2) {
      this.color_1.put("r", 10);
     this.color_1.put("g", 68);
     this.color_1.put("b", 168);
     particle_limit = 200;
     max_size = 70;
     yoffset = height / 4;
     xoffset = -width / 4;
     base_particle = false;
    } 
  }
  
  void draw_galaxy(float xpos, float ypos){
    if((frameCount % 2) == 0 && particles.size() < particle_limit){
      particles.add(new Particle(new PVector((xpos), (ypos)), random(10, 60), random(20, 60)));
      particles.add(new Particle(new PVector((xpos), (ypos)), random(144, 290), random(144, 290)));
    }
    for(int i = 0; i < particles.size(); i++){
      Particle p = (Particle) particles.get(i);
      if (this.selected_particles.containsKey(i)){
         continue; 
      }
      else {
        if (base_particle){
          p.draw(color_1, false, max_size);
        }
        else {
             p.draw(color_1, true, max_size); 
        }
        p.move();
      }
      //if(p.boundary() || p.alpha <= -10){
      //  particles.remove(p);
      //}
    }
    for (HashMap.Entry me : selected_particles.entrySet()){
        int val = (int)me.getKey();
        if (val >= particles.size()){
           continue; 
        }
        Particle p = (Particle) particles.get(val);
        p.draw(color_2, true, max_size);
        p.move();
        //if(p.boundary() || p.alpha <= 50){
        //  particles.remove(p);
        //}
    }
    
    for (int i = 0; i < particles.size(); i++) {
    Particle p1 = (Particle) particles.get(i);
    for (int j = 0; j < particles.size(); j++) {
      Particle p2 = (Particle) particles.get(j);
      if (p1 != p2) {
        if (p1.r > 10 && p2.r > 10){
          if (dist(p1.loc.x, p1.loc.y, p2.loc.x, p2.loc.y) < 3 * reactionDist) {
            if (random(0, 10) <= lineOdds) {
              stroke(255, 80);
              strokeWeight(2.0);
              line(p1.loc.x, p1.loc.y, p2.loc.x, p2.loc.y);
            }
          }
        }
      }
    }
  }
  }
  
  
  HashMap<Integer, Boolean> get_random_constellation(int size){
    HashMap<Integer, Boolean> res = new HashMap();
    int count = 0;
    int item = int(random(0, particles.size()));
    res.put(item, true);
    Particle seed = particles.get(item);
    // add rest of particles which are close enough.
    for (int i = 0; i < particles.size(); i++) {
       Particle p = particles.get(i); 
       if (p.r < 50){
         continue;
       }
       if (dist(seed.loc.x, seed.loc.y, p.loc.x, p.loc.y) <= reactionDist/4){
          res.put(i, true); 
          count += 1;
       }
       if (count == size){
          break;
       }
    }
    return res;
  }
}


 
Galaxy original = new Galaxy(0);
Galaxy green = new Galaxy(1);
Galaxy blue = new Galaxy(2);
float reactionDist = 50;
float start_year_static = 13;
float start_year = 13;
float lineOdds = 0.1;

 
void setup(){
  size(1320, 720);
  noStroke();
}
 
void draw(){
  background(0);
  if (start_year < 11.5) {
    // color 10 stars as purple: start with 1 particle. Select 10 more within a particular distance and 
    if (original.selected_particles.size() == 0) {
      original.selected_particles = original.get_random_constellation(10);  
    }
    else {
      if (start_year > 0){
        if (original.particles.size() % 8 == 0){
          if (original.selected_particles.size() < original.particles.size() / 10) {
            HashMap<Integer, Boolean> new_selected = original.get_random_constellation(4);
            for (HashMap.Entry me : new_selected.entrySet()) {
              original.selected_particles.put((Integer)me.getKey(), (Boolean)me.getValue());
            }
          }
        }
      }
    }
    //draw_galaxy("Omega Centauri", (2 * width * start_year_static)/(3 * start_year), (2 * height * start_year_static)/(3 * start_year), start_year);
  }
  if (start_year < 7.5) {
     green.draw_galaxy(3*width/4, 3*height/4); 
  }
  if (start_year < 4.5) {
     blue.draw_galaxy(width/4 + width/8, 3*height/4); 
  }
  if (start_year < 12.0){
    original.draw_galaxy(width/2, height/2);
  }
  //textSize(32);
  if (frameCount % 10 == 0){
    start_year -= (float)frameCount/10000;
  }
  //text(start_year, 10, 30);
}
 
class Particle {
  PVector loc, vel, acc;
   
  float vx, vy, num, alpha = 255, r;
   
  Particle(PVector loc, float vx, float vy){
    this.loc = loc;
    this.vx = vx;
    this.vy = vy;
    vel = new PVector();
    acc = new PVector();
  }
   
  void draw(HashMap<String, Integer> color_1, boolean is_colored, int max_size){
    acc = new PVector(sin(radians(vx+num/2))/2, cos(radians(vy-num/2))/2);
    // color
    int re = color_1.get("r");
    int g = color_1.get("g");
    int b = color_1.get("b");
    fill(re, g, b, alpha);
    float diff = abs(map(alpha, 255, 0, 1, 256) - r);
    if (is_colored){
      
      r = min(max_size, r + diff);
    }
    else {
      r = max(0, r - diff);
      if (r == 0){
        r = map(alpha, 255, 0, 1, 10);
      }
      //print ("base radius: " + r);
    }
    if (r == max_size){
      r = max(0, r - diff);
      if (r == 0){
        r = map(alpha, 255, 0, 1, 10);
      }
    }
    ellipse(loc.x, loc.y, r, r);
     
    num+=map(alpha, 255, 0, 1, 0);
    alpha-=0.1;
  }
   
  void move(){
    vel.add(acc);
    loc.add(vel);
    loc.add(vel);
    acc.mult(0);
    vel.limit(0.4);
  }
   
  boolean boundary(){
    if(loc.x < 0) return true;
    if(loc.x > width) return true;
    if(loc.y < 0) return true;
    if(loc.y > height) return true;
    return false;
  }
}
