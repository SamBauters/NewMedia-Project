class ScrollBar{
  int x,y,w,h,w2,h2,pos,dpos,poss;
  float posd;
  PImage bar,scroll;
  
  ScrollBar(PImage bar1, PImage scroll1, int x1,int y1,int w1,int h1,int ws, int ys){
    x=x1;y=y1;w=w1;h=h1;
    pos=h;
    bar=bar1;
    scroll=scroll1;
    ws=w2;ys=h2;
  }
   boolean selected(){
    if(mouseX>=x&&mouseX<=x+w&&
       mouseY>=y&&mouseY<=y+h) return true;
       else
         return false;
  }
  void update(){
    if (selected()&&mousePressed)
      pos=mouseX; 
   if (pos>w-25) pos=w-25;   
   if (pos<x+17) pos=x+17;  
  }
  
  void display(float posd, int step){
     if (selected()&&mousePressed) {posd=pos; cue(pos,step,0);}
    image(bar,x,y,w,h);
    
    image(scroll,posd+17,y);
  }
  void cue(int pos,int step, int dir){
    switch(dir){
      case -1: pos--; break;
      case 1: pos++; break;
    }
    player.cue(pos*step+17);
  }
  
  float getPos(){
    return posd;
  }
}
