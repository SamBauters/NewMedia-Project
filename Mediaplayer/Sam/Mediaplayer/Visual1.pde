import ddf.minim.*;
import ddf.minim.analysis.*;

class Visual1
{

BeatDetect beat;
AudioPlayer player;
int  r = 200;
float rad = 70;

Visual1(AudioPlayer oPlayer)
{
    player = oPlayer;
    beat = new BeatDetect();
}

void display()
{ 

  float t = map(mouseX, 0, width, 0, 1);
  beat.detect(player.mix);
  //fill(#1A1F18, 20);
  noStroke();
  rect(0, 0, width, height);
  translate(width/2, height/2);
  noFill();
  //fill(#000000, 80);
  if (beat.isOnset()) rad = rad*0.9;
  else rad = 70;
  //ellipse(0, 0, 2*rad, 2*rad);
  stroke(#000000, 90);
  int bsize = player.bufferSize();
  for (int i = 0; i < bsize - 1; i+=5)
  {
    float x = (r)*cos(i*2*PI/bsize);
    float y = (r)*sin(i*2*PI/bsize);
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    line(x, y, x2, y2);
  }
  beginShape();
  noFill();
  stroke(#000000, 50);
  for (int i = 0; i < bsize; i+=30)
  {
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    vertex(x2, y2);
    pushStyle();
    stroke(#000000);
    strokeWeight(2);
    point(x2, y2);
    popStyle();
  }
  endShape();
  return;
}
}
