import 'dart:html';
import 'include/World.dart';

// Engine globals
//int fps = 30;
//int mspf = 1000 ~/ fps;
int updateInterval;
List center;
int viewport_radius;

// Game globals
World world;

void main() {
  
  CanvasElement canvas = querySelector('#canvas');
  //CanvasRenderingContext2D ctx = canvas.getContext('2d');
  //canvas.height = window.innerHeight;
  //canvas.width = window.innerWidth;
  center = [canvas.width ~/ 2, canvas.height ~/ 2];
  
  // Initialize the world
  world = new World(canvas);
  world.load_level();
  
  // Animate!
  window.animationFrame.then((value) => world.update());

}