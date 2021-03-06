//+------------------------------------------------------------------+
//|                                                Ard_RT_Result.mq4 |
//|                                Copyright © 2010 Nikolay Stoychev |
//|                                                  FLOW TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Nikolay Stoychev"

#property indicator_separate_window
#property indicator_buffers 1

#property indicator_color1 Blue
#property indicator_width1 2

double BuffDirection[];

double time_direction;

int init() {          
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BuffDirection);                         
   return(0);
}
int deinit()  {
 
   return(0);
}

int start(){   
   InitBiasParametars();       
   InitPriceParametars();       
   MotionLine();
   return(0);
}

//int i;//, shift = 0;
double high_bar, low_bar, motion_high, motion_low = 0;
bool check_exit_high, check_exit_low = false;

int CountExt_Bars_up, save_count_up = 0;
int CountExt_Bars_down, save_count_down = 0;
int shift_high, shift_low, motion_shift_low, motion_shift_high = 0;
int up_down_neutral = 0;
double offset_price;



void MotionUpDown(int index, int direction){    
        
   CalcBias(GetShift(index), GetHigh(index), GetLow(index), direction);   

   if (direction == 1){ //нагоре
      CheckPriceLevel(GetShift(index), GetHigh(index));   
      //-------------------------------------------------------------
      CountExt_Bars_up++;        

      EndDownDirection();  
      shift_high = index;      
      //-------------------------------------------------------------   
      
      if (CountExt_Bars_up > save_count_down) {
         time_direction = 1;   
      }      
   }
   if (direction == -1){ //надолу
      CheckPriceLevel(GetShift(index), GetLow(index));   
      //------------------------------------------------------------- 
      CountExt_Bars_down++;          
      EndUpDirection();                   
      shift_low = index;  
      //-------------------------------------------------------------   
   
      if (CountExt_Bars_down > save_count_up){
         time_direction = -1;   
      }     
   }
}

void EndUpDirection(){
   if (CountExt_Bars_up != 0){                  
      motion_high = GetHigh(shift_high);
      motion_shift_high = shift_high;
            
      SaveExtremumPrice(GetShift(shift_high), GetHigh(shift_high), +1/*връх*/);
      
      save_count_up = CountExt_Bars_up;      
      CountExt_Bars_up = 0;
   } 
}

void EndDownDirection(){
   if (CountExt_Bars_down != 0){               
      motion_low = GetLow(shift_low); 
      motion_shift_low = shift_low;       
      
      SaveExtremumPrice(GetShift(shift_low), GetLow(shift_low), -1/*дъно*/);
                               
      save_count_down = CountExt_Bars_down;      
      CountExt_Bars_down = 0;       
   }
}

int GetTimeDirection(){
   return(up_down_neutral);
}

int SaveTrendDirection = 0;
void TrendDirection(int shift){
   
   if (GetPriceDirection() == 1 && GetBiasDirection() == 1){           
      BuffDirection[shift] = 1;
      SaveTrendDirection = 1;
      return;
   }
   
   if (GetPriceDirection() == -1 && GetBiasDirection() == -1){ 
      BuffDirection[shift] = -1;
      SaveTrendDirection = -1;
      return;   
   }
   BuffDirection[shift] = SaveTrendDirection;
   
}

void MotionLine(){
 
   //i = 100; // колко бара назад
   
   
   int counted_bars=IndicatorCounted();
 //---- check for possible errors
   if(counted_bars<0) return(-1);
 //---- the last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int i = 580-counted_bars;   
   if (i < 0) i = 580;
   Print("Limit  = ", i);
   
   while (Condition(i)){
      
      //записва екстремумите на бара
      high_bar = GetHigh(i);
      low_bar = GetLow(i);
      check_exit_high = false;        
      check_exit_low = false;      
      
      while (!check_exit_high && !check_exit_low && Condition(i)){  
         //търси бар пробиващ екстремум/екстремумите на бара преди входа в цикъла                  
         i--;         
         //if (View_Bias) BiasProcess(GetShift(i), GetHigh(i), GetLow(i));                                      
         if (GetHigh(i) > high_bar) check_exit_high = true;          
         if (GetLow(i) < low_bar) check_exit_low = true;           
         
         TrendDirection(GetShift(i));
      }   
      
                 
      if (check_exit_high && check_exit_low) {  
         //текущия бар е пробил и двата ексремума на предишния бар         

         if (GetLow(i) < motion_low && motion_shift_low < motion_shift_high) {
            //дъното на бара е пробило (LOW екстремума на MotionLine - най-близкия)
            MotionUpDown(i, -1);              
         }else{                  
            if (GetHigh(i) > motion_high && motion_shift_low > motion_shift_high) {
               //върха на бара е пробил (HIGH екстремума на MotionLine - най-близкия)
               MotionUpDown(i, 1);
            }else{
               if (check_exit_high && CountExt_Bars_up > 0){              
                  //пробив на нагоре по посоката на предишното направление на MotionLine
                  MotionUpDown(i, 1);
               }               
               if (check_exit_low && CountExt_Bars_down > 0){ 
                  //пробив на долу по посоката на предишното направление на MotionLine           
                  MotionUpDown(i, -1);                    
               }             
            }
         }            
      }else{
         //текущия бар е пробил един от двата ексремума на предишния бар
         if (check_exit_high){              
            // пробив нагоре
            MotionUpDown(i, 1);          
         }               
         if (check_exit_low){            
            //пробив надолу
            MotionUpDown(i, -1);          
         }       
      } 
      TrendDirection(GetShift(i)); 
         
   } 
   //СЛАГА НОМЕР НА ПОСЛЕДНОТО НАПРАВЛЕНИЕ КОЕТО НЕ Е ЗАВЪРШИЛО ВСЕ ОЩЕ
   EndUpDirection();
   EndDownDirection();   
}

bool Condition(int index){
   return(index > 0);
}


double GetHigh(int index){
   //return(High[index]);
   return(iHigh(NULL, Period(), index));
}

double GetLow(int index){
   //return(Low[index]);
   return(iLow(NULL, Period(), index));
}

int GetShift(int index){
   return(index);
}



//+------------------------------------------------------------------+
//|   Пресмята смяната на цената
//+------------------------------------------------------------------+

//Параметри записващи текущото състояние на цената
double price_level;
int price_level_shift_begin;
int price_level_direction = 1; // -1 тренд надолу, +1 тренд нагоре


double current_price_level;
int current_price_level_shift_begin;

int save_shift = 0;
double save_motion_line = 0;
bool change_direction = false;

int Save_Shift_begin = 0;

void InitPriceParametars(){
   price_level_direction = 1;
   save_shift = 0;
   save_motion_line = 0;
   change_direction = false;   
}

int GetPriceDirection(){
   return(price_level_direction);
}   
   
void SaveExtremumPrice(int shift, double motion_line, int direction){
   
   if (direction == 1){
      if (price_level_direction == -1){   
         price_level = motion_line;
         price_level_shift_begin = shift;               
      }
   }
   if (direction == -1){
      if (price_level_direction == 1){   
         price_level = motion_line;
         price_level_shift_begin = shift;               
      }
   } 
    
   current_price_level = motion_line;
   current_price_level_shift_begin = shift;                 
}

void CheckPriceLevel(int shift, double motion_line){
   CheckUpBreak(shift, motion_line);    
   CheckDownBreak(shift, motion_line);    
  
   save_motion_line = motion_line;
   save_shift = shift;       
}

//Когато цената е ПОЛОЖИТЕЛНА прави проверка дали имаме пробито Ценово ниво
void CheckUpBreak(int shift, double motion_line){   
   if (price_level_direction == 1 ){
      if (price_level > motion_line){
         price_level_direction = -1;                                                  
         change_direction = true;                  
         price_level = current_price_level;
         price_level_shift_begin = current_price_level_shift_begin;   
         
         //ползва се само в изчертаването на правоъгълниците
         Save_Shift_begin = shift;
      }else{               
         if (change_direction) {
            change_direction = false;            
         }else{
         }               
                  
      }
   }
}   

//Когато цената е ОТРИЦАТЕЛНА прави проверка дали имаме пробито Ценово ниво
void CheckDownBreak(int shift, double motion_line){ 
   if (price_level_direction == -1){
      if (price_level < motion_line){
         price_level_direction = 1;                                                         
         change_direction = true;                          
         price_level = current_price_level;
         
         price_level_shift_begin = current_price_level_shift_begin;          
      }else{ 
         if (change_direction) {
            change_direction = false; 
         }else{

         }                         
      }    
   }
}   

  

//+------------------------------------------------------------------+
//|   Пресмята и изчертава отклонението BIAS
//+------------------------------------------------------------------+
//Параметри записващи текущото състояние на цената
double bias_level = 0;
int bias_shift = 0;
int bias_direction = 0; // -1 тренд надолу, +1 тренд нагоре

int bias_begin_shift = 0;
int save_fisrt_bias_shift = 0;
int break_bias_shift = 0;

//-------------МАСИВ съдържащ motion баровете-------------
int count_motion_bars = 0;
double motion_bars[20000][3];
// motion_bars[0][0] - shift
// motion_bars[0][1] - high
// motion_bars[0][2] - low
double MotionBarHigh(int index){return(motion_bars[index][1]);}
double MotionBarLow(int index){return(motion_bars[index][2]);}
int MotionBarShift(int index){return(motion_bars[index][0]);}
int MotionBarFirst(){return(count_motion_bars-1);}

void AddMotionBarToArray(int shift, double high, double low){
   motion_bars[count_motion_bars][0] = shift;
   motion_bars[count_motion_bars][1] = high;
   motion_bars[count_motion_bars][2] = low;
   count_motion_bars++;  
}

void InitBiasParametars(){
   bias_level = 0;
   bias_shift = 0;
   bias_direction = 0; // -1 тренд надолу, +1 тренд нагоре

   bias_begin_shift = 0;
   save_fisrt_bias_shift = 0;

   ArrayInitialize(motion_bars, 0);
   count_motion_bars = 0;
}
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



void CalcBias(int shift, double high, double low, int zone){
   //zone : +1 възходящо движение на motionline
   //zone : -1 низходящо движение на motionline     
   
   AddMotionBarToArray(shift, high, low);  
   
   if (bias_direction == 0){
      //при начално започване
      bias_direction = 1;
      bias_level = low; 
   }
 
   if (bias_direction == 1){
      if (low < bias_level){         
         BreakBias(shift, bias_direction);                      
      }else{         
         ContinueBias(shift, bias_direction);      
      }       
   }else{  
      if (bias_direction == -1){
         if (high > bias_level){          
            BreakBias(shift, bias_direction);                                  
         }else{
            ContinueBias(shift, bias_direction);
         } 
      }
   }      
}

void BreakBias(int curr_bar_shift, int& bias_direction){    
   //записва началото на последния активен биас който е пробит
   //началото на бара     
   // Ползва се при намиране на текущия Биас, 4-ри бара назад или еьтремум ако няма 4-ри
   save_fisrt_bias_shift = bias_shift; 
          
   if (bias_direction == 1) {
      GetBiasHighLevel(bias_shift, MotionBarFirst(), bias_shift, bias_level);
      bias_direction = -1;
   }else{      
      if (bias_direction == -1) {
         GetBiasLowLevel(bias_shift, MotionBarFirst(), bias_shift, bias_level);  
         bias_direction = 1;
      }      
   }      
   
   //Записва Motion бара който е проби Биаса
   //Ползва се при намиране на Най ниския/Високия бар
   break_bias_shift = MotionBarFirst();
   
   //Записва Бара на графиката който става пробива на Biasa
   //ползва се само при изчертаване на линията
   bias_begin_shift = curr_bar_shift;                       
}


void ContinueBias(int curr_bar_shift, int bias_direction){
   
   int shift_motion;        
   
   if (bias_direction == 1){
      //-------------------------------------------------------------------
      // Пресмята положението на Отклонението(BIAS) когато той се намира
      // отдолу т.е. е положителен
      //-------------------------------------------------------------------   
      //Пресмята кой бар от Motion линията е с най-нисък връх
      //в интервала от началото на смяната на Bias-а от отрицателен в положителен.
      shift_motion = GetShiftMotionHighestLow(break_bias_shift,  MotionBarFirst());                 
      
      //Намира точното ниво на Bias-а според логиката 
      //(4-ри Motion бара назад с по високи върхове или най последния най висок Motion бар, ако са по малко от 4-ти)
      //по зададено начало от кой бар да се засича до дадения край.
      GetBiasLowLevel(save_fisrt_bias_shift, shift_motion, bias_shift, bias_level);                                       

      //Записва поможението на бара от реалната графика където се намира най-ниския връх
      bias_begin_shift = MotionBarShift(shift_motion); 
   }   
   
   if (bias_direction == -1){
      //-------------------------------------------------------------------
      // Пресмята положението на Отклонението(BIAS) когато той се намира
      // отгоре т.е. е отрицателен
      //-------------------------------------------------------------------   
      shift_motion = GetShiftMotionLowestHigh(break_bias_shift,  MotionBarFirst());                 
      GetBiasHighLevel(save_fisrt_bias_shift, shift_motion, bias_shift, bias_level);                                                                                
      bias_begin_shift = MotionBarShift(shift_motion);   
   }
}


//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
int GetBiasDirection(){
   return(bias_direction);
}





