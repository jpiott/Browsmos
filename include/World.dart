import 'dart:html';
import 'Cell.dart';

class World {

  // Constants
  double transfer_rate_k;
  
  // Variables and setup
  List cells;    // Array of 
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  //Camera cam;
  int _lastTick;
  int frameSpacing;              // for timer
  int frame_delta;             // for timer
  String surr_color;  // Surrounding color of canvas outside of the level
  String bg_color;    // Background color of the level (inside the boundaries)
  int level_width;   // Just a default; Will be set in load_level
  int level_height;  // Just a default; Will be set in load_level
  int level_total_mass;    // Will store the total mass of all cells at a given time
  bool won;     // Indicates if the player has won (and is now just basking in his own glory)
  bool user_did_zoom; // Indicates if the player manually zoomed (so we can turn off smart zooming)
  bool paused;
  bool has_started; // Indicates if the intro menu has been dismissed at least once
  bool debug;
  bool shadows;
  //MusicPlayer music;
  
  World(CanvasElement canvas) {
    // Constants
    this.transfer_rate_k = 0.25;
    
    // Variables and setup
    this.cells = [];    // Array of 
    this.canvas = canvas;
    this.ctx = this.canvas.getContext('2d');
    //this.cam = new Camera(canvas);
    //this._lastTick = (new Date()).getTime();  // for timer
    this.frameSpacing;              // for timer
    this.frame_delta;             // for timer
    this.surr_color = "#1D40B5";  // Surrounding color of canvas outside of the level
    this.bg_color = "#2450E4";    // Background color of the level (inside the boundaries)
    this.level_width = 800;   // Just a default; Will be set in load_level
    this.level_height = 800;  // Just a default; Will be set in load_level
    this.level_total_mass;    // Will store the total mass of all cells at a given time
    this.won = false;     // Indicates if the player has won (and is now just basking in his own glory)
    this.user_did_zoom = false; // Indicates if the player manually zoomed (so we can turn off smart zooming)
    this.paused = false;
    this.has_started = false; // Indicates if the intro menu has been dismissed at least once
    this.debug = false;
    this.shadows = true;
    /*
    this.music = new MusicPlayer(
      [ // Music tracks (filename, song name, artist)
        ['music/Pitx_-_Black_Rainbow.ogg', 'Black Rainbow', 'Pitx'], 
        ['music/rewob_-_Circles.ogg', 'Circles', 'rewob'],
      ], 
      { // Sound effects (identifier, filename)
        'blip': ['fx/blip.ogg'],
        'win': ['fx/win.ogg'],
        'death': ['fx/death.ogg'],
        'bounce': ['fx/bounce.ogg'],
      }
    );*/
    
    // Event registration
    this.canvas.onMouseDown.listen((event) => this.mouse_down(event));
    this.canvas.onTouchStart.listen((event) => this.touch_start(event));
    document.onMouseWheel.listen((event) => this.mouse_scroll(event));
    window.onKeyDown.listen((event) => this.key_down(event));
    window.onBlur.listen((event) => this.pause(forcepause: true));
    
    //querySelector("#mute").onClick.listen((event) => this.music.mute());
    querySelector("#newlevel").onClick.listen((event) => this.load_level());
    querySelector("#pause").onClick.listen((event) => this.pause());
    querySelector("#help").onClick.listen((event) => this.toggle_help());
    querySelector("#pausedmessage").onClick.listen((event) => this.pause());
    querySelector("#deathmessage").onClick.listen((event) => this.load_level());
    querySelector("#warningmessage").onClick.listen((event) => this.load_level());
    querySelector("#successmessage").onClick.listen((event) => this.load_level());
    
    querySelector("#playbutton").onClick.listen((event) {
      this.toggle_help();
      // Play a sound in order to allow any sound playback at all on iOS
     //this.music.play_sound("win");
    });
          
    //this.music.init();
  }
  
  toggle_help() {
    
  }
  
  pause({bool forcepause: false}) {
    window.console.log("pause()");
  }
  
  zoom_to_player() {
    
  }
  
  load_level() {
    window.console.log("load_level()");
  }
  
  get_player() {
    
  }
  
  push_player_from(int x, int y) {
    
  }
  
  click_at_point(int x, int y) {
    
  }
  
  touch_start(Event e) {
    
  }
  
  mouse_down(Event e) {
    window.console.log("Mouse Down");
  }
  
  mouse_scroll(Event e) {
    
  }
  
  key_down(Event e) {
    
  }
  
  transfer_mass(Cell cell1, Cell cell2) {
    
  }
  
  clear_msgs(bool forceclear) {
    
  }
  
  show_message(String id) {
    
  }
  
  player_did_die() {
    
  }
  
  player_did_win() {
    
  }
  
  update() {
    window.animationFrame.then((value) => this.update());
  }
  
  angleForVector(int x, int y) {
    
  }
  
}