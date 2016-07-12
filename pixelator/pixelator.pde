import processing.video.*;

// Number of columns and rows in our system
int cols, rows;
// Variable to hold onto Capture object
Capture video;
PImage output;

// size
int winHeight = 480;
int winWidth  = 640;

float avg_r, avg_g, avg_b;

int filter=20;
int filter_index = 6;
int[] filters = {1, 2, 4, 5, 8, 10, 20, 40, 80, 100, 120};

void setup() {
  
  size(640,480);
  surface.setResizable(true);
  surface.setSize(winWidth, winHeight);
  
  noFill();
  noStroke();
  smooth();
  
  filter = filters[filter_index];
  
  video = new Capture(this,"name=FaceTime HD Camera (Built-in),size=640x480,fps=30");
  video.start();
}

void draw() {
  
  if (video.available()) {
    
    background( 255 );
    
      video.read();    
      video.loadPixels();
      
        int minX = 120;
        int minY = 120;
        int maxX = 360;
        int maxY = 360;
        
        int nonPixSize = minX *minY;
        
        for (int x = 0; x < width; x++){
          for (int y = 0; y < height; y++){
            int pixNum = y + x*width;
            color c = video.get(x,y);
            set(x,y,c);
          }
        }
        
        for (int x = minX;  x < maxX; x+=filter) {
          for (int y = minY; y < maxY; y+=filter ) {
    
            avg_r = avg_g = avg_b = 255.0;
            
            for (int r = x; r < x+filter; r++) {
              for (int c = y; c < y+filter; c++ ) {
                int loc = r + c*video.width;
    
                avg_r += red   (video.pixels[loc]);
                avg_g += green (video.pixels[loc]);
                avg_b += blue  (video.pixels[loc]);
              }
            }
    
            color col = color(avg_r/(filter*filter), 
                              avg_g/(filter*filter), 
                              avg_b/(filter*filter));
            fill( col );
            rect(x,y,filter,filter);
          }
        }
          
      video.updatePixels();
  }
}

void keyPressed() {
  if( keyCode == 38 ) {
    filter_index++;
  } else if( keyCode == 40 ) {
    filter_index--;
  }
  
  if( filter_index < 0 ) {
    filter_index = 0;
  } else if( filter_index > 7 ) {
    filter_index = 7;
  }
  
  filter = filters[filter_index];
}