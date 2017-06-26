import SimpleOpenNI.*;
import java.util.Map;
import java.util.Iterator;
import java.awt.Robot;
import java.awt.event.*;
import java.awt.event.KeyEvent;
import processing.video.*;
// import and declarations for minim: 
import ddf.minim.*; 

class Dance
{
    Minim minim; 
    AudioPlayer player;
    // declare our poser object 
    SkeletonPoser pose; //play music
    SkeletonPoser pose1;//move mouse
    SkeletonPoser pose2;// zoom
    SkeletonPoser pose3;// swipe
    SkeletonPoser pose4;//KEYBOARD
     SkeletonPoser pose5;//ENTER
    SkeletonPoser reset;
    SimpleOpenNI  context;
    HandTracking Hand;
    int handVecListSize = 20;
    int time=0, flagOfKeyboard=0;
    Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
    color[]       userClr = new color[]{ color(255,0,0),
                                         color(0,255,0),
                                         color(0,0,255),
                                         color(255,255,0),
                                         color(255,0,255),
                                         color(0,255,255)
                                       };
    Robot robot;
    
    Movie myMovie;
    int diff1=0;
    PImage mouseCursor;
    int x = 0, y = 0,z=0;
    int prev=0;
    int xL, yL;
    PVector com = new PVector();                                   
    PVector com2d = new PVector();   
    PVector Lhand = new PVector();
    PVector Lshoulder = new PVector();
    PVector Lhip = new PVector();
    PVector Lelbow = new PVector();
    PVector Rhand = new PVector();
    PVector Relbow = new PVector();
    
    IntVector userList;
    ArrayList<PVector> vecList=new ArrayList<PVector>();
    ArrayList<PVector> vecList1=new ArrayList<PVector>();
    ArrayList<PVector> leftHd=new ArrayList<PVector>();
    ArrayList<PVector> rightHd=new ArrayList<PVector>();
    
    int size=0;
    int reference;
    int flag=0;
    int flagHand=0;
    MouseMove mouse;
    public Dance(SimpleOpenNI kinect)
    { 
        context=kinect;
        context.enableDepth(); 
        context.enableUser();
        Hand=new HandTracking(context);
          
       // context.setMirror(true);
        // initialize the minim object  
        minim = new Minim(KinectProject.this);
        // and load the stayin alive mp3 file 
        player = minim.loadFile("C:\\Users\\SHREYA\\Desktop\\KinectProject\\staying_alive.mp3");
        
        try 
        {
            robot = new Robot();
        } 
        catch (Exception e) 
        {
            println("Can't Initialize the Robot");
        }
        // enable hands + gesture generation
        //context.enableGesture();
        context.enableHand();
        context.startGesture(SimpleOpenNI.GESTURE_WAVE);
               
        vecList=new ArrayList<PVector>();
        
        // initialize the pose object  
        pose = new SkeletonPoser(context); 
        pose1 = new SkeletonPoser(context);
        pose2 = new SkeletonPoser(context);
        pose3 = new SkeletonPoser(context);
        pose4 = new SkeletonPoser(context);
        pose5 = new SkeletonPoser(context);
        reset = new SkeletonPoser(context);
        // rules for the right arm 
        
        pose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_ELBOW);  
        pose.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, PoseRule.RIGHT_OF,  SimpleOpenNI.SKEL_RIGHT_ELBOW);  
        pose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_SHOULDER);  
        pose.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, PoseRule.RIGHT_OF, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
        // rules for the left arm  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, PoseRule.ABOVE,  SimpleOpenNI.SKEL_LEFT_SHOULDER);  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, PoseRule.LEFT_OF, SimpleOpenNI.SKEL_LEFT_SHOULDER);  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_HAND,  PoseRule.LEFT_OF,   SimpleOpenNI.SKEL_LEFT_ELBOW);  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_HAND,  PoseRule.ABOVE,   SimpleOpenNI.SKEL_LEFT_ELBOW);
        // rules for the right leg 
        /*  pose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE,   PoseRule.BELOW, SimpleOpenNI.SKEL_RIGHT_HIP);
           pose.addRule(SimpleOpenNI.SKEL_RIGHT_KNEE,     PoseRule.RIGHT_OF,     SimpleOpenNI.SKEL_RIGHT_HIP);
          // rules for the left leg  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, PoseRule.BELOW,   SimpleOpenNI.SKEL_LEFT_HIP);  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_KNEE, PoseRule.LEFT_OF,  SimpleOpenNI.SKEL_LEFT_HIP);  
        pose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT, PoseRule.BELOW, SimpleOpenNI.SKEL_LEFT_KNEE); 
        pose.addRule(SimpleOpenNI.SKEL_LEFT_FOOT,               PoseRule.LEFT_OF,               SimpleOpenNI.SKEL_LEFT_KNEE);  */
        
        pose1.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_SHOULDER-30); 
        pose1.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.BELOW, SimpleOpenNI.SKEL_LEFT_SHOULDER);  
       
        pose2.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_HIP); 
        pose2.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.BELOW,  SimpleOpenNI.SKEL_RIGHT_SHOULDER); 
        pose2.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.ABOVE, SimpleOpenNI.SKEL_LEFT_SHOULDER);  
        pose2.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, PoseRule.ABOVE, SimpleOpenNI.SKEL_LEFT_SHOULDER);  
      
       
        pose3.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.BELOW,  SimpleOpenNI.SKEL_RIGHT_HIP); 
        pose3.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.ABOVE, SimpleOpenNI.SKEL_LEFT_SHOULDER); 
       
        pose4.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_ELBOW);  
        pose4.addRule(SimpleOpenNI.SKEL_RIGHT_HAND, PoseRule.RIGHT_OF,  SimpleOpenNI.SKEL_RIGHT_ELBOW);  
        pose4.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, PoseRule.BELOW,  SimpleOpenNI.SKEL_RIGHT_SHOULDER);  
        pose4.addRule(SimpleOpenNI.SKEL_RIGHT_ELBOW, PoseRule.RIGHT_OF, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
        // rules for the left arm  
        pose4.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, PoseRule.BELOW,  SimpleOpenNI.SKEL_LEFT_SHOULDER);  
        pose4.addRule(SimpleOpenNI.SKEL_LEFT_ELBOW, PoseRule.LEFT_OF, SimpleOpenNI.SKEL_LEFT_SHOULDER);  
        pose4.addRule(SimpleOpenNI.SKEL_LEFT_HAND,  PoseRule.LEFT_OF,   SimpleOpenNI.SKEL_LEFT_ELBOW);  
        pose4.addRule(SimpleOpenNI.SKEL_LEFT_HAND,  PoseRule.ABOVE,   SimpleOpenNI.SKEL_LEFT_SHOULDER);

        pose5.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_HIP);
       pose5.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.BELOW,  SimpleOpenNI.SKEL_RIGHT_SHOULDER-30); 
        pose5.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.BELOW, SimpleOpenNI.SKEL_LEFT_SHOULDER); 
        pose5.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.ABOVE, SimpleOpenNI.SKEL_LEFT_HIP); 
        pose5.addRule(SimpleOpenNI.SKEL_LEFT_HAND, PoseRule.RIGHT_OF, SimpleOpenNI.SKEL_LEFT_SHOULDER); 
        
        
        reset.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.BELOW,  SimpleOpenNI.SKEL_RIGHT_HIP); 
        reset.addRule(SimpleOpenNI.SKEL_LEFT_HAND,  PoseRule.BELOW,  SimpleOpenNI.SKEL_LEFT_HIP); 

        strokeWeight(5); 
    }
    /**
    *This method checks if user is in any of the given poses and performs their respective operations on a computer screen 
    */
    void drawDance()
    { 
      background(0); 
      context.update();
      // Hand.track();  
      image(context.depthImage(), 0, 0);
      userList = new IntVector(); 
      context.getUsers(userList); 
      if (userList.size() > 0) 
      {
          int userId = userList.get(0);    
          if( context.isTrackingSkeleton(userId)) 
          {
              // check to see if the user    
              // is in the pose   
              if(reset.check(userId)){
                flagHand=0;
                flagOfKeyboard=0;
              }
              //If pose4 is true for some time only then open the virtual keyboard
              //else check for pose given for music
             /* else if(pose4.check(userId))
              {
               
              // time++;
               if(flagOfKeyboard==0){
                 println("TIME FOR KEYBOARD OPENING "+time);
                 open("C:\\Program Files (x86)\\FreeVK\\FreeVK.exe");
                 flagOfKeyboard=1;
                 time=0;
                 delay(1500);
               }
               else if(flagOfKeyboard==1){
                 println("TIME FOR KEYBOARD CLOSING "+time);
               /* robot.keyPress(KeyEvent.VK_ALT);
                robot.keyPress(KeyEvent.VK_F4);
                robot.keyRelease(KeyEvent.VK_F4);
                robot.keyRelease(KeyEvent.VK_ALT);*/
                 /*flagOfKeyboard=0;
                 time=0;
                 delay(1500);
               }
                
              }*/  
              else if(!player.isPlaying() && pose.check(userId))
              { 
                 //if they are, set the color white      
                 stroke(255);
                 // and start the song playing   
//println("Playing");
                 if(!player.isPlaying()) 
                 {       
                     player.play(); 
                     delay(1500);       
                 }
               }
               else if(player.isPlaying() && pose.check(userId))
               {
                   stroke(255);
                   player.pause();
                   delay(1500);
               }
               else if(pose1.check(userId))
               {
                   // Hand.track(handPathList);
                    //int f=Hand.numOfFingers();
                    println("flaghand "+flagHand);
                   //If box has not been drawn over the hand, call drawBox() of BoxOverHand class
                   //else call mouseMove() method of MouseMove class
                    if(flagHand==0)
                    {
                          Rhand=new PVector();
                          //println("Object of rhand created");
                          context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
                        //  println("rhand position stored");
                          Rhand.y+=30;
                          mouse=new MouseMove(Rhand, context);
                          BoxOverHand box=new BoxOverHand(Rhand, context);
                          box.drawBox();
                          //println("mousemove object created");
                          flagHand=1;
                         // println("flagHand=1");
                          
                        //  pose1.removeRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_SHOULDER); 
                        //  pose1.addRule(SimpleOpenNI.SKEL_RIGHT_HAND,  PoseRule.ABOVE,  SimpleOpenNI.SKEL_RIGHT_HIP); 
                          
                    }
                    
                    else if(flagHand==1){
                          Rhand=new PVector();
                         // println("Object of rhand created");
                          context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
                          //println("rhand position stored");
                          mouse.mouseMove(Rhand, userId);
                          
                      
                    }
                    /*if(f>=4)
                    {  
                        if(handPathList.size() > 0)  
                        {    
                            Iterator itr = handPathList.entrySet().iterator();     
                            while(itr.hasNext())
                            {
                                Map.Entry mapEntry = (Map.Entry)itr.next(); 
                                int handId =  (Integer)mapEntry.getKey();
                                ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
                                PVector p;
                                PVector p2d = new PVector();
                                     
                                p = vecList.get(0);
                                
                                
                                x=(int)p.x%width*3 ;
                                y=(int)p.y%height*3;
                                z=(int)p.z%3;
                                
                                robot.mouseMove(x, -y);
                                
                             }       
                          }       
                          context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,Lhand                       context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDE,Lshoulder);
                          context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,Lhip);
                      
                          xL=(int)Lhand.x*2;
                          yL=(int)Lhand.y*2;
                   
                          //if left hand is up, press mouse
                          if(Lhand.y>Lhip.y && Lhand.y<Lshoulder.y )
                          {
                             // println("Left hand up");
                              robot.mousePress(InputEvent.BUTTON1_MASK);
                              delay(1);
                              robot.mouseRelease(InputEvent.BUTTON1_MASK);
                              delay(5);
                           }
                      
                    }
                     
                    if(f<4)
                    {
                         Rhand = new PVector();
                         context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
                         println("Scrolling");
                          scroll(Rhand);                        
                    }*/
                
              } 
              else if(pose3.check(userId))
              {
                   //println("swiping");
                   Lhand = new PVector();
                   Rhand = new PVector();
                   Lelbow = new PVector();
                   Relbow = new PVector();
                   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,Lhand);
                   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
                   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,Lelbow);
                   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,Relbow);
                   if(Lhand.y>Lelbow.y)
                   {                    
                      gesture(context,userId, Lhand, (int)Lelbow.x);
                      noLoop();
                   }
                  loop();
              }
              else if(pose2.check(userId))
              {
                   Rhand = new PVector();
                   Lelbow = new PVector();
                   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,Lelbow);
                   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,Rhand);
                   zoom(Rhand, Lelbow);
              } 
              else if(pose5.check(userId)){
                  robot.keyPress(KeyEvent.VK_ENTER);
                  robot.keyRelease(KeyEvent.VK_ENTER);
              }            
              else  
              {         
                   // otherwise set the color to red       
                   // and don’t start the song         
                   stroke(255,0,0); 
              }
               // draw the skeleton in whatever color we chose   
             drawSkeleton(userId); 
          } 
       }
     }
     
    void drawSkeleton(int userId) 
    {  
        context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD,  SimpleOpenNI.SKEL_NECK); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_NECK,  SimpleOpenNI.SKEL_LEFT_SHOULDER);
          
        context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);  
        context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER,  SimpleOpenNI.SKEL_TORSO); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
        context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO,  SimpleOpenNI.SKEL_LEFT_HIP);  
      //  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);  
      //  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);  
        context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP); 
      //  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
      //  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT); 
        context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
    }
    
    void drawLimb(int userId, int jointType1, int jointType2) 
    {  
        PVector jointPos1 = new PVector();  
        PVector jointPos2 = new PVector();  
        float  confidence;
        // draw the joint position 
        confidence = context.getJointPositionSkeleton(userId, jointType1, jointPos1); 
        confidence = context.getJointPositionSkeleton(userId, jointType2, jointPos2);
        line(jointPos1.x, jointPos1.y, jointPos1.z,  jointPos2.x, jointPos2.y, jointPos2.z);
    }
    /**
    *This method performs zoom operation by using the difference of hand positions over time as the scale factor for zooming
    *@param r The position of right hand
    *@param elb The position of right elbow 
    */
    void zoom(PVector r, PVector elb)
    {
         vecList1.add(0,r);
         float scale=vecList1.get(0).x-vecList1.get(vecList1.size()-1).x;
         if(vecList1.size()>2)
         {
             if(scale>0)
             {
                 // println("right satisfied");
                 zoomout(scale);
             }
             else if (scale<0 )
             {
                 //println("left satisfied");
                 zoomin(scale);
             }
          }
    } 
    /**
    *@param s The positive scale factor
    */
    void zoomout(float s)
    {    
        for(int i=vecList1.size()-1; i>=0;--i)
        {
            PVector part= vecList1.get(i);
            
            vecList1.remove(i);
            
        }
        robot.keyPress(KeyEvent.VK_CONTROL);
        robot.mouseWheel((int)s*10);
        robot.keyRelease(KeyEvent.VK_CONTROL);
    }
    /**
    *@param s The negative scale factor
    */
    void zoomin(float s)
    {
        for(int i=vecList1.size()-1; i>=0;--i)
        {
            PVector part= vecList1.get(i);
            
            vecList1.remove(i);
        
        }
        robot.keyPress(KeyEvent.VK_CONTROL);
        robot.mouseWheel((int)s*10);
        robot.keyRelease(KeyEvent.VK_CONTROL);
     }
     /**
    *This method performs scroll operation by using the difference of hand positions over time as the scale factor for scrolling
    *@param r The position of right hand
    */
     void scroll(PVector r)
     {              
         vecList1.add(0,r);
         println(vecList1);
         float scale=vecList1.get(0).y-vecList1.get(vecList1.size()-1).y;
         println("Scroll called "+scale);            
         if(scale>0)
         {
             // println("right satisfied");
            scrollUp((int)scale);
         }
         else if (scale<0 )
         {
            //println("left satisfied");
            scrollDown((int)scale);
         }
         
        
     }
      /**
      *@param scale The positive scale factor
      */
      void scrollUp(int scale){
         for(int i=vecList1.size()-1; i>=0;--i){
        PVector part= vecList1.get(i);
        
          vecList1.remove(i);
        
      }
        println("Scroll up");
        robot.mouseWheel(scale*10);
      }
      /**
      *@param scale The negative scale factor
      */
      void scrollDown(int scale){
        for(int i=vecList1.size()-1; i>=0;--i){
        PVector part= vecList1.get(i);
        
          vecList1.remove(i);
        
      }
        println("Scroll down");
        robot.mouseWheel(scale*10);
      }
      
    /**
    *This method performs the swipe left or right operations using the difference of hand positions over time to determine if left or right swipe
    *If the difference is positive right swipe is done else left swipe is done
    *@param curContext The kinect camera object
    *@param handId The user's id
    *@param pos The position of right hand
    *@param elb The position of right elbow
    */  
    void gesture(SimpleOpenNI curContext,int handId,PVector pos, int elb)
    {
      //println("called") ;
        vecList1.add(0,pos);
        size++;
        if(vecList1.size()>2){
         // println("large size");
         // println(vecList1);
      if((vecList1.get(0).x-vecList1.get(vecList1.size()-1).x)>300 && vecList1.get(0).x-elb>150){
       // println("right satisfied");
      right();
      }
        
       else if ((vecList1.get(0).x-vecList1.get(vecList1.size()-1).x)<-300 && vecList1.get(0).x-elb<-150){
         //println("left satisfied");
      left();
       }
        }
        //else
       // println("not satisfied");
    }
      
    /**
    *This method performs right swipe function
    */
    void right(){
      println("Moved right");
      // println(vecList);
      for(int i=vecList1.size()-1; i>=0;--i){
        PVector part= vecList1.get(i);
        
          vecList1.remove(i);
        
      }
      robot.keyPress(KeyEvent.VK_RIGHT);
      robot.keyRelease(KeyEvent.VK_RIGHT);
      delay(1000);
     // println(vecList);
      
    }
    /**
    *This method performs left swipe function
    */
    void left(){
      println("Moved left");
       for(int i=vecList1.size()-1; i>=0;--i){
        PVector part= vecList1.get(i);
        
          vecList1.remove(i);
        
      }
      robot.keyPress(KeyEvent.VK_LEFT);
      robot.keyRelease(KeyEvent.VK_RIGHT);
      delay(1000);
    }
    
    void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
    {
      println("onNewHand - handId: " + handId + ", pos: " + pos);
     
      ArrayList<PVector> vecList = new ArrayList<PVector>();
      vecList.add(pos);
      
      handPathList.put(handId,vecList);
    }
    
    void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
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
     
      
    }
    
    void onLostHand(SimpleOpenNI curContext,int handId)
    {
      println("onLostHand - handId: " + handId);
      handPathList.remove(handId);
    }
    
    // -----------------------------------------------------------------
    // gesture events
    
    void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
    {
      println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
      
      int handId = context.startTrackingHand(pos);
      println("hand stracked: " + handId);
    }
    void movieEvent(Movie m) {
      m.read();
    }
    
    
    // -----------------------------------------------------------------
    // Keyboard event
    void keyPressed()
    {
    
      switch(key)
      {
      case ' ':
        context.setMirror(!context.mirror());
        break;
      case '1':
        context.setMirror(true);
        break;
      case '2':
        context.setMirror(false);
        break;
      }
    }
    
    
    
    
    
    // -----------------------------------------------------------------
    // SimpleOpenNI events
    
    void onNewUser(SimpleOpenNI curContext, int userId)
    {
      println("onNewUser - userId: " + userId);
      println("\tstart tracking skeleton");
      if(userId==1)
      curContext.startTrackingSkeleton(userId);
    }
    
    void onLostUser(SimpleOpenNI curContext, int userId)
    {
      println("onLostUser - userId: " + userId);
      
      
    }
    
    void onVisibleUser(SimpleOpenNI curContext, int userId)
    {
      //println("onVisibleUser - userId: " + userId);
    }


}
