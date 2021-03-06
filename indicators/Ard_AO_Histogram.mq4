//+------------------------------------------------------------------+
//|                                                       SAN_AO.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Lime

//--- input parameters
extern int       MAFast=5;
extern int       MASlow=34;
extern int       MASignal=5;
//--- buffers
double AOBuff1[];
double AOBuff2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,AOBuff1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,AOBuff2);
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
int start(){
   int limit = Bars-IndicatorCounted();   
   double value, value_old;
   for (int i = 0; i < limit; i++) {
      value = iMA(NULL, NULL, MAFast, 0, MODE_SMA, PRICE_MEDIAN, i)
               -
            iMA(NULL, NULL, MASlow, 0, MODE_SMA, PRICE_MEDIAN, i);   
            
      value_old = iMA(NULL, NULL, MAFast, 0, MODE_SMA, PRICE_MEDIAN, i+1)
               -
            iMA(NULL, NULL, MASlow, 0, MODE_SMA, PRICE_MEDIAN, i+1);                                                         
            
      if (value > value_old){
         AOBuff2[i]  = value;
         AOBuff1[i]  = 0;
      }else{
      
         AOBuff1[i]  = value;
         AOBuff2[i]  = 0;
      
      }
   } 

   return(0);
}
//+------------------------------------------------------------------+