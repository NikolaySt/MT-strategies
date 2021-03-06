/********************************************************************************************
Помощни функции към дадения експерт
double  N001_FindMasterFractals(int settID, int TimeFrame, int trend, datetime& fractal_time, int fractal_bar = 5)
double  N001_FindOppositeFractals(int settID, int TimeFrame, datetime time_begin, int mode, datetime& fractal_time, int fractal_bar = 3)
bool    N001_HalfFractalRightCrossMA(int settID, int TimeFrame, int trend, int shift_begin, int shift_end)
double  N001_RatioCorection(int settID, LargeTimeFrame, int SmallTimeFrame, int trend, datetime impuls_end_time, double& corr_time_ratio, int& x1_corr, int& x2_corr)
double  N001_MALine(int setID, int mode, int shift)
********************************************************************************************/

double N001_FindMasterFractals(int settID, int TimeFrame, int trend, datetime& fractal_time, int fractal_bar = 5){       
   
   fractal_time = 0;   
   bool change_trend = false;   
   int shift = iBarShift(NULL, TimeFrame, Time[0]);
   int fr_half_bar = MathRound(fractal_bar / 2);
   double fr = 0;
   double base_line;      
    
   for(int i = fr_half_bar + 1; i <= fr_half_bar + 200; i++){   //15      
      //----------------------------------------------------------------------------------------
      if (trend == TD_UP){
         base_line = TN001_MALine(settID, MODE_LOWER, shift + i);
         fr = UpFractalFloat(fractal_bar, TimeFrame, shift + i);          
         if (fr > 0){
            if (fr > base_line && !N001_HalfFractalRightCrossMA(settID, TimeFrame, trend, shift + i, shift)){            
               fractal_time = iTime(NULL, TimeFrame, shift + i);                            
               if (change_trend) return(0);                              
               return(fr);               
            }else{
               return(0);   
            }
         }         
         if (fr == 0 && iOpen(NULL, TimeFrame, shift + i) < base_line && iClose(NULL, TimeFrame, shift + i) > base_line){
            return(0);
         }                         
      }
      //----------------------------------------------------------------------------------------
      
      //----------------------------------------------------------------------------------------
      if (trend == TD_DOWN){
         base_line = TN001_MALine(settID, MODE_UPPER, shift + i); 
         
         fr = DownFractalFloat(fractal_bar, TimeFrame, shift + i);    
                      
      
         if (fr > 0){                                 
            if (fr < base_line && !N001_HalfFractalRightCrossMA(settID, TimeFrame, trend, shift + i, shift)){                        
               
               fractal_time = iTime(NULL, TimeFrame, shift + i);               
               if (change_trend) return(0);               
               return(fr);                              
            }else{
               return(0); 
            }            
         }           
         if (fr == 0 && iOpen(NULL, TimeFrame, shift + i) > base_line && iClose(NULL, TimeFrame, shift + i) < base_line){
            return(0);
         }                 
      }      
      //----------------------------------------------------------------------------------------                             
   }     
}

//намира срещоположен фрактал
//използваме я за да намерим началото на импулса
double N001_FindOppositeFractals(int settID, int TimeFrame, datetime time_begin, int mode, datetime& fractal_time, int fractal_bar = 3){
   fractal_time = 0;   
   int shift = iBarShift(NULL, TimeFrame, time_begin);
   double fr = 0;    
   for(int i = shift; i <= shift + 15; i++){
      
      //----------------------------------------------------------------------------------------
      if (mode == MODE_UPPER){                  
         fr = UpFractalFloat(fractal_bar, TimeFrame, i);    
         if (fr > 0){    
            fractal_time = iTime(NULL, TimeFrame, i);                                                                   
            return(fr);               
         }         
               
      }
      //----------------------------------------------------------------------------------------
      
      //----------------------------------------------------------------------------------------
      if (mode == MODE_LOWER){         
         fr = DownFractalFloat(fractal_bar, TimeFrame, i);         
         if (fr > 0){
            fractal_time = iTime(NULL, TimeFrame, i);
            return(fr);               
         }  
      }      
      //----------------------------------------------------------------------------------------                             
   }  
   return(0);    
}

//Проверка дали десните барове на фрактала затварят над/под линията на тренда
bool N001_HalfFractalRightCrossMA(int settID, int TimeFrame, int trend, int shift_begin, int shift_end){   
   double base_line;      
   for (int i = shift_begin; i >= shift_end; i--)   {
      
      if (trend == 1){
         base_line = TN001_MALine(settID, MODE_LOWER, i);   
         if (iClose(NULL, TimeFrame, i) < base_line){
            return(true);
         }            
      }
      if (trend == -1){
         base_line = TN001_MALine(settID, MODE_UPPER, i);   
         if (iClose(NULL, TimeFrame, i) > base_line){
            return(true);
         }
      }
   }      
   
   return(false);
}

double N001_RatioCorection(int settID, int LargeTimeFrame, int SmallTimeFrame, int trend, datetime impuls_end_time, double& corr_time_ratio, int& x1_corr, int& x2_corr){
   //--------------------------------------------------------------------------------------------------------------------------------------------------------
   //-----------------------------------------------Отношение на корективната вълна към тласъка--------------------------------------------------------------
   //--------------------------------------------------------------------------------------------------------------------------------------------------------
   double fr_master_opposite = 0;
   datetime fr_opposite_time;

   if (trend == TD_UP){
      fr_master_opposite = N001_FindOppositeFractals(settID, LargeTimeFrame, impuls_end_time, MODE_LOWER, fr_opposite_time, N001_HeadFr_Bar);
   }else{
      fr_master_opposite = N001_FindOppositeFractals(settID, LargeTimeFrame, impuls_end_time, MODE_UPPER, fr_opposite_time, N001_HeadFr_Bar);
   }
   double y1, y2;
   int x1, x2;
   double y1_corr, y2_corr;
   double wave_impuls;
   double wave_corr;
   double ratio_corr = 0;

   if (fr_master_opposite > 0){
      if (trend == TD_UP){
         x1 = iHighest(NULL, SmallTimeFrame, MODE_HIGH, LargeTimeFrame/SmallTimeFrame, iBarShift(NULL, SmallTimeFrame, impuls_end_time)-LargeTimeFrame/SmallTimeFrame);
         x2 = iLowest(NULL, SmallTimeFrame, MODE_LOW, LargeTimeFrame/SmallTimeFrame, iBarShift(NULL, SmallTimeFrame, fr_opposite_time)-LargeTimeFrame/SmallTimeFrame);
         y1 = iHigh(NULL, SmallTimeFrame, x1);
         y2 = iLow(NULL, SmallTimeFrame, x2);

         x1_corr = x1;
         y1_corr = y1;
         x2_corr = iLowest(NULL, SmallTimeFrame, MODE_LOW, x1_corr, iBarShift(NULL, SmallTimeFrame, Time[1]));
         y2_corr = iLow(NULL, SmallTimeFrame, x2_corr);

      }else{
         x1 = iLowest(NULL, SmallTimeFrame, MODE_LOW, LargeTimeFrame/SmallTimeFrame, iBarShift(NULL, SmallTimeFrame, impuls_end_time)-LargeTimeFrame/SmallTimeFrame);
         x2 = iHighest(NULL, SmallTimeFrame, MODE_HIGH, LargeTimeFrame/SmallTimeFrame, iBarShift(NULL, SmallTimeFrame, fr_opposite_time)-LargeTimeFrame/SmallTimeFrame);
         y1 = iLow(NULL, SmallTimeFrame, x1);
         y2 = iHigh(NULL, SmallTimeFrame, x2);

         x1_corr = x1;
         y1_corr = y1;
         x2_corr = iHighest(NULL, SmallTimeFrame, MODE_HIGH, x1_corr, iBarShift(NULL, SmallTimeFrame, Time[1]));
         y2_corr = iHigh(NULL, SmallTimeFrame, x2_corr);
      }
      double time_impuls = MathAbs(x1 - x2);
      double time_corr = MathAbs(x1_corr-x2_corr);
      if (time_impuls != 0){
         corr_time_ratio = time_corr/time_impuls;
      }else{
         corr_time_ratio = 0;
      }

      wave_impuls = MathAbs(y1 - y2);
      wave_corr = MathAbs(y1_corr - y2_corr);
      if (wave_impuls != 0){
         ratio_corr = wave_corr/wave_impuls;
      }else{
         ratio_corr = 0;
      }
   }
   return(ratio_corr);
}





