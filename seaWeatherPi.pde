/**
 * Loading Images. 
 * 
 * Processing applications can load images from the network. 
 * 
 */

import processing.io.*;
import java.util.Timer;
import java.util.TimerTask;
import com.jogamp.newt.opengl.GLWindow;
import java.awt.image.*;
import javax.imageio.*;
import javax.imageio.stream.*;
import java.io.*;
import java.net.*;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.time.ZoneOffset;


int screenCounter = 0;
float scrollCount = -800;
float frameCount = 0;
//PImage img;
PImage loadingImg;
PImage sea;
PImage sea1;
PImage sea2;
PImage seaAll;
//Gif radar = null;
int frames = 15;
PImage[] rad = new PImage[frames];
boolean loading = true;
long updatetime = 0;
long blanktime = 0;
long screentime = 0;
boolean blank = false;
boolean doBlanking = true;
float pulse = 0;
int pulseVal = 0;
float percent = 0;

void setup() {
  
  fullScreen(P2D);
//  size(800,480,P3D);
//  size(320,240,P3D);
  GLWindow r = (GLWindow)surface.getNative();
  r.setPointerVisible(false);
  smooth();

  loadingImg = loadImage("logo-yr.png");
  
  thread("update");
  newScreen();
}

void update()
{
  print("Updating");
  
  loading = true;
  percent = 0;
  
  try{
    
    sea = loadImage("https://www.yr.no/sted/Hav/63,45790_8,67830/marinogram.png");
    sea1 = sea.get(5,42,774,152);
    sea2 = sea.get(5,274,774,338);//817
    seaAll = new PImage(sea1.width,sea1.height+sea2.height);
    seaAll.set(0,0,sea1);
    seaAll.set(0,sea1.height+1,sea2);
    System.gc();
    
    
    for(int i=0;i<frames;i++)
    {
      percent = ((float)i/(float)frames);
      
      int minutes = Integer.parseInt(DateTimeFormatter.ofPattern("mm").withZone(ZoneOffset.UTC).format(Instant.now().minusSeconds(300*i+600)).toString());
      String date = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:'00'X").withZone(ZoneOffset.UTC).format(Instant.now().minusSeconds(300*i+600+(minutes%5)*60)).toString();
  
      println(date);
      rad[i] = loadImage("https://api.met.no/weatherapi/radar/2.0/?area=central_norway&content=image&time="+date+"&type=5level_reflectivity","png");
      
    }
  
  }catch(Exception e)
  {}
  
  frameCount = rad.length-1;
  loading = false;
  println("updating images "+rad.length);
  updatetime = millis();

}

void newScreen()
{
//  loading = true;
  screenCounter++;
  if(screenCounter>1) screenCounter=0;
  screentime = millis();
//  loading = false;
}

void draw() {
  background(0);
  
  if(blanktime > millis()) blanktime = millis(); //rollover?
  if(millis() - blanktime > 1000*60*10)
  {
    //blank screen?
    if(doBlanking) blank = true;
    else thread("update");
  }
  if(screentime > millis()) screentime = millis(); //rollover?
  if(millis() - screentime > 1000*15)
  {
    newScreen();
  }
  if( !loading && !blank)
  {
    if(screenCounter == 0)
    {  
      if(scrollCount < height && scrollCount >= 0) scrollCount = scrollCount+20;
      else scrollCount = -height;
    }
    if(rad.length>0)
    {  
      if(rad[(int)frameCount] != null) 
        image(rad[(int)frameCount], 0, 0,width,height);
      frameCount -= 0.1;
      if((int)frameCount<=0) frameCount = rad.length-0.1;
    }
    if(sea != null)
    {  
      /*/top
      float scale = ((float)width/(float)sea1.width);
      float newHeight = scale*sea1.height;
      image(sea1, 0, 0+scrollCount,width,newHeight);//274
      //bottom
      float scale2 = ((float)width/(float)sea2.width);
      float newHeight2 = scale2*sea2.height;
      image(sea2, 0, newHeight+scrollCount,width,newHeight2);//274
      */
      
      image(seaAll, 0, 0+scrollCount,width,height);
      
      if(scrollCount < 0) scrollCount = scrollCount+20;
    }
  }
  if(loading)
  {
    noStroke();
    if(pulse >= 2*Math.PI) pulse = 0;
    if(millis()%5 == 0) pulse+=0.1;
    pulseVal = (int)(255*(Math.sin(pulse-(Math.PI/2.0))/2.0+0.5));
    
    fill(0,185,241);
    arc(width/2, height/2+(loadingImg.height/2)+50, loadingImg.width, loadingImg.width, -radians(90), percent*2f*3.1415f-radians(90));
    fill(0,0,0);
    circle(width/2, height/2+(loadingImg.height/2)+50, loadingImg.width-15);
    fill(0,185,241,pulseVal);
    circle(width/2,height/2-(loadingImg.height/2)-20,loadingImg.width+10);
    image(loadingImg,width/2-(loadingImg.width/2),height/2-(loadingImg.height)-20);
    

    fill(255,255,255);
    textAlign(CENTER, TOP);
    textSize(32);
    text("Loading", width/2, height/2);
    
    
  }
  /*fill(255);
  rect(width-30,0,30,30);
  fill(0);
  textSize(32);
  text("X",width-28,28);*/
}

void mousePressed() {
  if(mouseX<50 && mouseY<50)
    exit(); 
  else
  {
    if(updatetime > millis()) updatetime = millis(); //rollover?
    if(millis() - updatetime > 1000*60*10)
    {
      thread("update");
    }
    blanktime = millis();
    print("mousePressed");
    blank = false;
    //loading = true;
    scrollCount = -height;
    screenCounter++;
    if(screenCounter>1) screenCounter=0;
    //loading = false;
    screentime = millis();
    frameCount = rad.length-1;
  }
}
