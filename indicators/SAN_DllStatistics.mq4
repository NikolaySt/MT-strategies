//+------------------------------------------------------------------+
//|                                                 StdDevDouble.mq4 |
//|                               Copyright © 2010, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window


#import "StatisticsDll.dll"   
   int InitDll();
#import

int init(){
   InitDll();
   return(0);
}

int deinit(){  
   return(0);
}

int start()
{
   Comment("Load Statistics DLL");
}

