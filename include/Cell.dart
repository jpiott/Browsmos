library Cell;
import 'dart:math';
import 'dart:html';
import 'Mover.dart';
import 'Camera.dart';

class Cell extends Mover {
  
  //double x_veloc;
  //double y_veloc;
  //double radius;
  bool dead = false;
  double default_x;
  double default_y;
  String fillStyle = "#73DBFF";

  Cell(double xpos, double ypos, double radius) {
    this.radius = radius;
    this.x_pos = xpos;
    this.y_pos = ypos;
    this.default_x = this.x_pos;
    this.default_y = this.y_pos;
  }
  
  reset() {
    this.x_pos = this.default_x;
    this.y_pos = this.default_y;
    this.x_veloc = 0.0;
    this.y_veloc = 0.0;
    this.dead = false;
  }
  
  update(int frame_delta) {
    if (!this.dead)
      this.update_mover(frame_delta);
  }
  
  draw(CanvasRenderingContext2D ctx, Camera cam, bool shadow, {double player_radius:null}) {
    if (!this.dead) {
      // Shadow
      if (shadow) {
        ctx.fillStyle = "rgba(0,0,0,0.3)";  // gray
        ctx.beginPath();
        ctx.arc(cam.world_to_viewport_x(this.x_pos.toInt())+1, cam.world_to_viewport_y(this.y_pos.toInt())+3, this.radius*cam.scale, 0, PI*2, true);
        ctx.closePath();
        ctx.fill();
      }
      
      if (player_radius != null) {
        if (this.radius > player_radius)
          ctx.fillStyle = "#FF441A";  // red
        else if (player_radius - this.radius < 3)
          ctx.fillStyle = "#FFAF00";  // white
        else
          ctx.fillStyle = "#36B6FF"; // blue
      }
      else
        ctx.fillStyle = this.fillStyle;

      ctx.beginPath();
      ctx.arc(cam.world_to_viewport_x(this.x_pos.toInt()), cam.world_to_viewport_y(this.y_pos.toInt()), this.radius*cam.scale, 0, PI*2, true);
      ctx.closePath();
      ctx.fill();
    }
  }
  
  area() {
    return PI * this.radius * this.radius;
  }
}