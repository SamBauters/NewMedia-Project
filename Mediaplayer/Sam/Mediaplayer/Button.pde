class Button
{
  float x; //pos
  float y;
  float w=0; //size
  float h=0;
  
  //color
  PImage img;
  float imgX;
  float imgY; 
  
  color colorStroke;
  int commandNumber;

  Button(float x_, float y_, float w_, float h_, String imgName_, float imgX_, float imgY_, int commandNumber_) 
  { 
    //position
    x=x_;  y=y_;  w=w_; h=h_;
    imgX = imgX_;
    imgY = imgY_;

    //image
    if(imgName_!="")
    {
      img = loadImage(imgName_);
    }
     
    commandNumber=commandNumber_;
  }
  
  void display()
  {
    noStroke();
    if(img!=null)
    {
      tint(255, 63);  // Apply transparency without changing color
      image(img, imgX, imgY);
      tint(255, 255);
    }
    else 
    {
      fill(255,63);
      rect(x,y,w,h);
      fill(255);
    }
  }
  
  boolean over()
  {
    return (mouseX>x && mouseX<x+w&& mouseY>y&&mouseY<y+h);
  }
  
  void showMouseOver()
  {
    if(img!=null)
    {
      tint(255, 63);  // Apply transparency without changing color
      image(img, imgX, imgY);
      tint(255, 255);
    }
    else 
    {
      fill(255,30);
      rect(x,y,mouseX,h);
      fill(255);
    }
    
    if(commandNumber==2)
    {
      fill(255,30);
      rect(0,0,width/5,height-100);
    }
    else if(commandNumber==3)
    {
      fill(255,30);
      rect(width-width/5,0,width/5,height-100);
    }

  }
}