class Button{
  int x,y;
  int w,h; 
  PImage pic,sel,pres,cur;
  int selc=0;
  
  Button(int x1, int y1, int w1, int h1, PImage p, PImage s){
    x=x1;
    y=y1;
    w=w1;
    h=h1;
    pic=p;
    sel=s;
     cur=pic;
    }

   boolean selected(){
    if(mouseX>=x&&mouseX<=x+w&&
       mouseY>=y&&mouseY<=y+h) return true;
       else
         return false;
  }
 
   boolean pressed(){
    if (selected()&&mousePressed) return true;
    else
        return false;
   }
   void animate(){
     if(selected()){
      cur=sel;
    } else {
      cur=pic;
    }
   }
   
   void display(){
     image(cur,x,y,w,h);
     
}


 void presbut(){
   image(sel,x,y,w,h);
 }
 void opbut(){
   image(pic,x,y,w,h);
 }
 
 
    }
