//+------------------------------------------------------------------+
//|                                                       VgcHVR.mq4 |
//|                      Copyright © 2006, VGC & Forex-FreeZone Team |
//|                             http://www.forex-freezone.com/forum/ |
//+------------------------------------------------------------------+
#property copyright "VGC & Forex-FreeZone Team"
#property link      "http://www.forex-freezone.com/forum/"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 IndianRed
#property indicator_color2 LightSeaGreen
#property indicator_color3 Yellow
#property indicator_color4 OrangeRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_level1 -1
#property indicator_level2 -0.5
#property indicator_level3 0
#property indicator_level4 0.5
#property indicator_level5 1

extern int    SmallPeriod  = 5;           //Къс период
extern int    LargePeriod  = 100;         //Дълъг период
extern int    ScaleType    = 1;           //Възможните стойности са 0, 1 или 2
extern int    NRWRMax      = 15;          //Колко максимално бара да проверява
extern bool   ShowNRWRHist = true;        //Дали да показва изчислените NR,WR
extern bool   ShowHVRatio  = true;        //Дали да показва съотношението на историческата волатилност
extern bool   ShowATRRatio = false;       //Дали да показва съотношението на ATR
 
//---- buffers
double NRCounts[],WRCounts[],HVRatios[],ATRRatios[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorDigits(4);
   SetIndexDrawBegin(0,MathMax(SmallPeriod,LargePeriod));
   SetIndexDrawBegin(1,MathMax(SmallPeriod,LargePeriod));
   SetIndexDrawBegin(2,MathMax(SmallPeriod,LargePeriod));
   SetIndexDrawBegin(3,MathMax(SmallPeriod,LargePeriod));
//---- indicator lines
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, NRCounts);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1, WRCounts);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2, HVRatios);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3, ATRRatios);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("VgcHVR("+SmallPeriod+","+LargePeriod+")");
   SetIndexLabel(0,"NR Counts");
   SetIndexLabel(1,"WR Counts");
   SetIndexLabel(2,"HV Ratio");
   SetIndexLabel(3,"ATR Ratio");
//----
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   if(ScaleType>1)
     {
      SetIndexEmptyValue(2,-1);
      SetIndexEmptyValue(3,-1);
     }
   else  
     {
      SetIndexEmptyValue(2,0);
      SetIndexEmptyValue(3,0);
     }
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
   int limit,i,j;
   int counted_bars=IndicatorCounted();
   double dATR,dHV,dHVSMean,dHVLMean,dHVS,dHVL,dNR,dWR;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop
   for(i=0; i<limit; i++)
      {
       if(ShowHVRatio==false)
          dHV=0;
       else
         {
          //Средна стойност
          dHVSMean=0;
          for(j=0; j<SmallPeriod; j++)
             {
              dHVSMean=dHVSMean+MathLog(Close[i+j]/Close[i+j+1]);
             }
          dHVSMean=dHVSMean/SmallPeriod;
          //Стандартно отклонение
          dHVS=0;
          for(j=0; j<SmallPeriod; j++)
             {
              dHVS=dHVS+MathPow(MathLog(Close[i+j]/Close[i+j+1])-dHVSMean,2);
             }
          dHVS=MathSqrt(dHVS/(SmallPeriod-1));
          //Средна стойност
          dHVLMean=0;
          for(j=0; j<LargePeriod; j++)
             {
              dHVLMean=dHVLMean+MathLog(Close[i+j]/Close[i+j+1]);
             }
          dHVLMean=dHVLMean/LargePeriod;
          //Стандартно отклонение
          dHVL=0;
          for(j=0; j<LargePeriod; j++)
             {
              dHVL=dHVL+MathPow(MathLog(Close[i+j]/Close[i+j+1])-dHVLMean,2);
             }
          dHVL=MathSqrt(dHVL/(LargePeriod-1));
          //Най накрая и самото съотношение
          dHV=dHVS/dHVL;
         }
       if(ShowATRRatio==false)
          dATR=0;
       else
          dATR=iATR(NULL,0,SmallPeriod,i)/iATR(NULL,0,LargePeriod,i);
       //Кой поред бар с най-малък/голям диапазон е   
       dNR=0;
       dWR=0;
       if(ShowNRWRHist==true)
         {
          for(j=1; j<=NRWRMax; j++)
           if((High[i]-Low[i])<(High[i+j]-Low[i+j]) ||
              ((High[i]-Low[i])==(High[i+j]-Low[i+j]) && 
               ((High[i+1]-Low[i+1])<(High[i+j+1]-Low[i+j+1]) ||
                ((High[i+1]-Low[i+1])==(High[i+j+1]-Low[i+j+1]) &&
                 (High[i+2]-Low[i+2])<(High[i+j+2]-Low[i+j+2]) 
             ))))
              dNR=dNR-1;
           else
              break;   
          for(j=1; j<=NRWRMax; j++)
           if((High[i]-Low[i])>(High[i+j]-Low[i+j]) ||
              ((High[i]-Low[i])==(High[i+j]-Low[i+j]) && 
               ((High[i+1]-Low[i+1])>(High[i+j+1]-Low[i+j+1]) ||
                ((High[i+1]-Low[i+1])==(High[i+j+1]-Low[i+j+1]) &&
                 (High[i+2]-Low[i+2])>(High[i+j+2]-Low[i+j+2]) 
             ))))
              dWR=dWR+1;
           else
              break;   
         }
       if(ScaleType>1)
         {
          HVRatios[i]=dHV-1;
          ATRRatios[i]=dATR-1;
         }
       else  
         {
          HVRatios[i]=dHV;
          ATRRatios[i]=dATR;
         }
       if(ScaleType>0)
         {
          NRCounts[i]=dNR/10;
          WRCounts[i]=dWR/10;
         }
       else  
         {
          NRCounts[i]=dNR;
          WRCounts[i]=dWR;
         }
     } 
//---- done
   return(0);
  }
//+------------------------------------------------------------------+