import gab.opencv.*;
import processing.video.*;
import java.awt.*;

// Number of columns and rows in our system
int cols, rows;

// Variable to hold onto Capture object
Capture video;
OpenCV opencv;


// size
int winWidth  = 640;
int winHeight = 480;

float avg_r, avg_g, avg_b;

int filter=20;
int filter_index = 6;
int[] filters = {1, 2, 4, 5, 8, 10, 20, 40, 80, 100, 120};

void setup() {
  
  size(640,480);
  
  noFill();
  noStroke();
  smooth();
  
  filter = filters[filter_index];
  
  video = new Capture(this,"name=FaceTime HD Camera (Built-in),size=640x480,fps=30");
  
  opencv = new OpenCV(this, winWidth,winHeight);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  video.start();
}

void draw() {
 if (video.available()) {
      background( 255 );
      
        video.read();    
        video.loadPixels();
        if (video.width > 0 && video.height > 0){
          opencv.loadImage(video);
        }
        
          for (int x = 0; x < width; x++){
            for (int y = 0; y < height; y++){
              color c = video.get(x,y);
              set(x,y,c);
            }
          }
          
          Rectangle[] faces = opencv.detect();
          for (int i = 0; i < faces.length; i++){
            
            for (int x = faces[i].x;  x < faces[i].x+faces[i].width; x+=filter) {
              for (int y = faces[i].y; y < faces[i].y+faces[i].height; y+=filter ) {
    
                avg_r = avg_g = avg_b = 255.0;
                
                for (int r = x; r < x+filter; r++) {
                  for (int c = y; c < y+filter; c++ ) {
                    int loc = r + c*video.width;
                    //int loc = r + c*faces[i].width;
                    
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