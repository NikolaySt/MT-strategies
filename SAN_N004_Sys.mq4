//+------------------------------------------------------------------+
//|                               Copyright ? 2010, Nikolay Stoychev |
//+------------------------------------------------------------------+
#property copyright "Copyright ? 2010, Nikolay Stoychev"

#include <SAN_Systems\Common\CommonHeader.mqh>

//*-------------------------??????? ??????---------------------------------
#include <SAN_Systems\Signal\Common\Signals_Header.mqh>
#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
//-----------------------------------------------------------------------*/

//*------------------------------?????? ?????????----------------------------
//#include <SAN_Systems\Signal\N001\N001_Header.mqh>
#include <SAN_Systems\Signal\N001\N001_HeaderVars.mqh>

//#include <SAN_Systems\Signal\N002\N002_Header.mqh>
#include <SAN_Systems\Signal\N002\N002_HeaderVars.mqh>

//#include <SAN_Systems\Signal\N003\N003_Header.mqh>
#include <SAN_Systems\Signal\N003\N003_HeaderVars.mqh>

#include <SAN_Systems\Signal\N004\N004_Header.mqh>
//#include <SAN_Systems\Signal\N004\N004_HeaderVars.mqh>

#include <SAN_Systems\Signal\N006\N006_HeaderVars.mqh>

//#include <SAN_Systems\Signal\A001\A001_Header.mqh>
#include <SAN_Systems\Signal\A001\A001_HeaderVars.mqh>

//#include <SAN_Systems\Signal\A002\A002_Header.mqh>
#include <SAN_Systems\Signal\A002\A002_HeaderVars.mqh>

//#include <SAN_Systems\Signal\A003\A003_Header.mqh>
#include <SAN_Systems\Signal\A003\A003_HeaderVars.mqh>
//-----------------------------------------------------------------------*/

//*--------------------------------- ????? ---------------------------------
//#include <SAN_Systems\Trend\Common\Trend_Header.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderAll.mqh>
#include <SAN_Systems\Trend\Common\Trend_HeaderVarsAll.mqh>

//#include <SAN_Systems\Trend\Common\Trend_Header.mqh>
//#include <SAN_Systems\Trend\Common\Trend_HeaderVars.mqh>

//#include <SAN_Systems\Trend\TA001\TA001_Header.mqh>
//#include <SAN_Systems\Trend\TA001\TA001_HeaderVars.mqh>

//#include <SAN_Systems\Trend\TN001\TN001_Header.mqh>
//#include <SAN_Systems\Trend\TN001\TN001_HeaderVars.mqh>

//#include <SAN_Systems\Trend\TN002\TN002_Header.mqh>
//#include <SAN_Systems\Trend\TN002\TN002_HeaderVars.mqh>
//-------------------------------------------------------------------------*/

//-------------------------????? ?? ?????????-----------------------
#include <SAN_Systems\Limit\Common\Limit_HeaderAll.mqh>
//#include <SAN_Systems\Limit\Common\Limit_HeaderVars.mqh>
//#include <SAN_Systems\Limit\Common\Limit_HeaderVarsAll.mqh>
//------------------------------------------------------------------*/

//*-----------------------???? ?? ?????????-----------------------
//#include <SAN_Systems\Stop\Common\Stop_HeaderAll.mqh>
#include <SAN_Systems\Stop\Common\Stop_Header.mqh>
#include <SAN_Systems\Stop\SA002\SA002_Header.mqh>
//------------------------------------------------------------------*/

//*---------------------??????? ?????????-----------------------------
#include <SAN_Systems\Order\Common\Orders_HeaderAll.mqh>
//-------------------------------------------------------------------*/

//*------------------------?????????? ?? ????????---------------------
//#include <SAN_Systems\MM\Common\MM_HeaderAll.mqh>
#include <SAN_Systems\MM\Common\MM_HeaderVarsAll.mqh>
//-------------------------------------------------------------------*/

//*---------------------------?????? ?????????????--------------------
#include <SAN_Systems\Common\CommonIncludeAll.mqh>
#include <SAN_Systems\Signal\N004\N004.mqh>
//#include <SAN_Systems\Stop\SN003\SN003.mqh>
//-------------------------------------------------------------------*/

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
 
int settIDCurrent;
int init()
{  
   N004_Signal_Trace  = false;
   // --------------------------- localni sa o za edinichen signal      
   settIDCurrent = 0;//SAV_Settings_Create("name=trader_beta;");        
   Common_InitAll(settIDCurrent);          
   N004_Signals_Init(settIDCurrent);
   return(0);
}
  


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
//*

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
      
      
      Stat_HistOrdersToDll_Params(SignalBaseName, 
         "N004_MAPeriod="+N004_MAPeriod+";"+
         "N004_BiasPeriod="+N004_BiasPeriod+";"+
         "N004_ST_AtdPeriod="+N004_ST_AtdPeriod+";"+
         "N004_ST_Multiplier="+N004_ST_Multiplier+";"+
         "N004_CountCloseExtremumBar="+N004_CountCloseExtremumBar+";"     
      );      
   }           
   return(0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
     
int start()
{
   Common_Process(settIDCurrent);
   
   N004_Signals_Process(settIDCurrent);            
   
   
   return(0);
}





