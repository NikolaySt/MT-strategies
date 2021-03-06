//+------------------------------------------------------------------+
//|                                Copyright © 2010 Nikolay Stoychev |
//|                                                  BIAS TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Nikolay Stoychev"

#property indicator_chart_window
#property indicator_buffers 3

#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 Lime
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2

double BuffBias1[];
double BuffBias2[];
double BuffBias3[];
extern int LevelDistancePips = 20;
extern string TimeFrame1s = "D1";
extern string TimeFrame2s = "H4";
extern string TimeFrame3s = "H1";

int TimeFrame1 = PERIOD_D1;
int TimeFrame2 = PERIOD_H4;
int TimeFrame3 = PERIOD_H1;

extern int BiasBarCount = 4;
extern bool DrawChannel = true;
extern int bars = 2000;
#include <Bias\Utils.mqh>
#include <Bias\BiasLogic.mqh>
#include <Bias\MLArrays.mqh>
#include <Bias\RTMain.mqh>
#include <Bias\ChannelLogic.mqh>
int init() {     
   SetIndexStyle(0, DRAW_SECTION);
   SetIndexBuffer(0, BuffBias1);    
   
   SetIndexStyle(1, DRAW_SECTION);
   SetIndexBuffer(1, BuffBias2);  
   
   SetIndexStyle(2, DRAW_SECTION);
   SetIndexBuffer(2, BuffBias3);  
   
   if (TimeFrame1s == "") TimeFrame1 = Period();
   else
      TimeFrame1 = TimeFrameFromString(TimeFrame1s);
      
   if (TimeFrame2s == "") TimeFrame2 = Period();
   else   
      TimeFrame2 = TimeFrameFromString(TimeFrame2s);
      
   if (TimeFrame3s == "") TimeFrame3 = Period();    
   else  
      TimeFrame3 = TimeFrameFromString(TimeFrame3s);      
           
   return(0);
}

int deinit()  {
   DeleteObjects();
   return(0);
}

bool ViewBias = false;
void SetBiasLineToBuff(int index, double value){
   if (ViewBias && GetTimeFrame() == TimeFrame1) BuffBias1[index] = value;
   if (ViewBias && GetTimeFrame() == TimeFrame2) BuffBias2[index] = value;
   if (ViewBias && GetTimeFrame() == TimeFrame3) BuffBias3[index] = value;   
}

int start(){   
   ViewBias = false; 
   DeleteObjects(); 
           
   if (DrawChannel){
      SetTimeFrame(CalcUpTimeFrame(Period()));
      InitArraysParams(); 
      InitBiasParams();           
      RT_Main_Process(bars);
      Channel_Process();    
   }
   ViewBias = true;
    
   SetTimeFrame(TimeFrame1);
   InitArraysParams(); 
   InitBiasParams();           
   RT_Main_Process(bars);
   double bias_1 = GetBias_Level();
   DrawLine("BIAS_1_"+TimeFrame1, bias_1, 0, 10, bias_1, bias_1, Blue, 1);
      
   SetTimeFrame(TimeFrame2);
   InitArraysParams(); 
   InitBiasParams();           
   RT_Main_Process(bars);         
   double bias_2 = GetBias_Level();
   DrawLine("BIAS_2_"+TimeFrame2, bias_2, 0, 10, bias_2, bias_2, Lime, 1);
   
   SetTimeFrame(TimeFrame3);
   InitArraysParams(); 
   InitBiasParams();           
   RT_Main_Process(bars);     
   double bias_3 = GetBias_Level();
   DrawLine("BIAS_3_"+TimeFrame3, bias_3, 0, 10, bias_3, bias_3, Red, 1);
   
   double dist = LevelDistancePips*Point;
   double max = MathMax(bias_1, bias_2);
   double min = MathMin(bias_1, bias_2);
   max = MathMax(max, bias_3);
   min = MathMin(min, bias_3);   
   string comm = " bias_1 ("+TimeFrame1s+") = " + DoubleToStr(bias_1, Digits) +
   "\n bias_2 ("+TimeFrame2s+") = " + DoubleToStr(bias_2, Digits) + 
   "\n bias_3 ("+TimeFrame3s+") = " +  DoubleToStr(bias_3, Digits);
   if ((max - min) <= dist){
      DrawLine("BIAS_RANGE_MAX", max, 0, 10, max, max, Silver, 5);
      DrawLine("BIAS_RANGE_MIN", min, 0, 10, min, min, Silver, 5);
      comm = comm + "\n [Active] All timeframe ";
   }else{
      ObjectDelete("BIAS_RANGE_MAX");
      ObjectDelete("BIAS_RANGE_MIN");
   }
   Comment(comm);
   return(0);
}





