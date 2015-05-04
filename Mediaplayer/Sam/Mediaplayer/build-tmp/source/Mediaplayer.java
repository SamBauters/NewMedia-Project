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
import java.io.*; 
import java.awt.image.BufferedImage; 
import java.awt.BorderLayout; 
import java.awt.image.BufferedImage; 
import java.io.ByteArrayInputStream; 
import java.io.FileInputStream; 
import java.io.IOException; 
import java.io.InputStream; 
import java.io.UnsupportedEncodingException; 
import javax.imageio.ImageIO; 
import javax.swing.ImageIcon; 
import javax.swing.JFrame; 
import javax.swing.JLabel; 
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










//
//













 
 
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
Button buttonFolder;

//Visuals
Visual1 visual1;

//Files
String pathGlobal="";
String[] namesFiles; //Songs in folder
int indexFile=0; //Current song

//Frequence display
FFT fft;


 
public void setup()
{
  size(displayWidth, displayHeight);
    if (frame != null) {
    frame.setResizable(true);
  }
  
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
 
public void draw()
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
  
    if (showMp3Image) {
    if (mp3Image!=null) {
      image(mp3Image, width-mp3Image.width, height-mp3Image.height);
    }
  }
  
  checkMouseOver();

  visual1.display();
}

public void mousePressed()
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

public void keyPressed()
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

public void checkMouseOver()
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
    }/*else
    {
      println("not found 2");
    }*/
  }else
  {
    if(buttonFolder.over())
    {
      buttonFolder.showMouseOver();
    }
  }
}

public void showOtherScreenElements()
{
  if(!noSongFound)
  {
    /*if(!(fft==null))   //STANDAARD visual
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

public void command(int commandNumber)
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
     int newSongPosition = PApplet.parseInt(map(mouseX,buttonProgressFrame.x, buttonProgressFrame.x+buttonProgressFrame.w,0, songLength));
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

public void getCurrentSong()
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
    println("No song found at all - not ok");
    noSongFound = true;
    }
  }
  
  public void chooseFolder()
  {
    selectFolder("Select a music folder to play","folderSelected");
  }
  
  public void folderSelected(File selection)
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
      println("no song ################");
      noSongFound = true;
    }
    else
    {
      noSongFound = false;
      tryToShowCoverImage();
    }
  }
  
  public boolean fileIsOK(String name)
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
  
  public void showMeta()
  {
  	rectMode(CORNER);
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
    textTab("Comment: \t" + meta.comment(), 5, y+=yi);
  }
  /*textTab("Folder:\t" +  pathGlobal, 5, y+=yi);
  textTab("In folder:\t" +"song " + str(indexFile+1) + " of " + namesFiles.length + ".", 5,y+=yi);*/
  }
  
  public String showSongWithoutFolder()
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
  
  public void textTab(String s, float x, float y)
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
        indent = PApplet.parseInt(textWidth(texts[0]) + 10);
      }
      
      texts[1]=trim(texts[1]);
      text(texts[1],x+indent,y);
    }
  }
  
  public String strFromMillis(int m)
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
      return hrs+":"+nf(min,2)+":"+nf(PApplet.parseInt(sec),2);
    }else
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
    boolean hasColorFill = true; //if it has filling
    int colorFill; //what it is
  
  boolean hasColorStroke=true; //if it has an outline
  int colorStroke;
  String text ="";
  String textMouseOver="";
  int commandNumber;

  Button(float x_, float y_, float w_, float h_, boolean hasColorFill_, int cFill_, boolean hasColorStroke_, int cStroke_, String text_, String textMouseOver_, int commandNumber_) { x=x_;  y=y_;  w=w_; h=h_;
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
  
  public void display()
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
  
  public boolean over()
  {
    return (mouseX>x && mouseX<x+w&& mouseY>y&&mouseY<y+h);
  }
  
  public void showMouseOver()
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
  fill(0xff1A1F18, 20);
  noStroke();
  rect(0, 0, width, height);
  translate(width/2, height/2);
  noFill();
  fill(-1, 10);
  if (beat.isOnset()) rad = rad*0.9f;
  else rad = 70;
  ellipse(0, 0, 2*rad, 2*rad);
  stroke(-1, 50);
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
  stroke(-1, 50);
  for (int i = 0; i < bsize; i+=30)
  {
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    vertex(x2, y2);
    pushStyle();
    stroke(-1);
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
