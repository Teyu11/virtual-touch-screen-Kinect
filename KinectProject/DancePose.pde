import SimpleOpenNI.*;



class PoseRule
  { 
        int fromJoint;  
        int toJoint;  
        PVector fromJointVector;  
        PVector toJointVector;  
        SimpleOpenNI context;
        int jointRelation; 
        // one of:  
        static final int ABOVE     = 1;  
        static final int BELOW     = 2; 
        static final int LEFT_OF   = 3; 
        static final int RIGHT_OF  = 4;
 
        PoseRule(SimpleOpenNI tempContext, int tempFromJoint, int tempJointRelation, int tempToJoint) 
        {    
              context = tempContext; 
              fromJoint = tempFromJoint;   
              toJoint = tempToJoint;    
              jointRelation = tempJointRelation;
              fromJointVector = new PVector(); 
              toJointVector = new PVector();  
        }
        
        /**
        *This method check if user is in a pose or not
        *@param userID The user's id
        *@return True if user is correctly in the pose or False
        */
        boolean check(int userID)
        { 
              // populate the joint vectors for the user we're checking   
              context.getJointPositionSkeleton(userID, fromJoint, fromJointVector);
              context.getJointPositionSkeleton(userID, toJoint, toJointVector);
              boolean result= false;
              switch(jointRelation)
              { 
                    case ABOVE:      
                      result = (fromJointVector.y > toJointVector.y);    
                      break;     
                    case BELOW:  
                      result = (fromJointVector.y < toJointVector.y);    
                      break;     
                    case LEFT_OF:       
                      result = (fromJointVector.x < toJointVector.x);     
                      break;    
                    case RIGHT_OF:      
                      result = (fromJointVector.x > toJointVector.x);    
                      break;   
              }    
             return result; 
       } 
 }
 
class SkeletonPoser 
  { 
        SimpleOpenNI context;  
        ArrayList rules;
        
        SkeletonPoser(SimpleOpenNI context)
        { 
            this.context = context;    
            rules = new ArrayList();
        }
        
        void addRule(int fromJoint, int jointRelation, int toJoint){ 
            PoseRule rule = new PoseRule(context, fromJoint, jointRelation, toJoint);    
            rules.add(rule);  
        }
        
      
        
        boolean check(int userID){ 
            boolean result = true; 
            for(int i = 0; i < rules.size(); i++){
              PoseRule rule = (PoseRule)rules.get(i); 
              result = result && rule.check(userID); 
            }   
            return result; 
        }
    
  }
