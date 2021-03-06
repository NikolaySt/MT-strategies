//+------------------------------------------------------------------+
//|                                               SAV_TraderBeta.mq4 |
//|                                 Copyright © 2010, Andrey Kunchev |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Andrey Kunchev"
#property link      "http://www.metaquotes.net"

//*-------------------------œŒÃŒŸÕ» ÃŒƒ”À»---------------------------------
#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
//-----------------------------------------------------------------------*/

#include <SAN_Systems\Common\CommonHeader.mqh>

//*------------------------------—»√Õ¿À Ô‡‡ÏÂÚË----------------------------
#include <SAN_Systems\Signal\Common\Signals_Header.mqh>

#include <SAN_Systems\Signal\N001\N001_HeaderVars.mqh>
#include <SAN_Systems\Signal\N002\N002_HeaderVars.mqh>
#include <SAN_Systems\Signal\N003\N003_HeaderVars.mqh>
#include <SAN_Systems\Signal\N006\N006_HeaderVars.mqh>

#include <SAN_Systems\Signal\A001\A001_HeaderVars.mqh>
#include <SAN_Systems\Signal\A002\A002_HeaderVars.mqh>
#include <SAN_Systems\Signal\A003\A003_HeaderVars.mqh>//Signal
#include <SAN_Systems\Signal\A005t\A005_Header.mqh>
//-----------------------------------------------------------------------*/

//*--------------------------------- “–≈Õƒ ---------------------------------
#include <SAN_Systems\Trend\Common\Trend_Header.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderAll.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderVars.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderVarsAll.mqh>

#include <SAN_Systems\Trend\TA001\TA001_Header.mqh>
//#include <SAN_Systems\Trend\TA001\TA001_HeaderVars.mqh>

//#include <SAN_Systems\Trend\TN001\TN001_Header.mqh>
#include <SAN_Systems\Trend\TN001\TN001_HeaderVars.mqh>

//#include <SAN_Systems\Trend\TN002\TN002_Header.mqh>
#include <SAN_Systems\Trend\TN002\TN002_HeaderVars.mqh>
//-------------------------------------------------------------------------*/

//-------------------------À»Ã»“ Ì‡ ÔÓ˙˜ÍËÚÂ-----------------------
#include <SAN_Systems\Limit\Common\Limit_HeaderAll.mqh>
//#include <SAN_Systems\Limit\Common\Limit_HeaderVars.mqh>
//#include <SAN_Systems\Limit\Common\Limit_HeaderVarsAll.mqh>
//------------------------------------------------------------------*/

//*-----------------------—“Œœ Ì‡ ÔÓ˙˜ÍËÚÂ-----------------------
//#include <SAN_Systems\Stop\Common\Stop_HeaderAll.mqh>
#include <SAN_Systems\Stop\Common\Stop_Header.mqh>

#include <SAN_Systems\Stop\SA002\SA002_Header.mqh>
//#include <SAN_Systems\Stop\SA002\SA002_HeaderVars.mqh>
//------------------------------------------------------------------*/

//*---------------------œŒ–⁄◊ » œ¿–¿Ã≈“–»-----------------------------
#include <SAN_Systems\Order\Common\Orders_HeaderAll.mqh>
//-------------------------------------------------------------------*/

//*------------------------”œ–¿¬À≈Õ»≈ Õ¿  ¿œ»“¿À¿---------------------
#include <SAN_Systems\MM\Common\MM_HeaderAll.mqh>
//#include <SAN_Systems\MM\Common\MM_HeaderVarsAll.mqh>
//-------------------------------------------------------------------*/

//*---------------------------¬—»◊ » »ÃœÀ≈Ã≈Õ“¿÷»»--------------------
#include <SAN_Systems\Common\CommonIncludeAll.mqh>

#include <SAN_Systems\Signal\A005t\A005t.mqh>
//-------------------------------------------------------------------*/
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
#include <SAN_Systems\Common\WarningDisable.mqh>
int init()
{  
   DisableCompilerWarning();//samoz a kompilatora
// --------------------------- localni sa za edinichen signal

   //TrendBaseName  = "TA001_ZigZag";//Zigzag trend 
   //Trend_TimeFrameS = "H4";
   //OrdersBaseName = "ON001";
   //SignalBaseName = "A001";//Inner bars signal
   
   Signal_Trace = true; 
   
   //Orders_Trace = true;
   //Trend_Trace = true;
   //Stop_Trace = true;

   Common_InitAll(0);
   A005_Signals_Init(0);
   SANO_UseMagicFOROT = true;

   return(0);
}
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{ 
   if (IsTesting()){         
      if (!IsOptimization()){
         Stat_HistOrdersToFile(false, 1000, "history_"+SignalBaseName+".txt");
         Stat_DropDownToFile(false, 1000, "dropdown_"+SignalBaseName+".txt");
         Stat_AvgAnnualReturn(1000);
         Stat_SumMonthlyProfitToFile("monthly_profit_"+SignalBaseName+".txt");
         Stat_CalcMO(true);                                   
      }                      
      Stat_HistOrdersToDll(SignalBaseName);
   }                
   
   
//----
   Print( "[deinit] ..." );
   
   //print some statistics
   
   //SAV_Order_TraceStatistics();
   
   //end print statistics

   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
       
int start()
{

   if(SignalBaseName != "A005t")
   {
      Print("SignalBaseName != A005t error!!!!!!! SignalBaseName=", SignalBaseName);
      return (1);
   }
   

   // moje i dvata varianta zavisimost ot nujdite
   //Common_Signals_ProcessAll(0);
   ///*
   Common_Process(0);
   A005_Signals_Process(0);
   //*/
   return(0);
}





