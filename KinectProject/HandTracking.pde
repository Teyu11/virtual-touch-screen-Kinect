import java.util.Map;
import java.util.Iterator;
import fingertracker.*;
import SimpleOpenNI.*;

class HandTracking
{
    FingerTracker fingers;
    SimpleOpenNI context;
    int handVecListSize = 20;
    int threshold=1200;
    PImage contextDisplay=new PImage();
    int contextWidth;
    int contextHeight;
    int flag=0;
    int[] point1 = new int[2];
    int[] point2 = new int[2];
    int[] point3 = new int[2];
    Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
    color[]       userClr = new color[]{ color(255,0,0),
                                         color(0,255,0),
                                         color(0,0,255),
                                         color(255,255,0),
                                         color(255,0,255),
                                         color(0,255,255)
                                       };
    public HandTracking(SimpleOpenNI context)
    {  
       context = context;
       if(context.isInit() == false)
        {
           println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
           exit();
           return;  
        }   
      
        // enable depthMap generation 
        context.enableDepth();
        
        // disable mirror
        context.setMirror(true);
      
        // enable hands + gesture generation
        //context.enableGesture();
        context.enableHand();
        context.startGesture(SimpleOpenNI.GESTURE_WAVE);
        
        // set how smooth the hand capturing should be
        //context.setSmoothingHands(0.5);
         // initialize the FingerTracker object
        // with the height and width of the context
        // depth image
        fingers = new FingerTracker(KinectProject.this, 640, 480);
        // the "melt factor" smooths out the contour
        // making the finger tracking more robust
        // especially at short distances
        // farther away you may want a lower number
        fingers.setMeltFactor(100);
     }
     
    /**
    *This method tracks a user's hand, updates depthMap of kinect such that only the depthValues of hand is visible
    *The updated depthMap is passed as a parameter of fingertracker object
    *@param handPathList The array of user's hands
    */
    void track( Map<Integer,ArrayList<PVector>>  handPathList)
    {
        this.handPathList=handPathList; 
        // update the cam
        context.update();   
      
          
        // draw the tracked hands
        if(handPathList.size() > 0)  
        //this code is copied from the internet
        {   
            int depthMap[]=context.depthMap(); 
             
            Iterator itr = handPathList.entrySet().iterator();     
            while(itr.hasNext())
            {
                Map.Entry mapEntry = (Map.Entry)itr.next(); 
                int handId =  (Integer)mapEntry.getKey();
                ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
                PVector p;
                PVector p2d = new PVector();
                //this code is copied from the internet
                stroke(userClr[ (handId - 1) % userClr.length ]);
                noFill(); 
                strokeWeight(1);        
                Iterator itrVec = vecList.iterator(); 
               
                beginShape();
                while( itrVec.hasNext() ) 
                    { 
                        p = (PVector) itrVec.next(); 
                        
                        context.convertRealWorldToProjective(p,p2d);
                        vertex(p2d.x,p2d.y);
                    }
                endShape();   
            
                stroke(userClr[ (handId - 1) % userClr.length ]);
                strokeWeight(4);
                p = vecList.get(0);
                //this code is copied from the internet
                context.convertRealWorldToProjective(p,p2d);
                  
                  //this code is copied from the internet
                  
                point(p2d.x,p2d.y);
             //     println(p2d.x+" "+p2d.y);
                point1[0]=(int)(p2d.x-80);
                point1[1]=(int)(p2d.y-80);
                //this code is copied from the internet
                point2[0]=(int)(p2d.x+80);
                point2[1]=(int)(p2d.y-80);
                point3[0]=(int)(p2d.x-80);
                point3[1]=(int)(p2d.y+80);
                contextWidth= point2[0]-point1[0];
                contextHeight= point3[1]-point1[1];
                  //this code is copied from the internet
                contextDisplay=context.depthImage().get(point1[0], point1[1], contextWidth, contextHeight);
                contextDisplay.resize(640,480);
                  
                // image(contextDisplay,640,0);
                int m=0;
                int d=depthMap[(int)(p2d.x+p2d.y*640)];
                  
                //this code is copied from the internet
                for(int k=0;k<640;k++)
                for(int j=0;j<480;j++){
                  
                  if(!(j>point1[1] && j<point3[1] && k>point1[0] && k<point2[0])){
                  
                      depthMap[k+j*640]=0;
                      context.depthImage().pixels[k+j*640]=0;
                      
                    }
                }
                image(context.depthImage(),0,0);
                // println("M is" +m);
                //this code is copied from the internet 
                  
                println("Drawing hand contour");
                fingers.setThreshold(threshold);
                  
                // access the "depth map" from the context
                // this is an array of ints with the full-resolution
                // depth data (i.e. 500-2047 instead of 0-255)
                // pass that data to our FingerTracker 
                fingers.update(depthMap);
          
                // iterate over all the contours found
                // and display each of them with a green line
                stroke(0,255,0);
           
                for (int k = 0; k < fingers.getNumContours(); k++) {
                  fingers.drawContour(k);
                }
                //this code is copied from the internet
                // iterate over all the fingers found
                // and draw them as a red circle
                noStroke();
                fill(0,0,255);
                for (int i = 0; i < fingers.getNumFingers(); i++) {
                  PVector position = fingers.getFinger(i);
                  //this code is copied from the internet
                  ellipse(position.x - 5, position.y -5, 10, 10);
                }
                //this code is copied from the internet
                // show the threshold on the screen
                fill(255,0,0);
                text(threshold, 10, 20);
             
            }        
        }
    }
    /**
    *The methd returns number of fingers detected
    */
    int numOfFingers()
    {
        return fingers.getNumFingers();
    }
    
    int getHighestFinger()
    {
        int min_y=1000;
       
        for (int i = 0; i < fingers.getNumFingers(); i++) {
           PVector position = fingers.getFinger(i);
            //this code is copied from the internet
           if(position.y<min_y)
           {
               min_y=(int)position.y;             
           }
        }
        return min_y;
    }
    
    // -----------------------------------------------------------------
    // hand events
    
    /*void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
    {
      println("onNewHand - handId: " + handId + ", pos: " + pos);
      //this code is copied from the internet
     
      ArrayList<PVector> vecList = new ArrayList<PVector>();
      vecList.add(pos);
      
      handPathList.put(handId,vecList);
    }
    
    void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
    {
      println("onTrackedHand - handId: " + handId + ", pos: " + pos );
      //this code is copied from the internet
      ArrayList<PVector> vecList = handPathList.get(handId);
      if(vecList != null)
      {
        vecList.add(0,pos);
        if(vecList.size() >= handVecListSize)
          // remove the last point 
          vecList.remove(vecList.size()-1); 
          //this code is copied from the internet
      }  
      //if(vecList.get(0).x-vecList.get(vecList.size()-1).x>300)
      //display();
      
    }
    
    void onLostHand(SimpleOpenNI curContext,int handId)
    {
      //this code is copied from the internet
      println("onLostHand - handId: " + handId);
      handPathList.remove(handId);
    }
    
    // -----------------------------------------------------------------
    // gesture events
    
    void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
    {
      //this code is copied from the internet
      println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
      
      int handId = context.startTrackingHand(pos);
      println("hand stracked: " + handId);
    }
   
    
    // -----------------------------------------------------------------
    // Keyboard event
    void keyPressed()
    {
    
      switch(key)
      {
      case ' ':
        context.setMirror(!context.mirror());
        break;//this code is copied from the internet
      case '1':
        context.setMirror(true);
        break;
      case '2'://this code is copied from the internet
        context.setMirror(false);
        break;
      }
    }//this code is copied from the internet*/
}
