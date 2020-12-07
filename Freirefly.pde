
class Freirefly {
  int[] data;
  
  Freirefly(int slots) {
    data = new int[slots];
  }
  
  void addBlink() {
    int beg = int(random(data.length));
    int end = int(random(beg, data.length));
    colorMode(HSB, 255);
    int c = color(random(0, 255), random(150, 255), 255);
    for (int i = beg; i < end; i++) {
      data[i] = c;
    }
  }
  
  void clearColors() {
    for (int i = 0; i < data.length; i++) {
      data[i] = #000000;
    }
  }
  
  int getSlot(int i) {
    return data[i];
  }
  
  void setSlot(int i, int c) {
    data[i] = c;
  }
  
  void interact(Freirefly other, float tau) {
    for (int i = 0; i < data.length; i++) {
      data[i] = learn(data[i], other.getSlot(i), tau);
    }
  }
  
  int learn(int c, int other_c, float tau) {
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
  
  int boostColor(int c, float tau) {
    float B_boost = 102.4*tau;
    float B = brightness(c);
    colorMode(HSB, 1024);
    if (B > 1024*tau) {
      B += B_boost;
    }
    //B = pow(B/512.0, 1.1)*512.0;
    //B = 2*(B-512.0) + 512.0;
    if (B > 1024.0) B = 1024.0;
    if (B < 0.0) B = 0.0;
    return color(hue(c), 1024, B);
  }
};
