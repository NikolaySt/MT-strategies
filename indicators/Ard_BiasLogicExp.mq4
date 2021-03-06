//+------------------------------------------------------------------+
//|                                Copyright © 2010 Nikolay Stoychev |
//|                                                  BIAS TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Nikolay Stoychev"

#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 Black
#property indicator_width2 1

double BuffBias[];
double BuffBiasDirec[];

extern int BiasBarCount = 4;
extern int bars = 150;

#include <Bias\BiasLogic.mqh>
#include <Bias\MLArrays.mqh>
//#include <Bias\RTMain.mqh>
#include <Bias\RTMainExpert.mqh>

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
   //BuffBiasDirec[index] = value;
}
void TrendPoint(string name, datetime time, double price, int trend){                     
   if (time > 0){
      if ( ObjectFind(name) < 0 ) ObjectCreate(name, OBJ_ARROW, 0, 0, 0);    
      ObjectSet(name, OBJPROP_ARROWCODE, 159);
      ObjectMove(name, 0, time, price);   
      int clr = Silver;     
      ObjectSet(name, OBJPROP_COLOR, clr);   
      
      ObjectSetText(name, DoubleToStr(Period(), 0));
   }
}

int start(){   
   int limit=Bars-IndicatorCounted();
   RT_Main_Process(limit);
   return(0);
}








