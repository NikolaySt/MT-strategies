
#include <MonoWave\CreationWaves\CalculationPeriods.mqh>
#include <MonoWave\CreationWaves\CalculationRawMonoWave.mqh>

int ChartPoints_count;
double array_ChartPoints[const_wavecount][3];
/*
   //array_ChartPoints[0][0] = ценовo ниво - край - на графиката 
   //array_ChartPoints[0][1] = shift - край - на графиката    
   //array_ChartPoints[0][2] = Тип на вълната 
      1 Активност нагоре , 
      2 Активност надолу , 
      -1 - Хоризонатална активност Нагоре.
      -2 - Хоризонатална активност Надолу.
      -3 - Хоризонатална активност Странична    
*/
double GetPriceArrayChartPoints(int index){
   return(array_ChartPoints[index][0]);
}
int GetShiftArrayChartPoints(int index){
   return(array_ChartPoints[index][1]);
}

double GetTypeArrayChartPoints(int index){
   return(array_ChartPoints[index][2]);
}

void CreatChartPointToMonoWave(int period_calc, int period_calc_high_time){
    
        
   int p1, p2, p1_tmp, p2_tmp;
   int low_shift, high_shift, up_time_shift;
   int high_alter, low_alter;
   int none;
   int p1_high_time, p2_high_time;
   int low_shift_high_time, high_shift_high_time;
   double low_value, high_value;
   
   int s = 0; 
   int save_up_time_shift = -1;      
   
   
   int limit = CalcBarsIndicatorCounted();
   
   //Debug---------------
   //Print("Debug.MonoWaves.CreatChartPointToMonoWave: ", "Limit Count = ", limit);
   //---------------
   
   while (s <= limit && ChartPoints_count < const_wavecount){            
      up_time_shift = GetShiftPosition_Period(s, period_calc); 
      
      //Debug----------
      //if (s < 3){
      //   Print("s= ", s," : up_time_shift = ", up_time_shift, " : save_up_time_shift = ", save_up_time_shift);
      //}
      //Debug----------
      
      if (save_up_time_shift != up_time_shift){ 
         
         CalcPostionBeginEndPeriod(period_calc, s, up_time_shift, p1, p2);
         
         if (!ChartCompression) CalcVerticalGrid(p1);
         
         if (HighTimeWaveView) {
            PositionUpTimeMonoWave(s, up_time_shift, period_calc_high_time, p1_high_time, p2_high_time);                                 
             
            PositionExtremum(p1_high_time, p2_high_time, Period(), low_shift_high_time, high_shift_high_time);                 
            p2_high_time = MathRound((p1_high_time - p2_high_time)/2) + p2_high_time;
            SetPointHighTimeToMasive(p1_high_time, p2_high_time, low_shift_high_time, high_shift_high_time);
         }
         
         PositionExtremum(p1, p2, Period(), low_shift, high_shift);   


                              
         if (MonoWavesAlternation){
            PositionExtremum(low_shift, p2, Period(), none, high_alter);
            PositionExtremum(high_shift, p2, Period(), low_alter, none);
         }
                   

            
         
         //Debug--
         //if (s<50){
         //   Print("s= ", s, " : p1= ", p1, " : p2= ", p2, " : low_shift= ", low_shift, " : high_shift= ", high_shift);
         //}
         //---------         
         
        
         p2 = MathRound((p1 - p2)/2) + p2; 
         
         if (low_shift > high_shift){  
            if (MonoWavesAlternation){ 
               if (Low[low_shift] > (Low[low_alter] - iATR(NULL, 0, 20, p1)*0.3)){    
                  SetPointToAlterMonoWave(High[high_shift], p1);
                  SetPointToAlterMonoWave(Low[low_shift], p2);
               }else{
                  SetPointToAlterMonoWave(High[high_shift], p2);
                  SetPointToAlterMonoWave(Low[low_shift], p1);                              
               }
            }               

            SetPointToMasive(High[high_shift], p2);
            SetPointToMasive(Low[low_shift], p1);
         }else{
            if (low_shift == high_shift){ 
             
               if (period_calc == PERIOD_SIXFOLD || period_calc == PERIOD_TWOFOLD || period_calc == PERIOD_288){
                  SetPointToMasive(High[high_shift], p2);
                  SetPointToMasive(Low[low_shift], p1);                     
               }else{                                      
                  /*
                  PositionCustomTime(high_shift, PERIOD_M30, Period(), p1_tmp, p2_tmp);
                  PositionExtremum(p1_tmp, p2_tmp, PERIOD_M30, low_shift, high_shift);                                                   
                  PriceExtremum(low_shift, high_shift, PERIOD_M30, low_value, high_value);      
                    */                
                  high_value = High[high_shift];
                  low_value = Low[low_shift];
                  if (Close[low_shift] > Open[low_shift]){
                     low_shift++;
                     
                  }else{
                     low_shift--;                        
                  }
                                                                                                              
                  
                  if (low_shift > high_shift){                                     
                     SetPointToMasive(high_value, p2);
                     SetPointToMasive(low_value, p1);  
                     if (MonoWavesAlternation){
                        SetPointToAlterMonoWave(high_value, p2);
                        SetPointToAlterMonoWave(low_value, p1);                                                       
                     }
                  }else{
                     if (low_shift == high_shift){
                      
                        /*
                        PositionCustomTime(high_shift, PERIOD_M15, PERIOD_M30,p1_tmp, p2_tmp);
                        PositionExtremum(p1_tmp, p2_tmp, PERIOD_M15, low_shift, high_shift);
                        PriceExtremum(low_shift, high_shift, PERIOD_M15, low_value, high_value);                                                                                                               
                          */
                        if (Close[low_shift] > Open[low_shift]){
                           low_shift++;
                        }else{
                           low_shift--;   
                        }
                                              
                        if (low_shift > high_shift){                                                                       
                           SetPointToMasive(high_value, p2);
                           SetPointToMasive(low_value, p1);                
                           if (MonoWavesAlternation){  
                              SetPointToAlterMonoWave(high_value, p2);
                              SetPointToAlterMonoWave(low_value, p1);                                                                                     
                           }                             
                        }else{  
                           if (low_shift < high_shift){
                              SetPointToMasive(low_value, p2);                         
                              SetPointToMasive(high_value, p1); 
                              if (MonoWavesAlternation){  
                                 SetPointToAlterMonoWave(low_value, p2);                         
                                 SetPointToAlterMonoWave(high_value, p1);                                                                                     
                              }                                                     
                           }else{
                              SetPointToMasive((low_value + high_value)/2, p2);                         
                              SetPointToMasive((high_value + low_value)/2, p1);                                
                              if (MonoWavesAlternation){  
                                 SetPointToAlterMonoWave((low_value + high_value)/2, p2);                         
                                 SetPointToAlterMonoWave((high_value + low_value)/2, p1);                                                                                     
                              }                                 
                           }
                        }                  
                     }else{             
                        SetPointToMasive(low_value, p2);                         
                        SetPointToMasive(high_value, p1); 
                        if (MonoWavesAlternation){
                           SetPointToAlterMonoWave(low_value, p2);                         
                           SetPointToAlterMonoWave(high_value, p1);                                                      
                        }                                                          
                     }
                                     
                  } 
               }
                                                       
            }else{   
               if (MonoWavesAlternation){ 
                  if (High[high_shift] < (High[high_alter] + iATR(NULL, 0, 20, p1)*0.3)){                     
                     SetPointToAlterMonoWave(Low[low_shift], p1);      
                     SetPointToAlterMonoWave(High[high_shift], p2);                   
                  }else{
                     SetPointToAlterMonoWave(Low[low_shift], p2);      
                     SetPointToAlterMonoWave(High[high_shift], p1);                     
                  }
               }                                                               
               SetPointToMasive(Low[low_shift], p2);      
               SetPointToMasive(High[high_shift], p1);                                             
            }
         }

         save_up_time_shift = up_time_shift;                                     
      }      
      s++;              
   } 
   
}

int SetPointHighTimeToMasive(int p1, int p2, int low_shift, int high_shift){
   if (low_shift > high_shift){
      up_time_wave[p1] = Low[low_shift];
      up_time_wave[p2] = High[high_shift];
   }else{
      up_time_wave[p2] = Low[low_shift];
      up_time_wave[p1] = High[high_shift];      
   }
}

int SetPointToMasive(double Price, int shift){
   double new_level = 0;
   if (custom_point_count > 0){
      //проверка за ръчно поставена точка на това ниво
      new_level = Check_Custom_Wave_Point_Level(shift);
      
   }
   if (new_level > 0){
      array_ChartPoints[ChartPoints_count][0] = new_level;
      Wave[shift] = new_level;
   }else{
      array_ChartPoints[ChartPoints_count][0] = Price;      
      Wave[shift] = Price;
   }
   array_ChartPoints[ChartPoints_count][1] = shift;   

   ChartPoints_count++;
   return(0);
}

int SetPointToAlterMonoWave(double Price, int shift){    
   if (!ChartCompression){
      MonoAlternation[shift] = Price;
   }
   return(0);
}

int CalcVerticalGrid(int p1){
   VerticalLine1[p1] = Grid_Upper_Level;
   VerticalLine2[p1] = 0;
}

int save_curent_count_bars = 0;
int CalcBarsIndicatorCounted(){
   double max, min = 0;
   int limit = 0;
   
   if (ChartPoints_count > 0){
      max = MathMax(array_ChartPoints[0][0], array_ChartPoints[1][0]);      
      min = MathMin(array_ChartPoints[0][0], array_ChartPoints[1][0]);      
      //Print("max=", max, " : min=", min);
      if (iHighest(NULL, 0, MODE_HIGH, 4, 0) > max || iLowest(NULL, 0, MODE_LOW, 4, 0) < min){
         limit = Bars;   
      }else{
         limit = 0;   
      }        
   }else{
      limit = Bars;
   }  
   if (Bars > (save_curent_count_bars + 30)){
      limit = Bars;
   }
   save_curent_count_bars = Bars;
   return(limit);
}