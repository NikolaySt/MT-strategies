//-------------------------------------------------------------------------
//Намира "отрицателното" Отклонението (Bias) в даден интервал от Motion барове.
//-------------------------------------------------------------------------
void GetBiasHighLevel(int end_shift_motion, int begin_shift_motion, int &bias_shift_motion, double &bias_level){
   int i = begin_shift_motion; 
   int count = 1;    
   bool ch_exit = false;
   
   bias_level = MotionBarHigh(i); 
   while (i > end_shift_motion && !ch_exit){
      i--;
  
      if (MotionBarHigh(i) > bias_level){
         bias_level = MotionBarHigh(i);          
         bias_shift_motion = i;
         count++;
      }           
           
      if (count == 4) {
         ch_exit = true;
         bias_level = MotionBarHigh(i);          
         bias_shift_motion = i;        
      }
   }       
}

//-------------------------------------------------------------------------
//Намира "положителното" Отклонението (Bias) в даден интервал от Motion барове.
//-------------------------------------------------------------------------
void GetBiasLowLevel(int end_shift_motion, int begin_shift_motion, int &bias_shift_motion, double &bias_level){
   int i = begin_shift_motion; 
   int count = 1;    
   bool ch_exit = false;
   
   bias_level = MotionBarLow(i); 
   while (i > end_shift_motion && !ch_exit){
      i--;
  
      if (MotionBarLow(i) < bias_level){
         bias_level = MotionBarLow(i);          
         bias_shift_motion = i;
         count++;
      }           
           
      if (count == 4) {
         ch_exit = true;
         bias_level = MotionBarLow(i);          
         bias_shift_motion = i;        
      }
   }       
}

//-------------------------------------------------------------------------
//Намира Motion бара с най-ниския връх
//-------------------------------------------------------------------------
int GetShiftMotionLowestHigh(int end_shift_motion, int begin_shift_motion){
   int i = begin_shift_motion;       
   double level = MotionBarHigh(i); 
   int shift_motion = begin_shift_motion; 
   
   while (i >= end_shift_motion){
      i--;     
      if (MotionBarHigh(i) < level){
         shift_motion = i;    
         level = MotionBarHigh(i);
      }
   }      
   return(shift_motion);
}


//-------------------------------------------------------------------------
//Намира Motion бара с най-високо дъно
//-------------------------------------------------------------------------
int GetShiftMotionHighestLow(int end_shift_motion, int begin_shift_motion){
   int i = begin_shift_motion;       
   double level = MotionBarLow(i); 
   int shift_motion = begin_shift_motion; 
   
   while (i >= end_shift_motion){
      i--;     
      if (MotionBarLow(i) > level){
         shift_motion = i;    
         level = MotionBarLow(i);
      }
   }      
   return(shift_motion);
}


