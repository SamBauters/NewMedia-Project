class Button
  {
    float x; //pos
    float y;
    float w=0; //size
    float h=0;
    
    //color
    boolean hasColorFill = true; //if it has filling
    color colorFill; //what it is
  
  boolean hasColorStroke=true; //if it has an outline
  color colorStroke;
  String text ="";
  String textMouseOver="";
  int commandNumber;

  Button(float x_, float y_, float w_, float h_, boolean hasColorFill_, color cFill_, boolean hasColorStroke_, color cStroke_, String text_, String textMouseOver_, int commandNumber_) { x=x_;  y=y_;  w=w_; h=h_;
  //color fill
   hasColorFill=hasColorFill_;
   colorFill=cFill_;
   //color stroke
   hasColorStroke = hasColorStroke_;
   colorStroke = cStroke_;
   
   text=text_;
   textMouseOver=textMouseOver_;
   commandNumber=commandNumber_;
  }
  
  void display()
  {
    if(hasColorFill)
      fill(colorFill);
    else
      noFill();
    if(hasColorStroke)
      stroke(colorStroke);
    else
      noStroke();
      rect(x,y,w,h);
      fill(255);
      text(text, x+8,y+12);
  }
  
  boolean over()
  {
    return (mouseX>x && mouseX<x+w&& mouseY>y&&mouseY<y+h);
  }
  
  void showMouseOver()
  {
    //Yellow mouse over help text
    if(!textMouseOver.equals(""))
    {
      float pos=x; // or mouseX;
      //right screen border?
      if(pos+textWidth(textMouseOver)+10>width)
      {
        pos=width-textWidth(textMouseOver)-12;
      }
    fill(255,255,44);
    rect(pos,y+h+14, textWidth(textMouseOver)+2,20);
    fill(0);
    text(textMouseOver, pos+2, y+48);
    }
 }
  }