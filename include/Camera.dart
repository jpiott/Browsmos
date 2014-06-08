library Camera;
import 'dart:html';

class Camera {

  double scale_smoothness = .3;
  double move_smoothness = .3;
  int x = 0;
  int y = 0;
  int x_target = 0;
  int y_target = 0;
  double scale = .5;
  double scale_target = 1.0;
  CanvasElement canvas;

  Camera(CanvasElement canvas) {
    this.canvas = canvas;
  }
  
  world_to_viewport(int n, String dimension) {
    int canvas_side_length = (dimension == 'x') ? this.canvas.width : this.canvas.height;
    int offset = (dimension == 'x') ? this.x : this.y;
    return (n * this.scale) + (canvas_side_length / 2) - (offset * this.scale);
  }
  
  world_to_viewport_x(int x) {
    return this.world_to_viewport(x, 'x');
  }
  
  world_to_viewport_y(int y) {
    return this.world_to_viewport(y, 'y');
  }
  
  viewport_to_world(int n, String dimension) {
    int canvas_side_length = (dimension == 'x') ? this.canvas.width : this.canvas.height;
    int offset = (dimension == 'x') ? this.x : this.y;
    return (n + (offset * this.scale) - (canvas_side_length / 2)) ~/ this.scale;
  }
  
  viewport_to_world_x(int x) {
    return this.viewport_to_world(x, 'x');
  }
  
  viewport_to_world_y(int y) {
    return this.viewport_to_world(y, 'y');
  }
  
  update(int target_x, int target_y, int frame_delta) {
    this.x_target = target_x;
    this.y_target = target_y;
    
    // Gently move to target
    if (this.scale != this.scale_target)
      this.scale = this.scale.abs() + (frame_delta * (this.scale_target - this.scale) * this.scale_smoothness).abs();
    if (this.x != this.x_target)
      this.x += (frame_delta * (this.x_target - this.x) * this.move_smoothness).toInt();
    if (this.y != this.y_target)
      this.y += (frame_delta * (this.y_target - this.y) * this.move_smoothness).toInt();
  }
}