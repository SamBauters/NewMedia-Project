import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
 
 
 //Songs
Minim minim;
AudioPlayer song;
AudioMetaData meta;
int songLength=0;
boolean paused=false;
boolean noSongFound=false;

//Buttons
Button buttonPause;
Button buttonProgressFrame;
Button buttonProgressData;
Button buttonPrevious;
Button buttonNext;
Button buttonFolder;

//Files
String pathGlobal="";
String[] namesFiles; //Songs in folder
int indexFile=0; //Current song

//Frequence display
FFT fft;


 
void setup()
{
  size(500, 500);
  
  minim = new Minim(this);
  getFolder();
  
  //Define Buttons
  buttonPause = new Button(width/2-10,65,20,20,false,color(0),true,color(255),"||","Pause/Play",0);
  buttonProgressFrame = new Button(10,40,width-20,20,false, color(0),true,color(255),"","Click to set play position",1);
  buttonProgressData = new Button(12,42,0,17,true,color(222,1,1),false,color(255),"","",-1);
  buttonPrevious = new Button(width/2-70,65,20,20,false,color(0),true,color(255),"|<","Previous song",2);
  buttonNext = new Button(width/2+50,65,20,20,false,color(0),true,color(255),">|","Next song",3);
  buttonFolder = new Button(width-30,65,20,20,false,color(0),true,color(255),"v","Open folder",4);
  getCurrentSong();
  
  
}
 
void draw()
{
  background(0);
  
  if(noSongFound)
  {
    fill(255);
    textTab("No song found in \n" + pathGlobal + "\nPlease use open folder to change folder",20,20);
  }
  
  if(!noSongFound)
  {
    buttonProgressFrame.display();
    if(!(meta==null))
    buttonProgressData.w = map(song.position(),0,meta.length(),0,width-24);
    buttonProgressData.display();
    
    buttonPause.display();
  }
  
  showOtherScreenElements();
  
  if (!noSongFound) {
    showMeta();
  }
  
  if(!noSongFound)
  {
    try
    {
      if(!song.isPlaying()&&!paused)
      {
        //Next Song
        command(buttonNext.commandNumber);
      }
    }catch(Exception e)
    {
      //Doe niks
    }
  }
  
  checkMouseOver();
}

void mousePressed()
{
  //Welke button?
  if(buttonPause.over())
  {
    command(buttonPause.commandNumber);
  }else if(buttonProgressFrame.over())
  {
    command(buttonProgressFrame.commandNumber);
  }else if(buttonNext.over())
  {
     command(buttonNext.commandNumber);
  }else if(buttonPrevious.over())
  {
    command(buttonPrevious.commandNumber);
  }else if (buttonFolder.over()) {
    command(buttonFolder.commandNumber);
  }
  
  else{
    println("not found");
  }
}

void keyPressed()
{
  switch(key)
  {
    case ' ':
    command(buttonPause.commandNumber);
    break;
    
    case 'n':
    command(buttonNext.commandNumber);
    break;
    
    case 'p':
    command(buttonPrevious.commandNumber);
    break;
    
    case 'o':
    command(buttonFolder.commandNumber);
    break;
    
    default:
    break;
  }
}

void checkMouseOver()
{
  if(!noSongFound)
  {
    if(buttonPause.over())
    {
      buttonPause.showMouseOver();
    }else if(buttonProgressFrame.over())
    {
      buttonProgressFrame.showMouseOver();
    }else if(buttonNext.over())
    {
      buttonNext.showMouseOver();
    }else if(buttonPrevious.over())
    {
      buttonPrevious.showMouseOver();
    }else if(buttonFolder.over())
    {
      buttonFolder.showMouseOver();
    }else
    {
      println("not found 2");
    }
  }else
  {
    if(buttonFolder.over())
    {
      buttonFolder.showMouseOver();
    }
  }
}

void showOtherScreenElements()
{
  if(!noSongFound)
  {
    if(!(fft==null))
    {
      fft.forward(song.mix);
      stroke(255,0,0,128);
      
      for(int i = 0; i<fft.specSize(); i++)
      {
        line(i,height,i,height - fft.getBand(i)*4);
      }
    }
    
    fill(255);
    
    try
    {
      text("Played "+ strFromMillis(song.position())+ " of "+ strFromMillis(songLength) + ".",30, 30);
      if(!song.isPlaying())
      {
        fill(255);
        text("pause",width/2-17,54);
      }
    }catch(Exception e)
    {
      e.printStackTrace();
    }
    finally{
    }
    
    buttonPrevious.display();
    buttonNext.display();
  }
  buttonFolder.display();
}

void command(int commandNumber)
{
  switch(commandNumber)
  {
    case 0:
    if(song.isPlaying())
    {
      song.pause();
      paused = true;
      buttonPause.text=">";
    }
    else
    {
      song.play();
      paused=false;
      buttonPause.text="||";
    }
    break;
    
    case 1:
     int newSongPosition = int(map(mouseX,buttonProgressFrame.x, buttonProgressFrame.x+buttonProgressFrame.w,0, songLength));
     song.cue(newSongPosition);
    break;
    
    case 2:
     indexFile--;
    if(indexFile<0)
    {
      indexFile=0;
      getCurrentSong();
      break;
    }
    
    case 3:
    indexFile++;
    //Last song?
    if(indexFile>=namesFiles.length)
    //indexFile=namesFiles.length-1; //last song again and again
    indexFile=0;//1st song in folder
    getCurrentSong();
    break;
    
    case 4:
    chooseFolder();
    break;
    
    case -1:
    //undefined
    break;
    
    default:
    //Error
    println("Error 101");
    break;
  }
}

void getCurrentSong()
{
  //Song laden van data folder
  
  if(namesFiles.length>0)
  {
    if(fileIsOK(namesFiles[indexFile]))
    {
      //Stop old song if playing one
      if(song!= null)
      {
        song.close();
        minim.stop();
      }
      
      noSongFound = false;
      println(namesFiles[indexFile]);
      song = minim.loadFile(namesFiles[indexFile]); //pathGlobal + "\\ + songLength=song.length();
      songLength=song.length();
      //load meta
      meta = song.getMetaData();
      // an FFT needs to know how
      //long the audio buffer it will be analyzing are
      //and also needs to know the sample rate of the audio it is analyzing
       fft = new FFT(song.bufferSize(), song.sampleRate());
      song.play();
    }else
    {
      println("not ok" + namesFiles[indexFile]);
    }
    }else{
    println("No song found at all - not ok");
    noSongFound = true;
    }
  }
  
  void chooseFolder()
  {
    selectFolder("Select a music folder to play","folderSelected");
  }
  
  void folderSelected(File selection)
  {
    if(selection == null)
    {
      println("Window was closed or the user hit cancel.");
    } else{
      println("User selected " + selection.getAbsolutePath());
      noSongFound = false;
      indexFile = 0;
      pathGlobal=selection.getAbsolutePath();
      getFolder();
      getCurrentSong();
    }
  }
  
  void getFolder()
  {
    if(pathGlobal.equals(""))
      pathGlobal = dataPath("");
    File dir = new File(pathGlobal);
    println(dir);
    
    File[] namesFiles2 = dir.listFiles(); //dir.list();
    if(namesFiles2==null)
    {
      println("no file found - set folder to data path ##################");
      pathGlobal=dataPath("");
      dir = new File(pathGlobal);
      println(dir);
      namesFiles2 = dir.listFiles(); //dir.list();
    }
    namesFiles = new String[0];
    //Check all found files if they are ok
    for(int i=0; i<namesFiles2.length; i++)
    {
      //if ok
      if(fileIsOK(namesFiles2[i].getAbsolutePath()))
      {
        //New array
        namesFiles = append(namesFiles, namesFiles2[i].getAbsolutePath());
        noSongFound = false;
      }
      else{
        //println("skipped"+namesFiles2[i]);
      }
    }
    
    println("Found "+ namesFiles.length + " songs.");
    //println(namesFiles);
    indexFile=0;
    
    if(namesFiles.length==0)
    {
      println("no song ################");
      noSongFound = true;
    }
    else
    {
      noSongFound = false;
    }
  }
  
  boolean fileIsOK(String name)
  {
    //AudioPlayer: Mono and Stereo playback of WAV, AIFF, SND, and MP3 files.
    if(name==null)
      return false;
    name=trim(name);
    if(name.equals("")) return false;
    if (name.substring (  name.length()-4 ).equals (".MP3")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".mp3")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".WAV")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".wav")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".aiff")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".au")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".SND")  ) return true;
    if (name.substring (  name.length()-4 ).equals (".snd")  ) return true;
    //When no extension matched:
    return false;
  }
  
  void showMeta()
  {
    int ys = 115; //start pos
    int yi = 16; //y line diff.
    
    int y = ys;
    fill(255);
    if(!(meta==null))
    {
      textTab("File Name: \t" + showSongWithoutFolder(), 5, y);
      textTab("Length: \t" + strFromMillis(meta.length()), 5, y+=yi);
      textTab("Title: \t" + meta.title(), 5, y+=yi);
      textTab("Author: \t" + meta.author(), 5, y+=yi);
      textTab("Album: \t" + meta.album(), 5, y+=yi);
      textTab("Date: \t" + meta.date(), 5, y+=yi);
      textTab("Comment: \t" + meta.comment(), 5, y+=yi);
       try {
         // textTab("Track:   \t  " + meta.track(), 5, y+=yi);
       }
    catch (ArrayIndexOutOfBoundsException e) 
    { // to do ???
      System.err.println("Caught ArrayIndexOutOfBoundsException:      " +  e.getMessage());
    } finally{
      //do nothing
    };
    textTab("Genre:\t" + meta.genre(), 5, y+=yi);
    textTab("Copyright:  \t" + meta.copyright(), 5, y+=yi);
    textTab("Disc: \t" + meta.disc(), 5, y+=yi);
    textTab("Composer: \t" + meta.composer(), 5, y+=yi);
    textTab("Orchestra: \t" + meta.orchestra(), 5, y+=yi);
    textTab("Publisher: \t" + meta.publisher(), 5, y+=yi);
    textTab("Encoded: \t" + meta.encoded(), 5, y+=yi);
  }
  textTab("Folder:\t" +  pathGlobal, 5, y+=yi);
  textTab("In folder:\t" +"song " + str(indexFile+1) + " of " + namesFiles.length + ".", 5,y+=yi);
  }
  
  String showSongWithoutFolder()
  {
    //println(pathGlobal);
    //println(meta.fileName());
    if(meta == null)
    {
      println("meta==null");
      return "?";
    } else
    {
      return meta.fileName().substring(pathGlobal.length() + 1);  
    }
  }
  
  void textTab(String s, float x, float y)
  {
    // makes \t as tab for a table for one line
    // one for 2 columns yet
    //indent:
    int indent = 90;
    
    s=trim(s);
    String[] texts = split(s,"\t");
    s=null;
    texts[0]=trim(texts[0]);
    text(texts[0],x,y);
    
    //Do we have a second part?
    if(texts.length>1&&texts[1]!=null)
    {
      //is the indent too small
      if(textWidth(texts[0]) > indent)
      {
        indent = int(textWidth(texts[0]) + 10);
      }
      
      texts[1]=trim(texts[1]);
      text(texts[1],x+indent,y);
    }
  }
  
  String strFromMillis(int m)
  {
    // returns a string that represents a given millis m as hrs:minute:seconds
    float sec;
    int min;
    
    sec = m/1000;
    min = floor(sec/60);
    sec = floor(sec % 60);
    
    //over 1 hour?
    
    if(min>59)
    {
      int hrs = floor(min/60);
      min = floor(min % 60);
      return hrs+":"+nf(min,2)+":"+nf(int(sec),2);
    }else
    {
      return min+":"+nf(int(sec),2);
    }
  }
  
  void stop()
  {
    song.close();
    minim.stop();
    super.stop();
  }
  
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
