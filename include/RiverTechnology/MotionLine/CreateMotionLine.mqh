

int i, shift = 0;
double high_bar, low_bar, motion_high, motion_low = 0;
bool check_exit_high, check_exit_low = false;

int CountExt_Bars_up, save_count_up = 0;
int CountExt_Bars_down, save_count_down = 0;
int shift_high, shift_low, motion_shift_low, motion_shift_high = 0;
int up_down_neutral = 0;
double offset_price;



void SetText(string text, int shift, double price, int up_down_neutral){ 
   
   
   if (price == 0 || shift >= Bars || !View_Text_Time){
      return(0);
   }      
       
   string name_wave = "NRT_MCount" + DoubleToStr(shift, 0);
   if ( ObjectFind(name_wave) < 0 ) ObjectCreate(name_wave, OBJ_TEXT, 0, 0, 0);
    
   ObjectMove(name_wave, 0, Time[shift], price);            
      
   switch (up_down_neutral){
      case 0: ObjectSetText(name_wave, text, 10, "Arial Narrow", Silver); break;
      case 1: ObjectSetText(name_wave, text, 10, "Arial Narrow", Green);break;
      case 2: ObjectSetText(name_wave, text, 10, "Arial Narrow", Red); break;
   }  
   return(0);
}

  

void MotionUp(){   
   BuffMotionLine[GetShift(i)] = GetHigh(i); 
   
   if (View_Bias) CalcBias(GetShift(i), GetHigh(i), GetLow(i), 1);   
   if (View_Price) CheckPriceLevel(GetShift(i), GetHigh(i));
   


   //-------------------------------------------------------------
   CountExt_Bars_up++;        

   EndDownDirection();  
   shift_high = i;      
   //-------------------------------------------------------------   
   
   
   if (CountExt_Bars_up > save_count_down) {
      time_direction = 1;   
   }      
}

void MotionDown(){   
   BuffMotionLine[GetShift(i)] = GetLow(i);  
   
   if (View_Bias) CalcBias(GetShift(i), GetHigh(i), GetLow(i), -1);   
   if (View_Price) CheckPriceLevel(GetShift(i), GetLow(i));
   

      
   //------------------------------------------------------------- 
   CountExt_Bars_down++;          
   EndUpDirection();                   
   shift_low = i;  
   //-------------------------------------------------------------   
   
   if (CountExt_Bars_down > save_count_up){
      time_direction = -1;   
   }   
}

void EndUpDirection(){
   if (CountExt_Bars_up != 0){                  
      motion_high = GetHigh(shift_high);
      motion_shift_high = shift_high;
      
      if (CountExt_Bars_up > save_count_down) {
        up_down_neutral = 1;                 
        //BuffTimeLine[shift_high] = CountExt_Bars_up; 
        SetText(DoubleToStr(CountExt_Bars_up, 0), GetShift(shift_high), GetHigh(shift_high) + offset_price, 1);    
      }else{
         if (up_down_neutral == 1) {  
            //BuffTimeLine[shift_high] = CountExt_Bars_up;           
            SetText(DoubleToStr(CountExt_Bars_up, 0), GetShift(shift_high), GetHigh(shift_high) + offset_price, 1);
         }else{                        
            //BuffTimeLine[shift_high] = -1*CountExt_Bars_up;  
            SetText(DoubleToStr(CountExt_Bars_up, 0), GetShift(shift_high), GetHigh(shift_high) + offset_price, 0);
         }    
      }     
      //time_direction = BuffTimeLine[shift_high];              
      
      SaveExtremumPrice(GetShift(shift_high), GetHigh(shift_high), +1/*връх*/);
      
      save_count_up = CountExt_Bars_up;
      
      CountExt_Bars_up = 0;
   } 
}

void EndDownDirection(){
   if (CountExt_Bars_down != 0){               
      motion_low = GetLow(shift_low); 
      motion_shift_low = shift_low; 
      
      if (CountExt_Bars_down > save_count_up) {
         up_down_neutral = 2;         
         //BuffTimeLine[shift_low] = -1*(StrToInteger(DoubleToStr(CountExt_Bars_down, 0)));  
         SetText(DoubleToStr(CountExt_Bars_down, 0), GetShift(shift_low), GetLow(shift_low) - offset_price, 2);
      }else{
         if (up_down_neutral == 2) {            
            //BuffTimeLine[shift_low] = -1*(StrToInteger(DoubleToStr(CountExt_Bars_down, 0)));  
            SetText(DoubleToStr(CountExt_Bars_down, 0), GetShift(shift_low), GetLow(shift_low) - offset_price, 2);
         }else{                
            SetText(DoubleToStr(CountExt_Bars_down, 0), GetShift(shift_low), GetLow(shift_low) - offset_price, 0);
           // BuffTimeLine[shift_low] = (StrToInteger(DoubleToStr(CountExt_Bars_down, 0)));  
         }  
      }
      
      //time_direction = BuffTimeLine[shift_low];
      
      SaveExtremumPrice(GetShift(shift_low), GetLow(shift_low), -1/*дъно*/);
                               
      save_count_down = CountExt_Bars_down;
      
      CountExt_Bars_down = 0; 
      
   }
}

int GetTimeDirection(){
   return(up_down_neutral);
}
int LogicTrendConditon = 0;
void MotionLine(){
 
   if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ){
      i = 0;
   }else{
      i = 1300;
   }  
   //OpenFile();          
   while (Condition(i)){
      
      //записва екстремумите на бара
      high_bar = GetHigh(i);
      low_bar = GetLow(i);
      check_exit_high = false;        
      check_exit_low = false;
      
      
      while (!check_exit_high && !check_exit_low && Condition(i)){  
         //търси бар пробиващ екстремум/екстремумите на бара преди входа в цикъла
                  
         if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ){
            i++;
         }else{
            i--;
         }                                   
         
         if (View_Bias) BiasProcess(GetShift(i), GetHigh(i), GetLow(i)); 
                   
                  
         if (GetHigh(i) > high_bar){
            check_exit_high = true;          
         }
         if (GetLow(i) < low_bar){
            check_exit_low = true; 
          
         }    

/*
         if (bias_direction > 0 && price_level_direction > 0){
            BuffHigh[GetShift(i)] = 5; 
            LogicTrendConditon = 1;       
         }else{
            if (bias_direction < 0 && price_level_direction < 0){            
               BuffHigh[GetShift(i)] = -5; 
               LogicTrendConditon = -1;              
            } else{
               if (LogicTrendConditon == 1) {
                  BuffHigh[GetShift(i)] = 5;
               }
               if (LogicTrendConditon == -1){
                  BuffHigh[GetShift(i)] = -5;  
               }
            }               
         }            
*/         
                                                
      }   
      
      if (Period() == PERIOD_H1 || Period() == PERIOD_M30){ 
         offset_price = iATR(NULL, 0, 50, i) * 0.5;   
      }else{
         offset_price = iATR(NULL, 0, 50, i) * 0.5;   
      }  
                 
      if (check_exit_high && check_exit_low) {  
         //текущия бар е пробил и двата ексремума на предишния бар         

         if (GetLow(i) < motion_low && motion_shift_low < motion_shift_high) {
            //дъното на бара е пробило (LOW екстремума на MotionLine - най-близкия)
            MotionDown();              
         }else{                  
            if (GetHigh(i) > motion_high && motion_shift_low > motion_shift_high) {
               //върха на бара е пробил (HIGH екстремума на MotionLine - най-близкия)
               MotionUp();
            }else{
               if (check_exit_high && CountExt_Bars_up > 0){              
                  //пробив на нагоре по посоката на предишното направление на MotionLine
                  MotionUp();
               }               
               if (check_exit_low && CountExt_Bars_down > 0){ 
                  //пробив на долу по посоката на предишното направление на MotionLine           
                  MotionDown();                    
               }             
            }
         }            
      }else{
         //текущия бар е пробил един от двата ексремума на предишния бар
         if (check_exit_high){              
            // пробив нагоре
            MotionUp();          
         }               
         if (check_exit_low){            
            //пробив надолу
            MotionDown();          
         }       
      }  
      //LongShortCondition(time_direction, price_level_direction, bias_direction, GetShift(i), High[GetShift(i)], Low[GetShift(i)]);
      
      /*
      

         if (bias_direction > 0 && price_level_direction > 0){
            BuffHigh[GetShift(i)] = 5; 
            LogicTrendConditon = 1;       
         }else{
            if (bias_direction < 0 && price_level_direction < 0){            
               BuffHigh[GetShift(i)] = -5; 
               LogicTrendConditon = -1;              
            } else{
               if (LogicTrendConditon == 1) {
                  BuffHigh[GetShift(i)] = 5;
               }
               if (LogicTrendConditon == -1){
                  BuffHigh[GetShift(i)] = -5;  
               }
            }               
         }         
         */
      //-----------------------Показва смяната на трите елмента------------
      //if (time_direction > 0 && bias_direction > 0 && price_level_direction > 0){
      //if (bias_direction > 0 && price_level_direction > 0){
      //   BuffHigh[GetShift(i)] = 5;        
      //}            
      //if (time_direction < 0 && bias_direction < 0 && price_level_direction < 0){            
      //if (bias_direction < 0 && price_level_direction < 0){            
      //   BuffHigh[GetShift(i)] = -5;               
      //}            
      //--------------------------------------------------------------------        
         
   } 
   //СЛАГА НОМЕР НА ПОСЛЕДНОТО НАПРВЛЕНИЕ КОЕТО НЕ Е ЗАВЪРШИЛО ВСЕ ОЩЕ
   EndUpDirection();
   EndDownDirection();
   
   //провека в последния бар;
    if (View_Price) CheckPriceLevel_EndBar();
    if (View_Bias) BiasDrawEnd();
    
   //CloseFile();    
}

bool Condition(int index){
   if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ){
      return(index < Count_Bars_Array - 1);
   }else{
      return(index > 0);
   }   
}


double GetHigh(int index){
   if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ){
      return(Bars_Array[index][1]);
   }else{
      return(High[index]);
   }         
}

double GetLow(int index){
 
   if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ){
      return(Bars_Array[index][2]);
   }else{
      return(Low[index]);
   }    
}

int GetShift(int index){
 
   if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ){
      return(Bars_Array[index][0]);
   }else{
      return(index);
   }    
}


