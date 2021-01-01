#include <Adafruit_NeoPixel.h>

#define PIN        1
#define NUMPIXELS  10

Adafruit_NeoPixel freireflies(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);

String serial_input = "";

//smoothing
float smoothing_tau = 0.1;
uint32_t target_colors[NUMPIXELS];

void setup() {
  Serial.begin(9600);
  freireflies.begin();
  freireflies.show();
  freireflies.setBrightness(200);
}

void loop() {
  //Serial.println(freireflies.Color(255, 255, 0), HEX);
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n') {
      clearPixels();
      setLEDs(serial_input);
      serial_input = "";
    } else {
      serial_input += c;
    }
  }
  updatePixels();
  delay(10);
}

void updatePixels() {
  for (int i = 0; i < NUMPIXELS; i++) {
    uint32_t fly_color = freireflies.getPixelColor(i);
    uint8_t fly_r = 0x000000FF & fly_color>>16;
    uint8_t fly_g = 0x000000FF & fly_color>>8;
    uint8_t fly_b = 0x000000FF & fly_color;
    uint8_t target_r = 0x000000FF & target_colors[i]>>16;
    uint8_t target_g = 0x000000FF & target_colors[i]>>8;
    uint8_t target_b = 0x000000FF & target_colors[i];

    int r = (uint8_t)constrain(fly_r + int(float(target_r - fly_r)*smoothing_tau), 0, 255);
    int g = (uint8_t)constrain(fly_g + int(float(target_g - fly_g)*smoothing_tau), 0, 255);
    int b = (uint8_t)constrain(fly_b + int(float(target_b - fly_b)*smoothing_tau), 0, 255);
    freireflies.setPixelColor(i, freireflies.Color(r, g, b));
  }
  freireflies.show();
}

void setLEDs(String data) {
  int pixel_i = 0;
  
  for (int i = 0; i < data.length(); i++) {
    /*uint32_t col = 0xFF000000;
    col |= (byte)serial_input[i+1] << 16;
    col |= (byte)serial_input[i+2] << 8;
    col |= (byte)serial_input[i+3];
    target_colors[(byte)serial_input[i]] = col;*/
    
    char c = data[i];
    
    if (c == ',' || c == '\r') {
      String r = data.substring(i-6, i-4);
      String g = data.substring(i-4, i-2);
      String b = data.substring(i-2, i);
      if (pixel_i < NUMPIXELS) {
        target_colors[pixel_i] = freireflies.Color(hexToInt(r), hexToInt(g), hexToInt(b));
      }
      pixel_i++;
    }
  }
}

void clearPixels() {
  for (int i = 0; i < NUMPIXELS; i++) {
    target_colors[i] = 0xFF000000;
  }
}

int hexToInt(String hex_data) {
  int returnVal = 0;
  for (int i = 0; i < hex_data.length(); i++) {
    byte b = byte(hex_data[(hex_data.length()-1) - i]);
    if (b >= 48 && b <= 57) { //0-9
      returnVal += (b-48)*pow(16,i);
    } else if (b >= 65 && b <= 70) { //A-F
      returnVal += (b-55)*pow(16,i);
    } else if (b >= 97 && b <= 102) { //a-f
      returnVal += (b-87)*pow(16,i);
    } else {
      returnVal = 0; //default to 0
      break;
    }
  }
  return returnVal;
}
