class Human extends Vehicle{
  
  //For Part A PShape body;
  PImage spriteSheet;
  PVector steeringForce;
  int spriteSheetNumber;
  
  //constructor
  Human(float x, float y, float r, float ms, float mf){
    super(x, y, r, ms, mf);
    steeringForce = new PVector(0, 0);
    spriteSheetNumber = int(random(1, 7));
    spriteSheet = loadImage("res/" + spriteSheetNumber + "HumanSpriteSheet.png");
    
    //define plumbob
    plumbob = createShape();
    plumbob.beginShape();
      plumbob.fill(255, 0, 0, 128);
      plumbob.stroke(255, 0, 0, 255);
      plumbob.vertex(0, 10);
      plumbob.vertex(5, 0);
      plumbob.vertex(0, -10);
      plumbob.vertex(-5, 0);
    plumbob.endShape(CLOSE);
    
    /* For Part A
    //create human
    body = createShape();
    body.beginShape();
      body.stroke(255, 0, 0);
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
    Zombie nearest = findNearestZombie();
    if(nearest != null){
      steeringForce.add(evade(nearest).mult(.8));
      if(D_HUMANS){
        fill(110, 255, 30);
        line(position.x, position.y, nearest.position.x, nearest.position.y);
        fill(0);
      }
    }
    else{
      PVector wander = wander();
      wander.mult(.3);
      steeringForce.add(wander); 
    }
    
    //avoid abstacles
    for(Obstacle o: obstacles){
      steeringForce.add(avoidObstacle(o).mult(.2)); 
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
  
  //draws the human on screen and debug lines
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
      if(angle > -3 * QUARTER_PI && angle <= -1 * QUARTER_PI){
         PImage sprite = spriteSheet.get(40 * frame, 80, 40, 40);
         image(sprite, -20, -20);
      }
      else if(angle > -1 * QUARTER_PI && angle <= QUARTER_PI){
        PImage sprite = spriteSheet.get(40 * frame, 40, 40, 40);
         image(sprite, -20, -20);
      }
      else if(angle > 1 * QUARTER_PI && angle <= 3 * QUARTER_PI){
        PImage sprite = spriteSheet.get(40 * frame, 0, 40, 40);
         image(sprite, -20, -20);
      }
      else{
        PImage sprite = spriteSheet.get(40 * frame, 120, 40, 40);
         image(sprite, -20, -20);
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
      stroke(255, 0, 0);
      ellipse(position.x, position.y, radius * 2, radius * 2);
      stroke(0);
    }
  }
  
  //class methods
  
  //Returns the nearest zombie to this human that's within a certain distance.
  Zombie findNearestZombie(){
    Zombie nearest = null;
    float dist = radius * 20;  //only look 20 radii away
    
    //iterate through zombies
    for(Zombie z: zombies){
      //get vector to center from position
      PVector VTC = PVector.sub(z.position, position);
      
      //if zombie is closer than nearest, make neares that zombie
      if(dist > VTC.mag()){
        nearest = z;
        dist = VTC.mag();
      }
    }
    
    //detect collision
    if(nearest != null && dist <= radius + nearest.radius){
      becomeZombie();
    }
    
    return nearest;
  }
  
  //Creates a new zombie object with same stats as this human
  void becomeZombie(){
     //create identicle zombie
     Zombie me = new Zombie(position.x, position.y, radius, ZOMBIE_MAX_SPEED, ZOMBIE_MAX_FORCE);
     me.position = position.copy();
     me.velocity = velocity.copy();
     me.acceleration = acceleration.copy();
     me.spriteSheetNumber = spriteSheetNumber;
     me.spriteSheet = loadImage("res/" + spriteSheetNumber + "ZombieSpriteSheet.png");
     
     //remove the old human and add the new zombie in
     humansToRemove.add(this);
     zombiesToAdd.add(me);
  }
}