//+------------------------------------------------------------------+
//|                                           Standard Deviation.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
 
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_buffers 1
#property indicator_color1 Blue

extern int ExtStdDevPeriod = 20;
extern int ExtStdDevMAMethod = 0;
extern int ExtStdDevAppliedPrice = 0;
extern int ExtStdDevShift = 0;

double ExtStdDevBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string sShortName;
//---- indicator buffer mapping
   SetIndexBuffer(0,ExtStdDevBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
//---- line shifts when drawing
   SetIndexShift(0,ExtStdDevShift);   
//---- name for DataWindow and indicator subwindow label
   sShortName="StdDev("+ExtStdDevPeriod+")";
   IndicatorShortName(sShortName);
   SetIndexLabel(0,sShortName);
//---- first values aren't drawn
   SetIndexDrawBegin(0,ExtStdDevPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Standard Deviation                                               |
//+------------------------------------------------------------------+
int start(){
   int    i, j, nLimit, nCountedBars;
   double dAPrice, dAmount, dMovingAverage;  

   if (Bars <= ExtStdDevPeriod) return(0);

   nCountedBars = IndicatorCounted();

   i = Bars - ExtStdDevPeriod - 1;
   if (nCountedBars > ExtStdDevPeriod) i = Bars - nCountedBars;  
   while(i >= 0){
      dAmount=0.0;
      dMovingAverage = iMA(NULL, 0, ExtStdDevPeriod, 0, ExtStdDevMAMethod, ExtStdDevAppliedPrice, i);
      for(j = 0; j < ExtStdDevPeriod; j++){
         dAPrice = GetAppliedPrice(Period(), ExtStdDevAppliedPrice, i + j);
         dAmount = dAmount + (dAPrice - dMovingAverage) * (dAPrice - dMovingAverage);
      }
      ExtStdDevBuffer[i] = MathSqrt(dAmount / ExtStdDevPeriod);
      i--;
   }
   return(0);
}

double GetAppliedPrice(int timeframe, int applied_price, int index){
   double price;
   switch (applied_price){
      case 0: price = iClose(NULL, timeframe, index); break;
      case 1: price = iOpen(NULL, timeframe, index); break;
      case 2: price = iHigh(NULL, timeframe, index); break;
      case 3: price = iLow(NULL, timeframe, index); break;
      case 4: price = (iHigh(NULL, timeframe, index)+iLow(NULL, timeframe, index))/2.0; break;
      case 5: price = (iHigh(NULL, timeframe, index)+iLow(NULL, timeframe, index)+iClose(NULL, timeframe, index))/3.0; break;
      case 6: price = (iHigh(NULL, timeframe, index)+iLow(NULL, timeframe, index)+2*iClose(NULL, timeframe, index))/4.0; break;
      default: price = 0.0;
   }
   return(price);
}

