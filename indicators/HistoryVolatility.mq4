//+------------------------------------------------------------------+
//|                                                          HVR.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2010 Nikolay Stoychev"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 IndianRed
#property indicator_width1 2
#property indicator_level1 1
#property indicator_level2 0.5
#property indicator_level3 0

extern int    SmallPeriod  = 6;           //Къс период
extern int    LargePeriod  = 100;         //Дълъг период
extern int    BarsCount = 1000;
 
//---- buffers
double HVRatios[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
//---- drawing settings
   IndicatorDigits(2);
   SetIndexDrawBegin(0, MathMax(SmallPeriod, LargePeriod));
//---- indicator lines
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, HVRatios);

//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("HVR("+SmallPeriod+","+LargePeriod+")");
   SetIndexLabel(2,"HV Ratio");

//----
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);

   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i, j;
   int counted_bars =  IndicatorCounted();
   
   double dHV, dHVSMean, dHVLMean, dHVS, dHVL;

   if(counted_bars < 0) return(-1);

   if(counted_bars > 0) counted_bars--;
   limit = Bars-counted_bars;

   for(i = 0; i < limit; i++){
   
      //----------------------------------------------------------------------------------------------------
      //Средна стойност
      dHVSMean = 0;      
      for(j = 0; j < SmallPeriod; j++) dHVSMean = dHVSMean + MathLog(Close[i+j]/Close[i+j+1]);      
      dHVSMean = dHVSMean/SmallPeriod;
      
      //Стандартно отклонение
      dHVS = 0;
      for(j = 0; j < SmallPeriod; j++) dHVS = dHVS + MathPow(MathLog(Close[i+j]/Close[i+j+1]) - dHVSMean, 2);
      
      dHVS = MathSqrt(dHVS/(SmallPeriod-1));
      //----------------------------------------------------------------------------------------------------
      
      //----------------------------------------------------------------------------------------------------
      //Средна стойност      
      dHVLMean = 0;
      for(j = 0; j < LargePeriod; j++) dHVLMean = dHVLMean+MathLog(Close[i+j]/Close[i+j+1]);      
      dHVLMean = dHVLMean/LargePeriod;
      
      //Стандартно отклонение
      dHVL = 0;
      for(j = 0; j < LargePeriod; j++) dHVL = dHVL + MathPow(MathLog(Close[i+j]/Close[i+j+1]) - dHVLMean, 2);
      
      dHVL = MathSqrt(dHVL/(LargePeriod-1));
      //----------------------------------------------------------------------------------------------------
      
      
      dHV = dHVS/dHVL;

      HVRatios[i] = dHV;
   } 
   return(0);
}
//+------------------------------------------------------------------+