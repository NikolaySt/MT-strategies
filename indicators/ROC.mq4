#property copyright "Nikolay Stoychev"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

extern int ROCPeriod = 2;
double Buff[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Buff);

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
int start()  {

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars - counted_bars;  

   for (int i = limit; i >= 0; i--) {
      Buff[i] = iClose(NULL, NULL, i) - iClose(NULL, NULL, i+ROCPeriod);
   }      
   return(0);
}

