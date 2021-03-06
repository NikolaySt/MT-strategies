//+------------------------------------------------------------------+
//|                                         SAN_Portfolio_v2_ADD.mq4 |
//|                                        Copyright © 2011, SANTeam |
//|                                                     version 2ADD |
//|                                Nikolay Stoychev & Andrey Kunchev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, SANTeam /Nikolay Stoychev & Andrey Kunchev/"
#property link      ""

#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
#include <SAN_Systems\Common\CommonHeaderVarsAll.mqh>
#include <SAN_Systems\Common\CommonIncludeAll.mqh> 

extern string Description = "SANTeam.Portfolio.v2_Add(N17_23)_Real";
extern string MM_Portfolio_Descr = "MM_FP_FF";  
extern string MM_Portfolio_BaseName = "MM_FP_FF";
extern string MM_Portfolio_Descr1 = "MM:Метод Райн Джонс";
extern double MM_Portfolio_LotStep = 0.01;
extern double MM_Portfolio_BeginBalance = 1300;
extern double MM_Portfolio_AvailableBalance = 6191.33;
extern double MM_Portfolio_MaxDD = 260;
extern double MM_Portfolio_Delta = 130;
extern double MM_Portfolio_PersentDD = 10;
extern string MM_Portfolio_Descr2 = "Формата на датата трябва да е: yyyy.mm.dd, ако е празен текст не се ползва";
extern string MM_Portfolio_TimeStartS = "2011.08.01";
double MM_Portfolio_RiskPersent = 1;

extern int System1 = 2172;
extern int System2 = 2173;
extern int System3 = 2174;
extern int System4 = 2181;
extern int System5 = 2191;
extern int System6 = 2211;
extern int System7 = 2221;
extern int System8 = 2231;
int System9 = 0;
int System10 = 0;
int System11 = 0;
int System12 = 0;


#define SETTINGS_SIZE 12

#define SYSTEMS_SIZE 3000

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
   //M001_MM_SetTrace(false); 
   //SAV_SETTINGS_Trace = true;   
   
   //скрива индикаторите от графиката
   //HideTestIndicators(true);   
   Common_OptimizedProcess = true;     
   Common_InitVarsAll();
   
   init_systems();   
   init_input_values();   
   int activecnt=0;
   int settID;
   
   globalSettId = SAV_Settings_Create("");   
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
      
      string name = "P."+SignalBaseName;
      if (count > 1) 
         name = "P.Port"; 
      else{
         sys_text = sys_text + "L=" + DoubleToStr(Limit_FixPips, 0)+";S=" + DoubleToStr(InitialStop_Param1, 0)+";";
      }
      
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
      "\n", "  EURO-PORTFOLIO V2 - Copyright © 2011, SAN Team",
      "\n", "  ================================================",
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

/****************************************************************************************************************************************************
  СИСТЕМИ и варианти Николай
//***************************************************************************************************************************************************/   


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N017
//----------------------------------------------------------------------------------------------------------------------------------------------------      
//N017_N1_L300_S230_D462_P6760.htm
   Systems[2171] = 
" Expert_TimeFrameS=\"D1\"; SignalBaseName=\"N017\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N017_Ichimoku_TimeFrameS=\"D1\"; N017_TenkanSen=18; N017_KijinSen=27; N017_SencouSpanB=20; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=300; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=230;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.7;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=6;";
   
//N017_N2_L650_S350_D700_P15176.htm   
   Systems[2172] =
" Expert_TimeFrameS=\"D1\"; SignalBaseName=\"N017\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N017_Ichimoku_TimeFrameS=\"D1\"; N017_TenkanSen=18; N017_KijinSen=27; N017_SencouSpanB=36; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=650; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=350;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.5;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=6;";
   
//N017_N3_L750_S270_D540_P15602_Offset180.htm   
   Systems[2173] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N017\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N017_Ichimoku_TimeFrameS=\"D1\"; N017_TenkanSen=3; N017_KijinSen=21; N017_SencouSpanB=52; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=750; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=270;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=(NULL); ZeroStop_Param1=1.8;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=180;";
   
//N017_N4_L590_S210_D220_P13154_Offset280.htm   
   Systems[2174] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N017\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N017_Ichimoku_TimeFrameS=\"D1\"; N017_TenkanSen=15; N017_KijinSen=32; N017_SencouSpanB=52; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=500; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=210;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=(NULL); ZeroStop_Param1=2.3;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=280;";

//N017_N5_L300_S210_D320_P7454_Offset280.htm
   Systems[2175] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N017\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N017_Ichimoku_TimeFrameS=\"D1\"; N017_TenkanSen=15; N017_KijinSen=32; N017_SencouSpanB=52; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=300; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=210;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"(NULL)\";" +
" ZeroStop_Param1=2.3; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=280;";


   


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N018
//----------------------------------------------------------------------------------------------------------------------------------------------------      

//N018_N1_L950_S65_D260_P12390.htm
   Systems[2181] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N018\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N018_Ichimoku_TimeFrameS=\"D1\"; N018_TenkanSen=14; N018_KijinSen=21; N018_SencouSpanB=52; N018_FoziCount=0;" +
" N018_RSIPeriod=15; N018_MAPeriod=6; N018_MAExitPeriod=4; N018_MAExitShift=4; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\";" +
" Limit_FixPips=950; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=65; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.6; ZeroStop_Param2=0;" +
" StopBaseName=\"SN002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=40;";
   

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N019
//----------------------------------------------------------------------------------------------------------------------------------------------------      

//N019_N1_L750_S60_D419_P11900.htm
   Systems[2191] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N019\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N019_Ichimoku_TimeFrameS=\"D1\"; N019_TenkanSen=13; N019_KijinSen=21; N019_SencouSpanB=52; N019_SignalCount=0;" +
" N019_StochK=5; N019_StochSlow=16; N019_MAExitPeriod=4; N019_MAExitShift=4; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\";" +
" Limit_FixPips=750; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=60; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=2; ZeroStop_Param2=0;" +
" StopBaseName=\"SN002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=50;";
   

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N020
//----------------------------------------------------------------------------------------------------------------------------------------------------      

//N020_N1_L650_S120_D599_P9000.htm
   Systems[2201] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N020\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N020_Ichimoku_TimeFrameS=\"D1\"; N020_TenkanSen=14; N020_KijinSen=5; N020_SencouSpanB=52; N020_SignalCount=0;" +
" N020_MAExitPeriod=3; N020_MAExitShift=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=670; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=120; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.4; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=10;";
   

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N021
//----------------------------------------------------------------------------------------------------------------------------------------------------      

//N021_N1_L450_S70_D643_P13300.htm
   Systems[2211] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N021\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N021_Ichimoku_TimeFrameS=\"D1\"; N021_TenkanSen=6; N021_KijinSen=23; N021_SencouSpanB=64; N021_SignalCount=0;" +
" N021_AOMAFast=1; N021_AOMASlow=12; N021_MAExitPeriod=2; N021_MAExitShift=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\";" +
" Limit_FixPips=450; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=70; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=2.6; ZeroStop_Param2=0;" +
" StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=10;";
      
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N022
//----------------------------------------------------------------------------------------------------------------------------------------------------      

//N022_N1_L900_S200_D906_P23000.htm
   Systems[2221] =   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N022\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N022_Ichimoku_TimeFrameS=\"D1\"; N022_TenkanSen=13; N022_KijinSen=22; N022_SencouSpanB=52; N022_SignalCount=0;" +
" N022_ACMAFast=13; N022_ACMASlow=28; N022_ACMASignal=3; N022_MAExitPeriod=4; N022_MAExitShift=9; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\";" +
" Limit_FixPips=900; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=200; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.6; ZeroStop_Param2=0;" +
" StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=60;";
    
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N023
//----------------------------------------------------------------------------------------------------------------------------------------------------      

//N023_N1_L0_S0_D1160_P25000.htm
   Systems[2231] =    
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N023\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N023_Ichimoku_TimeFrameS=\"D1\"; N023_TenkanSen=13; N023_KijinSen=19; N023_SencouSpanB=52;" +
" N023_ZoneMAFast=5; N023_ZoneMASlow=38; N023_ZoneMASignal=3; N023_ZoneCount=6; N023_MAExitPeriod=4; N023_MAExitShift=4; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=0; InitialStop_TypeS=\"\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=0; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0; ZeroStop_Param2=0;" +
" StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
   
//N023_N2_L0_S0_D712_P18000.htm   
   Systems[2232] =
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N023\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N023_Ichimoku_TimeFrameS=\"D1\"; N023_TenkanSen=13; N023_KijinSen=19; N023_SencouSpanB=52; N023_ZoneMAFast=5;" +
" N023_ZoneMASlow=38; N023_ZoneMASignal=8; N023_ZoneCount=3; N023_MAExitPeriod=3; N023_MAExitShift=5; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=0; InitialStop_TypeS=\"\"; InitialStop_TimeFrameS=\"D1\"; InitialStop_Param1=0; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0; ZeroStop_Param2=0;" +
" StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
          
}