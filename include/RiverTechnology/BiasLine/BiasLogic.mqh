//+------------------------------------------------------------------+
//|   Пресмята и изчертава отклонението BIAS
//+------------------------------------------------------------------+
#include <RiverTechnology\BiasLine\BiasParametars.mqh>
#include <RiverTechnology\BiasLine\BiasUtils.mqh>


void CalcBias(int shift, double high, double low, int zone){
   //zone : +1 възходящо движение на motionline
   //zone : -1 низходящо движение на motionline     
   
   AddMotionBarToArray(shift, high, low);  
   
   if (bias_direction == 0){
      bias_direction = 1;
      bias_level = low; 
   }
 
   if (bias_direction == 1){
      if (low < bias_level){         
         BreakDownBias(shift);                      
      }else{         
         CalcContinueDownBias(shift);      
      }       
   }else{  
      if (bias_direction == -1){
         if (high > bias_level){          
            BreakUpBias(shift);            
         }else{
            CalcContinueUpBias(shift);
         } 
      }
   }   
   BiasProcess(shift, high, low);   
}

void BreakDownBias(int curr_bar_shift){ 
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);   

   //записва началото на последния активен биас който е пробит
   //началото на бара     
   // Ползва се при намиране на текущия Биас, 4-ри бара назад или еьтремум ако няма 4-ри
   save_fisrt_bias_shift = bias_shift; 
          
   GetBiasHighLevel(bias_shift, MotionBarFirst(), bias_shift, bias_level);
   
   //Записва Motion бара който е проби Биаса
   //Ползва се при намиране на Най ниския/Високия бар
   break_bias_shift = MotionBarFirst();
   
   //Записва Бара на графиката който става пробива на Biasa
   //ползва се само при изчертаване на линията
   bias_begin_shift = curr_bar_shift;  
          

   DrawLine(BiasLineName(bias_begin_shift), "",  curr_bar_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);
         
   bias_direction = -1;  
}

void BreakUpBias(int curr_bar_shift){
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);   
   
   save_fisrt_bias_shift = bias_shift;
   
   GetBiasLowLevel(bias_shift, MotionBarFirst(), bias_shift, bias_level);   
   
   break_bias_shift = MotionBarFirst();
   
   bias_begin_shift = curr_bar_shift;     
   
   DrawLine(BiasLineName(bias_begin_shift), "",  curr_bar_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);

   bias_direction = 1;      
}

//-------------------------------------------------------------------
// Пресмята положението на Отклонението(BIAS) когато той се намира
// отдолу т.е. е положителен
//-------------------------------------------------------------------
void CalcContinueDownBias(int curr_bar_shift){
   
   int shift_motion_highest_low;
   
   //Изчертава Bias-линията до бара които е в момента по старите параметри получени от предишното пресмятане   
   if (bias_begin_shift !=0){
      DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);   
   }
   
   
   
   //Пресмята кой бар от Motion линията е с най-нисък връх
   //в интервала от началото на смяната на Bias-а от отрицателен в положителен.
   shift_motion_highest_low = GetShiftMotionHighestLow(break_bias_shift,  MotionBarFirst());           
      
      
   //Намира точното ниво на Bias-а според логиката 
   //(4-ри Motion бара назад с по високи върхове или най последния най висок Motion бар, ако са по малко от 4-ти)
   //по зададено начало от кой бар да се засича до дадения край.
   GetBiasLowLevel(save_fisrt_bias_shift, shift_motion_highest_low, bias_shift, bias_level);                                       

   //Записва поможението на бара от реалната графика където се намира най-ниския връх
   bias_begin_shift = MotionBarShift(shift_motion_highest_low); 
   
   //Изчертава Bias-линията по пресметнатото текущо ниво от бара където е започалото пресмятането на Биас-а до текущия бар в момента на реалната графика.      
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);          
    
}

//-------------------------------------------------------------------
// Пресмята положението на Отклонението(BIAS) когато той се намира
// отгоре т.е. е отрицателен
//-------------------------------------------------------------------
void CalcContinueUpBias(int curr_bar_shift){
   int shift_motion_lowest_high;

   if (bias_begin_shift !=0){
      DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);         
   }      

   shift_motion_lowest_high = GetShiftMotionLowestHigh(break_bias_shift,  MotionBarFirst());           
   
   
   GetBiasHighLevel(save_fisrt_bias_shift, shift_motion_lowest_high, bias_shift, bias_level);                                                                                
   
   bias_begin_shift = MotionBarShift(shift_motion_lowest_high);
                                   
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);             
}


void BiasDrawEnd(){
   if (bias_begin_shift == 0 && bias_level != 0) {
     DrawLine(BiasLineName(bias_begin_shift), "",  1, 0, bias_level, bias_level, Blue, 2);
   }else{
     DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, 0, bias_level, bias_level, Blue, 2);
  }      
}

void BiasProcess(int shift, double high, double low){

   if (bias_direction == 1){
     BuffHigh[shift] = low;
     BuffLow[shift] = high;      
   }else{
      if (bias_direction == -1){
         BuffHigh[shift] = high;
         BuffLow[shift] = low;   
      }
   }
   
   if (bias_level != 0) {
      //BuffBiasLine[shift] = -1*(((bias_level - ((high + low)/2))/bias_level)*100);
      
         //BuffHigh[shift] = high;
         //BuffLow[shift] = low;  
   }      
   
   //Print(bias_level);
}

//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
int GetBiasDirection(){
   return(bias_direction);
}



/*
//DEBUG-------------------------------------------------------------------------------
   if (TimeToStr(Time[curr_bar_shift])=="2007.06.06 00:00"){
      
      Print("Най-високо дъно = ", TimeToStr(Time[bias_begin_shift]), 
      ": Начало на 4-ри = ", TimeToStr(Time[MotionBarShift(save_fisrt_bias_shift)]),
      ": Край 4-ри = ", TimeToStr(Time[MotionBarShift(shift_motion_highest_low)]),
      ": НИВО : ", bias_level,
      ": Име = ", BiasLineName(bias_begin_shift)
      
      );
   }   
//------------------------------------------------------------------------------------   
   
//DEBUG-------------------------------------------------------------------------------
   if (TimeToStr(Time[curr_bar_shift])=="2007.06.05 00:00" ){
      
      Print("BREAK - Начало = ", TimeToStr(Time[MotionBarShift(save_fisrt_bias_shift)]), 
      ": НИВО : ", bias_level
      );
   }   
   
   if (TimeToStr(Time[curr_bar_shift])=="2007.06.05 00:00"){
      
      Print("Най-високо дъно = ", TimeToStr(Time[bias_begin_shift]), 
      ": Начало на 4-ри = ", TimeToStr(Time[MotionBarShift(save_fisrt_bias_shift)]),
      ": Край 4-ри = ", TimeToStr(Time[bias_begin_shift]),
      ": НИВО : ", bias_level,
      ": Име = ", BiasLineName(bias_begin_shift)
      
      );
   }      
//------------------------------------------------------------------------------------  

*/



