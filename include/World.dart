library World;
import 'dart:html';
import 'dart:math';
import 'Cell.dart';
import 'Camera.dart';

class World {

  // Constants
  double transfer_rate_k;
  
  // Variables and setup
  List<Cell> cells;    // Array of 
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  Camera cam;
  DateTime _lastTick;
  int frameSpacing;              // for timer
  int frame_delta;             // for timer
  String surr_color;  // Surrounding color of canvas outside of the level
  String bg_color;    // Background color of the level (inside the boundaries)
  int level_width;   // Just a default; Will be set in load_level
  int level_height;  // Just a default; Will be set in load_level
  double level_total_mass;    // Will store the total mass of all cells at a given time
  double level_radius;
  bool won;     // Indicates if the player has won (and is now just basking in his own glory)
  bool user_did_zoom; // Indicates if the player manually zoomed (so we can turn off smart zooming)
  bool paused;
  bool has_started; // Indicates if the intro menu has been dismissed at least once
  bool debug;
  bool shadows;
  int fps = 30;
  int mspf;
  List center;
  //MusicPlayer music;
  
  World(CanvasElement canvas) {
    // Constants
    this.transfer_rate_k = 0.25;
    
    // Variables and setup
    this.cells = [];    // Array of 
    this.canvas = canvas;
    this.ctx = this.canvas.getContext('2d');
    this.cam = new Camera(canvas);
    this._lastTick = new DateTime.now();  // for timer
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
    this.mspf = 1000 ~/ this.fps;
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
    
    canvas.height = window.innerHeight;
    canvas.width = window.innerWidth;
    this.center = [canvas.width ~/ 2, canvas.height ~/ 2];
    
    // Event registration
    this.canvas.onMouseDown.listen((MouseEvent event) => this.mouse_down(event));
    this.canvas.onTouchStart.listen((TouchEvent event) => this.touch_start(event));
    document.onMouseWheel.listen((WheelEvent event) => this.mouse_scroll(event));
    window.onKeyDown.listen((KeyboardEvent event) => this.key_down(event));
    window.onBlur.listen((Event event) => this.pause(forcepause: true));
    
    //querySelector("#mute").onClick.listen((MouseEvent event) => this.music.mute());
    querySelector("#newlevel").onClick.listen((MouseEvent event) => this.load_level());
    querySelector("#pause").onClick.listen((MouseEvent event) => this.pause());
    querySelector("#help").onClick.listen((MouseEvent event) => this.toggle_help());
    querySelector("#pausedmessage").onClick.listen((MouseEvent event) => this.pause());
    querySelector("#deathmessage").onClick.listen((MouseEvent event) => this.load_level());
    querySelector("#warningmessage").onClick.listen((MouseEvent event) => this.load_level());
    querySelector("#successmessage").onClick.listen((MouseEvent event) => this.load_level());
    
    querySelector("#playbutton").onClick.listen((MouseEvent event) {
      this.toggle_help();
      // Play a sound in order to allow any sound playback at all on iOS
     //this.music.play_sound("win");
    });
          
    //this.music.init();
  }
  
  toggle_help() {
    DivElement overlay = querySelector("#helpoverlay");
    
    // If overlay is hidden
    if (overlay.style.display == "none") {
      this.pause(forcepause: true);         // Pause the game
      overlay.style.display = "block";  // Show overlay
    }
    else {
      overlay.style.display = "none";   // Hide overlay
    }
    
    // If we're just now starting the game
    if (!this.has_started) {
      this.load_level();
      //this.music.play_song();
      this.has_started = true;
    }
  }
  
  pause({bool forcepause: false}) {
    if (this.paused && !forcepause) {
      // Unpause
      this.clear_msgs();
      this.paused = false;
      //this.music.raise_volume();
    }
    else {
      // Pause
      this.show_message("pausedmessage");
      this.paused = true;
      //this.music.lower_volume();
    }
  }
  
  zoom_to_player() {
    // Scale 1x looks best when player radius is 40
    Cell player = this.get_player();
    this.cam.scale_target = 40.0 / player.radius;
  }
  
  load_level() {
    window.console.log("load_level()");
    this.cells = [];
    this.user_did_zoom = false;
    this.won = false;
    this.clear_msgs();
    
    // Define level boundary
    this.level_radius = 500.0;
    
    // Define the player first
    this.cells.add(new Cell(0.0, 0.0, 10.0));
    
    // Generate a bunch of random cells
    Random randomGen = new Random();
    int num_cells = 30;
    Cell cell;
    double rad, ang, r, x, y;
    for (int i=0; i<num_cells; i++) {
      if (i < 4)
        rad = 5 + randomGen.nextDouble() * 5;  // Small cells
      else if (i < 6)
        rad = 40 + randomGen.nextDouble() * 15;  // Big cells
      else
        rad = 7 + randomGen.nextDouble() * 35; // Everything else
      ang = randomGen.nextDouble() * 2 * PI;
      r = randomGen.nextDouble() * (this.level_radius - 20 - rad - rad);
      x = (30 + rad + r) * sin(ang);
      y = (30 + rad + r) * cos(ang);
      cell = new Cell(x, y, rad);
      cell.x_veloc = (randomGen.nextDouble() - .5) * .35;
      cell.y_veloc = (randomGen.nextDouble() - .5) * .35;
      this.cells.add(cell);
    }
    //delete cell;
    
    // Center camera over level
    if (this.cam.x == 0 && this.cam.y == 0) {
      this.cam.x = this.level_width ~/ 2;
      this.cam.y = this.level_width ~/ 2;
    }
    this.cam.x_target = this.cam.x;
    this.cam.y_target = this.cam.y;
    this.zoom_to_player();
    
    // Count total cell mass for loaded level
    this.level_total_mass = 0.0;
    for (int i=0; i<this.cells.length; i++) {
      cell = this.cells[i];
      this.level_total_mass += cell.area();
    }
  }
  
  get_player() {
    if (this.cells.length > 0)
      return this.cells[0];
  }
  
  push_player_from(int x, int y) {
    Cell player = this.get_player();
    if (player != null && !player.dead) {
      double dx = (player.x_pos - x).toDouble();
      double dy = (player.y_pos - y).toDouble();

      // Normalize dx/dy
      double mag = sqrt(pow(dx, 2) + pow(dy, 2));
      dx = (dx / mag);
      dy = (dy / mag);
      
      // Reduce force in proportion to area
      double area = player.area();
      double fx = dx * (5/9);// (400 / (area + 64));
      double fy = dy * (5/9);//(400 / (area + 64));
      
      // Push player
      player.x_veloc += fx;
      player.y_veloc += fy;
      
      // Lose some mass (shall we say, 1/25?)
      double expense = (area/25) / (2*PI*player.radius);
      player.radius -= expense;
      
      // Shoot off the expended mass in opposite direction
      double newrad = sqrt((area/20)/PI);
      double newx = player.x_pos - (dx * (player.radius + newrad + 1)); // The +1 is for cushioning!
      double newy = player.y_pos - (dy * (player.radius + newrad + 1));
      Cell newcell = new Cell(newx, newy, newrad);
      newcell.x_veloc = -fx * 9;
      newcell.y_veloc = -fy * 9;
      this.cells.add(newcell);

      // Blip!
      //this.music.play_sound("blip");
    }
  }
  
  click_at_point(int x, int y) {
    if (!this.paused) {
      // Convert view coordinates (clicked) to world coordinates
      x = this.cam.viewport_to_world_x(x);
      y = this.cam.viewport_to_world_y(y);
    
      // Push player
      this.push_player_from(x, y);
    }
  }
  
  touch_start(TouchEvent e) {
    e.preventDefault();    // Prevent dragging
    Touch touch = e.touches[0];  // Just pay attention to first touch
    this.click_at_point(touch.page.x, touch.page.y);// - offset.left/offset.top(?)
  }
  
  mouse_down(MouseEvent e) {
    e.preventDefault();
    if (e.layer.x != null || e.layer.x == 0) {
      this.click_at_point(e.layer.x, e.layer.y);
    }    
  }
  
  mouse_scroll(WheelEvent event) {
    double delta = 0.0;
 
    //if (event == null) event = window.event;

    // normalize the delta
    delta = -event.deltaY / 2;
    delta = delta / delta.abs();
    
    if (delta != 0) {
      this.user_did_zoom = true;
      if (delta > 0)
        this.cam.scale_target *= 1.2;
      if (delta < 0)
        this.cam.scale_target /= 1.2;
    }
  }
  
  key_down(KeyboardEvent e) {
    int code;
    //if (!e) var e = window.event;
    if (e.keyCode != null) code = e.keyCode;
    else if (e.which != null) code = e.which;
    
    if (this.debug)
      window.console.log("Pressed key with code " + code.toString());
    
    switch (code){ 
      case 80:  // P
        this.pause();
        break;
      case 82:  // R
        this.load_level();
        break;
      case 68:  // D
        this.debug = !this.debug;
        break;
      case 72:  // H
        this.toggle_help();
        break;
      case 83:  // S
        this.shadows = !this.shadows;
        break;
      case 77:  // M
        //this.music.mute();
        break;
      case 78:  // N
        //this.music.next_song();
        break;
    }
  }
  
  transfer_mass(Cell cell1, Cell cell2) {
    Cell player = this.get_player();
    
    // Determine bigger cell
    Cell bigger = cell1;
    Cell smaller = cell2;
    if (cell2.radius > cell1.radius) {
      bigger = cell2;
      smaller = cell1;
    }
    
    // Overlap amount will affect transfer amount
    double overlap = (cell1.radius + cell2.radius - cell1.distance_from(cell2)) / (2 * smaller.radius);
    if (overlap > 1) overlap = 1.0;
    overlap *= overlap;
    double mass_exchange = overlap * smaller.area();
    
    smaller.radius -= mass_exchange / (2*PI*smaller.radius);
    bigger.radius += mass_exchange / (2*PI*bigger.radius);
    
    // If the player is the one gaining mass here, zoom the camera
    if (bigger == player && !this.user_did_zoom) {
      this.zoom_to_player();
    }
    
    
    // Check if we just killed one of the cells
    if (smaller.radius <=1) {
      smaller.dead = true;
      
      // If we just killed the player, callback.
      if (smaller == player)
        this.player_did_die();
    }
  }
  
  clear_msgs({bool forceclear: false}) {
    List<DivElement> msgs = querySelectorAll('.messages');
    for (int i=0; i<msgs.length; i++) {
      msgs[i].style.display = 'none';
    }
    
    // Re-show important messages that are still relevant
    if (!forceclear) {
      Cell player = this.get_player();
      if (this.won)
        this.show_message('successmessage');
      else if (player != null && player.dead)
        this.show_message('deathmessage');
    }
  }

  show_message(String id) {
    this.clear_msgs(forceclear: true);
    DivElement div = querySelector('#'+id);
    if (div != null) {
      div.style.display = 'block';
    }
  }
  
  player_did_die() {
    //this.music.play_sound("death");
    this.show_message("deathmessage");
    
    // Cute animation thing
    Cell player = this.get_player();
    player.x_pos = player.y_pos = 0.0;
    if (this.cam.scale_target > 0.538)
      this.cam.scale_target = 0.538;
    for (int i=1; i<this.cells.length; i++) {
      Cell cell = this.cells[i];
      if (!cell.dead) {
        cell.x_veloc += (cell.x_pos - player.x_pos) / 50;
        cell.y_veloc += (cell.y_pos - player.y_pos) / 50;
      }
    }
  }
  
  player_did_win() {
    if (!this.won) {
      this.won = true;
      //this.music.play_sound("win");
      this.show_message("successmessage");
    }
  }
  
  update() {
    Cell player = this.get_player();
    
    // Advance timer
    DateTime currentTick = new DateTime.now();
    this.frameSpacing = currentTick.difference(this._lastTick).inMilliseconds;
    this.frame_delta = this.frameSpacing ~/ mspf;
    this._lastTick = currentTick;

    // Canvas maintenance
    this.canvas.height = window.innerHeight;
    this.canvas.width = window.innerWidth;
    this.center = [this.canvas.width/2, this.canvas.height/2];
    //viewport_radius = Math.min(this.canvas.height, this.canvas.width) / 2;
    
    // Background
    this.ctx.fillStyle = this.surr_color;
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.beginPath();
    this.ctx.rect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.closePath();
    this.ctx.fill();
    
    // Level boundary
    this.ctx.fillStyle = this.bg_color;
    this.ctx.beginPath();
    this.ctx.arc(this.cam.world_to_viewport_x(0), this.cam.world_to_viewport_y(0), 
            (this.level_radius*this.cam.scale).abs(), 0, PI*2, true);
    this.ctx.closePath();
    this.ctx.fill();
    if (this.shadows) {
      this.ctx.strokeStyle = "rgba(0,0,0,0.3)";
      this.ctx.lineWidth = 2;
      this.ctx.beginPath();
      this.ctx.arc(this.cam.world_to_viewport_x(0)+2, this.cam.world_to_viewport_y(0)+4, 
              this.level_radius*this.cam.scale, 0, PI*2, true);
      this.ctx.closePath();
      this.ctx.stroke();
    }   
    this.ctx.strokeStyle = "#ffffff";
    this.ctx.lineWidth = 2;
    this.ctx.beginPath();
    this.ctx.arc(this.cam.world_to_viewport_x(0), this.cam.world_to_viewport_y(0), 
            this.level_radius*this.cam.scale, 0, PI*2, true);
    this.ctx.closePath();
    this.ctx.stroke();
    
    // Run collisions and draw everything
    double smallest_big_mass = 9999999999.0; 
    double total_usable_mass = 0.0;
    double curr_area;
    for (int i=0; i<this.cells.length; i++) {
      if (!this.cells[i].dead) {
        if (!this.paused) {
          for (int j=0; j<this.cells.length; j++) {
            if ((i != j) && (!this.cells[j].dead)) {
              if (this.cells[i].collides_with(this.cells[j])) {
                this.transfer_mass(this.cells[i], this.cells[j]);
              }
            }
          }
          this.cells[i].update(this.frame_delta);
        
          // Get some stats about orb sizes
          curr_area = this.cells[i].area();
          if (this.cells[i].radius > this.get_player().radius) {
            if (curr_area < smallest_big_mass)
              smallest_big_mass = curr_area;
          }
          else 
            total_usable_mass += curr_area;
        
          // If cell is outside of level bounds, fix it
          double cell_x = this.cells[i].x_pos;
          double cell_y = this.cells[i].y_pos;
          double cellrad = this.cells[i].radius;
          double dist_from_origin = sqrt(pow(cell_x, 2) + pow(cell_y, 2));
          if (dist_from_origin + cellrad > this.level_radius) {
            // Do some homework
            double cell_xvel = this.cells[i].x_veloc;
            double cell_yvel = this.cells[i].y_veloc;
            
            // Move cell safely inside bounds
            this.cells[i].x_pos = (this.cells[i].x_pos * ((this.level_radius-cellrad-1) / dist_from_origin));
            this.cells[i].y_pos = (this.cells[i].y_pos * ((this.level_radius-cellrad-1) / dist_from_origin));
            cell_x = this.cells[i].x_pos;
            cell_y = this.cells[i].y_pos;
            dist_from_origin = sqrt(pow(cell_x, 2) + pow(cell_y, 2));
          
            // Bounce!

            // Find speed
            double cell_speed = sqrt(pow(cell_xvel, 2) + pow(cell_yvel, 2) );
            // Find angles of "center to cell" and cell's velocity
            double angle_from_origin = angleForVector(cell_x.toDouble(), cell_y.toDouble());
            double veloc_ang = angleForVector(cell_xvel, cell_yvel);
            // Get new velocity angle
            double new_veloc_ang = PI + angle_from_origin + (angle_from_origin - veloc_ang);
            // Normalize the vector from the origin to the cell's new position
            double center_to_cell_norm_x = -cell_x * (1 / dist_from_origin);
            double center_to_cell_norm_y = -cell_y * (1 / dist_from_origin);
            // Set new velocity components
            this.cells[i].x_veloc = cell_speed * cos(new_veloc_ang);
            this.cells[i].y_veloc = cell_speed * sin(new_veloc_ang);
            
            // If this cell is the player, make a bounce noise
            if (i == 0) {
              //this.music.play_sound("bounce");
            }
          }
        }
        
        // If not the player, draw it now
        if (i != 0) {
          this.cells[i].draw(this.ctx, this.cam, this.shadows, player_radius: this.get_player().radius);
        }
      }
    }
    
    // React to statistical events
    if (!player.dead && !this.paused && !this.won) {
      if (smallest_big_mass == 9999999999) {
        // Player won
        this.player_did_win();
      }
      else if (total_usable_mass < smallest_big_mass) {
        // Display the "not looking good..." message
        this.show_message("warningmessage");
      }
    }
    
    // Draw player
    player.draw(this.ctx, this.cam, this.shadows);
    
    // Camera-track player
    this.cam.update(player.x_pos.toInt(), player.y_pos.toInt(), this.frame_delta);
    
    // Update music player
    //this.music.update();
    window.animationFrame.then((value) => this.update());
  }
}

angleForVector(double x, double y) {
  double ang =  atan(y/x);
  if (x < 0) ang += PI;
  else if (y < 0) ang += 2 * PI;
  return ang;
}