import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class FreireFlies extends PApplet {

//FreireFlies
//MERR 1 Core Project
//by Riley Mann



//Constants
int   SLOT_NUM    = 40;
int   STUDENT_NUM = 9;
int   TIC_LENGTH  = 50;
int   BAUD_RATE   = 9600;

float T_BC = 0.5f;
float T_PP = 0.1f;
float S_BC = 0.0f;
float S_PP = 0.1f;

//GUI
float bar_off = 40;
float slider_x = bar_off;
boolean mouse_pressed = false;

//Freireflies
Freirefly teacherFly = new Freirefly(SLOT_NUM);
Freirefly[] studentFlies = new Freirefly[STUDENT_NUM];

float teacherTau = 0.0f;
float studentTau = 0.0f;

//timer stuff
long previous_millis = 0;
int slot = 0;

//Visual Representation
float r        = 50;
float class_r  = 160;
float theta    = TWO_PI/STUDENT_NUM;
float text_off = 20;

//Serial Stuff
Serial myPort;  // Create object from Serial class
boolean connected = false;

public void setup() {
  
  stroke(255);
  textSize(30);
  noStroke();
  
  serialConnect();
  
  for (int i = 0; i < STUDENT_NUM; i++) {
    studentFlies[i] = new Freirefly(SLOT_NUM);
  }
  resetTime();
}

public void resetTime() {
  previous_millis = millis();
}

public long getTime() {
  return millis() - previous_millis;
}

public void draw() {
  background(0);
  
  if (connected) {
    fill(teacherFly.getSlot(slot));
    ellipse(width/2.0f, height/2.0f, r, r);
    fill(255);
    text(0, width/2.0f + text_off, height/2.0f - text_off);
    for (int i = 0; i < STUDENT_NUM; i++) {
      fill(studentFlies[i].getSlot(slot));
      float x = width/2.0f + class_r*cos(theta*i);
      float y = height/2.0f + class_r*sin(theta*i);
      ellipse(x, y, r, r);
      fill(255);
      text(i+1, x + text_off, y - text_off);
    }
    GUI();
    update();
  } else {
   serialConnect(); 
  }
}

public void freireflyInit() {
  teacherTau = map(slider_x, bar_off, width-bar_off, T_BC, T_PP);
  studentTau = map(slider_x, bar_off, width-bar_off, S_BC, S_PP);
  teacherFly.clearColors();
  teacherFly.addBlink();
  teacherFly.addBlink();
  for (int i = 0; i < STUDENT_NUM; i++) {
    studentFlies[i].clearColors();
    if (slider_x > bar_off) {
      studentFlies[i].addBlink();
    }
  }
  slot = 0;
  resetTime();
}

public void update() {
  if (getTime() > TIC_LENGTH) {
    slot++;
    if (slot >= SLOT_NUM) {
      slot = 0;
      updateColors();
    }
    updateArduino();
    resetTime();
  }
}

public void updateColors() {
  for (int i = 0; i < STUDENT_NUM; i++) {
    studentFlies[i].interact(teacherFly, teacherTau);
    teacherFly.interact(studentFlies[i], studentTau);
  }
  for (int i = 0; i < STUDENT_NUM; i++) {
    for (int j = 0; j < STUDENT_NUM; j++) {
      if (i != j) studentFlies[i].interact(studentFlies[j], studentTau);
    }
  }
}

public void updateArduino() {
  String m = "";
  int c = teacherFly.getSlot(slot);
  m += byteToHex(PApplet.parseByte(c>>16));
  m += byteToHex(PApplet.parseByte(c>>8));
  m += byteToHex(PApplet.parseByte(c));
  
  for (int i = 0; i < STUDENT_NUM; i++) {
    int flyslot = slot;
    if (i < 3) flyslot -= 1;
    else if (i < 5) flyslot -= 2;
    else if (i < 7) flyslot -= 3;
    else flyslot -= 4;
    
    if (flyslot < 0) flyslot += SLOT_NUM;
    c = studentFlies[i].getSlot(flyslot);
    m += ',';
    m += byteToHex(PApplet.parseByte(c>>16));
    m += byteToHex(PApplet.parseByte(c>>8));
    m += byteToHex(PApplet.parseByte(c));
  }
  m += "\r\n";
  myPort.write(m);
  //println("");
}

public void GUI() {
  colorMode(RGB, 255);
  fill(100);
  rect(0, 0, width, 100);
  fill(150);
  rect(bar_off, 60, width-2*bar_off, 10);
  ellipse(bar_off, 65, 10, 10);
  ellipse(width-bar_off, 65, 10, 10);
  fill(200);
  text("Banking vs Problem-Posing", 100, 40);
  fill(50, 150, 50);
  rect(0, height-100, width/2.0f, 100);
  fill(150, 50, 50);
  rect(width/2.0f, height-100, width/2.0f, 100);
  fill(255, 50);
  text("START/RESET", 50, height-40);
  text("STOP", width-190, height-40);
  
  fill(180);
  ellipse(slider_x, 65, 20, 20);
  
  if (mousePressed) {
    if (mouseY < 100) {
      slider_x = mouseX;
      if (slider_x < bar_off) slider_x = bar_off;
      if (slider_x > width-bar_off) slider_x = width-bar_off;
    }
    mouse_pressed = true;
  } else {
    if (mouse_pressed) {
      if (mouseY > height - 100) {
        if (mouseX < width/2.0f) {
          freireflyInit();
        } else {
          teacherFly.clearColors();
          for (int i = 0; i < STUDENT_NUM; i++) {
            studentFlies[i].clearColors();
          }
        }
      }
      mouse_pressed = false;
    }
  }
}

public void serialConnect() {
  fill(150);
  text("Select port:", 30, 40);
  for (int i = 0; i < Serial.list().length; i++) {
    String port = Serial.list()[i];
    text(PApplet.parseChar(i+48) + ": " + port, 50, 50*i + 80);
  }
  if (keyPressed) {
    for (int i = 0; i < Serial.list().length; i++) {
      if (i+48 == PApplet.parseInt(key)) {
        String selected_port = Serial.list()[i];
        myPort = new Serial(this, selected_port, BAUD_RATE);
        connected = true;
        break;
      }
    }
  }
}
public String byteToHex(byte c) {
  String return_string = "";
  int digit_1 = floor(c / 16);
  if (digit_1 > 9) {
    return_string += PApplet.parseChar(digit_1+55);
  } else {
    return_string += PApplet.parseChar(digit_1+48);
  }
  int digit_2 = c % 16;
  if (digit_2 > 9) {
    return_string += PApplet.parseChar(digit_2+55);
  } else {
    return_string += PApplet.parseChar(digit_2+48);
  }
  return return_string;
}

class Freirefly {
  int[] data;
  
  Freirefly(int slots) {
    data = new int[slots];
    clearColors();
  }
  
  public void addBlink() {
    int beg = PApplet.parseInt(random(data.length));
    int end = PApplet.parseInt(random(beg, data.length));
    colorMode(HSB, 255);
    int c = color(random(0, 255), random(150, 255), 255);
    for (int i = beg; i < end; i++) {
      data[i] = c;
    }
  }
  
  public void clearColors() {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0xff000000;
    }
  }
  
  public int getSlot(int i) {
    return data[i];
  }
  
  public void setSlot(int i, int c) {
    data[i] = c;
  }
  
  public void interact(Freirefly other, float tau) {
    for (int i = 0; i < data.length; i++) {
      data[i] = learn(data[i], other.getSlot(i), tau);
    }
  }
  
  public int learn(int c, int other_c, float tau) {
    colorMode(RGB, 1024);
    float r0 = red(c), g0 = green (c), b0 = blue(c);
    float r1 = red(other_c), g1 = green (other_c), b1 = blue(other_c);
    return boostColor(color(r0 + tau*(r1-r0), g0 + tau*(g1-g0), b0 + tau*(b1-b0)), tau);
  }
  
  /*int learn2(int c, int other_c) {
    colorMode(RGB, 1024);
    float r0 = red(c), g0 = green (c), b0 = blue(c);
    float r1 = red(other_c), g1 = green (other_c), b1 = blue(other_c);
    if (r1 > r0) r0 += 32*lern_tau;
    else if (r1 < r0) r0 -= 32*lern_tau;
    if (g1 > g0) g0 += 32*lern_tau;
    else if (g1 < g0) g0 -= 32*lern_tau;
    if (b1 > b0) b0 += 32*lern_tau;
    else if (b1 < b0) b0 -= 32*lern_tau;
    return color(r0, g0, b0);
  }*/
  
  public int boostColor(int c, float tau) {
    float B_boost = 102.4f*tau;
    float B = brightness(c);
    colorMode(HSB, 1024);
    if (B > 1024*tau) {
      B += B_boost;
    }
    //B = pow(B/512.0, 1.1)*512.0;
    //B = 2*(B-512.0) + 512.0;
    if (B > 1024.0f) B = 1024.0f;
    if (B < 0.0f) B = 0.0f;
    return color(hue(c), saturation(c), B);
  }
};
  public void settings() {  size(600, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "FreireFlies" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
