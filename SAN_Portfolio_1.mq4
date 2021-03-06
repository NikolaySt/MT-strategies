//+------------------------------------------------------------------+
//|                                              SAN_Portfolio_1.mq4 |
//|                                        Copyright © 2011, SANTeam |
//|                                Nikolay Stoychev & Andrey Kunchev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, SANTeam /Nikolay Stoychev & Andrey Kunchev/"
#property link      ""

#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
#include <SAN_Systems\Common\CommonHeaderVarsAll.mqh>
#include <SAN_Systems\Common\CommonIncludeAll.mqh> 

extern string Description = "SANTeam.Portfolio.1";
extern string MM_Portfolio_Descr = "MM_FP_FF, MM_FF";  
extern string MM_Portfolio_BaseName = "";
extern string MM_Portfolio_Descr1 = "MM:Метод Райн Джонс";
extern double MM_Portfolio_LotStep = 0.1;
extern double MM_Portfolio_BeginBalance = 5000;
extern double MM_Portfolio_AvailableBalance = 0;
extern double MM_Portfolio_MaxDD = 1000;
extern double MM_Portfolio_Delta = 500;
extern double MM_Portfolio_PersentDD = 10;
extern string MM_Portfolio_Descr2 = "Формата на датата трябва да е: yyyy.mm.dd, ако е празен текст не се ползва";
extern string MM_Portfolio_TimeStartS = "";
extern string MM_Portfolio_Descr3 = "MM:пресмята Лота чрез зададен процент от капитала и големина на стопа";
extern double MM_Portfolio_RiskPersent = 1;

extern int System1 = 101;
extern int System2 = 0;
extern int System3 = 0;
extern int System4 = 0;
extern int System5 = 0;
extern int System6 = 0;
extern int System7 = 0;
extern int System8 = 0;
extern int System9 = 0;
extern int System10 = 0;
extern int System11 = 0;
extern int System12 = 0;
extern int System13 = 0;
extern int System14 = 0;

#define SETTINGS_SIZE 14

#define SYSTEMS_SIZE 2000

string Systems[SYSTEMS_SIZE];

string SETTINGS[SETTINGS_SIZE];
bool   SETTINGS_ENABLED[SETTINGS_SIZE];
int    SETTINGS_ID[SETTINGS_SIZE];

bool Portfolio_Trace = false;

int Portfolio_Init(int settID){
   //трябва да се инициализира в инит() преди Common_InitAll()
   //за да може да се изчислят променливите които се изчисляват   
   MMBaseName = MM_Portfolio_BaseName;
   
   MM_TimeStartS = MM_Portfolio_TimeStartS;          
   MM_LotStep = MM_Portfolio_LotStep;
   
   //-----------------------------------------------
   M001_FP_BeginBalance = MM_Portfolio_BeginBalance;
   M001_FP_AvailableBalance = MM_Portfolio_AvailableBalance;
   M001_FP_MaxDD = MM_Portfolio_MaxDD;
   M001_FP_Delta = MM_Portfolio_Delta;
   M001_FF_PersentDD = MM_Portfolio_PersentDD;  
   
   //-----------------------------------------------
   M002_RiskPersent = MM_Portfolio_RiskPersent;
}

int globalSettId;

int init(){ 
   //ako e false se izpolzva comment
   //SANO_UseMagicFOROT = true;     
   //------------------------------
   M001_MM_SetTrace(true); 
   //MM_Trace = true;
   //Orders_Trace = true;   
   //Signal_Trace = true;
   //Stop_Trace = true;
   //Portfolio_Trace = true;  
   //SAV_SETTINGS_Trace = true; 
   //ZZDebugType = 1;  
   //------------------------------      
      
   Common_OptimizedProcess = true ;     
   Common_InitVarsAll();
     
   init_systems();   
   init_input_values();   
   int activecnt=0;
   int settID;
   
   globalSettId = SAV_Settings_Create("name=global_settings;");
   for( int i = 0; i < SETTINGS_SIZE; i++ )
   {
        SETTINGS_ID[i] = 0;
        if( SETTINGS_ENABLED[i] == true )
        {
            if( StringLen(SETTINGS[i]) > 20 )
            {                              
               SETTINGS_ID[i] =  SAV_Settings_Create(SETTINGS[i]);  
               settID = SETTINGS_ID[i];
                             
               Common_UpdateVarsAll( settID ); 
               
               Portfolio_Init( settID );               
               
               Common_InitAll( settID );                                                                          
               if (Portfolio_Trace) Print("[Portfolio::init()] SignalBaseName = ", SignalBaseName);
               Common_UpdateCalcVarsAll( settID );                                                     
                                                        
               activecnt++;
            }
            else
            {
               SETTINGS_ENABLED[i] = false;
            }
        }        
   } 
   if (Portfolio_Trace) {
      Print("[Portfolio::init()] SAV_Settings_GetTotalCount = ", SAV_Settings_GetTotalCount());
      Print("[Portfolio::init()] ZZIndicatorsCount = ", ZZIndicatorsCount);
      
      for (int izzid = 0; izzid <= ZZIndicatorsCount; izzid++){
         for (int peak = 0; peak <= 10; peak++){
            Portfolio_Debug_ZZDrawPeak(izzid+"_"+peak+"_"+Period(), ZZTimes_Get(izzid, peak), ZZValues_Get(izzid, peak));
         }
      }
      //start(); // za da moje da napravi edin cikal kogato niama aktiven pazar t.e. niama tikove            
      //Internal_Histroy_TradesToDll("Port", "");      
   }
   
   
   
   ///*
   //принтиране на позледните 5 върха на зигзага когато открие нови
   //int zzind = ZZFindIndexFromDepth(1,PERIOD_H4);
   //only to not trace initial calculation of peaks
   //ZZValues_Get(zzind,0);
   //ZZSetDebugForIndex(zzind,true);
   //*/  
    
   
   return(0);   
}

void Portfolio_Debug_ZZDrawPeak(string name, datetime time, double price){                     
   if (time > 0){
      if ( ObjectFind(name) < 0 ) ObjectCreate(name, OBJ_ARROW, 0, 0, 0);    
      ObjectSet(name, OBJPROP_ARROWCODE, 159);
      ObjectMove(name, 0, time, price);   
      int clr = Silver;
      if (Period() == PERIOD_D1) clr = Yellow;
      if (Period() == PERIOD_H4) clr = White;
      if (Period() == PERIOD_H1) clr = Red;
      ObjectSet(name, OBJPROP_COLOR, clr);   
      ObjectSetText(name, DoubleToStr(Period(), 0));
   }
}

int deinit(){

   if (IsTesting()){         
      if (!IsOptimization()){
         Stat_HistOrdersToFile(false, 5000, "history_portfolio.txt");
         Stat_DropDownToFile(false, 5000, "dropdown_portfolio.txt");
         Stat_AvgAnnualReturn(5000);
         Stat_SumMonthlyProfitToFile("monthly_profit_portfolio.txt");
         Stat_CalcMO(true);                                   
      }                               
            
      //-------------------------------------------------------------------------------
      string sys_text = "";
      int count = 0;
      if (System1 != 0) {sys_text  = "S1="+System1+";"; count++;}
      if (System2 != 0) {sys_text  = sys_text + "S2="+System2+";"; count++;}
      if (System3 != 0) {sys_text  = sys_text + "S3="+System3+";"; count++;}
      if (System4 != 0) {sys_text  = sys_text + "S4="+System4+";"; count++;}
      if (System5 != 0) {sys_text  = sys_text + "S5="+System5+";"; count++;}
      if (System6 != 0) {sys_text  = sys_text + "S6="+System6+";"; count++;}
      if (System7 != 0) {sys_text  = sys_text + "S7="+System7+";"; count++;}
      if (System8 != 0) {sys_text  = sys_text + "S8="+System8+";"; count++;}
      if (System9 != 0) {sys_text  = sys_text + "S9="+System9+";"; count++;}
      if (System10 != 0) {sys_text  = sys_text + "S10="+System10+";"; count++;}
      if (System11 != 0) {sys_text  = sys_text + "S11="+System11+";"; count++;}
      if (System12 != 0) {sys_text  = sys_text + "S12="+System12+";"; count++;}
      if (System13 != 0) {sys_text  = sys_text + "S13="+System13+";"; count++;}
      if (System14 != 0) {sys_text  = sys_text + "S14="+System14+";"; count++;}
    
      
      string name = "P."+SignalBaseName;
      if (count > 1) name = "P.Port";
      
      Stat_HistOrdersToDll_Params(name, sys_text);       
      //-------------------------------------------------------------------------------
   }   
   return(0);
}
/*
#define SIZE_HIST_ARRAY 500
#import "StatisticsDll.dll"  
   int AddNewSystemTrades(string SysName, string Params, int& arr_years[], int& arr_months[], int& arr_days[], int& arr_hours[], double& arr_profit[], int size);
#import
void Internal_Histroy_TradesToDll(string SignalBaseName, string Params){      
   //int i, hstTotal = HistoryTotal();     
   
   int index = 0; 
   datetime date;
   
   int arr_years[SIZE_HIST_ARRAY], arr_months[SIZE_HIST_ARRAY], arr_days[SIZE_HIST_ARRAY], arr_hours[SIZE_HIST_ARRAY];
   double arr_profit[SIZE_HIST_ARRAY];
   
   ArrayInitialize(arr_years, 0);
   ArrayInitialize(arr_months, 0);
   ArrayInitialize(arr_days, 0);
   ArrayInitialize(arr_hours, 0);
   ArrayInitialize(arr_profit, 0.0);
   index = 0;
   int arr_inc = 20;// увеличение на масива
   double max_balance = MM_History_MaxBalance_SortByCT(M001_FP_BeginBalance, M001_FP_AvailableBalance, MM_TimeStart, M001_Tickets);
   int hstTotal = ArraySize(M001_Tickets);
   for(int i = 0; i < hstTotal; i++){
   //for(i = 0; i < hstTotal; i++){
      if (OrderSelect(M001_Tickets[i], SELECT_BY_TICKET, MODE_HISTORY)){
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){                        
            date = OrderCloseTime();
            arr_years[index] = TimeYear(date);
            arr_months[index] = TimeMonth(date);
            arr_days[index] = TimeDay(date);
            arr_hours[index] = TimeHour(date);
            arr_profit[index] =  OrderProfit();
            index++;
            if (index >= ArraySize(arr_profit)) {
               ArrayResize(arr_years, index + arr_inc);               
               ArrayResize(arr_months, index + arr_inc);               
               ArrayResize(arr_days, index + arr_inc);               
               ArrayResize(arr_hours, index + arr_inc);               
               ArrayResize(arr_profit, index + arr_inc);               
            }               
         }            
      }
   }
   
   
   if(IsDllsAllowed()){    
      AddNewSystemTrades(SignalBaseName, Params, arr_years, arr_months, arr_days, arr_hours, arr_profit, index);      
   }      
   
}
*/


int start() {   
   
   if (!IsTesting() && !IsOptimization()){
      if (StringSubstr(Symbol(), 0, 6) != "EURUSD"){
         Comment("\n", " ГРЕШКА : портфейла работи само на EURUSD");
         Alert("ГРЕШКА : портфейла работи само на EURUSD");
         return(0);
      }         
   }
   //Print("BrokerLevel = ", MinBrokerLevel(), ", PipsToPoints = ", PipsToPoints(10));
   int settID;
   for( int i = 0; i < SETTINGS_SIZE; i++ )
   {      
      if( SETTINGS_ENABLED[i] == true)
      {            
         settID = SETTINGS_ID[i];                      
         //*
         Common_UpdateVarsAll(settID);         
         Common_Signals_ProcessAll(settID);          
         Common_UpdateCalcVarsAll( settID );          
         //*/
                          
         /*------------------------------------DEBUG na MM---------------------------------------------------
         //Print("Time[] = ", Time[0], ", settID = ", settID, ", SignalBaseIndex = ", SignalBaseIndex, ", MAGIC = ", MAGIC);
         //trace MM da zapo4va ot opredelena data i sas razli4en na4alen kapitala ot na4alnia kapital na MM
         if ((settID >= 8 )&& Time[0] < StrToTime("2005.01.01")){ 
            
            Common_UpdateVarsAll(settID);                     
            //Print("MM_TimeStart = ", TimeToStr(MM_TimeStart), ", MMBaseIndex = ", MMBaseIndex);
            MMBaseIndex = 0; 
            Common_Signals_ProcessAll(settID);  
            Common_UpdateCalcVarsAll( settID ); 
         }else{        
            if (settID <= 7 && Time[0] > StrToTime(MM_Portfolio_TimeStartS)){         
               Common_UpdateVarsAll(settID); 
               Common_Signals_ProcessAll(settID);  
               Common_UpdateCalcVarsAll( settID ); 
            }           
         }                  
         //------------------------------------------------------------------------------------------------*/
         
      }
   }        

   /*
   static int close_count = 0;
   double prof = SumOrdersProfitInPipsCurr();
   int count = CountAllOpenOrders();
   if ( count > 4)
      if( prof/count > 200 ) 
   {
      close_count++;
      Print("[CloseAllOrders] count=",count,";profit=",prof,";close_count=",close_count);
      Orders_CloseAll();
   }
   //*/
   
   if (!IsTesting()) AddComment();
   return(0);
}


void AddComment(){
   //индекс 0 от историята винаги връща първоначалната вноска по сметката
   //следователно ако е цялата история от началото ще ни върне oradertype = 6     
   string hist_info = "ГРЕШКА: историята е непълна.";   
   if (OrderSelect(0, SELECT_BY_POS, MODE_HISTORY)){
      if (OrderType() == 6 && OrderProfit() > 0){
         hist_info = "историята е ОК";
      }else{
         Alert(hist_info);
      }
   }else{
      Alert(hist_info);
   }   
   
   Comment(
      "\n", "  EURO-PORTFOLIO - Copyright © 2011, SAN Team",
      "\n", "  ========================================",
      "\n", 
      "\n", "   ММ параметри",  
      "\n", "      Ниво: ",  M001_Comment_Level, " Общт риск ", M001_Comment_Risk*100, "%",
      "\n", "      Праг 1 ", M001_Comment_Limit1, 
      "\n", "      Праг 2 ", M001_Comment_Limit21, " Праг 2(30%) ", M001_Comment_Limit22, 
      "\n", "      Праг 3 ", M001_Comment_Limit3, 
      "\n", "  --------------------------------------------------------------------------------------",      
      "\n",       
      "\n", "    Текущо пропадане ", M001_Comment_DD, " (", M001_Comment_DD_Percent*100, " %)",
      "\n", "  --------------------------------------------------------------------------------------", 
      "\n", "    Текущ Баланс        : ", AccountBalance(), 
      "\n", "    Теглене           : ", M001_Comment_Withdrawal,    
      "\n", "    Виртуален Баланс : ", M001_Comment_VB,      
      "\n", "    Салдо                   : ", AccountEquity(),       
      "\n", "    Печалба               : ", AccountProfit(), 
      "\n", "  --------------------------------------------------------------------------------------", 
      "\n", "    Текущи поръчки        : ", OrdersTotal(),       
      "\n", "    Приключени поръчки : ", OrdersHistoryTotal(), "/", hist_info, "/",
      "\n");
}


void init_input_values()
{
   int i;
   for( i = 0; i < SETTINGS_SIZE; i++ )
   {
      SETTINGS_ENABLED[i] = false;
   }   
   init_system( 1, System1 );
   init_system( 2, System2 ); 
   init_system( 3, System3 );                
   init_system( 4, System4 );   
   init_system( 5, System5 );   
   init_system( 6, System6 );   
   init_system( 7, System7 );                
   init_system( 8, System8 );   
   init_system( 9, System9 );   
   init_system( 10, System10 ); 
   init_system( 11, System11 );
   init_system( 12, System12 ); 
   init_system( 13, System13 );                
   init_system( 14, System14 );        
}

void init_system( int index, int id )
{
   if( id > 0 )
   {      
      string sys_setting = GetSystemConfiguration(id);      
      if (sys_setting != ""){
         SETTINGS_ENABLED[index] = true;
         SETTINGS[index] = sys_setting;
      }else{
         Print("[init_system]: Невалиден номер System"+index+" = "+id);         
         Alert("[init_system]: Невалиден номер System"+index+" = "+id);
      }
   }  
}

string GetSystemConfiguration( int id )
{      
   return (Systems[id]);
}



void init_systems(){  
   //инициализира масива с празни стрингове преди да запълни данните
   for(int i = 0; i < SYSTEMS_SIZE; i++ ) { Systems[i] = "";}   
   
   Systems[0] = "";            
/****************************************************************************************************************************************************
  СИСТЕМИ и варианти Андрей
//***************************************************************************************************************************************************/   
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A001
//----------------------------------------------------------------------------------------------------------------------------------------------------   
   Systems[101] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=9; A001_TrendOptions=3; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=2; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=380; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=33; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=22; SA001_Stop_PipsOffset=-1; SA001_Stop_t1_ZZDepth=8; SA001_Stop_Pips1=30; SA001_Stop_Pips2=135;" +
" SA001_Stop_Pips3=140; SA001_Stop_Percent1=60; SA001_Stop_Percent2=50; SA001_Stop_Percent3=0; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=240; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";

   Systems[102] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=10; A001_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=420; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=30; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=2; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=20; SA001_Stop_Pips2=220;" +
" SA001_Stop_Pips3=310; SA001_Stop_Percent1=130; SA001_Stop_Percent2=55; SA001_Stop_Percent3=44; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=2;";

   Systems[103] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=11; A001_TrendOptions=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=310; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=33; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=15; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=50; SA001_Stop_Pips2=180;" +
" SA001_Stop_Pips3=250; SA001_Stop_Percent1=160; SA001_Stop_Percent2=60; SA001_Stop_Percent3=30; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=2;";

   Systems[104] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=5; A001_TrendOptions=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=10; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=340; Limit_ATRActive=0; Limit_ATRRatio=0;" +
" Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0;" +
" StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0;" +
" Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=28; SN001_InitialStopParam2=0;" +
" SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=10; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=8; SA001_Stop_Pips1=0; SA001_Stop_Pips2=210;" +
" SA001_Stop_Pips3=280; SA001_Stop_Percent1=100; SA001_Stop_Percent2=25; SA001_Stop_Percent3=4; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[105] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=6; A001_TrendOptions=3; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=250; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=30; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=2; SA001_Stop_t1_ZZDepth=8; SA001_Stop_Pips1=15; SA001_Stop_Pips2=135;" +
" SA001_Stop_Pips3=140; SA001_Stop_Percent1=130; SA001_Stop_Percent2=50; SA001_Stop_Percent3=2; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=2;";

//-----------------
//todo: povtatia se da se premahne
   //Systems[106] = Systems[101];
   /*
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=9; A001_TrendOptions=3; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=2; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=380; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=37; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=46; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=40; SA001_Stop_Pips2=120;" +
" SA001_Stop_Pips3=260; SA001_Stop_Percent1=60; SA001_Stop_Percent2=90; SA001_Stop_Percent3=50; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";
*/
   Systems[107] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=9; A001_TrendOptions=3; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=2; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=380; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=37; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=22; SA001_Stop_PipsOffset=-1; SA001_Stop_t1_ZZDepth=8; SA001_Stop_Pips1=30; SA001_Stop_Pips2=135;" +
" SA001_Stop_Pips3=140; SA001_Stop_Percent1=60; SA001_Stop_Percent2=50; SA001_Stop_Percent3=0; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";

   Systems[108] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=10; A001_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=420; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=40; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=60; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=20; SA001_Stop_Pips2=220;" +
" SA001_Stop_Pips3=380; SA001_Stop_Percent1=130; SA001_Stop_Percent2=70; SA001_Stop_Percent3=5; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=2;";

   Systems[109] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=5; A001_TrendOptions=11; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=8; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=340; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=28; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=10; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=8; SA001_Stop_Pips1=0; SA001_Stop_Pips2=210;" +
" SA001_Stop_Pips3=280; SA001_Stop_Percent1=100; SA001_Stop_Percent2=25; SA001_Stop_Percent3=4; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";

   Systems[110] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=10; A001_TrendOptions=-1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=420; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=40; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=60; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=20; SA001_Stop_Pips2=220;" +
" SA001_Stop_Pips3=380; SA001_Stop_Percent1=130; SA001_Stop_Percent2=70; SA001_Stop_Percent3=5; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=2;";


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A002
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[201] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=5; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=390; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=31; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=50; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=50; SA001_Stop_Pips2=60;" +
" SA001_Stop_Pips3=360; SA001_Stop_Percent1=130; SA001_Stop_Percent2=100; SA001_Stop_Percent3=44; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";

   Systems[202] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=6; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=230; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=45; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=6; SA001_Stop_t1_ZZDepth=8; SA001_Stop_Pips1=30; SA001_Stop_Pips2=110;" +
" SA001_Stop_Pips3=190; SA001_Stop_Percent1=150; SA001_Stop_Percent2=120; SA001_Stop_Percent3=64; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=9;";

   Systems[203] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=7; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=280; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=46; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=30; SA001_Stop_Pips2=170;" +
" SA001_Stop_Pips3=190; SA001_Stop_Percent1=150; SA001_Stop_Percent2=130; SA001_Stop_Percent3=56; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=9;";

//---------------------
   Systems[204] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=7; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=280; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SA001\";" +
" Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=46; SN001_InitialStopParam2=0; SA001_Stop_Type=2;" +
" SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0; SA001_Stop_Pips1=80; SA001_Stop_Pips2=170;" +
" SA001_Stop_Pips3=190; SA001_Stop_Percent1=140; SA001_Stop_Percent2=130; SA001_Stop_Percent3=56; Orders_OneLimitByTrend=0;" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=9;";

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A003
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[301] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=3; A003_TrendOptions=3; A003_ZZExtDepth=2; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=315; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=31;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=88; SA001_Stop_PipsOffset=1; SA001_Stop_t1_ZZDepth=18;" +
" SA001_Stop_Pips1=0; SA001_Stop_Pips2=0; SA001_Stop_Pips3=0; SA001_Stop_Percent1=0; SA001_Stop_Percent2=0; SA001_Stop_Percent3=0;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=4;";

   Systems[302] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=3; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=315; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=31;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=88; SA001_Stop_PipsOffset=1; SA001_Stop_t1_ZZDepth=18;" +
" SA001_Stop_Pips1=0; SA001_Stop_Pips2=0; SA001_Stop_Pips3=0; SA001_Stop_Percent1=0; SA001_Stop_Percent2=0; SA001_Stop_Percent3=0;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=4;";

   Systems[303] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=2; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=270; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=28;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=1; SA001_Stop_ZeroLossPips=16; SA001_Stop_PipsOffset=1; SA001_Stop_t1_ZZDepth=18;" +
" SA001_Stop_Pips1=0; SA001_Stop_Pips2=100; SA001_Stop_Pips3=290; SA001_Stop_Percent1=90; SA001_Stop_Percent2=50; SA001_Stop_Percent3=10;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=-1;";

   Systems[304] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=395; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=160; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=28;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=1; SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=5; SA001_Stop_t1_ZZDepth=19;" +
" SA001_Stop_Pips1=130; SA001_Stop_Pips2=230; SA001_Stop_Pips3=250; SA001_Stop_Percent1=170; SA001_Stop_Percent2=35; SA001_Stop_Percent3=30;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=7;";

   Systems[305] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=395; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=160; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=28;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=1; SA001_Stop_ZeroLossPips=14; SA001_Stop_PipsOffset=5; SA001_Stop_t1_ZZDepth=19;" +
" SA001_Stop_Pips1=130; SA001_Stop_Pips2=230; SA001_Stop_Pips3=250; SA001_Stop_Percent1=170; SA001_Stop_Percent2=35; SA001_Stop_Percent3=30;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=7;";

   Systems[306] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=260; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=160; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=45;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0;" +
" SA001_Stop_Pips1=120; SA001_Stop_Pips2=140; SA001_Stop_Pips3=220; SA001_Stop_Percent1=130; SA001_Stop_Percent2=120; SA001_Stop_Percent3=5;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=7;";

   Systems[307] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=1; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=8; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=295; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"D1\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=29;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=48; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0;" +
" SA001_Stop_Pips1=50; SA001_Stop_Pips2=70; SA001_Stop_Pips3=70; SA001_Stop_Percent1=20; SA001_Stop_Percent2=55; SA001_Stop_Percent3=0;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";

   Systems[308] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=5; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=1; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=54;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=1; SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=-2; SA001_Stop_t1_ZZDepth=6;" +
" SA001_Stop_Pips1=200; SA001_Stop_Pips2=270; SA001_Stop_Pips3=390; SA001_Stop_Percent1=70; SA001_Stop_Percent2=45; SA001_Stop_Percent3=0;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=-2;";

//---------------------
   Systems[309] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=280; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=160; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=45;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0;" +
" SA001_Stop_Pips1=110; SA001_Stop_Pips2=140; SA001_Stop_Pips3=220; SA001_Stop_Percent1=50; SA001_Stop_Percent2=120; SA001_Stop_Percent3=5;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=7;";

   //Systems[310] = Systems[311];
//todo: da se pramahne 310 izpolzva se 311 povtaria se
/*
   Systems[310] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=280; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=160; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=45;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0;" +
" SA001_Stop_Pips1=110; SA001_Stop_Pips2=140; SA001_Stop_Pips3=260; SA001_Stop_Percent1=50; SA001_Stop_Percent2=0; SA001_Stop_Percent3=10;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=7;";
*/
   Systems[311] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=260; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"H4\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=160; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=45;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=0; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0;" +
" SA001_Stop_Pips1=120; SA001_Stop_Pips2=140; SA001_Stop_Pips3=220; SA001_Stop_Percent1=130; SA001_Stop_Percent2=120; SA001_Stop_Percent3=5;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=7;";

 
  Systems[312] = Systems[307];
//todo: Съвпада с 307
/*
   Systems[312] =
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=1; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=8; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=295; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SA001\"; Stop_TimeFrameS=\"D1\"; Stop_TimeBegin=0; Stop_TimeEnd=0; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=140; Stop_MaxPips=300; SN001_InitialStopType=1; SN001_InitialStopParam1=29;" +
" SN001_InitialStopParam2=0; SA001_Stop_Type=2; SA001_Stop_ZeroLossPips=48; SA001_Stop_PipsOffset=0; SA001_Stop_t1_ZZDepth=0;" +
" SA001_Stop_Pips1=50; SA001_Stop_Pips2=70; SA001_Stop_Pips3=70; SA001_Stop_Percent1=20; SA001_Stop_Percent2=55; SA001_Stop_Percent3=0;" +
" Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";
*/

/****************************************************************************************************************************************************
  СИСТЕМИ и варианти Николай
//***************************************************************************************************************************************************/   


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N001
//----------------------------------------------------------------------------------------------------------------------------------------------------      
   Systems[1101] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=6; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0.2;" +
" N001_MinCorrTimeRatio=0; N001_LevelRatio1=0.2; N001_LevelRatio2=0.3; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=1; TrendBaseName=\"TN001\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2; TN001_Atr_Period=2;" +
" TN001_Atr_Ratio=0.2; TN001_Bars_Break=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=1250; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=2.2;" +
" SN001_InitialStopParam2=34; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.9;" +
" SN002_Stop_ZeroRatio=0.4; SN002_Stop_Fractals=1; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=1; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1103] =   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=6; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0;" +
" N001_LevelRatio1=0; N001_LevelRatio2=0; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=0; TrendBaseName=\"TN001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2; TN001_Atr_Period=2; TN001_Atr_Ratio=0.2; TN001_Bars_Break=7;" +
" LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=1250; Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0;" +
" InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0; InitialStop_Minimal=0; StopBaseName=\"SN002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0; Stop_TPDistancePips=0; Stop_OpenDistancePips=0;" +
" Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=2.2; SN001_InitialStopParam2=34; SN002_Stop_Save=1;" +
" SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.9; SN002_Stop_ZeroRatio=0.4; SN002_Stop_Fractals=1;" +
" SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=1; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1;" +
" Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0;" +
" Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1104] =   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=17; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=2; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0.3;" +
" N001_LevelRatio1=0.2; N001_LevelRatio2=0.3; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=1; TrendBaseName=\"TN001\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2; TN001_Atr_Period=2;" +
" TN001_Atr_Ratio=0.2; TN001_Bars_Break=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=500; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=2.1;" +
" SN001_InitialStopParam2=31; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=0.9;" +
" SN002_Stop_ZeroRatio=0.3; SN002_Stop_Fractals=1; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1108] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=17; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=5; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0.3;" +
" N001_LevelRatio1=0.2; N001_LevelRatio2=0.3; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=1; TrendBaseName=\"TN001\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2; TN001_Atr_Period=2;" +
" TN001_Atr_Ratio=0.2; TN001_Bars_Break=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=500; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=2.1;" +
" SN001_InitialStopParam2=31; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=0.9;" +
" SN002_Stop_ZeroRatio=0.3; SN002_Stop_Fractals=1; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N002
//----------------------------------------------------------------------------------------------------------------------------------------------------   

Systems[1202] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=4; N002_FastPeriod=9; N002_SlowPeriod=25;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.6; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1203] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=4; N002_FastPeriod=13; N002_SlowPeriod=17;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1205] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=14; N002_SlowPeriod=20;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1206] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=15; N002_SlowPeriod=22;" +
" N002_MABreakPeriod=27; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1207] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=9; N002_SlowPeriod=26;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1208] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=10; N002_SlowPeriod=25;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1210] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=15; N002_SlowPeriod=20;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1211] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=9; N002_SlowPeriod=25;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1212] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=14; N002_SlowPeriod=20;" +
" N002_MABreakPeriod=26; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1214] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=10; N002_SlowPeriod=26;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1215] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=9; N002_SlowPeriod=26;" +
" N002_MABreakPeriod=23; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1216] =
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=5; N002_FastPeriod=12; N002_SlowPeriod=22;" +
" N002_MABreakPeriod=26; N002_Bars_Break=7; N002_MPModa_BackBar=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=65;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=0; SN002_Stop_ProfitOffset=3; SN002_Stop_Ratio=0.7;" +
" SN002_Stop_ZeroRatio=0.5; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N003
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[1301] =       
" SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=18; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=18; N003_SlowPeriod=38; N003_BarsCross_BackBar=2;" +
" N003_Bars_Break=12; N003_MAPeriod=25; N003_MAShift=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=1.5;" +
" SN001_InitialStopParam2=46; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=1.5;" +
" SN002_Stop_ZeroRatio=0.7; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";   

   Systems[1302] = 
" SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=18; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=18; N003_SlowPeriod=38; N003_BarsCross_BackBar=2;" +
" N003_Bars_Break=12; N003_MAPeriod=25; N003_MAShift=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=1.7;" +
" SN001_InitialStopParam2=25; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=0.3;" +
" SN002_Stop_ZeroRatio=1.6; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1304] = 
" SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=18; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=18; N003_SlowPeriod=37; N003_BarsCross_BackBar=2;" +
" N003_Bars_Break=12; N003_MAPeriod=25; N003_MAShift=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=1.5;" +
" SN001_InitialStopParam2=46; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=1.5;" +
" SN002_Stop_ZeroRatio=0.7; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
  
   Systems[1306] =    
" SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=18; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=18; N003_SlowPeriod=38; N003_BarsCross_BackBar=2;" +
" N003_Bars_Break=12; N003_MAPeriod=25; N003_MAShift=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=1.5;" +
" SN001_InitialStopParam2=46; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=1.5;" +
" SN002_Stop_ZeroRatio=2; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1307] = 
" SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=18; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=18; N003_SlowPeriod=38; N003_BarsCross_BackBar=2;" +
" N003_Bars_Break=12; N003_MAPeriod=25; N003_MAShift=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=1.5;" +
" SN001_InitialStopParam2=46; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=1.5;" +
" SN002_Stop_ZeroRatio=0.7; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1308] = 
" SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=3; Signal_TimeEnd=18; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=17; N003_SlowPeriod=31; N003_BarsCross_BackBar=2;" +
" N003_Bars_Break=12; N003_MAPeriod=26; N003_MAShift=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; Limit_ATRActive=0;" +
" Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=3; SN001_InitialStopParam1=1.5;" +
" SN001_InitialStopParam2=46; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=1; SN002_Stop_ProfitOffset=1; SN002_Stop_Ratio=1.5;" +
" SN002_Stop_ZeroRatio=0.7; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N006
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[1601] =    
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N006\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N006_ZZTimeFrameS=\"H1\"; N006_ZZDepth=6; N006_RatioFilter=0.5; N006_BarsOffset=5; TrendBaseName=\"TA001\";" +
" Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=2; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=280;" +
" Limit_ATRActive=0; Limit_ATRRatio=0; Limit_ATRPeriod=0; InitialStopBaseName=\"SN001\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Maximum=0;" +
" InitialStop_Minimal=0; StopBaseName=\"SN002\"; Stop_TimeFrameS=\"H1\"; Stop_TimeBegin=0; Stop_TimeEnd=23; Stop_OffsetMinutes=0;" +
" Stop_TPDistancePips=0; Stop_OpenDistancePips=0; Stop_MinPips=0; Stop_MaxPips=0; SN001_InitialStopType=1; SN001_InitialStopParam1=85;" +
" SN001_InitialStopParam2=0; SN002_Stop_Save=1; SN002_Stop_ZeroOffset=90; SN002_Stop_ProfitOffset=90; SN002_Stop_Ratio=1.5;" +
" SN002_Stop_ZeroRatio=0.2; SN002_Stop_Fractals=0; SN002_Stop_TimeFrameS=\"D1\"; Orders_OneLimitByTrend=0; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";   
      
}