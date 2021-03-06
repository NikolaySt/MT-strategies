//+------------------------------------------------------------------+
//|                               Copyright © 2010, Nikolay Stoychev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Stoychev"

#include <SAN_Systems\Common\CommonHeader.mqh>

//*-------------------------œŒÃŒŸÕ» ÃŒƒ”À»---------------------------------
#include <SAN_Systems\Signal\Common\Signals_Header.mqh>
#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
//-----------------------------------------------------------------------*/

//*------------------------------—»√Õ¿À Ô‡‡ÏÂÚË----------------------------
#include <SAN_Systems\Signal\N001\N001_Header.mqh>


#include <SAN_Systems\Signal\N002\N002_HeaderVars.mqh>
#include <SAN_Systems\Signal\N003\N003_HeaderVars.mqh>
#include <SAN_Systems\Signal\N004\N004_HeaderVars.mqh>
#include <SAN_Systems\Signal\N005\N005_HeaderVars.mqh>
#include <SAN_Systems\Signal\N006\N006_HeaderVars.mqh>
#include <SAN_Systems\Signal\N007\N007_HeaderVars.mqh>
#include <SAN_Systems\Signal\N008\N008_HeaderVars.mqh>
#include <SAN_Systems\Signal\N009\N009_HeaderVars.mqh>
#include <SAN_Systems\Signal\N010\N010_HeaderVars.mqh>
#include <SAN_Systems\Signal\N011\N011_HeaderVars.mqh>
#include <SAN_Systems\Signal\N012\N012_HeaderVars.mqh>
#include <SAN_Systems\Signal\N013\N013_HeaderVars.mqh>
#include <SAN_Systems\Signal\N014\N014_HeaderVars.mqh>
#include <SAN_Systems\Signal\N015\N015_HeaderVars.mqh>
#include <SAN_Systems\Signal\N016\N016_HeaderVars.mqh>

#include <SAN_Systems\Signal\A001\A001_HeaderVars.mqh>
#include <SAN_Systems\Signal\A002\A002_HeaderVars.mqh>
#include <SAN_Systems\Signal\A003\A003_HeaderVars.mqh>
//-----------------------------------------------------------------------*/

//*--------------------------------- “–≈Õƒ ---------------------------------
#include <SAN_Systems\Trend\Common\Trend_Header.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderAll.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderVars.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderVarsAll.mqh>

//#include <SAN_Systems\Trend\TA001\TA001_Header.mqh>
#include <SAN_Systems\Trend\TA001\TA001_HeaderVars.mqh>

#include <SAN_Systems\Trend\TN001\TN001_Header.mqh>
//#include <SAN_Systems\Trend\TN001\TN001_HeaderVars.mqh>

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
//------------------------------------------------------------------*/

//*---------------------œŒ–⁄◊ » œ¿–¿Ã≈“–»-----------------------------
#include <SAN_Systems\Order\Common\Orders_HeaderAll.mqh>
//-------------------------------------------------------------------*/

//*------------------------”œ–¿¬À≈Õ»≈ Õ¿  ¿œ»“¿À¿---------------------
//#include <SAN_Systems\MM\Common\MM_HeaderAll.mqh>
#include <SAN_Systems\MM\Common\MM_HeaderVarsAll.mqh>
//-------------------------------------------------------------------*/

//*---------------------------¬—»◊ » »ÃœÀ≈Ã≈Õ“¿÷»»--------------------
#include <SAN_Systems\Common\CommonIncludeAll.mqh>
//-------------------------------------------------------------------*/

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
 
int settIDCurrent;

int init()
{  
   //M001_MM_SetTrace(true);   
   //MM_Trace = true;
   settIDCurrent = 0;        
   Common_InitAll(settIDCurrent);      
   SAN_Stop_Trace = false;
   return(0);
}
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
   return(0);
} 

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

      
int start()
{      
   Common_Signals_ProcessAll(settIDCurrent);  
   return(0);
}





