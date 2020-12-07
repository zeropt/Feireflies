//FreireFlies
//MERR 1 Core Project

int SLOT_NUM = 40;
float STUDENT_TAU = 0.1;
float TEACHER_TAU = 0.1;

Freirefly studentFly = new Freirefly(SLOT_NUM, STUDENT_TAU);
Freirefly teacherFly = new Freirefly(SLOT_NUM, TEACHER_TAU);

//timer stuff
long previous_millis = 0;
int slot = 0;

void setup() {
  size(500, 500);
  noStroke();
  teacherFly.addBlink();
  teacherFly.addBlink();
  studentFly.addBlink();
  resetTime();
}

void resetTime() {
  previous_millis = millis();
}

long getTime() {
  return millis() - previous_millis;
}

void draw() {
  fill(teacherFly.getSlot(slot));
  rect(0, 0, width/2.0, height);
  fill(studentFly.getSlot(slot));
  rect(width/2.0, 0, width, height);
  update();
}

void update() {
  if (getTime() > 50) {
    slot++;
    if (slot >= SLOT_NUM) {
      slot = 0;
      updateColors();
    }
    resetTime();
  }
}

void updateColors() {
  studentFly.interact(teacherFly);
  teacherFly.interact(studentFly);
}
