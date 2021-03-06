//+------------------------------------------------------------------+
//|                                Copyright © 2010 Nikolay Stoychev |
//|                                                    ML TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Nikolay Stoychev"

#property indicator_chart_window
#property indicator_buffers 1

#property indicator_color1 Blue
#property indicator_width1 2

double Buff[];

extern int BiasBarCount = 4;
extern int bars = 150;

#include <Bias\MLArrays.mqh>
#include <Bias\RTMotionLine.mqh>
#include <Bias\Utils.mqh>

int init() {     
   SetIndexStyle(0, DRAW_SECTION);
   SetIndexBuffer(0, Buff);      
   
   SetTimeFrame(Period());               
   return(0);
}

int deinit()  {
   return(0);
}


void SetMLLineToBuff(int index, double value){
   Buff[index] = value;
}

int start(){     
   DeleteObjects();        
   InitArraysParams();         
   RT_Main_Process(bars);     
   Draw_MotionLine();
   Draw_Peaks();
   return(0);
}

void Draw_MotionLine(){
   double low, high;
   double low1, high1;
   double price, price1;
   datetime time, time1;
   int direction, direction1;
   
   
   double count;   
   string text;   
   double offset; 
   int shift;
   
   for (int i = 1; i <= MLLastBarIndex(); i++){    
   
      MLGetBar(i, high1, low1, time1, direction1);
      MLGetBar(i-1, high, low, time, direction);

      if ( direction == 1) price = high;   
      if ( direction == -1) price = low;   
      if ( direction1 == 1) price1 = high1;   
      if ( direction1 == -1) price1 = low1;         
      
      DrawLine("line_ml_"+time1+"_"+direction1, "", 
               GetShift(time, Period()), GetShift(time1,  Period()),
               price, price1, Gray, 2, STYLE_SOLID);       
               
      //SetTextEx("text_ml_"+time1+"_" +direction1, MLBarForming(i), GetShift(time1, Period()), price1+(direction1*15*Point), Lime);               
   } 
}

void Draw_Peaks(){
   double value, value1;
   double price;
   datetime time, time1;
   int direction, direction1;
   double count;
   
   int shift;
   string text;
   
   for (int i = 1; i <= MLLastPeakIndex(); i++){          
      
      MLGetPeak(i-1, value, time, direction, count);
      MLGetPeak(i, value1, time1, direction1, count);

      DrawLine("line_peak_"+time1+"_" +direction1, "", 
               GetShift(time, Period()), GetShift(time1, Period()),
               value, value1, White, 1, STYLE_SOLID);
               
      //SetTextEx("text_peak_"+time1+"_" +direction1, MLGetFormingPeak(i), GetShift(time1, Period()), value1+(direction1*15*Point), Lime);
   } 
}








