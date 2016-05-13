class Obstacle{
  PVector position;
  int radius;
  
  PImage tree;
  
  //constructor
  Obstacle(int x, int y, int radius){
    position = new PVector(x, y);
    this.radius = radius;
    
    tree = loadImage("res/tree_" + int(random(1, 4)) + ".png");
  }
  
  //draws the obstacle on screen
  void display(){
    if(D_OBSTACLE){
      ellipse(position.x, position.y, radius * 2, radius * 2); 
    }
    image(tree, position.x - 25, position.y - 75);
  }
}