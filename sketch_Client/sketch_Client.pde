import ddf.minim.*;
import processing.net.*;
AudioPlayer player, player2;
Minim minim;//audio context


PShape marioObj;//mario obj
PImage me;
PShader basicShader;
boolean  gameOver, rotation =false;
float initX, initY, initZ;
float actX, actY, speedZ;
float nY;//rotation angle
int marioFallDownValueY = 0;
Fireball [] fireball = new Fireball[100000];
int count = 0;
boolean lock = false;

//L for Left, R for right, U for Up,
//D for Down, Z for Z-axis, B for back
float startL, startR, startU, startD, startZ, startB, startF = 0, now;
Server s;
Client c;
String input; 
float foreignX, foreignY, foreignZ;
int spacePos;
String []temp;
int hp = 100;

public void setup() {
  size(720, 800, P3D);
  basicShader = loadShader("basicfrag.glsl", "basicvert.glsl");
  actX = width / 2 ;
  initX = 0;
  initY = height - height / 5;
  initZ = 30;
  print("loading...");
  marioObj = loadShape("mario_obj.obj");
  me = loadImage("me.jpg");
  print(marioObj.width);

  c = new Client(this, "127.0.0.1", 12345);
  minim = new Minim(this);
  player = minim.loadFile("powerup.mp3", 256);
  player2 = minim.loadFile("blast.wav", 256);
  print("loading done");
}

public void draw() {

  textSize(100); 
  background(100);
  String out = "";
  if (c.available() > 0) {
    input = c.readString();
    //println(input);
    try {
      //if (input.length() > 0) {
      //input = input.substring(0, input.indexOf("\n"));
      spacePos = input.indexOf("\n");
      temp = input.substring(0, spacePos).split(" ");
      //}
    } 
    catch (Exception e) {
    }
  }

  beginCamera();
  //camera(actX + 200, initY - 400, -400, width/2.0 - 2400, height/2.0 + 1300, -900, 0, 1, 0);
  //camera( width/2.0 - 2400, height/2.0 + 1300, -900, initX + 200, initY - 400, -400, 0, 1, 0);
  camera(actX - 200, initY + actY + marioFallDownValueY - 100, initZ +speedZ + 600, width/2.0, height/2.0 + 1300, -90000, 0, 1, 0);
  rotateY(+PI * 180);//( - width /2) / width);
  //println(mouseX);
  //rotateY(+PI * (width - width /2) / width);
  endCamera();

  pushMatrix();
  /*float cameraY = height/2.0;
   float fov = mouseX/float(width) * PI;
   float cameraZ = cameraY / tan(fov / 2.0);
   float aspect = float(width)/float(height);
   //rotateY(radians(180));
   perspective(fov, aspect, cameraZ/10.0, cameraZ*10.0);*/
  popMatrix();


  boolean stayInBound = false;
  for (int i = 0; i < 20; i++) {
    for (int x = 0; x < 20; x++) {
      pushMatrix();
      //translate(initX, initY, initZ); 
      //translate(initX+ 50 * i, initY+ 25 + i * 0, initZ+-75); 
      translate(initX+ -75 + 100 * x, initY+ 25, initZ -  100 * i); 
      //reason for -75 is the width of mario for checking the falldown....
      box(100, 50, 100);
      shader(basicShader); 
      popMatrix();
      if ((actX >= initX + x * 100 - 50 
        && ((actX+25) <= (initX + 100 * x + 75))//is it around on a particular grid?
      ) && (initY + actY <= initY ))//on top of it?
      {//by doing grid by grid
        stayInBound = true;
      }

      //println( (initZ) + " " +(initZ + speedZ) + " " + (initZ - i * 50 - 50));
      //println((initY + actY ) + " " +( initY  + i * 1));
    }
  }

  pushMatrix();
  translate(initX+ -75 + 100 * 9, initY -50, initZ -  100 * 9); 
  //reason for -75 is the width of mario for checking the falldown....
  box(300, 100, 100);
  shader(basicShader); 
  popMatrix();

  if ((abs(initZ + speedZ) > abs(initZ - 20 * 100 - 50)) ||  ((initZ + speedZ - 25) > (initZ))) {
    stayInBound = false;
  }

  if (gameOver == false) {
    now = millis();
    if (startU > 0 && now - startU < 2 * 1000) {
      actY = -int(160 * sin(radians(180 * (now - startU) / (2 * 1000))));
      //println(actY);
    }
    if (startR > 0 && now - startR < 1 * 1000) {
      actX -= -10;//int(20 * sin(radians(90 * (0.5 +(now - startR) / (1 * 1000)))));
    }
    if (startL > 0 && now - startL < 1 * 1000) {
      actX += -10;//int(20 * sin(radians(90 * (0.5 +(now - startL) / (1 * 1000)))));
    }
    if (startZ > 0 && now - startZ < 1 * 1000) {
      //initZ += 1;//-int(10 * sin(radians(90 * (0.5 +(now - startZ) / (1 * 1000)))));
      speedZ +=  -10;//int(20 * sin(radians(90 * (0.5 +(now - startZ) / (1 * 1000)))));
    }    
    if (startB > 0 && now - startB < 1 * 1000) {
      //initZ -= 1;//-int(10 * sin(radians(90 * (0.5 +(now - startZ) / (1 * 1000)))));
      speedZ +=  10;//int(20 * sin(radians(90 * (0.5 +(now - startB) / (1 * 1000)))));
    }
    if (stayInBound == false && startD > 0 && now - startD < 2 * 1000 && now - startU > 2 * 1000 ) {
      marioFallDownValueY = 10;//+int(3 * tan(radians(90 * ((now - startD) / (2 * 1000)))));
      actY = actY + marioFallDownValueY;
      //actY = -int(160 * sin(radians(90 * (0.5 +(now - startR) / (1 * 1000)))));

      if (initY + actY >= 1000) {
        gameOver = true;
        marioFallDownValueY = 0;
        startOver();
      }
    }

    out = 1 + " " + actX+" "+(initY + actY) + " " + (initZ + speedZ) + "\n";

    lights();
    pushMatrix();
    translate(actX, initY + actY, initZ + speedZ + 50);  
  
    text("HP : " + hp, 0 - actX, 0 - (initY + actY), -2000);
    if(hp >= 0){
      gameOver = false;
    }
    rotateX(radians(180));
    if (rotation) {
      nY += 0.01;
    }
    rotateY(nY);
    //rotateY(radians(90));
    shape(marioObj);
    //translate(-75, +50, fbCount);
    //fbCount+=10;
    //println(fbCount);
    //sphere(50);
    popMatrix();

    if (temp != null) {
      pushMatrix();
      try {
        if (abs(parseInt(temp[1])) >= 0 && abs(parseInt(temp[2])) >= 0&& abs(parseInt(temp[3])) >= 0) {
          foreignX = parseInt(temp[1]);
          foreignY = parseInt(temp[2]);
          foreignZ = parseInt(temp[3]);
        }
      } 
      catch (Exception e) {
      } 
      finally {
        translate(foreignX - 130, foreignY, initZ -  100 * 20 + -(foreignZ) + 50);  
        rotateX(radians(180));
        rotateY(radians(180));
        shape(marioObj);
        popMatrix();
      }
    }

    while (input != null && spacePos != -1 && input.indexOf ("\n", spacePos + 1) != -1) {
      int former = spacePos;
      spacePos = input.indexOf ("\n", spacePos + 1);
      //println("H " + spacePos + " " + input.substring(former, spacePos));
      try {
        String [] tArray = input.substring(former + 1, spacePos).split(" ");
        if (parseInt(tArray[0]) == 2) {
          //println("found");
          pushMatrix();
          translate(parseInt(tArray[1]), parseInt(tArray[2]), initZ -  100 * 20 + -parseInt(tArray[3]) + 200);
          translate(-50, -100, - 100);
          sphere(50);
          shader(basicShader); 
          popMatrix();

          if (Math.abs(parseInt(tArray[1]) + 25 - actX) <= 50 && Math.abs(parseInt(tArray[2]) - (initY + actY)) <= 80 && Math.abs((initZ -  100 * 20 + -parseInt(tArray[3]) + 200) - (initZ + speedZ + 50)) <= 50 ) {
            hp -= 5;
            println("hello");
            player2.rewind();
            player2.play();
          }
        }
        //println(parseInt(tArray[0]) );
      } 
      catch (Exception e) {
      }
      //spacePos = input.indexOf ("\n", spacePos + 1);
      //println("H " + spacePos);/*/*
      //parseInt(temp[1])) >= 0 && abs(parseInt(temp[2])) >= 0&& abs(parseInt(temp[3]))
      /*temp = (input.substring(former, next)).split(" ");
       println("!" + temp[1]);
       pushMatrix();
       //println("fb" +fireball[fbCount].x + " "+ fireball[fbCount].y + " "+ fireball[fbCount].w);
       //translate(fireball[fbCount].x, fireball[fbCount].y, fireball[fbCount].w);
       translate(-50, -100, - 100);
       sphere(50);
       shader(basicShader); 
       popMatrix();*/
    }


    int fbCount = 0;
    while (fbCount < count) {
      if (fireball[fbCount].hit ==false && abs(fireball[fbCount].w )< 2500) {
        pushMatrix();
        //println("fb" +fireball[fbCount].x + " "+ fireball[fbCount].y + " "+ fireball[fbCount].w);
        translate(fireball[fbCount].x, fireball[fbCount].y, fireball[fbCount].w);
        out += 2 + " " + fireball[fbCount].x +" "+ fireball[fbCount].y + " " +  fireball[fbCount].w + "\n";
        translate(-50, -100, - 100);
        sphere(50);
        shader(basicShader); 
        fireball[fbCount].w -= 50;
        popMatrix();
      }
      //translate(initX+ -75 + 100 * 9, initY -50, initZ -  100 * 9); 
      // println(initX+ -75 + 100 * 9 + " " + (fireball[fbCount].x - 50));
      if ((fireball[fbCount].x - 125 > initX+ -75 + 100 * 9 - 300 &&  fireball[fbCount].x + 75 < initX+ -75 + 100 * 9 + 300) && (fireball[fbCount].y - 50 > initY -50 ) &&
        ((initZ -  100 * 9 > fireball[fbCount].w  ) && (fireball[fbCount].w  > initZ -  100 * 10) && fireball[fbCount].hit == false)) {//&& fireball[fbCount].w - 50 <= initZ -  100 * 10){
        fireball[fbCount].hit = true;
        player2.rewind();
        player2.play();
        //println(fbCount + "hit1" + (fireball[fbCount].w - 50)+ (initZ -  100 * 9) + (initZ -  100 * 10));
        //println(fireball[fbCount].w - 50 + " " + (initZ -  100 * 9));
      }
      if (fireball[fbCount].w  <= initZ -  100 * 10) {
        //println(fbCount + "hit2");
        //println(fireball[fbCount].w - 50 + " " + (initZ -  100 * 10));
      }
      fbCount += 1;
    }

    if (stayInBound == false && now - startD > 2 * 1000) {
      //println(false);
      startD = millis();
    }

    if (keyPressed) {
      if (keyCode == RIGHT) {
        if (startR == 0 || now - startR > 1 * 1000) {
          startR = millis();
        }
      } 
      else if (keyCode == LEFT) {
        if (startL == 0 || now - startL > 1 * 1000) {
          startL = millis();
        }
      } 
      else if (key == ' ' ) {
        //actY = actY - 20;
        if (startU == 0 || now - startU > 2 * 1000) {
          startU = millis();
          stayInBound = true;
        }
      } 
      else if (keyCode == UP) {
        if (startZ == 0 || now - startZ > 2 * 1000) {
          startZ = millis();
        }
      } 
      else if (keyCode == DOWN) {
        if (startB == 0 || now - startB > 2 * 1000) {
          startB = millis();
          //println('f');
        }
      } 
      else if (keyCode == 'f') {
        out += ("f\n");
      }
    }
  } else {
    
    pushMatrix();
    translate(actX, initY + actY, initZ + speedZ + 50);  
  
    text("GameOver" , 0 - actX, 0 - (initY + actY), -2000);
    if(hp >= 0){
      gameOver = true;
    }
    rotateX(radians(180));
    if (rotation) {
      nY += 0.01;
    }
    rotateY(nY);
    //rotateY(radians(90));
    shape(marioObj);
    //translate(-75, +50, fbCount);
    //fbCount+=10;
    //println(fbCount);
    //sphere(50);
    popMatrix();
  }
  c.write(out);
}

void keyPressed() {
  if (key == 'r') {
    startOver();
  } 
  if (key =='t') {
    if (rotation)
      rotation = false;
    else
      rotation = true;
  }

  if (key == 'f') {
    //println('f');
    if (millis() - startF > 0.2 * 1000) {
      player.rewind();
      player.play();
      fireball[count] = new Fireball(actX - 50, initY + actY + marioFallDownValueY + 50, initZ + speedZ);
      count++;
      startF = millis();
    }
  }
}

void startOver() {
  gameOver = false;
  initX = 0;
  initZ = 0;
  actX = width / 2 ;
  actY = 0;
  initY = height - height / 5;
  startR = 0;
  startL = 0;
  startU = 0;
  startD = 0;
  speedZ = 0;
  startB = 0;
  hp = 100;
}

void stop() {
  s.stop();
  c.stop();
}

