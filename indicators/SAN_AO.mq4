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
double AOBuff[];
double ACBuff[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AOBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ACBuff);
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
   for (int i = 0; i < limit; i++) {
      AOBuff[i] = iMA(NULL, NULL, MAFast, 0, MODE_SMA, PRICE_MEDIAN, i)
               -
            iMA(NULL, NULL, MASlow, 0, MODE_SMA, PRICE_MEDIAN, i);                                                
   }
   for ( i = 0; i < limit; i++) {
      ACBuff[i] = AOBuff[i] - iMAOnArray(AOBuff, Bars, MASignal, 0, MODE_SMA, i);                                                
   }   

   return(0);
}
//+------------------------------------------------------------------+