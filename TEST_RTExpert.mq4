//+------------------------------------------------------------------+
//|                                                  Copyright 2010  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010 RiverTechnology"

int BiasBarCount = 4;
bool ActiveSetToChart = false;
bool VisualModeOnChart = false;
bool ViewTime = false;
bool ViewPrice = false;
bool ViewBias = false;
bool SmallTimeFrame = true;
bool LargeTimeFrame = true;

//------------------------МОДУЛИ в които се генерира и управлява сигнала ----------------------------------------
#include <NRT\SysRTVars.mqh>
#include <NRT\SysRTUtils.mqh>
#include <NRT\SysRTLogic.mqh>
//---------------------------------------------------------------------------------------------------------------

//----------------модули съдуржащи логиката на RiverTechnology---------------------------------------------------
#include <NRT\MLArrays.mqh>
#include <NRT\RTMainExpert.mqh>
#include <NRT\RTLogic.mqh>
#include <NRT\BiasLogic.mqh>
#include <NRT\PriceLogic.mqh>
#include <NRT\TimeLogic.mqh>
#include <NRT\ChannelLogic.mqh>
#include <NRT\DrawObj.mqh>
#include <NRT\Utils.mqh>
//---------------------------------------------------------------------------------------------------------------


int init()  {
   //прави изчисления за LARGELOC timeframe
   
   if (IsTesting() && IsVisualMode()){
      ViewTime = true;
      ViewPrice = true;
      ViewBias = true;        
      VisualModeOnChart = true;
   }else{
      VisualModeOnChart = false;
   }
   
   System_RT1_Init();
   
   
   //-------------ИНИЦИАЛИЗИРАННЕ на RiverTechnology
   SIGNAL_TIMEFRAME = Period();
   TREND_TIMEFRAME = CalcUpTimeFrame(Period());
   SetTimeFrame(TREND_TIMEFRAME);   
   InitArraysParams(); 
   InitBiasParams(); 
   InitPriceParams();     
   InitTimeParams();
   ActiveSetToChart = false;   
   RT_Main_Process(150);
   //----------------------------------------------
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() {
/*
   if (IsTesting()){
      HistoryClosePositionToFile(false, 1200, "history.txt");
      DropDownToFile(false, 1200, "dropdown.txt");
      AverageAnnualReturn(1200);
      SumMonthlyProfitToFile("monthly_profit.txt");
      MOSystem(true);
   }   
*/     
   return(0);
}
  
double CalcLotSizeMM(int MAGIC, int SLPoints){   
   return(0.1);   
}

int start(){  

   if (VisualModeOnChart) DeleteObjects();      
/*
   //прави изчисления за SmallLOC timeframe
   SetTimeFrame(SIGNAL_TIMEFRAME);   
   InitArraysParams(); 
   InitBiasParams(); 
   InitPriceParams();     
   InitTimeParams();
    */
   if (VisualModeOnChart) ActiveSetToChart = true;
   RT_Main_Process(2);
   RTSmall_SaveLevels();
   if (VisualModeOnChart){
      Draw_MotionLine();
      DrawObj_Process();
   }         
   //--------------------------------------------

/*
   //прави изчисления за LARGELOC timeframe
   SetTimeFrame(TREND_TIMEFRAME);
   InitArraysParams(); 
   InitBiasParams(); 
   InitPriceParams();     
   InitTimeParams();
   //ActiveSetToChart = false;
*/
   //прави изчисления за LARGELOC timeframe
   RT_Main_Process(2);      
   Channel_Process(VisualModeOnChart);
   if (VisualModeOnChart){     
      DrawObj_Process();
      Draw_MotionLine();
      Draw_Peaks();
   }    
   //if (VisualModeOnChart) DrawObj_Process();      
   //------------------------------------------                  
                
   System_RT1_Process(1001);  //MAGIC = 1001;          
   
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
   }
}





