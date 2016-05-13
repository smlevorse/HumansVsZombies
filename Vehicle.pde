//Vehicle class
//Specific autonomous agents will inherit from this class 
//Abstract since there is no need for an actual Vehicle object
//Implements the stuff that each auto agent needs: movement, steering force calculations, and display

abstract class Vehicle {

  //--------------------------------
  //Class fields
  //--------------------------------
  //vectors for moving a vehicle
  PVector position, velocity, acceleration;

  //no longer need direction vector - will utilize forward and right
  //these orientation vectors provide a local point of view for the vehicle
  PVector forward, right;

  //floats to describe vehicle movement and size
  float mass = 1;
  float radius;
  float maxSpeed, maxForce;
  
  PShape plumbob;

  //--------------------------------
  //Constructor
  //Vehicle(x position, y position, radius, max speed, max force)
  //--------------------------------
  Vehicle(float x, float y, float r, float ms, float mf) {
    //Assign parameters to class fields
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    radius = r;
    maxSpeed = ms;
    maxForce = mf;
    
    forward = new PVector(0,0);
    right = new PVector(0,0);
    
  }

  //--------------------------------
  //Abstract methods
  //--------------------------------
  //every sub-class Vehicle must use these functions
  abstract void calcSteeringForces();
  abstract void display();

  //--------------------------------
  //Class methods
  //--------------------------------
  
  //Method: update()
  //Purpose: Calculates the overall steering force within calcSteeringForces()
  //         Applies movement "formula" to move the position of this vehicle
  //         Zeroes-out acceleration 
  void update() {
    //calculate forward and right vectors
    forward = velocity.copy();
    forward.normalize();
    right.x = -forward.y;
    right.y = forward.x;
    
    //update forwad and right vectors
    //calculate steering forces by calling calcSteeringForces()
    calcSteeringForces();
    
    //add acceleration to velocity, limit the velocity, and add velocity to position
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    
    //reset acceleration
    acceleration.mult(0);
  }

  
  //Method: applyForce(force vector)
  //Purpose: Divides the incoming force by the mass of this vehicle
  //         Adds the force to the acceleration vector
  void applyForce(PVector force) {
    acceleration.add(PVector.div(force, mass));
  }
  
  
  //--------------------------------
  //Steering Methods
  //--------------------------------
  
  //Method: seek(target's position vector)
  //Purpose: Calculates the steering force toward a target's position
  PVector seek(PVector target){
      
    //write the code to seek a target!
    PVector desiredVelocity = PVector.sub(target, position);
    desiredVelocity.normalize();
    desiredVelocity.mult(maxSpeed);
    PVector steeringForce = PVector.sub(desiredVelocity, velocity);
    return steeringForce;
  }
  
  //Calculates the steering force to flee the target position given
  PVector flee(PVector target){
      
    //write the code to flee a target!
    PVector desiredVelocity = PVector.sub(target, position);
    desiredVelocity.normalize();
    desiredVelocity.mult(-1 * maxSpeed);
    PVector steeringForce = PVector.sub(desiredVelocity, velocity);
    return steeringForce;
  }
  
  //Calculates the steering force to pursue the given target
  PVector pursue(Vehicle target){
    //get the targets position in 10 frames
    PVector pos = target.position.copy();
    PVector deltaPos = target.velocity.copy();
    deltaPos.mult(TIME_AHEAD);
    pos.add(deltaPos);
    return seek(pos);
  }
  
  //Calculates the steering force to evade a given target
  PVector evade(Vehicle target){
    //get the targets position in 10 frames
    PVector pos = target.position.copy();
    PVector deltaPos = target.velocity.copy();
    deltaPos.mult(TIME_AHEAD);
    pos.add(deltaPos);
    return flee(pos);
  }
  
  //calculates the steering force needed to avoid an obstacle o
  PVector avoidObstacle(Obstacle o){
    //get vector to center
    PVector VTC = PVector.sub(o.position, position);
    
    //if the distance to obstacle is greater than VtoC.mag(), ignore
    if(VTC.mag() < radius * OBST_AHEAD + o.radius){
      
      //if the PVector.dot(VtoC, forward) < 0, ignore
      float fDot = PVector.dot(VTC, forward);
      if(fDot < 0){
        return new PVector(0,0); 
      }
      
      //if the PVector.dot(VtoC, right) < radius[vehicle] + radius[object]
      float rDot = PVector.dot(VTC, right);
      if(abs(rDot) < abs(radius + o.radius)){
        //draw debugging line
        if(D_OBSTACLE){
          stroke(255, 0, 255);
          line(position.x, position.y, position.x + VTC.x, position.y + VTC.y);
          stroke(0);
        }
        
        //add the scaled steering force
        PVector steeringForce = right.copy();
        steeringForce.mult(maxSpeed);
        steeringForce.mult(-rDot);
        return steeringForce;
      }
      
    }
    return new PVector(0,0);
  }
  
  //Calculates a random steering force
  PVector wander(){
    //get a random point on the circle in front of the point
    PVector rad = velocity.copy();
    if(rad.mag() == 0){
      rad = new PVector(randomGaussian(), randomGaussian()); 
    }
    rad.normalize();
    rad.mult(WANDER_RADIUS);
    PVector center = PVector.add(position, rad);
    PVector delta = new PVector(rad.mag() * cos(random(0, TAU)), rad.mag() * sin(random(0, TAU)));
    return seek(PVector.add(center, delta));
  }
  
}