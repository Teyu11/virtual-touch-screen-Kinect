import SimpleOpenNI.*;
import java.awt.*;
import java.awt.event.*;

class Touch
{
    SimpleOpenNI kinect;
    Robot bot;
    int flagofTouch=-1, flagForDrag=0;
    int rightWithinScreen=0, leftWithinScreen=0;
    int cursorX, prevX=0, cursorXofClick=0;
    int cursorY, prevY=0, cursorYofClick=0;
    int handWidth, handHeight;
    int time=0, timeFordrag=0;
    PImage userImage=new PImage();
    PVector p2d=new PVector();
    PVector p2dr=new PVector();
    PVector p2dl=new PVector();
    PVector p1=new PVector();
    PVector p2=new PVector();
    PVector p3 = new PVector();
   boolean handInside;
    float x,y;
    color usrclr=color(0,0,255);
    public Touch(SimpleOpenNI k)
    {
      kinect=k;
      kinect.enableRGB();
      kinect.enableDepth();
     //   kinect.enableUser();
      kinect.setMirror(true);
      try
      {
        bot = new Robot();
      }
      catch(Exception e)
      {
         println(e);
      }
      println(displayWidth+" "+displayHeight);
      handInside=false;
      smooth();
    }
    
    /**
    *This method performs operations like right-click, drag, left-click when any hand is touches the screen
    *For right-click, touch for a long time like 2 seconds
    *For left-click, short touch
    *For drag, short touch an icon to drag and long press at the same location 
    *@param userId The user's id
    */
    void drawTouch( int userId)
    {      
          
           handInside=false;
          // image(kinect.userImage(),0,0);
           image(kinect.depthImage(),0,0);

         //  userImage=kinect.userImage();
           stroke(usrclr);
          //println("Px "+p2d.x+" Py "+p2d.y);
          PVector Rhand = new PVector();
          kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
          PVector Lhand = new PVector();
          kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,Lhand);
          kinect.convertRealWorldToProjective(Rhand,p2dr);
          kinect.convertRealWorldToProjective(Lhand,p2dl);
          //Check which hand is close to screen and draw box around it
          if(withinCapturedScreen((int)p2dr.x, (int)p2dr.y))
          {
               drawBox(p2dr);
               if(rightWithinScreen==0)
               {  //println("Right hand inside");
               rightWithinScreen=1;
               leftWithinScreen=0;
             }
          }
          if(withinCapturedScreen((int)p2dl.x, (int)p2dl.y))
          {
               drawBox(p2dl);
               if(leftWithinScreen==0){
              // println("Left hand inside");
               leftWithinScreen=1;
               rightWithinScreen=0;
               }

          }
          if(handInside)
          {  
              float tempX,tempY;
              PVector max=maxDepth();
              tempX=x;
              tempY=y;
              //println("Max Depth "+max);
              x=max.x-point1[0];
              y=max.y-point1[1];
              //fill(255,0,0);
              //ellipse(max.x, max.y, 10, 10);
              if((x<30 && x>-30) || (y<30 && y>-30))
              {
                x=tempX;
                y=tempY;
              }
              cursorX=displayWidth-(int)(((double)displayWidth/kinectWidth)*x);
              cursorY=(int)(((double)displayHeight/kinectHeight)*y);
             // println("X'= "+cursorX+" Y'= "+cursorY);
             
               
               if(compare(size, max.z)>0 ) 
               {
                  flagofTouch=0;
                  
                    //Drag Condition
                    if(diff(prevX,cursorX)>0 && diff(prevX ,cursorX)<500 && diff(prevY,cursorY)>0 && diff(prevY ,cursorY)<500)
                    {
                      time++;
                     // println("TIME "+time);
                      if(time==5)
                      {
                        /*  flagofTouch=-1;
                          if((diff(cursorXofClick,cursorX)>75 && diff(cursorXofClick ,cursorX)<500) && (diff(cursorYofClick,cursorY)>75 && diff(cursorYofClick ,cursorY)<500) && flagForDrag==0)
                            {
                              flagForDrag=1;
                              flagofTouch=0;
                            }
                          else if(flagofTouch==-1)
                            */  flagofTouch=1;
                         // println(flagofTouch);
                      }
                     
                      else                     

                      {
                          prevX=cursorX;
                          prevY=cursorY;
                      }
                    }
               }
               
               //Enabling drag
               if(flagForDrag==1 &&  flagofTouch==0)
               {
                 
                 if(compare(size, max.z)>0){
                   println("Dragging");
                 bot.mouseMove(cursorXofClick, cursorYofClick);
                 bot.mousePress(InputEvent.BUTTON1_MASK);
                 cursorXofClick=cursorX;
                 cursorYofClick=cursorY;
                 }
                 else if(compare(size, max.z)<0){
                   println("Releasing");
                   bot.mouseRelease(InputEvent.BUTTON1_MASK);
                   flagForDrag=0;
                   flagofTouch=-1;
                   time=0;
                 }
                 
               }
               
               //Enabling left-click
               if(compare(size, max.z)>0 && flagofTouch==0)// && flagForDrag==0)
               {  
                   cursorXofClick=cursorX;
                   cursorYofClick=cursorY;
                   println("Clicking");
                    bot.mouseMove(cursorX,cursorY);
                    bot.mousePress(InputEvent.BUTTON1_MASK);
                    delay(300);
                    bot.mouseRelease(InputEvent.BUTTON1_MASK);
                    delay(300);
                    //time=0;
                    flagofTouch=-1;
               }
             /* else if(compare(size, max.z)<0){// && flagForDrag==0)
                   bot.mouseRelease(InputEvent.BUTTON1_MASK);
                   delay(300);
                   flagofTouch=-1;
                 
           }*/
               //Enabling right-click
               if(flagofTouch==1)
               {
                     bot.mouseMove(cursorX,cursorY);
                     println("Right click");
                    bot.mousePress(InputEvent.BUTTON3_MASK);
                    delay(50);
                    bot.mouseRelease(InputEvent.BUTTON3_MASK);
                    time=0;
                    
                    flagofTouch=-1;
                    delay(1000);
               }
                   
                      
              }
          
              //bot.mouseMove(cursorX,cursorY);
             // bot.mouseRelease(InputEvent.BUTTON1_MASK);
              //delay(100);
          
    }
    
    /**
    *This method returns the difference between two numbers
    *@param p The first number
    *@param c The second number
    *@return The difference
    */
      int diff(int p, int c){
        if(p<c)
        return c-p;
        else
        return p-c;
      }
      
     /**
     *This method draws box around a given point
     *@param p The position of hand closest to the screen
     */
     
    void drawBox(PVector p)
    {
     
      if(p.x-30<point1[0])
      {
         p1.x=p3.x=point1[0]; 
                   
      }
     else 
       p1.x=p3.x=p.x-30;
     
     if(p.x+30>point2[0])
     {
       p2.x=point2[0];
     }
     else 
     p2.x=p.x+30;
     
     if(p.y-50<point1[1])
     {
       p1.y=p2.y=point1[1];
     }
     else p1.y=p2.y=p.y-50;
     
     if(p.y+20>point3[1])
     {
       p3.y=point3[1];
     }
     else p3.y=p.y+20;
     
     handWidth=(int)(p2.x-p1.x);
     handHeight=(int)(p3.y-p1.y);
     stroke(255);
     noFill();
     rect(p1.x, p1.y, handWidth, handHeight);
     
   }
   
   /**
   *This method calculates the position of hand that is closest to the screen
   *@return PVector of the closest position of hand
   */
    PVector maxDepth()
    {
      int []depMap=kinect.depthMap();
      int max=0;
      PVector result=new PVector();
      for(int i=(int)p1.x;i<=(int)p2.x;i++)
      for(int j=(int)p1.y;j<=(int)p3.y;j++)
       //if(get(i,j)==color(0,0,255))
        {
           // println("color red="+red(get(i,j))+" green "+green(get(i,j))+" blue "+blue(get(i,j)));
            int index=i+j*640;
            if(depMap[index]>max && !isDepthOfScreen(depMap[index]))
            {
                max=depMap[index];
                result.x=i;
                result.y=j;
                result.z=max;
            }
        }
        
        return result;
    }
    
    /**
    *This method checks if a given depth value is the depth of the screen
    *@param dep The depth to check against the screen
    *@return True if depth value is the depth of the screen else False
    */
    boolean isDepthOfScreen(int dep){
      for(int i=0;i<size;i++){
        if(dep==depthMap[i])
          return true;
      }
      return false;
    }
    
    /**
    *This method checks if a point is within the screen
    *@param x The x coordinate
    *@param y The y coordinate
    *@return True if the point is within the screen else False
    */
    boolean withinCapturedScreen(int x, int y)
    {
        if(x>=point1[0] && x<=point2[0] && y>=point1[1] && y<=point3[1])
        {
          
            // println("Inside the captured screen");
           handInside=handInside || true;
         
           return true;
        }   
        else
        {
         
         // println("Not inside the captured screen"); 
          return false;
        }
        
    }
    
    /**
    *This method compares the depth of hand and depth of screen
    *@param size The size of depthMap array
    *@param dOfhand The depth of hand
    *@return The difference between depths of hand and screen if the diff is between 18 and 0 else returns -1
    */
    float compare( int size, float dOfhand)
    {
        for(int i=0;i<size;i++)
        {
            float diff=depthMap[i]-dOfhand;
           // println("depthmap "+depthMap[i]+" dOfHand"+dOfhand);
            if(diff<=18 && diff >0){
            //  println(depthMap[i]+" "+dOfhand);
                return diff;
            }
        }
        
        return -1;
    }        

}
