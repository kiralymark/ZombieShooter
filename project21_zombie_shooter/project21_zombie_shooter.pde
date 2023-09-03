import com.jogamp.newt.opengl.GLWindow;

GLWindow r;

float angV = 0;
float angH = 0;
float x = 0;
float z = 0;
float y = -100.0;

int zombiSzam = 0;
int pontszam;
int oles;

int mp;
float mpszam;
int helimp;

boolean helimove = true;
boolean gameover = false;
boolean win = false;

float heliX;
float heliZ;

int last_reload = -100;
int ammo = 30;



ArrayList<Zombi> zombik = new ArrayList<Zombi>();

float pont_egyenes_tavolsag(PVector cameraQ, PVector cameraE, PVector zombiC) {

  PVector u = cameraE.copy().sub(cameraQ);
  PVector v = zombiC.copy().sub(cameraQ);
  return u.cross(v).mag()/u.mag();
}

void setup() {
  size(1280, 720, P3D); //3D mode
  mpszam = 1.2; // "X" másodpercenként spawnol

  //Capture mouse
  r = (GLWindow)surface.getNative();
  r.confinePointer(true);
  Zombi z = new Zombi();
  z.x = 0;
  z.z = 0;
  zombik.add(z);

  heliX = 2500;
  heliZ = 2500;

  //r.setPointerVisible(false);
}
void draw() {
  mp  = millis()/1000;
  helimp  = 60 - millis()/1000;


  stroke(0);
  background(#90FAFF);
  lights();

  if (keyPressed) {
    if (key == 'r') {
      last_reload= mp;
      ammo = ammo + 30;
      ammo=min(ammo, 30);
    }
  }


  if (mp >mpszam) {

    if (frameCount % 10 == 0) {
      zombik.add(new Zombi());
      zombiSzam = zombiSzam + 1;
      mpszam = mpszam + 1.2;
    }
  }

  if (mp > 60) {   //helicopter incoming
    if (helimove == true) {
      float helitav = sqrt(heliX*heliX+heliZ*heliZ);
      float helinewX = heliX - 3*heliX/helitav; 
      float helinewZ = heliZ - 3*heliZ/helitav;
      heliX = helinewX;
      heliZ = helinewZ;
    }
    if (abs(heliX) <= 35 && abs(heliZ) <= 35) {
      win = true;
      helimove = false;
      if (win == true && y >= -800) {
        y = y - 4;
      }
    }
  }



  if (abs(heliX) <= 35 && abs(heliZ) <= 35) {
    win = true;
  }


  noCursor();

  camera(
    x, y, z, //From
    x + cos(angH) * cos(angV), y +  sin(angV), z + sin(angH) * cos(angV), //At
    0, 1, 0 //Up
    );

  for (Zombi zombi : zombik) {
    zombi.move();
    float xx = zombi.x;
    float zz = zombi.z;
    if (abs(xx) <= 30 && abs(zz) <= 30) {
      gameover = true;
    }
  }
  for (Zombi z : zombik) {
    z.render();
  }

  if (mp > 60) {
    stroke(255);
    pushMatrix(); //'helicopter'
    translate(heliX, -800, heliZ);
    rotateY(0.8);    // rotate
    fill(0);
    box(200, 150, 300);
    popMatrix();
  }


  noStroke();
  pushMatrix(); //plain
  translate(x, +20, z);
  fill(#009102);
  box(5000, 35, 5000);
  popMatrix();

  pushMatrix();  //BOX
  translate(x, 0, z);
  fill(#964100);
  noStroke();
  box(35);
  popMatrix();

  camera();
  hint(DISABLE_DEPTH_TEST);

  /*if(mp % 60 == 0){
   mp = " perc";
   }*/

  noStroke();  //CÉLKERESZT
  fill(15);
  ellipse(640, 360, 1, 1);
  fill(255);
  rect(639, 350, 2, 8);
  rect(630, 359, 8, 2);
  rect(639, 362, 2, 8);
  rect(642, 359, 8, 2);

  pontszam = oles * 10;

  stroke(255);
  fill(0, 29, 255);
  text("Kills: " + oles, 50, 50);
  text("Time passed: " + mp + " sec", 50, 80);

  fill(255);
  textSize(32);
  text(ammo + " / 30", 1000, 650);

  if (helimp>0) {
    fill(0, 29, 255);
    text("Helicopter incoming in: " + helimp + " seconds", 50, 110);
  }

  hint(ENABLE_DEPTH_TEST);

  if (gameover == true) {   //gameover
    clear();
    background(255, 255, 204);
    fill(0);
    textSize(32);
    textAlign(CENTER);
    text("Whoopsie, maybe next time! " + "Time you survived: " + mp + " seconds", width/2, height/3);
    text("Your score: " + pontszam + " points", width/2, height/2);
    //looping = !looping;
    noLoop();
  }

  if (win == true && y <= -800) {
    clear();
    background(255);
    fill(0);
    textSize(32);
    textAlign(CENTER);
    text("Nicely done, good job! You WON!" + "                Your time: " + mp + " sec", width/2, height/3);
    text("Your score: " + pontszam + " points", width/2, height/2);
    //looping = !looping;
    noLoop();
  }
}

//Teleport mouse
void mouseMoved() {

  angH += (mouseX - width/2)/800.0;
  angV += (mouseY - height/2)/800.0;

  if (angV > 1.57) {
    angV = 1.57;
  }

  if (angV < -0.5) {
    angV = -0.5;
  }


  r.warpPointer( width / 2, height / 2);
}

void mousePressed() {
  if (ammo > 0 && mp-last_reload >= 3) {
    PVector cameraQ=new PVector(x, y, z);
    PVector cameraE= new PVector(x + cos(angH) * cos(angV), y +  sin(angV), z + sin(angH) * cos(angV));

    for (int i=zombik.size()-1; i>=0; i--) {

      PVector zombiC=new PVector(zombik.get(i).x, -55, zombik.get(i).z);
      float diff = pont_egyenes_tavolsag(cameraQ, cameraE, zombiC);
      //println(diff);
      if (diff <= 25) {
        zombik.remove(i);
        oles = oles + 1;
        //println(zombik.size());
      }
    }

    ammo = ammo-1;
  }
}
