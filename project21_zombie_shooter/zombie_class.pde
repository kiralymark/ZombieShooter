class Zombi {
  float x, z;

  Zombi() {
    float r = random(360, 1000);
    float p = random(0, TWO_PI);
    x = r * sin(p);
    z = r * cos(p);
  }

  void move(){
    float tav = sqrt(x*x+z*z);
    float newX = x - 2*x/tav; 
    float newZ = z - 2*z/tav;
    x = newX;
    z = newZ;
  }   
  void render() {     //"void display"

    pushMatrix();
    noStroke();
    translate(x, -55, z);
    fill(0, 255, 100);
    sphere(25);
    popMatrix();
  }
}
