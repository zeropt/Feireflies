
class Freirefly {
  int[] data;
  float lern_tau;
  
  Freirefly(int slots, float tau) {
    data = new int[slots];
    lern_tau = tau;
  }
  
  void addBlink() {
    int beg = int(random(data.length));
    int end = int(random(beg, data.length));
    colorMode(HSB, 255);
    int c = color(random(0, 255), random(0, 255), 255);
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
  
  void interact(Freirefly other) {
    for (int i = 0; i < data.length; i++) {
      data[i] = learn(data[i], other.getSlot(i));
    }
  }
  
  int learn(int c, int other_c) {
    colorMode(RGB, 1024);
    float r0 = red(c), g0 = green (c), b0 = blue(c);
    float r1 = red(other_c), g1 = green (other_c), b1 = blue(other_c);
    return color(r0 + lern_tau*(r1-r0), g0 + lern_tau*(g1-g0), b0 + lern_tau*(b1-b0));
  }
  
  int learn2(int c, int other_c) {
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
  }
};
