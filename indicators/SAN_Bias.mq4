//+------------------------------------------------------------------+
//|                                        Copyright © 2011 SAN_TEAM |
//|                                                  BIAS TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 SAN_TEAM"

#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 Black
#property indicator_width2 1

double BuffBias[];
double BuffBiasDirec[];

extern int BiasBars = 4;

#include <SAN_Systems\Indicators\Bias\BiasLogic.mqh>
#include <SAN_Systems\Indicators\Bias\MLArrays.mqh>
#include <SAN_Systems\Indicators\Bias\RTMainExpert.mqh>

int init() {     
   SetIndexStyle(0, DRAW_SECTION);
   SetIndexBuffer(0, BuffBias);      
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, BuffBiasDirec);      
   
   SetTimeFrame(Period());               
   InitArraysParams(); 
   InitBiasParams();     
   return(0);
}

int deinit()  {
   return(0);
}

void SetBiasLineToBuff(int index, double value){
   BuffBias[index] = value;
}
void SetBiasDirectionToBuff(int index, double value){
   BuffBiasDirec[index] = value;
}
int start(){   
   int limit=Bars-IndicatorCounted();
   RT_Main_Process(limit);
   return(0);
}








