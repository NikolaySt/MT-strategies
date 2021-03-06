//+------------------------------------------------------------------+
//|                                                  Ard_Trapper.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 19.03.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 19.03.2009"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 ForestGreen
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0, 159);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1, 159);
   SetIndexBuffer(1,ExtMapBuffer2);
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
   int limit = 600;
   double prev_low = 0;
   double prev_high = 0;
   for (int i = limit - 1; i >= 0; i--){   
      if (Low[i] <= Low[i-1] && Low[i] <= Low[i+1] && i > 0){
         ExtMapBuffer1[i] = Low[i];
         prev_low = Low[i];
      }else{
         ExtMapBuffer1[i] = prev_low;
      }
      if (High[i] >= High[i-1] && High[i] >= High[i+1] && i > 0){
         ExtMapBuffer2[i] = High[i];
         prev_high = High[i];
      }else{
         ExtMapBuffer2[i] = prev_high;
      }      
   }
   return(0);
  }
//+------------------------------------------------------------------+