//+------------------------------------------------------------------+
//|                                                 StdDevDouble.mq4 |
//|                               Copyright © 2010, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Lime


#import "StatisticsDll.dll"   
   int InitDll();
#import

//---- input parameters
extern int       MAPeriod=11;
extern int       AtrPeriod=15;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexShift(0, 1);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexShift(1, 1);
   InitDll();
 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   //DeInitCharts();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double ma;
   int shift = 0;
   int timeframe = Period();
   for(int i = Bars-1; i >= 0; i--){
      shift = i;//iBarShift(NULL, timeframe, Time[i]);
      ma = iMA(NULL, timeframe, MAPeriod, 0, 0, 0, shift);  
      ExtMapBuffer1[i] = ma + iATR(NULL, timeframe,   AtrPeriod, shift);
      ExtMapBuffer2[i] = ma - iATR(NULL, timeframe,   AtrPeriod, shift);
            
   }
   
   return(0);
  }
//+------------------------------------------------------------------+

