#define DEF_MAX_BARS_COUNT 5000
double Bars_Array[DEF_MAX_BARS_COUNT][5];
int Count_Bars_Array = 0;
//Bars_Array[0][0] = shift;
//Bars_Array[0][1] = high;
//Bars_Array[0][2] = low;
//Bars_Array[0][3] = null;
//Bars_Array[0][4] = null;

void InitTimeFrameParametars(){
   ArrayInitialize(Bars_Array, 0);
   Count_Bars_Array = 0; 
}

int GetBuffPriceCount(){
   return(Count_Bars_Array);
}

int GetShift(int index){
   return(Bars_Array[index][0]);
}
double GetHigh(int index){
   return(Bars_Array[index][1]);
}
double GetLow(int index){
   return(Bars_Array[index][2]);
}

double GetMedianPrice(int index){
   return((Bars_Array[index][1] + Bars_Array[index][2])/2);
}

void Create288Bars(double &BuffHigh[], double &BuffLow[],
   double &BuffOpen[], double &BuffClose[], int acount = 1000){
   
   InitTimeFrameParametars();
   
   int limit = acount;
   if (limit > DEF_MAX_BARS_COUNT) limit = DEF_MAX_BARS_COUNT;
   
   int shift, i = 0;
   
   int curr_day_shift, next_day_shift;
   datetime curr_day, next_day, save_day;
   
   int begin_curr_day_m1, begin_next_day_m1; 
   
   int delta_bars, count_one_bar;
   double high_bar, low_bar, open_bar, close_bar;  
   
   int shift_view, offset_view, end_bar;     
      
   for (shift = limit; shift >= 0; shift--){
      //Buff[shift]=High[iHighest(NULL,0,MODE_HIGH,20,shift)];
      
      curr_day_shift = iBarShift(NULL, PERIOD_D1, Time[shift], false);  
      
      curr_day = iTime(NULL, PERIOD_D1, curr_day_shift);      
      

      next_day_shift = curr_day_shift - 1;
      next_day = iTime(NULL, PERIOD_D1, next_day_shift);             
      
      
      begin_curr_day_m1 = iBarShift(NULL, PERIOD_M1, curr_day, false);  
      if (curr_day_shift != 0){
         begin_next_day_m1 = iBarShift(NULL, PERIOD_M1, next_day, false);
      }else{
         begin_next_day_m1 = 0;   
      }            
      
      if (curr_day != save_day){
                          
         shift_view = shift;
         
         if (Period() == PERIOD_H1){
            offset_view = 5;
         }else{
            offset_view = 10;
         }
         for (i = 1; i <= 5; i++){
            
            if (begin_next_day_m1 != 0){
               delta_bars = begin_curr_day_m1 - begin_next_day_m1;
               count_one_bar = MathRound(delta_bars / 5);            
               
               end_bar = begin_curr_day_m1 - count_one_bar*i;
               
               if (end_bar < begin_next_day_m1){
                  end_bar = begin_next_day_m1 + 1;
                  count_one_bar = (begin_curr_day_m1 - count_one_bar*(i-1)) - end_bar;
               }else{
                  count_one_bar = MathRound(delta_bars / 5);   
               }
            }else{
               count_one_bar = PERIOD_D1/5;                             
               end_bar = begin_curr_day_m1 - count_one_bar*i;   
               
               if (end_bar < 0){
                  end_bar = 0;
                  count_one_bar = (begin_curr_day_m1 - count_one_bar*(i-1)) - end_bar;
               }else{
                  count_one_bar = PERIOD_D1/5;   
               } 
               
            }               
            high_bar = iHigh(NULL, PERIOD_M1, 
                                 iHighest(NULL, PERIOD_M1, MODE_HIGH, count_one_bar, end_bar)
                              );
            low_bar = iLow(NULL, PERIOD_M1, 
                                 iLowest(NULL, PERIOD_M1, MODE_LOW, count_one_bar, end_bar)
                              );
                              
            Bars_Array[Count_Bars_Array][0] = shift_view;
            Bars_Array[Count_Bars_Array][1] = high_bar;
            Bars_Array[Count_Bars_Array][2] = low_bar;
            Count_Bars_Array++;
                                                         
            open_bar = iOpen(NULL, PERIOD_M1, begin_curr_day_m1 - count_one_bar*(i-1)); 
            close_bar = iClose(NULL, PERIOD_M1, end_bar);
            //Print("OK ", shift_view, ":", high_bar, ":", low_bar);
            BuffHigh[shift_view] = high_bar;
            BuffLow[shift_view] = low_bar;
            BuffClose[shift_view] = close_bar;         
            BuffOpen[shift_view] = open_bar;
            if (i == 4){
               shift_view = shift_view - (offset_view-1);
            }else{
               shift_view = shift_view - offset_view;
            }               
         }            
         
         save_day = curr_day;
      }         
   }
}

