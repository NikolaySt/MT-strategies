//+------------------------------------------------------------------+
//|                                                   Ard_RSI_MA.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//--- input parameters
extern int       RSIPeriod=8;
extern int       MAPeriod=8;

//--- buffers
double RSIBuff[];
double MABuff[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MABuff);
   
   IndicatorShortName("MA( RSI ("+RSIPeriod+"), " + RSIPeriod+")");
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
   int limit = Bars-IndicatorCounted();           
   for (int i = 0; i < limit; i++) {
      RSIBuff[i] = iRSI(NULL, NULL, RSIPeriod, PRICE_CLOSE, i);                                              
   }
   
   for ( i = 0; i < limit; i++) {
      MABuff[i] = iMAOnArray(RSIBuff, Bars, MAPeriod, 0, MODE_EMA, i);                                                
   } 
   return(0);
  }
//+------------------------------------------------------------------+