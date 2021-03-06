#property copyright "Nikolay Stoychev"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 OrangeRed

extern int HVPeriod1 = 6;
extern int HVPeriod2 = 100;
extern int BarsCount = 1000;
double Buff[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE, EMPTY, 2, OrangeRed);
   SetIndexBuffer(0, Buff);
   IndicatorShortName("Volatility");
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
int start()  {

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars-counted_bars;  

   for (int i = 0; i < limit; i++) Buff[i] = Volatility(i);//*100;
   return(0);
}
//+------------------------------------------------------------------+

double Volatility(int j){
   double sum = 0, avr_hl_1 = 0, avr_hl_2 = 0;
   int i;
   
   for (i = j; i < (HVPeriod1 + j); i++)
   {
      sum = sum + (iHigh(NULL, NULL, i) - iLow(NULL, NULL, i));
   }
   avr_hl_1 = sum/HVPeriod1;
   
   sum = 0;
   for (i = j; i < (HVPeriod2 + j); i++)
   {
     sum = sum + (iHigh(NULL, NULL, i) - iLow(NULL, NULL, i));      
   }
   avr_hl_2 = sum/HVPeriod2;
   
   return(avr_hl_1/avr_hl_2);
}