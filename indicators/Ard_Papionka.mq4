//+------------------------------------------------------------------+
//|                                                 Ard_Papionka.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Silver
#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 3
extern int SMA_Period = 10;
extern int EMA_Period1 = 20;
extern int EMA_Period2 = 30;
//--- buffers
double buffup[];
double buffdown[];
double buffpoint[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,buffup);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,buffdown);
   SetIndexEmptyValue(1,0.0);
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,buffpoint);
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
   int limit = Bars-counted_bars;      
   
   double sma1, ema1_1, ema2_1;                   
   int trend = 0;
   bool up_signal = false;
   bool down_signal = false;
   datetime up_signal_time = 0, down_signal_time = 0;
   for (int i = limit; i >= 1; i--) {
      sma1 = iMA_GetValue(SMA_Period, MODE_SMA, i);
      ema1_1 = iMA_GetValue(EMA_Period1, MODE_EMA, i); 
      ema2_1 = iMA_GetValue(EMA_Period2, MODE_EMA, i);
     
      //if (!(sma1 > ema1_1 && ema1_1 > ema2_1) && !(sma1 < ema1_1 && ema1_1 < ema2_1)){
        // trend = 0;
      //}
      
      //-------------------------------------------------------------------------------
      if (
         sma1 > ema1_1 && ema1_1 > ema2_1){         
         if (trend == 0 || trend == -1){
            up_signal = false;
            up_signal_time = iTime(0, 0, i);
         }
         trend = 1;      
      }
      
      if (
         !up_signal && 
         trend == 1 && iHigh(0,0,i) < iHigh(0,0,i+1) && iLow(0,0,i) < iLow(0,0,i+1)      
         && iTime(0, 0, i) > up_signal_time
         ){
         buffup[i] = iHigh(NULL, NULL, i);
         up_signal = true;
      }else{
         if(
         trend == 1 && iHigh(0,0,i) < iHigh(0,0,i+1) && iLow(0,0,i) < iLow(0,0,i+1)      
         && iTime(0, 0, i) > up_signal_time
         ){
            buffpoint[i] = iHigh(NULL, NULL, i);   
         }      
      }
      
      //-------------------------------------------------------------------------------
      if (
         sma1 < ema1_1 && ema1_1 < ema2_1){
         if (trend == 0 || trend == 1){
            down_signal = false;
            down_signal_time = iTime(0, 0, i);
         }      
         trend = -1;       
      }
            
      if (
         !down_signal && 
         trend == -1 && iHigh(0,0,i) > iHigh(0,0,i+1) && iLow(0,0,i) > iLow(0,0,i+1)         
         &&
         iTime(0, 0, i) > down_signal_time
         ){
         buffdown[i] = iLow(NULL, NULL, i);
         down_signal = true;
      }else{
         if(
            trend == -1 && iHigh(0,0,i) > iHigh(0,0,i+1) && iLow(0,0,i) > iLow(0,0,i+1)         
            &&
            iTime(0, 0, i) > down_signal_time
         ){
            buffpoint[i] = iLow(NULL, NULL, i);   
         }
      }
      
      
      //-------------------------------------------------------------------------------
       
   }
   return(0);
  }
//+------------------------------------------------------------------+

double iMA_GetValue(int period, int mode, int shift)
{
   return (iMA(NULL, NULL, period, 0, mode, PRICE_CLOSE, shift));
}