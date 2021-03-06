//+------------------------------------------------------------------+
//|                                                 Copyright © 2010 |
//|                                                 RIVER TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010"

#property indicator_chart_window
#property indicator_buffers 5

#property indicator_color1 Red
#property indicator_width1 2

#property indicator_color2 Lime
#property indicator_width2 2

#property indicator_color3 Blue
#property indicator_width3 2

#property indicator_color4 Brown
#property indicator_width4 2

#property indicator_color5 MediumOrchid
#property indicator_width5 2

double BuffUp[];
double BuffDown[];
double BuffBias[];
double BuffPrice[];
double BuffTime[];

extern int BiasBarCount = 4;

extern bool ViewTime = true;
extern bool ViewPrice = true;
extern bool ViewBias = true;
extern bool SmallTimeFrame = true;
extern bool LargeTimeFrame = true;

bool check_trace = false;
bool ActiveSetToChart = false;

#include <NRT\MLArrays.mqh>
#include <NRT\RTMain.mqh>
#include <NRT\RTLogic.mqh>
#include <NRT\BiasLogic.mqh>
#include <NRT\PriceLogic.mqh>
#include <NRT\TimeLogic.mqh>
#include <NRT\ChannelLogic.mqh>
#include <NRT\DrawObj.mqh>
#include <NRT\Utils.mqh>


int init() {     
   DeleteObjects();      
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, BuffUp);         
    
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, BuffDown);      
   
   SetIndexStyle(2, DRAW_SECTION);
   SetIndexBuffer(2, BuffBias);      
   
   SetIndexStyle(3, DRAW_SECTION);
   SetIndexBuffer(3, BuffTime);     
   
   SetIndexStyle(4, DRAW_SECTION);
   SetIndexBuffer(4, BuffPrice);        
              
   return(0);
}

int deinit()  {
   DeleteObjects();
   return(0);
}

void SetBiasToBuff(int index, double value){ 
   if (ActiveSetToChart) 
      DrawLine("line_point1_" + index + "_" + MathRand(), "Bias", index, index, value, value, DodgerBlue, 8, STYLE_SOLID, true);
}   
void SetPriceToBuff(int index, double value){
   if (ActiveSetToChart)   
      DrawLine("line_point2_" + index + "_" + MathRand(), "Price", index, index, value, value, MediumOrchid, 8, STYLE_SOLID, true);
}
void SetTimeBreakToBuff(int index, double value){
   if (ActiveSetToChart)
      DrawLine("line_point3_" + index + "_" + MathRand(), "Time", index, index, value, value, Brown, 8, STYLE_SOLID, true);
}

void SetControlBuff(int index, int control){
   
   if (ActiveSetToChart){
      if (control < 0){
         //BuffUp[index] = High[index];
         //BuffDown[index] = Low[index];
      }
      if (control > 0){
         //BuffUp[index] = Low[index];
         //BuffDown[index] = High[index];
      }
   }
}

void SetBiasLineToBuff(int index, double value){
   if (ActiveSetToChart){
      //BuffBias[index] = value;
   }
}

void SetTimeLineToBuff(int index, double value){
   if (ActiveSetToChart){
      //BuffTime[index] = value;
   }
}

void SetPriceLineToBuff(int index, double value){
   if (ActiveSetToChart){
      //BuffPrice[index] = value;
   }
}


int start(){          
   check_trace = false;
   DeleteObjects();
   
   if (SmallTimeFrame){
      //прави изчисления за SMALL timeframe
      
      SetTimeFrame(Period());   
      
      InitArraysParams(); 
      InitBiasParams(); 
      InitPriceParams();     
      InitTimeParams();
      
       
      ActiveSetToChart = true;  
      RT_Main_Process(2000);
      Draw_MotionLine();
      DrawObj_Process();         
      //Draw_Peaks(); //- само при тестове и проверка работата на индикатора
   }
   
     
   if (LargeTimeFrame){
      //прави изчисления за LARGE timeframe
      SetTimeFrame(CalcUpTimeFrame(Period()));
      InitArraysParams(); 
      InitBiasParams(); 
      InitPriceParams();     
      InitTimeParams();
      
      ActiveSetToChart = false;
      RT_Main_Process();      
               
      Channel_Process();
      DrawObj_Process();
      
      CreateSmallSignal();
   }   
     
   return(0);
}








