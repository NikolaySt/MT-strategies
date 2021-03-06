//+------------------------------------------------------------------+
//|                                            Ard_FloatFractals.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 29.10.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 29.10.2009"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 2
//---- input parameters
extern int       BarsFr=5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
   
   SetIndexStyle(2,DRAW_LINE);
   
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double value = 0;
   int shift;
   int count = 0;
   int count_up = 0;
   int count_down = 0;
   for(int i = Bars; i >= (BarsFr/2+1); i--){
      shift = iBarShift(NULL, Period(), Time[i]);

      value = UpFractalFloatHigh(BarsFr, Period(), shift);
      
      if (value != 0){     
         ExtMapBuffer1[i] = value;
         count++;       
         count_up++;  
      }
      
      shift = iBarShift(NULL, Period(), Time[i]);
      value = DownFractalFloatLow(BarsFr, Period(), shift);
      if (value != 0){
         ExtMapBuffer2[i] = value;
         count++;
         count_down++;
      }      
      //ExtMapBuffer3[i] = iMA(NULL, Period(), 8, BarsFr, MODE_SMMA, PRICE_MEDIAN, i);
   }
   
   Comment("\n", Symbol(), 
      " - ÁÐÎÉ ÁÀÐÎÂÅ â ÅÄÈÍ ÔÐÀÊÒÀË = ", BarsFr
      );
   return(0);
  }
//+------------------------------------------------------------------+

//-----------------------------------------------------------------

double UpFractalFloatHigh(int bars_count, int period,  int i){   
   int day = TimeDayOfWeek(iTime(NULL, period, i));
   if (!(day >= 1 && day <= 5)) return(0);

   int left_offset = 0;
   int right_offset = 0;
   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      day = TimeDayOfWeek(iTime(NULL, period, i+n));
      if (!(day >= 1 && day <= 5)) left_offset = 1;      
      day = TimeDayOfWeek(iTime(NULL, period, i-n));
      if (!(day >= 1 && day <= 5)) right_offset = 1; 

      if (iHigh(NULL, period, i) < iHigh(NULL, period, i+n+left_offset)){
         return(0);
      }   

     
      if (iHigh(NULL, period, i) < iHigh(NULL, period, i-n-right_offset)){
         return(0);      
      }     
   }
   
   return(iHigh(NULL, period, i)); 
}


double DownFractalFloatLow(int bars_count, int period,  int i){  
   int day = TimeDayOfWeek(iTime(NULL, period, i));
   if (!(day >= 1 && day <= 5)) return(0);

   int left_offset = 0;
   int right_offset = 0;

   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      day = TimeDayOfWeek(iTime(NULL, period, i+n));
      if (!(day >= 1 && day <= 5)) left_offset = 1;      
      day = TimeDayOfWeek(iTime(NULL, period, i-n));
      if (!(day >= 1 && day <= 5)) right_offset = 1; 
         
      if (iLow(NULL, period, i) > iLow(NULL, period, i+n+left_offset)){
         return(0);              
      }
      if (iLow(NULL, period, i) > iLow(NULL, period, i-n-right_offset)){
         return(0);              
      }      
   }   
  
   return(iLow(NULL, period, i)); 
}



//-----------------------------------------------------------------
//-----------------------------------------------------------------
double UpFractalFloatClose(int bars_count, int period,  int i){   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      if (!(iClose(NULL, period, i) >= iClose(NULL, period, i+n))){
         return(0);         
      }
      if (!(iClose(NULL, period, i) >= iClose(NULL, period, i-n))){
         return(0);       
      }            
   }
   return(iHigh(NULL, period, i)); 
}


double DownFractalFloatClose(int bars_count, int period,  int i){   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      if (!(iClose(NULL, period, i) <= iClose(NULL, period, i+n))){
         return(0);              
      }
      if (!(iClose(NULL, period, i) <= iClose(NULL, period, i-n))){
         return(0);              
      }      
   }   
   return(iLow(NULL, period, i)); 
}



//-----------------------------------------------------------------
//-----------------------------------------------------------------
double UpFractalFloatLow(int bars_count, int period,  int i){   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      if (!(iLow(NULL, period, i) >= iLow(NULL, period, i+n))){
         return(0);         
      }
      if (!(iLow(NULL, period, i) >= iLow(NULL, period, i-n))){
         return(0);       
      }            
   }
   return(iHigh(NULL, period, i)); 
}


double DownFractalFloatHigh(int bars_count, int period,  int i){   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      if (!(iHigh(NULL, period, i) <= iHigh(NULL, period, i+n))){
         return(0);              
      }
      if (!(iHigh(NULL, period, i) <= iHigh(NULL, period, i-n))){
         return(0);              
      }      
   }   
   return(iLow(NULL, period, i)); 
}

//-----------------------------------------------------------------

