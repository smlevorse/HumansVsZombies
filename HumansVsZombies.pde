//Sean Levorse
//Humans Vs Zombies

//Debug options
boolean D_ZOMBIES = false;        //Zombie targeting human
boolean D_HUMANS = false;         //Human seeing zombie
boolean D_TRANSFORM = false;      //Forward and Right Vector
boolean D_FUTURE_POS = false;     //Human and zombie future positions as interpreted by evade and pursue 
boolean D_VELOCITY = false;       //Human and zombie velocity
boolean D_OBSTACLE = false;       //Human and zombie obstacle avoidance
boolean D_STEERING_FORCE = false; //Steering force on human and zombie

//Global variables
ArrayList<Zombie> zombies;
ArrayList<Human> humans;
ArrayList<Obstacle> obstacles;
ArrayList<Zombie> zombiesToAdd;
ArrayList<Human> humansToRemove;

//"Constants"
float HUMAN_MAX_SPEED = 4;
float HUMAN_MAX_FORCE = .2;
float ZOMBIE_MAX_SPEED = 2.5;
float ZOMBIE_MAX_FORCE = .05;
int BORDER = 150;
int TIME_AHEAD = 10;
int WANDER_RADIUS = 50;
int ANIMATION_FRAMES_PER_FRAME = 5;
int OBST_AHEAD = 12;

void setup(){
  size(1920, 1000);  
  
  //initialize arrays
  zombies = new ArrayList<Zombie>();
  humans = new ArrayList<Human>();
  obstacles = new ArrayList<Obstacle>();
  zombiesToAdd = new ArrayList<Zombie>();
  humansToRemove = new ArrayList<Human>();
  
  //populate arrays
  for(int i = 0; i < 24; i++){
    humans.add(new Human(random(BORDER, width - BORDER), random(BORDER, height - BORDER), 20, HUMAN_MAX_SPEED, HUMAN_MAX_FORCE));
  }
  
  
  for(int i = 0; i < 5; i++){
    obstacles.add(new Obstacle(int(random(BORDER, width - BORDER)), int(random(BORDER, height - BORDER)), 37)); 
  }
  
  
  zombies.add(new Zombie(width/2, height/2, 20, 4, .1));
}

void draw(){
  background(44, 103, 0);
  stroke(0);
  fill(255, 0);
  
  rect(BORDER, BORDER, width - 2 * BORDER, height - 2 * BORDER);
  
  //display obstacles
  for(Obstacle o:obstacles){
    o.display(); 
  }
  
  //diplay and update humans
  for(Human h: humans){
    h.update();
    h.display();
  }
  
  //diplay and update zombies
  for(Zombie z: zombies){
    z.update();
    z.display();
  }
  
  //add new zombies and remove new humans
  for(Zombie z: zombiesToAdd){
    zombies.add(z);
  }
  for(Human h: humansToRemove){
    humans.remove(h); 
  }
  
  //reset array
  zombiesToAdd.clear();
  humansToRemove.clear();
  
  //help text
  fill(0);
  textSize(36);
  textAlign(CENTER, CENTER);
  text("H or Left Mouse spawns Humans", width/2, 20);
  text("Z or Right Mouse spawns Zombies", width / 2, 55);
  textSize(42);
  textAlign(LEFT, TOP);
  text("Humans: ", 40, 20);
  text("Zombies:", width - 290, 20);
  fill(255,0,0);
  text("" + humans.size(), 230, 20);
  fill(0,255,0);
  text("" + zombies.size(), width - 90, 20);
  
  
  
  //Debug buttons
  stroke(0);
  String[] buttons = { "Zombie Tracing: 1", "Human tracing: 2", "Transforms: 3", "Future Position: 4", "Velocity: 5", "Obstacle Detection: 6", "Steering Force: 7"};
  textSize(18);
  textAlign(CENTER, CENTER);
  for(int i = 0; i < 7; i++){
    fill(85, 215, 101);
    rect(BORDER + i * (width / 10 + 46), height - 3 * BORDER / 4, width / 10, BORDER / 2);
    fill(255);
    text(buttons[i], BORDER + i * (width / 10 + 46) + width/20, height - BORDER / 2);
  }
  
  fill(255);
  
}

//toggle debug mode
void keyPressed(){
  if(key == '1'){
    D_ZOMBIES = !D_ZOMBIES;
  }
  if(key == '2'){
    D_HUMANS = !D_HUMANS;
  }
  if(key == '3'){
    D_TRANSFORM = !D_TRANSFORM;
  }
  if(key == '4'){
    D_FUTURE_POS = !D_FUTURE_POS;
  }
  if(key == '5'){
    D_VELOCITY = !D_VELOCITY;
  }
  if(key == '6'){
    D_OBSTACLE = !D_OBSTACLE;
  }
  if(key == '7'){
    D_STEERING_FORCE = !D_STEERING_FORCE;
  }
  
  //spawning new human
  if(key == 'h'){
    humans.add(new Human(mouseX, mouseY, 10, HUMAN_MAX_SPEED, HUMAN_MAX_FORCE));
  }
  if(key == 'z'){
    zombies.add(new Zombie(mouseX, mouseY, 10, 4, .1));
  }
}

void mousePressed(){
  if( mouseButton == LEFT){
    if(mouseY > height - 3 * BORDER / 4 && mouseY < height - BORDER / 4){
      if(mouseX >  BORDER && mouseX < BORDER + width / 10){
        D_ZOMBIES = !D_ZOMBIES;
        return;
      }
      else if(mouseX >  BORDER + 1 * (width / 10 + 46) && mouseX < BORDER + 1 * (width / 10 + 46) + width / 10){
        D_HUMANS = !D_HUMANS;
        return;
      }
      else if(mouseX >  BORDER + 2 * (width / 10 + 46) && mouseX < BORDER + 2 * (width / 10 + 46) + width / 10){
        D_TRANSFORM = !D_TRANSFORM;
        return;
      }
      else if(mouseX >  BORDER + 3 * (width / 10 + 46) && mouseX < BORDER + 3 * (width / 10 + 46) + width / 10){
        D_FUTURE_POS = !D_FUTURE_POS;
        return;
      }
      else if(mouseX >  BORDER + 4 * (width / 10 + 46) && mouseX < BORDER + 4 * (width / 10 + 46) + width / 10){
        D_VELOCITY = !D_VELOCITY;
        return;
      }
      else if(mouseX >  BORDER + 5 * (width / 10 + 46) && mouseX < BORDER + 5 * (width / 10 + 46) + width / 10){
        D_OBSTACLE = !D_OBSTACLE;
        return;
      }
      else if(mouseX >  BORDER + 6 * (width / 10 + 46) && mouseX < BORDER + 6 * (width / 10 + 46) + width / 10){
        D_STEERING_FORCE = !D_STEERING_FORCE;
        return;
      }
    }
    humans.add(new Human(mouseX, mouseY, 10, HUMAN_MAX_SPEED, HUMAN_MAX_FORCE));
  }
  else if(mouseButton == RIGHT){
    zombies.add(new Zombie(mouseX, mouseY, 10, 4, .1));
  }
}