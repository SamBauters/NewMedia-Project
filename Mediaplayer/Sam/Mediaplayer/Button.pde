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
      tint(36,92,100);  // Apply transparency without changing color
      image(img, imgX, imgY);
      //tint(255, 255);
      tint(86, 135,177);
    }
    else 
    {
      fill(127,63);
      rect(x,y,w,h);
      fill(255);
    }
  }
  
  boolean over(float lmx, float lmy)
  {
    return (lmx>x && lmx<x+w && lmy>y && lmy<y+h);
  }
  
  void showMouseOver(float lmx)
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
      rect(x,y,lmx,h);
      fill(255);
    }

  }
}
