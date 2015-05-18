import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.awt.image.BufferedImage;
import java.awt.BorderLayout;

import java.io.*;
import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
 
import com.leapmotion.leap.Gesture.State;
import com.leapmotion.leap.ScreenTapGesture;
import com.onformative.leap.*;
import com.leapmotion.leap.*;
 
 //Songs
Minim minim;
AudioPlayer song;
AudioMetaData meta;
int songLength=0;
boolean paused=false;
boolean noSongFound=false;
PImage mp3Image;  // show cover image from MP3
boolean showMp3Image = true; 

//Buttons
Button buttonPause;
Button buttonProgressFrame;
Button buttonProgressData;
Button buttonPrevious;
Button buttonNext;

//Visuals
Visual1 visual1;

//Files
String pathGlobal="";
String[] namesFiles; //Songs in folder
int indexFile=0; //Current song

//Frequence display
FFT fft;

//leap motion
LeapMotionP5 leap;
int x, y;
int timePassed;
boolean next = false;
boolean prev = false;
boolean pausee = false;

Frame fullScreenFrame;

 
void setup()
{
  	size(displayWidth, displayHeight, P3D);
    	if (frame != null) 
    	{
    		frame.setResizable(false);
        }
	noCursor();
	minim = new Minim(this);
	getFolder();
	  
	//Define Buttons
	buttonProgressData = new Button(0,				75,		0,			100,		"",			0,			0,-1); 						//move progress
	buttonProgressFrame = new Button(0,				75,		width,		100, 		"",			0,			0,	1); //frame Click to set play position
	  
	buttonPrevious = 	new Button(0, 				height/2-200,	width/5,	height/2,	"prev.png",	10,			height/2-175,2);//Previous song
	buttonPause = 		new Button(width/3,			height/2-200,	width/2,	height/2,	"play.png",	width/2-185,	height/2-175,0); //Pause/Play
	buttonNext = 		new Button(width-width/5,	height/2-200,	width/5,	height/2,	"next.png",	width-360,	height/2-175,3);//Next song

	getCurrentSong();

	leap = new LeapMotionP5(this);
	leap.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
	leap.enableGesture(Gesture.Type.TYPE_SWIPE);
        leap.enableGesture(Gesture.Type.TYPE_CIRCLE);
}

public void screenTapGestureRecognized(ScreenTapGesture gesture) 
{
  if (gesture.state() == State.STATE_STOP) 
  {
  	if(timePassed>10)
  	{
          println("CLICK: ");
          mousePressed();
    	  timePassed = 0;
  	}
   }
}

boolean sketchFullScreen() {
  return true;
}

public void circleGestureRecognized(CircleGesture gesture, String clockwiseness) {
  if (gesture.state() == State.STATE_STOP) {    
    //System.out.println("Duration: " + gesture.durationSeconds() + "s");
    if(clockwiseness == "clockwise")
    {
      song.shiftGain(gesture.durationSeconds()*15, 0.0, 20000);
    } else
    {
      song.shiftGain(-(gesture.durationSeconds()*15), 0.0, 20000);
    }
  }
}

public void swipeGestureRecognized(SwipeGesture gesture) 
{
  	if (gesture.state() == State.STATE_STOP) 
  	{
    	if(gesture.direction().get(0)>0)
    	{
			if(timePassed>10)
  			{
  	                prev = true;
	    		command(buttonPrevious.commandNumber);
	    		timePassed = 0;
	    		println("SWIPE PREV");
                        tryToShowCoverImage();
    		}
    	}
    	else 
		{
  			if(timePassed>10)
  			{
  			next = true;
  			command(buttonNext.commandNumber);	
    			timePassed = 0;
    			println("SWIPE NEXT");
                        tryToShowCoverImage();
  			}
  		} 
  	}
}
 
void draw()
{
  background(217,228,233);
  
  if(noSongFound)
  {
    fill(#000000);
    textTab("Geen songs gevonden in \n" + pathGlobal,20,20);
  }
  
  if(!noSongFound)
  {
    buttonProgressFrame.display();
    if(!(meta==null))
    buttonProgressData.w = map(song.position(),0,meta.length(),0,width);
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
  
    if (showMp3Image) {
    if (mp3Image!=null) {
      image(mp3Image, width-mp3Image.width, height-mp3Image.height);
    }
  }
  
  checkMouseOver();
  LeapDraw();
  timePassed++;
  visual1.display();

}

void LeapDraw()
  {
      noFill();
      stroke(#000000);

      if(leap.getFingerList().size()==1)
      {
        Finger f = leap.getFingerList().get(0);
          
        PVector position = leap.getTip(f);
        x = (int)position.x;
        y = (int)position.y;
      }
    
    mouseX = x;
    mouseY = y;
    ellipse(x, y, 10, 10);
  }

void mousePressed()
{
  //Welke button?
  if(buttonPause.over())
  {
  	pausee = true;
    command(buttonPause.commandNumber);
    println("PAUSED: ");
  }
  else if(buttonProgressFrame.over())
  {
    command(buttonProgressFrame.commandNumber);
    println("PROGRESSED: ");
  }
  else if(buttonNext.over())
  {
  	next = true;
     command(buttonNext.commandNumber);
     tryToShowCoverImage();
     println("NEXTED: ");
  }
  else if(buttonPrevious.over())
  {
  	prev = true;
    command(buttonPrevious.commandNumber);
    tryToShowCoverImage();
    println("PREVIOUSED: ");
  }
  
  else{
    println("not found");
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
    }
    /*else
    {
      println("not found 2");
    }*/
  }
  else
  {
  	//no songs found in folder	
  }
}

void showOtherScreenElements()
{
  if(!noSongFound)
  {
    /*if(!(fft==null))   										//STANDAARD visual
    {
      fft.forward(song.mix);
      stroke(255,0,0,128);
      
      for(int i = 0; i<fft.specSize(); i++)
      {
        line(i,height,i,height - fft.getBand(i)*4);
        line(width-i,height,width-i,height - fft.getBand(i)*4);
      }
    }
    */
    
    fill(#000000);
    
    try
    {
    	textSize(26);
      	text(strFromMillis(song.position()),map(song.position(),0,meta.length(),0,width)-20, 205);
      	text(strFromMillis(songLength), width-75, height-55);
      	textSize(14);

	    if(!song.isPlaying())
	    {
	      fill(#000000);
	      text("Gepauzeerd",width/2-17,54);
	    }
	}
	catch(Exception e)
	{
	    e.printStackTrace();
	}
	finally
	{}
    
    buttonPrevious.display();
    buttonNext.display();
  }

}

void command(int commandNumber)
{
  switch(commandNumber)
  {
    case 0:
    if(pausee == true)
    {
    	if(song.isPlaying())
	    {
	      song.pause();
	      paused = true;
	    }
	    else
	    {
	      song.play();
	      paused=false;
	    }
	    pausee = false;
    }
    
    break;
    
    case 1:

     	int newSongPosition = int(map(mouseX,buttonProgressFrame.x, buttonProgressFrame.x+buttonProgressFrame.w,0, songLength));
     	song.cue(newSongPosition);
    	break;
    
    case 2:
    	if(prev == true)
    	{
    		indexFile--;

	    	if(indexFile<0)
	    	{
	     		indexFile=namesFiles.length-1;
	  		}
	      	getCurrentSong();
	      	prev = false;
    	}
     	
      	break;

    case 3:
	    if(next == true)
	    {
	    	indexFile++;
		    //Last song?
		    if(indexFile>=namesFiles.length)
		    	indexFile=0;//1st song in folder
		    getCurrentSong();
		    next = false;
	    
    	}
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
      
      //song.setGain(-80);
      visual1 = new Visual1(song);
    }else
    {
      println("not ok" + namesFiles[indexFile]);
    }
    }else{
    println("Geen nummers gevonden - not ok");
    noSongFound = true;
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
      println("Geen nummer ################");
      noSongFound = true;
    }
    else
    {
      noSongFound = false;
      tryToShowCoverImage();
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
    fill(#000000);
    if(!(meta==null))
    {
    	    textSize(26);
	    textTab(showSongWithoutFolder(), 10, 35);
  	}
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
      //return meta.fileName().substring(pathGlobal.length() + 1); 
      return meta.author() + " - " + meta.title();
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
