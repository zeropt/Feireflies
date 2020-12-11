//FreireFlies
//MERR 1 Core Project
//by Riley Mann

import processing.serial.*;

//Constants
int   SLOT_NUM    = 40;
int   STUDENT_NUM = 9;
int   TIC_LENGTH  = 50;
int   BAUD_RATE   = 115200;

float T_BC = 0.5;
float T_PP = 0.1;
float S_BC = 0.0;
float S_PP = 0.1;

//GUI
float bar_off = 40;
float slider_x = bar_off;
boolean mouse_pressed = false;

//Freireflies
Freirefly teacherFly = new Freirefly(SLOT_NUM);
Freirefly[] studentFlies = new Freirefly[STUDENT_NUM];

float teacherTau = 0.0;
float studentTau = 0.0;

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

void setup() {
  size(600, 600);
  stroke(255);
  textSize(30);
  noStroke();
  
  serialConnect();
  
  for (int i = 0; i < STUDENT_NUM; i++) {
    studentFlies[i] = new Freirefly(SLOT_NUM);
  }
  resetTime();
}

void resetTime() {
  previous_millis = millis();
}

long getTime() {
  return millis() - previous_millis;
}

void draw() {
  background(0);
  
  if (connected) {
    fill(teacherFly.getSlot(slot));
    ellipse(width/2.0, height/2.0, r, r);
    fill(255);
    text(0, width/2.0 + text_off, height/2.0 - text_off);
    for (int i = 0; i < STUDENT_NUM; i++) {
      fill(studentFlies[i].getSlot(slot));
      float x = width/2.0 + class_r*cos(theta*i);
      float y = height/2.0 + class_r*sin(theta*i);
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

void freireflyInit() {
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

void update() {
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

void updateColors() {
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

void updateArduino() {
  int c = teacherFly.getSlot(slot);
  myPort.write(byte(c>>16));
  myPort.write(byte(c>>8));
  myPort.write(byte(c));
  
  for (int i = 0; i < STUDENT_NUM; i++) {
    c = studentFlies[i].getSlot(slot);
    myPort.write(byte(c>>16));
    myPort.write(byte(c>>8));
    myPort.write(byte(c));
  }
  myPort.write('\n');
  //for (int i = 0; i < STUDENT_NUM; i++) {
}

void GUI() {
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
  rect(0, height-100, width/2.0, 100);
  fill(150, 50, 50);
  rect(width/2.0, height-100, width/2.0, 100);
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
        if (mouseX < width/2.0) {
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

void serialConnect() {
  fill(150);
  text("Select port:", 30, 40);
  for (int i = 0; i < Serial.list().length; i++) {
    String port = Serial.list()[i];
    text(char(i+48) + ": " + port, 50, 50*i + 80);
  }
  if (keyPressed) {
    for (int i = 0; i < Serial.list().length; i++) {
      if (i+48 == int(key)) {
        String selected_port = Serial.list()[i];
        myPort = new Serial(this, selected_port, BAUD_RATE);
        connected = true;
        break;
      }
    }
  }
}
