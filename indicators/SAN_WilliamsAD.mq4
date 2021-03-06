//+------------------------------------------------------------------+
//|                          Williams' Accumulation/Distribution.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
extern int MAPeriod = 57;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("W_A/D, MA("+MAPeriod+")");
//---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double AD, TRH, TRL;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars-counted_bars;      
   double atr;
   double medianPrice;   
         
   for (int i = limit; i >= 0; i--) {   

      TRH = MathMax(High[i], Close[i+1]);
      TRL = MathMin(Low[i], Close[i+1]);
      if (Close[i] > Close[i+1] + Point){
         AD = Close[i] - TRL;
      }else{
         if(Close[i] < Close[i+1] - Point) AD = Close[i] - TRH; else AD = 0;
      }              
      ExtMapBuffer1[i] = ExtMapBuffer1[i+1] + AD;      
   }
   for (int n = limit; n >= 0; n--) {    
      ExtMapBuffer2[n] = iMAOnArray(ExtMapBuffer1, 0, MAPeriod, 0, MODE_SMA, n);     
   }

   return(0);
}
//+------------------------------------------------------------------+