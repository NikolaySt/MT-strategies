//+------------------------------------------------------------------+
//|                                                 Ard_RTSystem.mq4 |
//|                                                 Copyright © 2010 |
//|                                                 RIVER TECHNOLOGY |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007"

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 8

#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Silver//CornflowerBlue
#property indicator_color4 Green
#property indicator_color5 Red
#property indicator_color6 Blue
#property indicator_color7 Green
#property indicator_color8 Black

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 2
#property indicator_width5 2

extern bool View_MotionLine = true;
extern bool View_Bias = true;
extern bool View_Text_Time = false;
extern bool View_Price = true;
bool View_288minutes = false;

string Version = "1.00";
string Revision= "13.08.2007";
string Info = "not for sale";

double BuffMotionLine[];
double BuffHigh[];
double BuffLow[];
double BuffUpPrice[];
double BuffDownPrice[];
double BuffMotionLineDown[];

double BuffBiasLine[];
double BuffTimeLine[];
double BuffPriceLine[];

double BuffBiasUp[300];
double BuffBiasDown[300];

//---Временно за изследва записва текущи те посоки на елементите---
double time_direction;
//-----------------------------------------------------------------

//-------Помощни---------------------------------------
#include <RiverTechnology\Utils\DrawChangeDirection.mqh>
#include <RiverTechnology\MotionLine\FileUtils.mqh>
#include <RiverTechnology\MotionLine\LogicCondition.mqh>
//-----------------------------------------------------

#include <RiverTechnology\Utils\WorkWithObjects.mqh>
//------------------TIME FRAME--------------------
#include <RiverTechnology\TimeFrame\FrameVariables.mqh>
#include <RiverTechnology\TimeFrame\Frame288minutes.mqh>
//-----------------------BIAS---------------------
#include <RiverTechnology\BiasLine\BiasLogic.mqh>
//-----------------------PRICE--------------------
#include <RiverTechnology\Price\PriceUtils.mqh>
//------------------------------------------------
#include <RiverTechnology\MotionLine\CreateMotionLine.mqh>

int init() {
   
   //SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,BuffHigh);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,BuffLow);  
   
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,BuffMotionLine);   

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3,BuffUpPrice);
   //SetIndexArrow(3,159);

   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4,BuffDownPrice);
   //SetIndexArrow(4,159);
   /*     
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,BuffBiasDown);     
   */
   
   SetIndexStyle(5,DRAW_SECTION);
   SetIndexBuffer(5,BuffBiasLine);     
   
   SetIndexStyle(6,DRAW_SECTION);
   SetIndexBuffer(6,BuffTimeLine);        
   
   SetIndexStyle(7,DRAW_SECTION);
   SetIndexBuffer(7,BuffPriceLine);     
            
   DeleteObjects();
   return(0);
}
int deinit()  {
   DeleteObjects();
   return(0);
}

int start(){
    
   if ((Period() == PERIOD_H1 || Period() == PERIOD_M30) && View_288minutes ) {
      //Create288Bars();
      Comment("288 chart");
   }else{      
      Comment("");
   }   
//DEBUG
   Print("New Recal");
//--------------------------   
   InitBiasParametars();       
   InitPriceParametars();       
   MotionLine();
   return(0);
  }



