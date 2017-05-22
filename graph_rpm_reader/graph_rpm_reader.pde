/* 
 This was a small project to measure the rpm and stats of fidget spinners. Just input the radius of your fidget spinner below and that's it!
 This processing script reads the input buffer for readings of rpm from the hardware (Arduino). 
 You'll also need to create the hardware for it, there's an arduino file that can be uploaded to your Arduino. */

import processing.serial.*; 

float radius = 3.5; // in cm.


Serial myPort;    // The serial port
PFont myFont;     // The display font
int rpm_int = 0;
int lf = 10;      // ASCII linefeed 
int rpm_limit = 1000;
int rpm_limit_low = 0;
int inc = 10;
// For graphing
float x_coord = 0;
float y_coord = 0;
float thickness = 1;
int rotations = 0;
int max_rpm = 0;
String[] input_data;
float[] data = {};

void setup() { 
  size(960, 540); 
  myPort = new Serial(this, Serial.list()[5], 9600); 
  myPort.bufferUntil(lf);
} 

void draw() { 
  background(0); 
  textSize(14);

  float min_angle = 0;

  // Drawing the needle
  pushMatrix();
  translate(0, height/2);
  rectMode(CORNERS);  
  fill(255);  
  //rect(0, 0, width/2, -height/2); 
  y_coord = map(rpm_int, 0, rpm_limit, 0, height/2);
  noFill();
  stroke(127, 34, 255);     
  strokeWeight(5);        
  //strokeJoin(ROUND);
  beginShape();
  for (int i = 1; i < data.length; i++) {
    //line((i-1)*thickness, data[i-1], i*thickness, data[i]); 
    //rect(i*thickness, 0, x_coord+thickness, -data[i]);
    curveVertex(i*thickness, -data[i]);
  }
  endShape();
  if (data.length*thickness >= width/2.0) {
    float last = data[data.length-1];
    data = new float[1]; 
    data[0] = last;
  }
  popMatrix();

  // Stats
  pushMatrix();
  textSize(40);
  max_rpm = max(max_rpm, rpm_int);
  text("Max RPM: "+str(max_rpm), width/4, height*0.6); 
  text("Rotations: "+str(rotations), width/4, height*0.7); 
  textSize(20);
  text("Frequency (Hz): "+nf(rpm_int*0.0167, 0, 2), width/4, height*0.8); 
  text("Linear speed (km/h): "+nf(rpm_int*2*PI*radius*60/100/1000, 0, 2), width/4, height*0.85); 
  text("Linear speed (mph): "+nf(rpm_int*2*PI*radius*60/100/1000/1.60934, 0, 2), width/4, height*0.9); 
  textSize(20);
  rectMode(CORNERS); 
  fill(0);
  rect(width/2-80, height*0.95-20, width/2+80, height*0.95+20); 
  fill(255);
  text("iBuyNewStuff", width/2, height*0.945); 
  popMatrix();

  // Markers
  rpm_limit = ceil(max_rpm/1000.0)*1000;
  if (rpm_limit == 0) {
    rpm_limit = 500;
  }
  for (int rpm=0; rpm <= rpm_limit; rpm+=(rpm_limit-rpm_limit_low)/inc) { 
    float angle = map(rpm, rpm_limit_low, rpm_limit, -180, 90);
    min_angle = min(min_angle, angle);
    pushMatrix();
    translate(width*0.75, height/2);
    rotate(radians(angle));
    strokeWeight(4.0);
    // Line markers
    line(0, -height*0.30, 0, -height*0.35);
    // RPM markers
    rectMode(CENTER);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(str(rpm), 0, -height*0.38); 
    popMatrix();
  }

  // Drawing the dial
  pushMatrix();
  float angle = map(rpm_int, rpm_limit_low, rpm_limit, -180, 90);
  translate(width*0.75, height/2);
  fill(255);
  //arc(0, 0, height*0.7, height*0.7, -PI, TWO_PI);
  noFill();
  stroke(#EC0909);
  strokeWeight(15);
  strokeCap(SQUARE);
  arc(0, 0, height*0.86, height*0.86, radians(min_angle-90), radians(angle-90));
  // Speedometer
  stroke(167);
  strokeWeight(0);
  // Drawing the main RPM
  textSize(100);
  fill(127, 34, 255);
  text(rpm_int, 0, 0);
  textSize(20);
  text("RPM", 0, 70);
  popMatrix();
} 

// Pressing the mouse on the button resets the stats.
void mousePressed() {
  if  (mouseX >= width/2-80 && mouseX <= width/2+80 && mouseY >= height*0.95-20 && mouseY <= height*0.95+20) {
    rotations = 0;
    max_rpm = 0;
    rpm_int = 0;
    data = new float[1];
  }
}

void serialEvent(Serial p) { 
  input_data = split(p.readString().trim(), ',');
  rpm_int = int(input_data[0]);
  rotations += int(input_data[1]);
  data = append(data, y_coord);
} 