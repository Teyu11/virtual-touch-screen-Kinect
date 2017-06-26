
import SimpleOpenNI.*;
import java.awt.*;
import java.awt.event.*;

SimpleOpenNI kinect;
Robot bot;

PImage kinectDisplay;
int kinectWidth;
int kinectHeight;
int flag=0, flagScreen=0, flagGestures=0;
int[] point1 = new int[2];
int[] point2 = new int[2];
int[] point3 = new int[2];
int cursorX;
int cursorY;
int depthMap[] = new int[640*480];
int d[];
int size=0;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
int handVecListSize = 20;
Dance dance;
IntVector userList;
Touch touch;

void setup()
{
  size(640 *2, 480, P3D);
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);
  frameRate(30);
  try
  {
    bot = new Robot();
  }
  catch(Exception e)
  {
     println(e);
  }
  dance=new Dance(kinect);
  touch= new Touch(kinect);
  
}

void draw()
{
  kinect.update();
  kinectDisplay = kinect.rgbImage();
  image(kinectDisplay,0,0);
  d=kinect.depthMap();
  if(flag<3)
  {
    image(kinectDisplay,640,0);
  }
    else
  {
    kinectDisplay=kinectDisplay.get(point1[0], point1[1], kinectWidth, kinectHeight);
   // kinectDisplay.resize(640,480);
   
   // image(kinectDisplay,640,0);     
   // drawBox();
   }
   MouseMove mouse;
   userList = new IntVector(); 
   kinect.getUsers(userList); 
   if (userList.size() > 0) 
   {
      
       int userId = userList.get(0);    
      if( kinect.isTrackingSkeleton(userId)) 
      {   
          PVector Rhand = new PVector();
          kinect.getJointPositionSkeleton(userList.get(0),SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
          PVector Lhand = new PVector();
          kinect.getJointPositionSkeleton(userList.get(0),SimpleOpenNI.SKEL_LEFT_HAND,Lhand);
          
          // Check if user's hand is close enough to the selected screen to enable touch
          if((compareUser(Rhand.z)>0 || compareUser( Lhand.z)>0 ))
          {      
             if(flagScreen==0)           
                println("Touch activated");
              touch.drawTouch(userId );
              flagScreen=1;
              flagGestures=0;
          }
          else
          {
              if(flagGestures==0)
                println("Hand Gestures");
            dance.drawDance();
              flagScreen=0;
              flagGestures=1;
          }
      }
      dance.drawSkeleton(userId); 
      
   }
   
  
}

/* void drawSkeleton(int userId) 
{  
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD,  SimpleOpenNI.SKEL_NECK); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK,  SimpleOpenNI.SKEL_LEFT_SHOULDER);
      
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);  
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,  SimpleOpenNI.SKEL_TORSO); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,  SimpleOpenNI.SKEL_LEFT_HIP);  
  //  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);  
  //  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);  
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP); 
  //  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
   // kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT); 
    kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
}
    
void drawLimb(int userId, int jointType1, int jointType2) 
{  
    PVector jointPos1 = new PVector();  
    PVector jointPos2 = new PVector();  
    float  confidence;
    // draw the joint position 
    confidence = kinect.getJointPositionSkeleton(userId, jointType1, jointPos1); 
    confidence = kinect.getJointPositionSkeleton(userId, jointType2, jointPos2);
    line(jointPos1.x, jointPos1.y-10, jointPos1.z,  jointPos2.x, jointPos2.y-10, jointPos2.z);
}
*/
/*void drawBox(){
  stroke(255);
  noFill();
  rect(point1[0], point1[1], kinectWidth, kinectHeight);
}
*/
void mousePressed()
{
  int temp1;
  int temp2;
  //Select the screen 
  if(mouseButton==LEFT)
  {
    // Store first coordinate
    if(flag==0)
    {
      point1[0]=mouseX;
      point1[1]=mouseY;
      flag++;
    }
    //Store the second coordinate
    else if(flag==1 && mouseX>point1[0])
    {
      point2[0]=mouseX;
      point2[1]=mouseY;
      flag++;
      kinectWidth= point2[0]-point1[0];
      println("Width= "+kinectWidth);
    }
    //Store the third coordinate and depthMap of selected screen
    else if(flag==2 && mouseY>point1[1])
    {
      point3[0]=mouseX;
      point3[1]=mouseY;
      flag++;  
      kinectHeight= point3[1]-point1[1];
      println("height= "+kinectHeight);
      int m=0;
       for(int i=point1[0];i<=point2[0];i++)
      for(int j=point1[1];j<=point3[1];j++)
      {
       
        depthMap[m++]=d[i+j*640];
        
      }
      size=m;
    }
    else
    {
   //  println("X= "+mouseX+" Y= "+mouseY);
    // println("Px "+p2d.x+" Py "+p2d.y);
      cursorX=(int)(((double)displayWidth/640)*mouseX);
      cursorY=(int)(((double)displayHeight/480)*mouseY);
     // println(displayWidth+" "+displayHeight);
     // println("X'= "+cursorX+" Y'= "+cursorY);
      temp1=mouseX;
      temp2=mouseY;
      bot.mouseMove(cursorX,cursorY);
     
    }
  }  
} 

/**
*The method checks if user is close enough the screen
*@param dOfUser The depth of User
*@return difference between user and screen if the user is close else -1
*/
 float compareUser( float dOfUser)
    {
        for(int i=0;i<size;i++)
        {
            float diff=depthMap[i]-dOfUser;
            //println("depthmap "+depthMap[i]+" dOfHand"+dOfhand);
            if(diff<500 && diff >0)
                return diff;
        }
        
        return -1;
    }        
void onNewHand(SimpleOpenNI curkinect,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);
  
  handPathList.put(handId,vecList);
}

void onTrackedHand(SimpleOpenNI curkinect,int handId,PVector pos)
{
  println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);
  if(vecList != null)
  {
    vecList.add(0,pos);
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1); 
  }  
 // if(vecList.get(0).x-vecList.get(vecList.size()-1).x>300)
  //display();
  
}

void onLostHand(SimpleOpenNI curkinect,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curkinect,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  
  int handId = kinect.startTrackingHand(pos);
  println("hand stracked: " + handId);
}

void onNewUser(SimpleOpenNI curkinect, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curkinect.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curkinect, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curkinect, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
