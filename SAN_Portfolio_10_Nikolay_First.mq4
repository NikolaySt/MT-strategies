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

extern string Description = "SANTeam.Portfolio.10.Nikolay.First";
extern string MM_Portfolio_Descr = "MM_FP_FF, MM_FF";  
extern string MM_Portfolio_BaseName = "MM_FP_FF";
extern string MM_Portfolio_Descr1 = "MM:Метод Райн Джонс";
extern double MM_Portfolio_LotStep = 0.1;
extern double MM_Portfolio_BeginBalance = 7192;
extern double MM_Portfolio_AvailableBalance = 0;
extern double MM_Portfolio_MaxDD = 1400;
extern double MM_Portfolio_Delta = 700;
extern double MM_Portfolio_PersentDD = 10;
extern string MM_Portfolio_Descr2 = "Формата на датата трябва да е: yyyy.mm.dd, ако е празен текст не се ползва";
extern string MM_Portfolio_TimeStartS = "2011.01.01";
double MM_Portfolio_RiskPersent = 0;

extern int System1 = 1101;
extern int System2 = 1108;
extern int System3 = 1212;
extern int System4 = 1216;
extern int System5 = 1301;
extern int System6 = 1307;
extern int System7 = 1601;
extern int System8 = 101;
extern int System9 = 110;
extern int System10 = 203;
extern int System11 = 204;
extern int System12 = 311;
extern int System13 = 312;
int System14 = 0;

#define SETTINGS_SIZE 14

#define SYSTEMS_SIZE 2000

string Systems[SYSTEMS_SIZE];

string SETTINGS[SETTINGS_SIZE];
bool   SETTINGS_ENABLED[SETTINGS_SIZE];
int    SETTINGS_ID[SETTINGS_SIZE];

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
   if (!IsTesting()) M001_MM_SetTrace(true);    
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
               
               Common_UpdateCalcVarsAll( settID );                                                     
                                                        
               activecnt++;
            }
            else
            {
               SETTINGS_ENABLED[i] = false;
            }
        }        
   } 
   //*--------------------------------------------------------------------
   //ВРЕМЕННО
   //TRACE на ЗЗ за провекра коректността на работа при реална търговия 
   //принтиране на позледните 5 върха на зигзага когато открие нови
   int zzind = ZZFindIndexFromDepth(1,PERIOD_H4);
   //only to not trace initial calculation of peaks
   ZZValues_Get(zzind,0);
   ZZSetDebugForIndex(zzind,true);
   //--------------------------------------------------------------------*/     
   return(0);
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

int start() { 
   if (!IsTesting() && !IsOptimization()){
      if (StringSubstr(Symbol(), 0, 6) != "EURUSD"){
         Comment("\n", " ГРЕШКА : портфейла работи само на EURUSD");
         Alert("ГРЕШКА : портфейла работи само на EURUSD");
         return(0);
      }         
   }
   int settID;
   for( int i = 0; i < SETTINGS_SIZE; i++ )
   {      
      if( SETTINGS_ENABLED[i] == true)
      {            
         settID = SETTINGS_ID[i];                      
         Common_UpdateVarsAll(settID); 
         Common_Signals_ProcessAll(settID);          
         Common_UpdateCalcVarsAll(settID);          
      }
   }   

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
      "\n", "    Текущ Баланс           : ", AccountBalance(), 
      "\n", "    Теглене                    : ", M001_Comment_Withdrawal,
      "\n", "    Виртуален Баланс    : ", M001_Comment_VB,      
      "\n", "    Салдо                      : ", AccountEquity(),       
      "\n", "    Печалба                  : ", AccountProfit(), 
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

//todo: Съвпада с 307 
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