class Zombie extends Vehicle{
  
  PShape body;
  PImage spriteSheet;
  PVector steeringForce;
  int spriteSheetNumber;
  
  //constructor
  Zombie(float x, float y, float r, float ms, float mf){
    super(x, y, r, ms, mf);
    steeringForce = new PVector(0, 0);
    spriteSheetNumber = int(random(1, 7));
    spriteSheet = loadImage("res/" + spriteSheetNumber + "ZombieSpriteSheet.png");
    
    //define plumbob
    plumbob = createShape();
    plumbob.beginShape();
      plumbob.fill(0, 255, 0, 128);
      plumbob.stroke(0, 255,0, 255);
      plumbob.vertex(0, 10);
      plumbob.vertex(5, 0);
      plumbob.vertex(0, -10);
      plumbob.vertex(-5, 0);
    plumbob.endShape(CLOSE);
    
    /* For part A
    //create zombie
    body = createShape();
    body.beginShape();
      body.stroke(0, 255, 0);
      body.fill(255, 255);
      body.vertex(radius, 0);
      body.vertex(-radius, -radius);
      body.vertex(-radius, radius);
      body.vertex(radius, 0);
    body.endShape();
    */
  }
  
  //Abstract methods
  void calcSteeringForces(){
    //reset steeringFoce
    steeringForce.mult(0);
    
    //Find nearest zombie
    Human nearest = findNearestHuman();
    if(nearest != null){
      steeringForce.add(seek(nearest.position).mult(.9));
      if(D_ZOMBIES){
        fill(110, 0, 245);
        line(position.x, position.y, nearest.position.x, nearest.position.y);
        fill(0);
      }
    }
    else{
      steeringForce.add(wander().mult(.4)); 
    }
    
    //avoid abstacles
    for(Obstacle o: obstacles){
      steeringForce.add(avoidObstacle(o).mult(.1)); 
    }
    
    //detect leaving the park
    if(position.x < BORDER || position.x > width - BORDER){
      PVector center = new PVector(width/2, position.y);
      steeringForce.add(seek(center).mult(10));
    }
    if(position.y < BORDER || position.y > height - BORDER){
      PVector center = new PVector(position.x, height/2);
      steeringForce.add(seek(center).mult(10));
    }
    
    //limit steering force
    steeringForce.limit(maxForce);
    
    //apply sterring force
    applyForce(steeringForce);
    
  }
  
  //draws the zombie to the screen as well as debug lines
  void display(){
    float angle = velocity.heading();
    
    //draw the vehicle
    pushMatrix();
      translate(position.x, position.y);
      /* Old Bodies
      rotate(angle);
      shape(body);
      */
      
      //Sprite Sheets from http://opengameart.org/content/character-rpg-sprites
      int frame = (frameCount / ANIMATION_FRAMES_PER_FRAME) % 3;
      int x = 0;
      if(frame == 0)
        x = 3;
      else if(frame == 1)
        x = 48;
      else if(frame == 2)
        x = 94;
      
      if(angle > -3 * QUARTER_PI && angle <= -1 * QUARTER_PI){
         PImage sprite = spriteSheet.get(x, 72, 29, 36);
         image(sprite, -14, -18);
      }
      else if(angle > -1 * QUARTER_PI && angle <= QUARTER_PI){
        PImage sprite = spriteSheet.get(x, 36, 29, 36);
         image(sprite, -14, -18);
      }
      else if(angle > 1 * QUARTER_PI && angle <= 3 * QUARTER_PI){
        PImage sprite = spriteSheet.get(x, 0, 29, 36);
         image(sprite, -14, -18);
      }
      else{
        PImage sprite = spriteSheet.get(x, 108, 29, 36);
         image(sprite, -14, -18);
      }
      
      //Plumbob for easy species recognition
      shape(plumbob, 0, -5 - radius);
      
    popMatrix();
    
    //degbug lines
    if(D_VELOCITY){
      //velocity
      stroke(255, 0, 0);
      line(position.x, position.y, position.x + velocity.x * 20, position.y + velocity.y * 20 );
      stroke(0);
    }
    if(D_STEERING_FORCE){
      stroke(0, 0, 255);
      //steering force
      line(position.x, position.y, position.x + steeringForce.x * 200, position.y + steeringForce.y * 200);
      stroke(0);
    }
    if(D_TRANSFORM){
      stroke(0,255,0);
      //forward and right
      line(position.x, position.y, position.x + forward.x * 20, position.y + forward.y * 20);
      line(position.x, position.y, position.x + right.x * 20, position.y + right.y * 20);
      stroke(0);
    }
    if(D_FUTURE_POS){
      PVector deltaPos = velocity.copy();
      deltaPos.mult(TIME_AHEAD);
      stroke(255, 128, 0);
      line(position.x, position.y, position.x + deltaPos.x, position.y + deltaPos.y);
      stroke(0);
    }
    if(D_OBSTACLE){
      stroke(0, 0, 255, 60);
      strokeWeight(radius);
      line(position.x, position.y, position.x + forward.x * OBST_AHEAD * radius, position.y + forward.y * OBST_AHEAD * radius); 
      strokeWeight(1);
      stroke(0, 255, 0);
      ellipse(position.x, position.y, radius * 2, radius * 2);
      stroke(0);
    }
  }
  
  //class methods

  //Returns the nearest human to this zombie. Returns null if there are none
  Human findNearestHuman(){
    Human nearest = null;
    float dist = 2000000;
    for(Human h: humans){
      PVector VTC = PVector.sub(h.position, position);
      if(dist > VTC.mag()){
        nearest = h;
        dist = VTC.mag();
      }
    }
    
    return nearest;
  }
}