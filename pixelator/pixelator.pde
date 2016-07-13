import gab.opencv.*;
import processing.video.*;
import java.awt.*;

import oscP5.*;
import netP5.*;

// Number of columns and rows in our system
int cols, rows;

// Variable to hold onto Capture object
Capture video;
OpenCV opencv;

float avg_r, avg_g, avg_b;

int filter=20;
int filter_index = 6;
int[] filters = {8, 10, 20, 24, 32, 40, 50, 60};

// for OSC communication
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {

  size(640, 480);

  noFill();
  noStroke();
  smooth();

  filter = filters[filter_index];
    
  video = new Capture(this,"name=FaceTime HD Camera (Built-in),size=640x480,fps=60");

  opencv = new OpenCV(this, 640, 480);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  video.start();

  // make sure to have TSPS sending to this port at localhost
  oscP5 = new OscP5(this, 12000);
}

void draw() {

  if (video.available()) {
    background( 255 );

    video.read();    
    video.loadPixels();
    if (video.width > 0 && video.height > 0) {
      opencv.loadImage(video);
      //println("totalPix: ", video.width*video.height);
    }

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        color c = video.get(x, y);
        set(x, y, c);
      }
    }

    Rectangle[] faces = opencv.detect();
    for (int i = 0; i < faces.length; i++) {

      for (int x = faces[i].x; x < faces[i].x+faces[i].width; x+=filter) {
        for (int y = faces[i].y; y < faces[i].y+faces[i].height; y+=filter ) {

          avg_r = avg_g = avg_b = 255.0;

          for (int r = x; r < x+filter; r++) {
            for (int c = y; c < y+filter; c++ ) {
              int loc = r + c*video.width;

              // keep the array inside bound
              // will probably get array out of bound if tracking two
              // people or more. keep loc lower than total pixel
              if (loc <= video.width*video.height) {
                avg_r += red   (video.pixels[loc]);
                avg_g += green (video.pixels[loc]);
                avg_b += blue  (video.pixels[loc]);
              }
            }
          }

          color col = color(avg_r/(filter*filter), 
            avg_g/(filter*filter), 
            avg_b/(filter*filter));
          fill( col );
          rect(x, y, filter, filter);
        }
      }
    } 

    video.updatePixels();
  }
}

void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */

  if (theOscMessage.checkAddrPattern("/TSPS/scene")==true) {
    /* check if the typetag is the right one. */
    if (theOscMessage.checkTypetag("iifffii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      filter_index = theOscMessage.get(1).intValue();
      filter = filters[filter_index];
      print("### received an osc message /test with typetag iiffffii.");
      println(" values: "+filter_index);
      return;
    }
  } 
  //println("### received an osc message. with address pattern "+theOscMessage.addrPattern());
}

void keyPressed() {

  // up button, bigger pixelation
  if ( keyCode == 38 ) {
    filter_index++;

    // down button, smaller pixelation
  } else if ( keyCode == 40 ) {
    filter_index--;
  }
  // min filter
  if ( filter_index < 0 ) {
    filter_index = 0;
    // max filter
  } else if ( filter_index > 7 ) {
    filter_index = 7;
  }

  filter = filters[filter_index];

}