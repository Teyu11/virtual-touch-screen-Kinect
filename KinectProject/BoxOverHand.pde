import SimpleOpenNI.*;
import java.awt.*;
import java.awt.event.*;
import processing.opengl.*; 
 
SimpleOpenNI context;
Robot robot;
Point a;
PVector coord1, coord2, coord3, coord4;
int boxWidth, boxHeight, boxDepth;
int boxSize = 150;  
// a vector holding the center of the box 
PVector mouse1 = new PVector();
PVector mouse2 = new PVector();
PVector Lhand, Lhip;
//static int flag=0;
ArrayList<PVector> vecList = new ArrayList<PVector>();

class BoxOverHand
{
  public BoxOverHand(PVector h, SimpleOpenNI k)
  {
     coord1=new PVector();
    coord2=new PVector();
    coord3=new PVector();
    coord4=new PVector(); 
    PVector com2d=new PVector();
    context=k;
    context.convertRealWorldToProjective(h,com2d);
    coord1.x=com2d.x-150;
    coord1.y=com2d.y-130;
    coord2.x=com2d.x+130;
    coord2.y=com2d.y-130;
    coord3.x=com2d.x-130;
    coord3.y=com2d.y+90;
    println("coords values stored");
    boxWidth=int(coord2.x-coord1.x);
    boxHeight=int(coord3.y-coord1.y);
    println("boxWidth "+boxWidth+" boxHeight "+boxHeight);
    //robot.mouseMove(mouseX,mouseY);
    
  }
  /**
  *The method just draws a red box around the hand 
  */
  void drawBox()
  {
    stroke(255, 0, 0);
    noFill();
    rect(coord1.x, coord1.y, boxWidth, boxHeight);
      
    
  }
  
  
}


class MouseMove
{
  int cursorX2;
  int cursorY2;
  public MouseMove(PVector h,SimpleOpenNI k)
  {
    
       try
       {
         robot = new Robot();
       }
       catch(Exception e)
       {
         println(e);
       }
       context=k;
       mouse1.x=mouse1.y=mouse1.z=0;
       mouse2=h; 
  }
  /**
  *The method moves the mouse with respect to the user's hand
  *@param h The user's hand position
  *@param userId The user's id created when user is detected by kinect camera
  */
  void mouseMove(PVector h, int userId)
  {
   a= MouseInfo.getPointerInfo().getLocation();
    PVector com2d = new PVector();               
    context.convertRealWorldToProjective(h,com2d);
    if(withinBox(com2d))
    {  
       h.x=200-h.x;
       mouse1.x=mouse2.x-h.x;
       mouse1.y=mouse2.y-h.y;
       mouse1.z=mouse2.z-h.z;
       println(mouse1);
       println(h.z);
       println(mouse2);
       mouse2=h;       
       cursorX=(int)(((double)displayWidth/boxWidth)*mouse1.x);
       cursorY=(int)(((double)displayHeight/boxHeight)*mouse1.y);
       float X = lerp(cursorX2, cursorX, 0.4f); 
     float Y = lerp(cursorY2, cursorY, 0.4f);
       if((mouse1.x<30 && mouse1.x>-30) || (mouse1.y<30 && mouse1.y>-30))
         {
           delay(60);   
           mouse1.x=mouse1.y=0;
         }    
         robot.mouseMove(a.x+(int)X,a.y+(int)Y);
         println(a.x+" "+a.y);
         cursorX2=cursorX;
         cursorY2=cursorY;

         Lhand=new PVector();
       Lhip=new PVector();     
       context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,Lhand);
       context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,Lhip);
       if(Lhand.y>Lhip.y-10)
       {
          
           robot.mousePress(InputEvent.BUTTON1_MASK);
           delay(1);
           robot.mouseRelease(InputEvent.BUTTON1_MASK);
           delay(1);
       }
         
       //}
    }
  } 
  /**
  *This method checks if hand is within the box
  *@param v The current position of user's hand
  *@return True if hand is within the box else False
  */
  
  boolean withinBox(PVector v)
  {
      if(coord1.x<v.x && coord2.x>v.x && coord1.y<v.y && coord3.y>v.y)
      {
          cursor(HAND);
          println("It is inside the box");
          return true;
      }
      else
      {
        cursor(CROSS);
        println("Not inside the box");    
        return false;
      }
  }
}
