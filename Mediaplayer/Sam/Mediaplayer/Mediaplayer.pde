import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import java.awt.image.BufferedImage;
import java.awt.BorderLayout;
import java.awt.image.BufferedImage;

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


 
void setup()
{
  size(displayWidth, displayHeight);
    if (frame != null) {
    frame.setResizable(false);
  }
  
  minim = new Minim(this);
  getFolder();
  
  //Define Buttons
  buttonProgressData = 	new Button(0,				height-100,		0,			100,		"",			0,			0,-1); 						//move progress
  buttonProgressFrame = new Button(0,				height-100,		width,		100, 		"",			0,			0,	1); //frame Click to set play position
  
  buttonPrevious = 		new Button(0, 				height/2-200,	width/5,	height/2,	"prev.png",	10,			height/2-85,2);//Previous song
  buttonPause = 		new Button(width/3,			height/2-200,	width/3,	height/2,	"play.png",	width/2-50,	height/2-85,0); //Pause/Play
  buttonNext = 			new Button(width-width/5,	height/2-200,	width/5,	height/2,	"next.png",	width-210,	height/2-85,3);//Next song

  getCurrentSong();
}
 
void draw()
{
  background(0);
  
  if(noSongFound)
  {
    fill(255);
    textTab("No song found in \n" + pathGlobal,20,20);
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
      image(mp3Image, width-mp3Image.width, 0);
    }
  }
  
  checkMouseOver();

  visual1.display();
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
    
    case 'i':
    // show image from MP3 when available
    tryToShowCoverImage();
    showMp3Image=true;
    break;
    
    case 'I':
    showMp3Image=false;
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
    }
    else if(mouseX>width-mp3Image.width && mouseY<mp3Image.height)
    {
    	rectMode(CORNER);
	    int ys = 50; //start pos
	    int yi = 16; //y line diff.
	    
	    int y = ys;
	    fill(255);
	    /*if(!(meta==null))
	    {
	    	textTab("Duur: \t" + strFromMillis(meta.length()), 35, y+=yi);
		    textTab("Titel: \t" + meta.title(), 35, y+=yi);
		    textTab("Artiest: \t" + meta.author(), 35, y+=yi);
		    textTab("Genre:\t" + meta.genre(), 35, y+=yi);
	  	}*/
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
    
    fill(255);
    
    try
    {
    	textSize(26);
      	text(strFromMillis(song.position()),map(song.position(),0,meta.length(),0,width)-20, height-115);
      	text(strFromMillis(songLength), width-75, height-55);
      	textSize(14);

	    if(!song.isPlaying())
	    {
	      fill(255);
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
    //fill(255);
    if(!(meta==null))
    {
    	textSize(26);
	    textTab(showSongWithoutFolder(), 10, 35);
	    textSize(12);
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
