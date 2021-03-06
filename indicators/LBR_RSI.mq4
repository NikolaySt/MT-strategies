//+------------------------------------------------------------------+
//|                                                      LBR_RSI.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Black
//--- input parameters
extern int       Period_MOM=1;
extern int       Period_RSI=3;
//--- buffers
double RSIBuff[];
double MOMBuff[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MOMBuff);   
   SetIndexLabel(0, "RSI");
   SetIndexLabel(1, "Momentum");
   IndicatorShortName("LBR_RSI("+Period_MOM+", "+Period_RSI+")");
   SetLevelStyle(STYLE_SOLID, 1, Red);
   SetLevelValue(0, 30);  
   SetLevelValue(1, 70);
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
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars - counted_bars;  
   int i;
   for(i = 0; i < limit; i++) {
      MOMBuff[i] = iMomentum(NULL, NULL, Period_MOM, PRICE_CLOSE, i);
   }      
   for(i = 0; i < limit; i++) {
      RSIBuff[i]=iRSIOnArray(MOMBuff, Bars, Period_RSI, i);   
   }      
   return(0);
  }
//+------------------------------------------------------------------+