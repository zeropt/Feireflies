#include <Adafruit_NeoPixel.h>

#define PIN        1
#define NUMPIXELS  7

Adafruit_NeoPixel freireflies(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  Serial.begin(9600);
  freireflies.begin();
}

void loop() {
  //Serial.println(freireflies.Color(255, 255, 0), HEX);
}

void serialEvent() {
  while (Serial.available()) {
    int x = Serial.parseInt();
    freireflies.show();
  }
}
