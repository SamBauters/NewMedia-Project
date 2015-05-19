import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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
import ddf.minim.*; 
import ddf.minim.analysis.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Mediaplayer extends PApplet {






















 




 
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

 
public void setup()
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

public boolean sketchFullScreen() {
  return true; //fullscreen mode
}

public void circleGestureRecognized(CircleGesture gesture, String clockwiseness) {
  if (gesture.state() == State.STATE_STOP) {    
    //System.out.println("Duration: " + gesture.durationSeconds() + "s");
    if(clockwiseness == "clockwise")
    {
      song.shiftGain(gesture.durationSeconds()*15, 0.0f, 20000);//geluid omhoog
    } else
    {
      song.shiftGain(-(gesture.durationSeconds()*15), 0.0f, 20000);//geluid omlaag
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
 
public void draw()
{
	background(217,228,233);

	if(noSongFound)	//zou niet mogen gebeuren
	{
		fill(0xff000000);
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

public void LeapDraw()
{
	noFill();
	stroke(0xff000000);

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

public void mousePressed()
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

public void checkMouseOver()
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

public void showOtherScreenElements()
{
	if(!noSongFound)
	{    
		fill(0xff000000);

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
		      fill(0xff000000);
		      text("Gepauzeerd",width/2-17,54);
		    }
		}
		catch(Exception e)
		{
		    e.printStackTrace();
		}
	}

}

public void command(int commandNumber)
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

			int newSongPosition = PApplet.parseInt(map(lmx,buttonProgressFrame.x,displayWidth,0,songLength));
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

public void getCurrentSong()
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
  
  public void getFolder()
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
  
	public boolean fileIsOK(String name)//controleert of het liedje afgespeeld kan worden (extensies controleren)
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
  
	public String showSongWithoutFolder()
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
  
	public String strFromMillis(int m)//tijd converteren naar formaat 3:12
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
			  return hrs+":"+nf(min,2)+":"+nf(PApplet.parseInt(sec),2);
		}
		else
		{
		  	return min+":"+nf(PApplet.parseInt(sec),2);
		}
	}
  
	public void stop()
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
  PImage img;
  float imgX;
  float imgY; 
  
  int colorStroke;
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
  
  public void display()
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
  
  public boolean over(float lmx, float lmy)
  {
    return (lmx>x && lmx<x+w && lmy>y && lmy<y+h);
  }
  
  public void showMouseOver(float lmx)
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


// show cover image from MP3 

final boolean DEBUG = true;

String[] PICTURE_TYPES =
{
  "Other", 
  "32x32 pixels 'file icon' (PNG only)", 
  "Other file icon", 
  "Cover (front)", 
  "Cover (back)", 
  "Leaflet page", 
  "Media (e.g. label side of CD)", 
  "Lead artist/lead performer/soloist", 
  "Artist/performer", 
  "Conductor", 
  "Band/Orchestra", 
  "Composer", 
  "Lyricist/text writer", 
  "Recording Location", 
  "During recording", 
  "During performance", 
  "Movie/video screen capture", 
  "A bright coloured fish", 
  "Illustration", 
  "Band/artist logotype", 
  "Publisher/Studio logotype"
};

public void tryToShowCoverImage()
{
  final String path = namesFiles[indexFile]; 
  File file = new File(path);
  try
  {
    InputStream is = new FileInputStream(file);
    BufferedImage image = getID3Image(is);
    is.close();
    if (image != null)
    {
      mp3Image = new PImage(image.getWidth(), image.getHeight(), PConstants.ARGB);
      image.getRGB(0, 0, mp3Image.width, mp3Image.height, mp3Image.pixels, 0, mp3Image.width);
      mp3Image.updatePixels();
      mp3Image.resize(200, 0);
      println("image werkt");
    }
    else 
      println("image was null");
  }
  catch (IOException e)
  {
    println(e);
  }
}

// Adapted from http://supportforums.blackberry.com/t5/Java-Development/how-to-retrieve-ID3-art-Image-from-an-mp3-file/m-p/358490#M67015
// Minor fixes / improvements, and getting rid of the RIM Blackberry dependency by PhiLho.

public BufferedImage getID3Image(InputStream dataStream)
throws UnsupportedEncodingException, IOException
{
  /*---------------------------
   * ID3 v1 tags cannot contain images, so no need to process them.
   * ID3 v1 tags are also placed at the end of the MP3 so checking the beginning of the file won't do anything useful.
   *---------------------------
   */

  // Read the tags, searching for the album artwork
  long currentPosition = 0;
  byte[] imageData = null;
  String mimeType = null;

  byte[] buffer = new byte[10];
  if (dataStream.read(buffer, 0, 10) != 10 || !(new String(buffer, 0, 3).equals("ID3")))
  {
    // Not on start of ID3 data, nothing to find, just don't try
    if (DEBUG) 
      System.out.println("Not ID3");
    return null;
  }
  currentPosition += 10;
  // Found a ID3 version 2 or greater tag

  // Now to actually parse a tag
  int majorVersion = buffer[3] & 0xFF;
  byte minorVersion = buffer[4];
  byte[] destinationArray = new byte[4];
  System.arraycopy(buffer, 6, destinationArray, 0, 4);
  // Read a 28-bit int for size
  int size = read28bit(destinationArray);
  long end = currentPosition + size;
  long dataLength = end - 11L;

  if (DEBUG) System.out.println("Version: " + majorVersion + "." + minorVersion);
  boolean v2_2 = false;
  if (majorVersion == 2)
  {
    // ID3 v2.2
    v2_2 = true;
  }
  else if (majorVersion == 3 || majorVersion == 4)
  {
    // ID3 v2.3 / ID3 v2.4

      // Extra data seems might exist, go through
    boolean hasExtendedHeader = (buffer[5] & 0x40) == 0x40;
    if (hasExtendedHeader)
    {
      byte[] extendedHeaderBuffer = new byte[4];
      dataStream.read(extendedHeaderBuffer, 0, 4);
      currentPosition += 4;
      int extendedHeaderLength = read32bit(extendedHeaderBuffer);
      byte[] extendedHeaderData = new byte[extendedHeaderLength + 4];
      System.arraycopy(extendedHeaderBuffer, 0, extendedHeaderData, 4, extendedHeaderLength);
      dataStream.read(extendedHeaderData, 4, extendedHeaderLength);
      currentPosition += extendedHeaderLength;
      // No use for this data in the picture so just ignore it
    }
    v2_2 = false;
  }

  while (currentPosition < dataLength)
  {
    // Get the frame header and make sure that it is a valid frame.
    byte[] frameBuffer = new byte[v2_2 ? 6 : 10];
    if (dataStream.read(frameBuffer, 0, frameBuffer.length) != frameBuffer.length || (frameBuffer[0] & 0xFF) <= 0)
      break;

    currentPosition += frameBuffer.length;
    String frameId = new String(frameBuffer, 0, v2_2 ? 3 : 4);
    if (DEBUG) 
      System.out.println("Found frame " + frameId);
    destinationArray = new byte[v2_2 ? 3 : 4];
    System.arraycopy(frameBuffer, destinationArray.length, destinationArray, 0, destinationArray.length);
    int frameSize = 0;
    switch (majorVersion)
    {
    case 2:
      // 24-bit
      frameSize = read24bit(destinationArray);
      break;
    case 3:
      // 32-bit
      frameSize = read32bit(destinationArray);
      break;
    case 4:
      // 28-bit
      frameSize = read28bit(destinationArray);
      break;
    default:
      continue;
    }
    // Now read the data and check to see if it is a picture
    frameBuffer = new byte[frameSize];
    if (dataStream.read(frameBuffer, 0, frameSize) == frameSize)
    {
      currentPosition += frameSize;
      if (frameId.equals("PIC") || frameId.equals("APIC"))
      {
        // Got the frame data
        int refPoint = 0;
        // First we get the encoding type
        int encodingType = (frameBuffer[refPoint++] & 0xFF); // 0=ISO-8859-1, 1=UTF-16, 2=UTF-16BE, 3=UTF-8
        if (encodingType < 0 || encodingType > 3)
          // Do we need to stop reading the image because we can't get the description?
          // On the other hand, it should not happen anyway, perhaps the data is corrupt?
          throw new UnsupportedEncodingException("Cannot get picture description. Frame Encoding is invalid.");

        // Second we get the mime type
        int indexPoint = refPoint;
        while (frameBuffer[refPoint++] != 0)
          ;
        int mimeLength = refPoint - indexPoint;
        if (mimeLength > 1)
        {
          mimeType = new String(frameBuffer, indexPoint, mimeLength - 1);
          if (DEBUG) System.out.println("Mime type: " + mimeType);
        }

        // Third we get the picture type
        int pictureType = frameBuffer[refPoint++] & 0xFF;
        if (DEBUG) System.out.println("Picture type: " + pictureType + " - " + PICTURE_TYPES[pictureType]);

        // Fourth we load the picture description
        // Check length
        int scanPoint = refPoint;
        switch (encodingType)
        {
        case 0:
        case 3:
          // 8-bit string
          while (scanPoint < frameBuffer.length && frameBuffer[scanPoint++] != 0)
            ;
          break;
        case 1:
        case 2:
          // 16-bit string
          do
          {
            byte b1 = frameBuffer[scanPoint++];
            byte b2 = frameBuffer[scanPoint++];
            if (b1 == 0 && b2 == 0)
              break;
          } 
          while (scanPoint < frameBuffer.length - 1);
          break;
        }
        // And read the string
        int descriptionLength = scanPoint - refPoint;
        byte[] descriptionBuffer = new byte[descriptionLength];
        int pos = 0;
        switch (encodingType)
        {
        case 0:
        case 3:
          // 8-bit string
          while (pos < descriptionLength)
          {
            descriptionBuffer[pos++] = frameBuffer[refPoint++];
          }
          break;
        case 1:
        case 2:
          // 16-bit string
          do
          {
            byte b1 = frameBuffer[refPoint++];
            byte b2 = frameBuffer[refPoint++];
            if (encodingType == 1 && b1 == 0xFF && b2 == 0xFE)
              continue; // Skip BOM

            descriptionBuffer[pos++] = b1;
            descriptionBuffer[pos++] = b2;
          } 
          while (pos < descriptionLength);
          break;
        }

        String encoding = null;
        switch (encodingType)
        {
        case 0:
          encoding = "ISO-8859-1";
          break;
        case 1:
          encoding = "UTF-16";
          break;
        case 2:
          encoding = "UTF-16BE";
          break;
        case 3:
          encoding = "UTF-8";
          break;
        }
        String description = new String(descriptionBuffer, encoding);
        if (DEBUG) System.out.println("Description: " + description);

        // Finally, THE MAIN EVENT, the image data
        int imageSize = frameBuffer.length - refPoint;
        imageData = new byte[imageSize];
        System.arraycopy(frameBuffer, refPoint, imageData, 0, imageSize);
        break;
      }
    }
  }

  if (imageData != null)
  {
    //We found the image
    System.out.println("Got image: " + mimeType + " / " + imageData.length + " bytes");
    /*
      if (mimeType != null && mimeType.length() > 0)
     {
     // Save some time in searching for image type
     return net.rim.device.api.system.EncodedImage.createEncodedImage(imageData, 0, imageData.length, mimeType);
     }
     else
     {
     return net.rim.device.api.system.EncodedImage.createEncodedImage(imageData, 0, imageData.length);
     }
     */
    InputStream imageStream = new ByteArrayInputStream(imageData);
    BufferedImage image = ImageIO.read(imageStream);
    imageStream.close();
    return image;
  }
  // No image found
  return null;
}

public int read32bit(byte[] data)
{
  return
    ((data[0] & 0xFF) << 24) |
    ((data[1] & 0xFF) << 16) |
    ((data[2] & 0xFF) <<  8) |
    (data[3] & 0xFF);
}

public int read28bit(byte[] data)
{
  return
    ((data[0] & 0xFF) << 21) |
    ((data[1] & 0xFF) << 14) |
    ((data[2] & 0xFF) <<  7) |
    (data[3] & 0xFF);
}

public int read24bit(byte[] data)
{
  return
    ((data[1] & 0xFF) << 16) |
    ((data[2] & 0xFF) <<  8) |
    (data[3] & 0xFF);
}
// 




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

public void display()
{ 

  float t = map(mouseX, 0, width, 0, 1);
  beat.detect(player.mix);
  //fill(#1A1F18, 20);
  noStroke();
  rect(0, 0, width, height);
  translate(width/2, height/2);
  noFill();
  //fill(#000000, 80);
  if (beat.isOnset()) rad = rad*0.9f;
  else rad = 70;
  //ellipse(0, 0, 2*rad, 2*rad);
  stroke(0xff000000, 90);
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
  stroke(0xff000000, 50);
  for (int i = 0; i < bsize; i+=30)
  {
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    vertex(x2, y2);
    pushStyle();
    stroke(0xff000000);
    strokeWeight(2);
    point(x2, y2);
    popStyle();
  }
  endShape();
  return;
}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Mediaplayer" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
