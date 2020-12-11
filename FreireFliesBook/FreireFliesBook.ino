#include <Adafruit_NeoPixel.h>

#define PIN        1
#define NUMPIXELS  10

Adafruit_NeoPixel freireflies(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

String serial_input = "";

void setup() {
  Serial.begin(9600);
  freireflies.begin();
  freireflies.show();
  freireflies.setBrightness(50);
}

void loop() {
  //Serial.println(freireflies.Color(255, 255, 0), HEX);
  while (Serial.available()) {
    char c = Serial.read();
    serial_input += c;
    if (c == '\n') {
      freireflies.clear();
      uint32_t col = 0xFF000000;
      col |= (byte)serial_input[0] << 16;
      col |= (byte)serial_input[1] << 8;
      col |= (byte)serial_input[2];
      freireflies.setPixelColor(0, col);
      serial_input = "";
    }
  }
  freireflies.show();
  delay(10);
}
