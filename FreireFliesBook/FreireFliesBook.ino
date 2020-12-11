#include <Adafruit_NeoPixel.h>

#define PIN        1
#define NUMPIXELS  10

Adafruit_NeoPixel freireflies(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

String serial_input = "";

void setup() {
  Serial.begin(115200);
  freireflies.begin();
  freireflies.show();
  freireflies.setBrightness(50);
}

void loop() {
  //Serial.println(freireflies.Color(255, 255, 0), HEX);
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n') {
      freireflies.clear();
      setLEDs(serial_input);
      serial_input = "";
    } else {
      serial_input += c;
    }
  }
  freireflies.show();
  delay(10);
}

void setLEDs(String data) {
  int pixel = 0;
  
  for (int i = 0; i < data.length(); i += 3) {
    uint32_t col = 0xFF000000;
    col |= (byte)serial_input[i] << 16;
    col |= (byte)serial_input[i+1] << 8;
    col |= (byte)serial_input[i+2];
    if (pixel < NUMPIXELS) freireflies.setPixelColor(pixel, col);
    pixel++;
  }
}
