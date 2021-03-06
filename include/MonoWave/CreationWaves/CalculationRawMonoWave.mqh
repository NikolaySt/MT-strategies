
bool CalcPostionBeginEndPeriod(int time_period, int shift, int up_shift, int& p1, int& p2){
   switch (time_period){
      case PERIOD_SIXFOLD: PositionSixfold(shift, p1, p2); break;                            
      case PERIOD_TWOFOLD: Position“wofold(shift, p1, p2); break;
      case PERIOD_288: {
           Position288minutes(shift, p1, p2);
           p1 = check_begin_position(p1, time_period); 
           break;
         }
      default:{
         PositioDayWeekMonth(shift, up_shift, time_period, p1, p2);                          
         p1 = check_begin_position(p1, time_period); 
         break;            
      }                                                                                
   } 
   return(true);
}   
         
int GetShiftPosition_Period(int shift, int period){ 
   int time_shift = 0;
   
   if (period == PERIOD_SIXFOLD){
      time_shift = GetSixfold(shift);                     
      //time_shift = GetSixfold_Year(shift);
      
   }else{      
      if (period == PERIOD_TWOFOLD){
         time_shift = GetTwofold(shift);
      }else{   
         if (period == PERIOD_288){
            time_shift = Get288Minutes(shift);                             
         }else{
            time_shift = iBarShift(NULL, period, Time[shift]);
         }
      }
   }
   return(time_shift);
}    



int PositioDayWeekMonth(int shift, int shift_period, int period, int& p1, int& p2){
   if (shift != 0){   
        
       //old version    
      //datetime time_p2 = iTime(NULL, period, shift_period);
      //datetime time_p1 = iTime(NULL, period, shift_period+1);
      
      //new 01.03.2007
      datetime time_p2 = iTime(NULL, period, shift_period-1);
      datetime time_p1 = iTime(NULL, period, shift_period);      
      //Debug--
      //if (shift == 0){
      //   Print("s= ", shift," : time_p2 = ", TimeToStr(time_p2), " : time_p1 = ", TimeToStr(time_p1));
      // }
      //----------
      
      switch (period){
         case PERIOD_MN1: {
            if (TimeMonth(time_p2) == TimeMonth(time_p1)){
               time_p1 = iTime(NULL, period, shift_period+2);
            }
            break;
         }      
         case PERIOD_D1: {
            if (TimeDay(time_p2) == TimeDay(time_p1)){
               time_p1 = iTime(NULL, period, shift_period+2);
            }
            break;
         }  
      }                        
                  
      if (period == PERIOD_MN1){
         p2 = iBarShift(NULL, Period(), time_p2);            
         p1 = iBarShift(NULL, Period(), time_p1);
         if (TimeMonth(Time[p2]) != TimeMonth(Time[p1])){            
            p2 = p2 + 1;
         }
      }else{
         if (period == PERIOD_W1){
            p2 = iBarShift(NULL, Period(), time_p2)+1;            
            p1 = iBarShift(NULL, Period(), time_p1);  
            if (TimeDayOfWeek(Time[p2]) <= TimeDayOfWeek(Time[p2])){
               p2 = p2 - 1;
            }
         }else{
            p2 = iBarShift(NULL, Period(), time_p2)+1;            
            p1 = iBarShift(NULL, Period(), time_p1);         
         }
      }    
      
   }else{
      p2 = 0;
      p1 = iBarShift(NULL, Period(), iTime(NULL, period, shift_period));                     
   }
}

int PositionSixfold(int shift, int& p1, int& p2){
   Get_Position_Sixfold(shift);
   //Get_Position_Sixfold_Year(shift);
   p1 = begin_sixfold;
   if (shift != 0){                      
      p2 = end_sixfold;            
   }else{
      p2 = 0;                  
   }    
}

int Position“wofold(int shift, int& p1, int& p2){
   Get_Position_“wofold(shift);
   p1 = begin_twofold;      
   if (shift != 0){                
      p2 = end_twofold;            
   }else{
      p2 = 0;                  
   }  
}   

int Position288minutes(int shift, int& p1, int& p2){
   Get_Position_288_minutes(shift);
   p1 = begin_minutes_288;
   if (shift != 0){                
      p2 = end_minutes_288+1;            
   }else{
      p2 = 0;                  
   }
}   

int PositionCustomTime(int shift, int period_down, int period_up, int& p1, int& p2){
   p1 = iBarShift(NULL, period_down, iTime(NULL, period_up, shift))+1;
   if (shift != 0){
      p2 = iBarShift(NULL, period_down, iTime(NULL, period_up, shift-1));    
   }else{
      p2 = 0;
   }
}

int PositionUpTimeMonoWave(int shift, int shift_period, int period, int& p1, int& p2){
   if (period == PERIOD_SIXFOLD){
      PositionSixfold(shift, p1, p2);   
   }else{
      if (period == PERIOD_TWOFOLD){ 
         Position“wofold(shift, p1, p2);   
      }else{
         if (shift == 0){ 
            p2 = 0;
         }else{ 
            p2 = iBarShift(NULL, Period(), iTime(NULL, period, shift_period))+1;  
         }
         p1 = iBarShift(NULL, Period(), iTime(NULL, period, shift_period+1));                     
      }         
   }  
} 

void PositionExtremum(int p1, int p2, int period, int& low_shift, int& high_shift){
   low_shift = iLowest(NULL, period, MODE_LOW, p1 - p2+1, p2); 
   high_shift = iHighest(NULL, period, MODE_HIGH, p1 - p2+1, p2); 
}

void PriceExtremum(int low_shift, int high_shift, int period, double& low_value, double& high_value){

   low_value = iLow(NULL, period, low_shift);
   high_value = iHigh(NULL, period, high_shift); 
}