AudioMetaData meta;
Button Prev;
Button Rew;
Button Stop;
Button Play;
Button Pause;
Button Fwd;
Button Next;

Button Shuffle;
Button Repeat;
Button RepeatAll;

Button Open;
Button Add;
Button Ext;
ScrollBar Scr;
int selshuf=0;
int selrep=0;
int selrepall=0;

import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import javax.swing.*;
JFileChooser jfc;
Minim minim;
AudioPlayer player;
boolean isRepeat;
int count=0;
int num=0;
int playnum=0;
int sh;
String[] filename=new String[200];
FFT fft;

void setup(){

  isRepeat=false;
filename[0]="Eskimo Callboy - Monsieur Moustache vs. Clitcat.mp3";
  size(512,300,P2D);
  PImage prev=loadImage("prev.png");
  PImage rew=loadImage("rew.png");
  PImage stop=loadImage("stop.png");
  PImage play=loadImage("play.png");
  PImage pause=loadImage("pause.png");
  PImage fwd=loadImage("fwd.png");
  PImage next=loadImage("next.png");
  PImage shuffle=loadImage("shuffle.png");
  PImage repeat=loadImage("repeat.png");
  PImage repeatall=loadImage("repeatall.png");
  PImage open=loadImage("open.png");
  PImage add=loadImage("add.png");
  PImage ext=loadImage("exit.png");
  
   PImage prev1=loadImage("prev1.png");
  PImage rew1=loadImage("rew1.png");
  PImage stop1=loadImage("stop1.png");
  PImage play1=loadImage("play1.png");
  PImage pause1=loadImage("pause1.png");
  PImage fwd1=loadImage("fwd1.png");
  PImage next1=loadImage("next1.png");
  PImage shuffle1=loadImage("shuffle1.png");
  PImage repeat1=loadImage("repeat1.png");
  PImage repeatall1=loadImage("repeatall1.png");
  PImage open1=loadImage("open1.png");
  PImage add1=loadImage("add1.png");
  PImage ext1=loadImage("exit1.png");
  
  PImage scroll=loadImage("scroll.png");
  PImage bar=loadImage("scrollbar.png");
  
 Prev = new Button(0,0,50,50,prev,prev1);
 Rew = new Button(50,0,50,50,rew,rew1);
 Stop = new Button(100,0,50,50,stop,stop1);
 Play = new Button(150,0,50,50,play,play1);
 Pause = new Button(200,0,50,50,pause,pause1);
 Fwd = new Button(250,0,50,50,fwd,fwd1);
 Next = new Button(300,0,50,50,next,next1);
 Shuffle = new Button(0,70,50,50,shuffle,shuffle1);
 Repeat = new Button(50,70,50,50,repeat,repeat1);
 RepeatAll = new Button(100,70,50,50,repeatall,repeatall1);
 Open = new Button(width-50,0,50,50,open,open1);
 Add = new Button(width-50,50,50,50,add,add1);
 Ext = new Button(width-50,100,50,50,ext,ext1);

  

minim = new Minim(this);
player = minim.loadFile(filename[num], 512);
jfc = new JFileChooser();
Scr=new ScrollBar(bar,scroll,0,200,bar.width,bar.height,scroll.width,scroll.height);

  rectMode(CORNERS);
   
}

void draw(){
  fft = new FFT(player.bufferSize(), player.sampleRate());
  fft.linAverages(128);
    meta = player.getMetaData();
    background(255);
    fft.forward(player.mix);
    fill(255);
  int w = int(fft.specSize()/50);
  for(int i = 0; i < fft.avgSize(); i++)
  {
    // draw a rectangle for each average, multiply the value by 5 so we can see it better
    rect(i*w, height, i*w + w, height - fft.getAvg(i)*5);
  }
    float step=player.length()/(Scr.w-56);
    float pos=player.position()/step;
  Scr.display(pos,(int)step);
  Scr.update();
  int ys = 140;
int yi = 15;
  int y = ys;
fill(0, 102, 153);
  textFont(createFont("Serif", 12));
 textMode(SCREEN);
  text("File Name: " + meta.fileName(), 5, y);
  text("Title: " + meta.title(), 5, y+=yi);
  text("Author: " + meta.author(), 5, y+=yi); 
  text("Album: " + meta.album(), 5, y+=yi);

  
  if (Rew.pressed())  player.cue(player.position()-1200);
  if (Fwd.pressed())  player.cue(player.position()+100);
  
   Prev.animate();
  Rew.animate();
  Stop.animate();
  Play.animate();
  Pause.animate();
  Fwd.animate();
  Next.animate();
  Open.animate();
  Add.animate();
  Ext.animate();
 
  Prev.display();
  Rew.display();
  Stop.display();
  Play.display();
  Pause.display();
  Fwd.display();
  Next.display();
  Open.display();
  Add.display();
  Ext.display();
  pressedButtons();
  if(isRepeat==true){
    if(player.position() >= player.length()-256){
      player.cue(0);
    }
  }
  
    
    if(player.position() >= player.length()-256){
      sh=int(random(count+1)); 
      if (selshuf==1) {player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[sh]);
      player.play();
    }
    else{
      num++; 
      if (selrepall==1&&filename[num]==null) {num=0;player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[num]);
      player.play();
    }
     if (selrepall==0&&filename[num]==null) {num=0;player.pause(); player.rewind(); player.close(); playnum=1;
    }
      else {player.pause(); player.rewind(); player = minim.loadFile(filename[num]);
      player.play();
    }
    }
  }
   
}
  
  void mouseReleased(){
     if (Next.selected()){
     sh=int(random(count+1));  if (selshuf==1) {player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[sh]);
      player.play();
    } 
    else{num++; 
       if (selrepall==1&&filename[num]==null) {num=0;player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[num]);
      player.play();
    }
    if (selrepall==0&&filename[num]==null) {num=0;player.pause(); player.rewind();player.close(); playnum=1;
    }
     else{  player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[num]);
      player.play();
    }
    }
     }
    if (Prev.selected()){
     sh=int(random(count+1));  if (selshuf==1) {player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[sh]);
      player.play();
    } 
    else{num--; 
    if (num==-1) {num=0;player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[num]);
      player.play();
    }
       if (selrepall==1&&filename[num]==null) {num=0;player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[num]);
      player.play();
    }
    if (selrepall==0&&filename[num]==null) {num=0;player.pause(); player.rewind();player.close(); playnum=1;
    }
     else{  player.pause(); player.rewind();      player.close(); player = minim.loadFile(filename[num]);
      player.play();
    }
    }
     }
    if (Shuffle.selected())
   switch(selshuf){
     case 0: Shuffle.presbut(); selshuf=1; break;
    case 1: Shuffle.opbut();selshuf=0;break;
  }
   if (Repeat.selected())
   switch(selrep){
     case 0: Repeat.presbut(); selrep=1; break;
    case 1: Repeat.opbut();selrep=0;break;
  }
   if (RepeatAll.selected())
   switch(selrepall){
     case 0: RepeatAll.presbut(); selrepall=1; break;
    case 1: RepeatAll.opbut();selrepall=0;break;
  }
  if (Play.selected()){
     if (playnum==1) {player = minim.loadFile(filename[num]);playnum=0;}
  player.play();}
  if (Pause.selected()) {player.pause(); }
  if (Stop.selected()) {player.pause(); player.rewind(); }
  if (Add.selected()){
          count++;
          println(count);
//  int result = jfc.showOpenDialog(this);
//    if( result == jfc.APPROVE_OPTION){
 filename[count] = selectInput();//jfc.getSelectedFile().getAbsolutePath();
  }
  if (Open.selected()){
    player.pause(); player.rewind();      player.close();
//  int result = jfc.showOpenDialog(this);
//    if( result == jfc.APPROVE_OPTION){
      count=0; num=0;
    filename[count] = selectInput();//jfc.getSelectedFile().getAbsolutePath();

      player = minim.loadFile(filename[count]);
      player.play();
    //}
  }
  if (Ext.selected()) {exit(); }
  }

  void pressedButtons(){
    if (selshuf==1) Shuffle.presbut(); else Shuffle.opbut();
   if (selrep==1) {Repeat.presbut(); isRepeat = true; }else {Repeat.opbut(); isRepeat=false;}
   if (selrepall==1) RepeatAll.presbut(); else RepeatAll.opbut();
  }
