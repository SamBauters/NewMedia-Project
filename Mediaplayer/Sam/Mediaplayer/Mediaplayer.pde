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
FFT fft;

//Images
PImage mp3Image;
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


//leap motion
LeapMotionP5 leap;
float lmx, lmy;
int timePassed;
boolean next = false;
boolean prev = false;
boolean pausee = false;

 
void setup()
{
	//init frame
  	size(displayWidth, displayHeight, P3D);
	if (frame != null) 
	{
		frame.setResizable(false);
    }

	noCursor();

	//init geluid + folder selectie
	minim = new Minim(this);
	getFolder();
	getCurrentSong();

	//Buttons
	buttonProgressData = new Button(0,				75,		0,			100,		"",			0,			0,-1); 						//move progress
	buttonProgressFrame = new Button(0,				75,		width,		100, 		"",			0,			0,	1); //frame Click to set play position
	buttonPrevious = 	new Button(0, 				height/2-200,	width/3,	height/2,	"prev.png",	10,			height/2-175,2);//Previous song
	buttonPause = 		new Button(width/3,			height/2-200,	width/3,	height/2,	"play.png",	width/2-177,height/2-175,0); //Pause/Play
	buttonNext = 		new Button(width-width/3,	height/2-200,	width/3,	height/2,	"next.png",	width-360,	height/2-175,3);//Next songs

	//init Leap Motion
	leap = new LeapMotionP5(this);
	leap.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
	leap.enableGesture(Gesture.Type.TYPE_SWIPE);
    leap.enableGesture(Gesture.Type.TYPE_CIRCLE);
}

public void screenTapGestureRecognized(ScreenTapGesture gesture) 
{
  if (gesture.state() == State.STATE_STOP) 
  {
  	if(timePassed>10)//controle op spam
  	{
  		//hetzelfde als muis-klik + spam-timer reset
	    mousePressed();
		timePassed = 0;
  	}
   }
}

boolean sketchFullScreen() {
  return true; //fullscreen mode
}

public void circleGestureRecognized(CircleGesture gesture, String clockwiseness) {
  if (gesture.state() == State.STATE_STOP) {    
    //System.out.println("Duration: " + gesture.durationSeconds() + "s");
    if(clockwiseness == "clockwise")
    {
      song.shiftGain(gesture.durationSeconds()*15, 0.0, 20000);//geluid omhoog
    } else
    {
      song.shiftGain(-(gesture.durationSeconds()*15), 0.0, 20000);//geluid omlaag
    }
  }
}

public void swipeGestureRecognized(SwipeGesture gesture) 
{
  	if (gesture.state() == State.STATE_STOP) 
  	{
    	if(gesture.direction().get(0)>0)
    	{
			if(timePassed>10)//spam controle
  			{
  				//controle op command + command zelf
  	            prev = true; 
	    		command(buttonPrevious.commandNumber);
	    		timePassed = 0;

	    		//image
                tryToShowCoverImage();
    		}
    	}
    	else 
		{
  			if(timePassed>10)//spam controle
  			{
  				//controle op command + command zelf
	  			next = true;
	  			command(buttonNext.commandNumber);	
    			timePassed = 0;

    			//image
                tryToShowCoverImage();
  			}
  		} 
  	}
}
 
void draw()
{
	background(217,228,233);

	if(noSongFound)	//zou niet mogen gebeuren
	{
		fill(#000000);
		text("Geen songs gevonden in \n" + pathGlobal,20,20);
	}
  
	if(!noSongFound)
	{
		//de progress bar & progress bar container
		buttonProgressFrame.display();
	    if(!(meta==null))
	    {
	    	buttonProgressData.w = map(song.position(),0,meta.length(),0,width);
	    	buttonProgressData.display();
	    }
	    
	    buttonPause.display();
	    buttonPrevious.display();
		buttonNext.display();

	    //naam song + artist
	    fill(0);
	    textSize(26);
		text(showSongWithoutFolder(), 10, 35);

		//dit gebeurt als een liedje eindigt
		try
	    {
	      if(!song.isPlaying() && !paused)
	      {
	        //volgend liedje
	        next = true;
	        command(buttonNext.commandNumber);

	        //image
	        tryToShowCoverImage();
	      }
	    }catch(Exception e)
	    {
	      //Doe niks
	    }
	}
  
  	showOtherScreenElements();
  	

    if (showMp3Image && mp3Image!=null) 
    {
    	//image
      	image(mp3Image, width-mp3Image.width, height-mp3Image.height);
  	}
  	
  	//controle op mouse hover
	checkMouseOver();

	//leap motion cursor
	LeapDraw();

	//anti-spam timer
	timePassed++;

	//visual
	visual1.display();
}

void LeapDraw()
{
	noFill();
	stroke(#000000);

	if(leap.getFingerList().size()==1)//werkt alleen er maar 1 vinger gedetecteerd wordt
	{
		Finger f = leap.getFingerList().get(0);

		PVector position = leap.getTip(f);
		lmx = position.x;
		lmy = position.y;
	}

	//de verborgen muis volgt Leap motion cursor
	//mouseX = x;
	//mouseY = y;

	//Leap motion cursor
	ellipse(lmx, lmy, 10, 10);
}

void mousePressed()
{
	//Welke button?
	if(buttonPause.over(lmx, lmy))
	{
		pausee = true;
		command(buttonPause.commandNumber);
		return;
	}
	else if(buttonProgressFrame.over(lmx, lmy))
	{
		command(buttonProgressFrame.commandNumber);
		return;
	}
	else if(buttonNext.over(lmx, lmy))
	{
		next = true;
		command(buttonNext.commandNumber);
		tryToShowCoverImage();
		return;
	}
	else if(buttonPrevious.over(lmx, lmy))
	{
		prev = true;
		command(buttonPrevious.commandNumber);
		tryToShowCoverImage();
		return;
	}
	else{//als er op niets geklikt geweest was
		println("not found");
	}
}

void checkMouseOver()
{
	if(!noSongFound)
	{
		//controleert op hovers over buttons
		if(buttonPause.over(lmx, lmy))
		{
			buttonPause.showMouseOver(lmx);
		}
		else if(buttonProgressFrame.over(lmx, lmy))
		{
			buttonProgressFrame.showMouseOver(lmx);
		}
		else if(buttonNext.over(lmx, lmy))
		{
			buttonNext.showMouseOver(lmx);
		}
		else if(buttonPrevious.over(lmx, lmy))
		{
			buttonPrevious.showMouseOver(lmx);
		}
	}
}

void showOtherScreenElements()
{
	if(!noSongFound)
	{    
		fill(#000000);

		try
		{
			//hoelang het liedje al speelt en in totaal duurt
			textSize(26);
		  	text(strFromMillis(song.position()),map(song.position(),0,meta.length(),0,width)-20, 205);
		  	text(strFromMillis(songLength), width-75, height-55);

		  	//hulp voor volume
		  	textSize(14);
		  	text("Maak een cirkelbeweging om het volume te regelen", 20, height - 20);

		  	//indien gepauseerd is
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

				//controle op actie
				pausee = false;
			}
		break;

		case 1:
			paused = true;

			int newSongPosition = int(map(lmx,buttonProgressFrame.x,displayWidth,0,songLength));
			song.cue(newSongPosition);

			paused = false;
		break;

		case 2:
			if(prev == true)//vorig liedje
			{
				indexFile--;

				if(indexFile<0)//laatste liedje uit het lijst indien je al op 1ste liedje staat
				{
					indexFile=namesFiles.length-1;
				}

				getCurrentSong();

				//controle op actie
				prev = false;
			}
		break;

		case 3:
			if(next == true)//volgende liedje
			{
				indexFile++;
				
				if(indexFile>=namesFiles.length)//1ste liedje in het lijst indien je op het laatste staat
				{
					indexFile=0;//1st song in folder
				}

				getCurrentSong();

				//controle op actie
				next = false;
			}
		break;
	}
}

void getCurrentSong()
{
	//liedje laden uit data folder
	if(namesFiles.length>0)
	{
		//controleer of het liedje ok is
		if(fileIsOK(namesFiles[indexFile]))
		{
			//stop alles indien er iets aan het afspelen is
			if(song!= null)
			{
				song.close();
				minim.stop();
			}

			noSongFound = false;

			println(namesFiles[indexFile]);
			song = minim.loadFile(namesFiles[indexFile]); //pathGlobal + "\\ + songLength=song.length();
			songLength=song.length();

			//meta data
			meta = song.getMetaData();

			//FFT
			fft = new FFT(song.bufferSize(), song.sampleRate());

			//speel af
			song.play();

			//visual heeft Audio player nodig
			visual1 = new Visual1(song);
		}
		else
		{
		  	println("!!!!Iets mis met het file!!!! " + namesFiles[indexFile]);
		}
	}
	else
	{
		println("!!!!Geen nummers gevonden!!!!");
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
  
	boolean fileIsOK(String name)//controleert of het liedje afgespeeld kan worden (extensies controleren)
	{
		//geen file?
		if(name==null)
			return false;
		
		name=trim(name);

		//lege filenaam?
		if(name.equals("")) return false;

		if (name.substring (  name.length()-4 ).equals (".MP3")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".mp3")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".WAV")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".wav")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".aiff")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".au")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".SND")  ) return true;
		if (name.substring (  name.length()-4 ).equals (".snd")  ) return true;
		
		//hier mag hij niet komen
		return false;
	}
  
	String showSongWithoutFolder()
	{
		if(meta == null)//geen meta? toon warning
		{
			println("meta==null");
			return "?";
		} 
		else
		{	
			//naam liedje + artist
			return meta.author() + " - " + meta.title();
		}
	}
  
	String strFromMillis(int m)//tijd converteren naar formaat 3:12
	{
		
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
		}
		else
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
