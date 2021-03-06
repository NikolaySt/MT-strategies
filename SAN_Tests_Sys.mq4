//+------------------------------------------------------------------+
//|                                               SAV_TraderBeta.mq4 |
//|                                 Copyright © 2010, Andrey Kunchev |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Andrey Kunchev"
#property link      "http://www.metaquotes.net"

#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
#include <SAN_Systems\Common\CommonHeaderVarsAll.mqh>
#include <SAN_Systems\Common\CommonIncludeAll.mqh> 


//-------------------------------------------------------------------*/

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
void TestDate(datetime dt)
{
   int sdt = DateHash_FromDateTime(dt);
   int tyear = TimeYear(dt);
   datetime timeyear = StrToTime(StringConcatenate(tyear,".12.31 23:59"));
   datetime dt1 = DateHash_ToDateTime(sdt, timeyear);
   
   Print("[TestDate] Success=",dt==dt1,"inputdate=",TimeToStr(dt),";",dt,";shortdate=",sdt,
         ";outputdate=",TimeToStr(dt1),";",dt1);
}
void TestMagic(int settID,datetime dt, int stop )
{
   int m = Magic_Create(settID, dt, stop);
   int tstop = Magic_GetStop(m);
   int tsettID = Magic_GetSettingsID(m);
   int tdt = Magic_GetDateHash(m);
   int dtHash = DateHash_FromDateTime(dt);
   
   Print("[TestMagic] success=", settID == tsettID && stop == tstop && dtHash == tdt,
          ";settID=",settID,";",tsettID,
          ";stop=",stop,";",tstop,
          ";dth=",dtHash,";",tdt,
          ";datetime=",TimeToStr(dt));
   
   
}

void TestShifts(int number)
{
   int sb=16;
   //int ns = ShiftLeft(number,sb);
   //int nag = ShiftRight(ns,sb);
   
   //Print("[TestShifts] success=", number == nag,"input=",number,";shiftleft=",ns,"shftright=",nag);
}
void MakeMagicTests()
{
   TestShifts(9876);
   TestShifts(15876);
   TestShifts(17476);
   TestShifts(21476);
   TestShifts(31476);
   TestShifts(19865);
   TestShifts(31752);
   
   datetime dtMin = D'1970.01.01 00:00';
   datetime dtyear = D'1971.01.01 00:00';
   datetime dtmonth = D'1970.02.01 00:00';
   datetime dtday = D'1970.01.02 00:00';
   
   Print("min=",TimeToStr(dtMin),";",dtMin,"year=",dtyear-dtMin,";month=",dtmonth-dtMin,";day=",dtday-dtMin);
   
   datetime dt1 = D'2004.01.01 01';
   datetime dt2 = D'2001.01.02 03';
   
   
   
   TestDate(dt1);
   TestDate(dt2);
   
   
   TestMagic(1,D'2011.01.02 03:04', 66);
   TestMagic(2,D'2001.02.03 04:05', 77);
   TestMagic(3,D'2002.03.04 05:06', 88);
}

void MakeSettingsTests()
{
   
   string sett = " Stop_OffsetPips=0; SA002_Stop_TypeS=\"PER;PIPS;LOHI;\"; SA002_Stop_Lev1=160;"; 
   Print("Input=",sett);
   
   int cnt = String_GetCount(sett, "\"" );
   Print("String_GetCount cnt \" =",cnt,"OK=",cnt == 2 );
   cnt = String_GetCount(sett, ";" );
   Print("String_GetCount cnt ; =",cnt,"OK=",cnt == 6 );
   
 /*  
   " Stop_OffsetPips=0; SA002_Stop_TypeS=\"PER;PIPS;LOHI;\"; SA002_Stop_Lev1=160; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=60;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSignleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;";
*/
   
   int sID =SAV_Settings_Create(sett);
   Print("SA002_Stop_TypeS=", SAV_Settings_GetValueI(sID,SNI_SA002_Stop_TypeS),
         "   ok=",
         SAV_Settings_GetValueI(sID,SNI_SA002_Stop_TypeS)== "PER;PIPS;LOHI;");
   Print("MakeSettingsTests Exit");
}

int init()
{  
   //SAV_SETTINGS_Trace = true;
   Common_InitVarsAll();
   MakeSettingsTests();
   //MakeMagicTests();
// --------------------------- localni sa za edinichen signal

   //TrendBaseName  = "TA001_ZigZag";//Zigzag trend 
   //Trend_TimeFrameS = "H4";
   //OrdersBaseName = "ON001";
   //SignalBaseName = "A001";//Inner bars signal
   
   //Signal_Trace = true; 
   //Orders_Trace = true;
   //Trend_Trace = true;

   //Common_InitAll(0); 

   //MakOrderComentTest();

   return(0);
}
  
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{ 
/*
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
   //*/
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
/*
   if(SignalBaseName != "A001")
   {
      Print("SignalBaseName != A001 error!!!!!!! SignalBaseName=", SignalBaseName);
      return (1);
   }
   
   if( TrendBaseName != "TA001" && A001_TrendOptions > 0)
   {
      Print("TrendBaseName != TA001 error !!!!!!! signala raboti samo s trend A001 ne sys ",TrendBaseName );
      return (1);
   }
   //*/
   // moje i dvata varianta zavisimost ot nujdite
   //Common_Signals_ProcessAll(0);
   //Common_Process(settIDCurrent);
   //A001_Signals_Process(settIDCurrent);
   
   return(0);
}





