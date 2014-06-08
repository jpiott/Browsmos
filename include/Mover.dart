library Mover;
import 'dart:math';
import 'dart:html';

// Super-"class" of Ball and Player
// Handles physical attributes and actions
class Mover {
  
  // Variables to hold size
  double radius = 20.0;

  // Variables to hold current position
  int x_pos = 0;
  int y_pos = 0;

  // Variables to hold current velocity
  double x_veloc = 0.0;
  double y_veloc = 0.0;

  // Speed limits
  double x_veloc_max = 100.0;
  double y_veloc_max = 100.0;

  // Variables to hold x position bounds
  int x_min = 0;
  int x_max = 640;
  
  double friction = 0.997;
  
  Mover() {
  }
  
  horizontalBounce() {
    this.x_veloc = -this.x_veloc;
  }
  
  verticalBounce() {
    this.y_veloc = -this.y_veloc;
  }
  
  distance_from(Mover other) {
    int dx = this.x_pos - other.x_pos;
    int dy = this.y_pos - other.y_pos;
    return sqrt(pow(dx, 2) + pow(dy, 2));
  }
  
  collides_with(Mover other) {
    return this.distance_from(other) < this.radius + other.radius;
  }
  
  set_position(int x, int y) { 
    this.x_pos = x; this.y_pos = y; 
  }
  
  update_mover(int frame_delta) {
    // Enforce speed limits
    int xvelsign = (this.x_veloc == 0.0 ? 0 : this.x_veloc ~/ this.x_veloc.abs());
    if (this.x_veloc.abs() > this.x_veloc_max)
      this.x_veloc = xvelsign * this.x_veloc_max;
    int yvelsign = (this.y_veloc == 0.0 ? 0 : this.y_veloc ~/ this.y_veloc.abs());
    if (this.y_veloc.abs() > this.y_veloc_max)
      this.y_veloc = yvelsign * this.y_veloc_max;
   
    // Adjust the position, according to velocity.
    this.x_pos += (this.x_veloc).toInt();
    this.y_pos += (this.y_veloc).toInt();
    
    // Friction
    this.x_veloc *= this.friction;
    this.y_veloc *= this.friction;
  }
  /*
  draw_mover(CanvasRenderingContext2D ctx) {
    ctx.beginPath();
    ctx.rect(this.x_pos, this.y_pos, this.width, this.height);
    ctx.closePath();
    ctx.fill();
  }

  this.reset = this.reset_mover;    // Override me
  this.update = this.update_mover;  // Override me
  this.draw = this.draw_mover;    // Override me
  */
  
}