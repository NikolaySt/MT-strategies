//+------------------------------------------------------------------+
//|                           SAN_Portfolio_v2_var5_Nikolay_Real.mq4 |
//|                                        Copyright © 2011, SANTeam |
//|                                                        version 2 |
//|                                Nikolay Stoychev & Andrey Kunchev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, SANTeam /Nikolay Stoychev & Andrey Kunchev/"
#property link      ""

#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
#include <SAN_Systems\Common\CommonHeaderVarsAll.mqh>
#include <SAN_Systems\Common\CommonIncludeAll.mqh> 

extern string Description = "SANTeam.Portfolio.v2.var5.Nikolay.Real";
extern string MM_Portfolio_Descr = "MM_FP_FF";  
extern string MM_Portfolio_BaseName = "MM_FP_FF";
extern string MM_Portfolio_Descr1 = "MM:Метод Райн Джонс";
extern double MM_Portfolio_LotStep = 0.1;
extern double MM_Portfolio_BeginBalance = 12000;
extern double MM_Portfolio_AvailableBalance = 0;
extern double MM_Portfolio_MaxDD = 2400;
extern double MM_Portfolio_Delta = 1200;
extern double MM_Portfolio_PersentDD = 10;
extern string MM_Portfolio_Descr2 = "Формата на датата трябва да е: yyyy.mm.dd, ако е празен текст не се ползва";
extern string MM_Portfolio_TimeStartS = "2011.07.15";
double MM_Portfolio_RiskPersent = 0;

extern int System1=1011; 
extern int System2=1022; 
extern int System3=1032; 
extern int System4=1035; 
extern int System5=1046; 
extern int System6=1063; 
extern int System7=1072; 
extern int System8=2011; 
extern int System9=2012; 
extern int System10=2013; 
extern int System11=2021; 
extern int System12=2031; 
extern int System13=2041; 
extern int System14=2051; 
extern int System15=2081; 
extern int System16=2091; 
extern int System17=2101; 
extern int System18=2111; 
extern int System19=2121; 
extern int System20=2131; 
extern int System21=2141; 
extern int System22=2151; 
extern int System23=2161;
int System24 = 0;
int System25 = 0;
int System26 = 0;


#define SETTINGS_SIZE 26

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
   //скрива индикаторите от графиката
   HideTestIndicators(true);      
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
      if (System13 != 0) {sys_text  = sys_text + "S13="+System13+";"; count++;}
      if (System14 != 0) {sys_text  = sys_text + "S14="+System14+";"; count++;}
      if (System15 != 0) {sys_text  = sys_text + "S15="+System15+";"; count++;}
      if (System16 != 0) {sys_text  = sys_text + "S16="+System16+";"; count++;}
      if (System17 != 0) {sys_text  = sys_text + "S17="+System17+";"; count++;}
      if (System18 != 0) {sys_text  = sys_text + "S18="+System18+";"; count++;}
      if (System19 != 0) {sys_text  = sys_text + "S19="+System19+";"; count++;}      
      if (System20 != 0) {sys_text  = sys_text + "S20="+System20+";"; count++;}            
      if (System21 != 0) {sys_text  = sys_text + "S21="+System21+";"; count++;}          
      if (System22 != 0) {sys_text  = sys_text + "S22="+System22+";"; count++;}      
      if (System23 != 0) {sys_text  = sys_text + "S23="+System23+";"; count++;}            
      if (System24 != 0) {sys_text  = sys_text + "S24="+System24+";"; count++;}              
      if (System25 != 0) {sys_text  = sys_text + "S25="+System25+";"; count++;}      
      if (System26 != 0) {sys_text  = sys_text + "S26="+System26+";"; count++;}            
      
    
      
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
   init_system( 13, System13 );                
   init_system( 14, System14 );   
   init_system( 15, System15 ); 
   init_system( 16, System16 );
   init_system( 17, System17 ); 
   init_system( 18, System18 );                
   init_system( 19, System19 );          
   init_system( 20, System20 );                
   init_system( 21, System21 );      
   init_system( 22, System22 );                
   init_system( 23, System23 );          
   init_system( 24, System24 );                
   init_system( 25, System25 );              
   init_system( 26, System26 );              
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
   Systems[1011] = 
//A001_N1_L220_S33_P6475_D322.htm   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=9; A001_TrendOptions=3; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=2; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=220; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=33; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0.7; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=-1; SA002_Stop_TypeS=\"LOHI;LOHI;LOHI;\"; SA002_Stop_Lev1=80; SA002_Stop_Lev2=150; SA002_Stop_Lev3=190;" +
" SA002_Stop_Param1_Lev1=2; SA002_Stop_Param1_Lev2=5; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H4\"; SA002_TimeFrameS_Lev2=\"H4\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0;" +
" Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=216;" +
" Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";

   Systems[1012] =    
//A001_N2_L290_S30_P6325_D442.htm   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=8; A001_TrendOptions=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=4; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=31; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0.7; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=90; SA002_Stop_Lev2=160; SA002_Stop_Lev3=260; SA002_Stop_Param1_Lev1=2;" +
" SA002_Stop_Param1_Lev2=4; SA002_Stop_Param1_Lev3=1; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H4\"; SA002_TimeFrameS_Lev2=\"H4\"; SA002_TimeFrameS_Lev3=\"H4\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=240; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=-1;";

   Systems[1013] =    
//A001_N3_L420_S33_P6352_D321   
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=10; A001_TrendOptions=-1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=420; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=33; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=(NULL);" +
" ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=130; SA002_Stop_Lev2=290; SA002_Stop_Lev3=340; SA002_Stop_Param1_Lev1=8;" +
" SA002_Stop_Param1_Lev2=6; SA002_Stop_Param1_Lev3=2; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H4\"; SA002_TimeFrameS_Lev2=\"H4\"; SA002_TimeFrameS_Lev3=\"H4\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=192; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=-5;";  

   Systems[1014] =    
//A001_N4_L420_S38_P6338_D317
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A001\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A001_InnerBars=10; A001_TrendOptions=-1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=430; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=38; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=(NULL);" +
" ZeroStop_Param1=0.6; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=130; SA002_Stop_Lev2=290; SA002_Stop_Lev3=340; SA002_Stop_Param1_Lev1=8;" +
" SA002_Stop_Param1_Lev2=6; SA002_Stop_Param1_Lev3=2; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H4\"; SA002_TimeFrameS_Lev2=\"H4\"; SA002_TimeFrameS_Lev3=\"H4\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=-5;";

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A002
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[1021] =    
//A002_N1_L230_S28_P6460_D534.htm
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=7; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=230; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=28; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=90; SA002_Stop_Lev2=140; SA002_Stop_Lev3=190; SA002_Stop_Param1_Lev1=80;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=20; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-2;";

   Systems[1022] =    
//A002_N2_L230_S47_P6343_D656
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=6; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=230; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=47; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=90; SA002_Stop_Lev2=140; SA002_Stop_Lev3=190; SA002_Stop_Param1_Lev1=80;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=20; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=12;";

   Systems[1023] =    
//A002_N3_L288_S28_P8340_D654
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=5; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=288; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=28; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0.8; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS;\"; SA002_Stop_Lev1=260; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=20;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"D1\"; SA002_TimeFrameS_Lev3=\"D1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-2;";


   Systems[1024] =    
//A002_N4_L420_S32_P9461_D677
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A002\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A002_ZZExtDepth=5; A002_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0;" +
" TA001_ExtDepth=0; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=420; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"\";" +
" InitialStop_Param1=32; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0.7; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=140; Stop_MaxPips=300;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=130; SA002_Stop_Lev2=200; SA002_Stop_Lev3=340; SA002_Stop_Param1_Lev1=5;" +
" SA002_Stop_Param1_Lev2=10; SA002_Stop_Param1_Lev3=2; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"D1\"; SA002_TimeFrameS_Lev2=\"D1\"; SA002_TimeFrameS_Lev3=\"D1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=1;";


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A003
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[1031] =
//A003_N1_L245_S29_P9931_D545   
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=1; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=9; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=245; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"\"; InitialStop_Param1=29; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=2; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\";" +
" Stop_MinPips=140; Stop_MaxPips=300; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=80; SA002_Stop_Lev2=100;" +
" SA002_Stop_Lev3=170; SA002_Stop_Param1_Lev1=0.5; SA002_Stop_Param1_Lev2=0.3; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";

   Systems[1032] =
//A003_N2_L250_S30_P11509_D537
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=1; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=9; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=250; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"\"; InitialStop_Param1=30; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=2.5; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"D1\";" +
" Stop_MinPips=130; Stop_MaxPips=300; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS;PIPS;LOHI;\"; SA002_Stop_Lev1=100; SA002_Stop_Lev2=170;" +
" SA002_Stop_Lev3=200; SA002_Stop_Param1_Lev1=60; SA002_Stop_Param1_Lev2=50; SA002_Stop_Param1_Lev3=1; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H4\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";

   Systems[1033] =
//A003_N3_L290_S28_P9635_D758
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=1; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=9; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"\"; InitialStop_Param1=28; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.7; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\";" +
" Stop_MinPips=160; Stop_MaxPips=300; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS;LOHI;PIPS;\"; SA002_Stop_Lev1=140; SA002_Stop_Lev2=190;" +
" SA002_Stop_Lev3=282; SA002_Stop_Param1_Lev1=50; SA002_Stop_Param1_Lev2=10; SA002_Stop_Param1_Lev3=0.04; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=1;";

   Systems[1034] =
//A003_N4_L290_S30_P10656_D593
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=1; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=9; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"\"; InitialStop_Param1=30; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.5; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\";" +
" Stop_MinPips=140; Stop_MaxPips=300; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=110; SA002_Stop_Lev2=130;" +
" SA002_Stop_Lev3=140; SA002_Stop_Param1_Lev1=0.5; SA002_Stop_Param1_Lev2=95; SA002_Stop_Param1_Lev3=8; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=1;";

   Systems[1035] =
//A003_N5_L410_S28_P6623_D483
" Expert_TimeFrameS=\"H4\"; SignalBaseName=\"A003\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=0; Signal_Year=0;" +
" Signal_WorkByToday=0; A003_SeqPeaks=4; A003_TrendOptions=3; A003_ZZExtDepth=1; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=14; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=410; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"\"; InitialStop_Param1=28; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.7; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\";" +
" Stop_MinPips=190; Stop_MaxPips=300; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI;PIPS;PIPS;\"; SA002_Stop_Lev1=290; SA002_Stop_Lev2=300;" +
" SA002_Stop_Lev3=390; SA002_Stop_Param1_Lev1=1; SA002_Stop_Param1_Lev2=65; SA002_Stop_Param1_Lev3=0.06; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H4\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H4\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=1; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=5;";
 
      
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A004
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[1041] =  
//A004_N1_L225_S38_P12288_D561   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=1; A004_TrendOptions=-1; A004_RemoveOnRevTrend=0; A004_MinBarPips=5; A004_MaxPipsOffset=140;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=225; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=38;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.4;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\";" +
" SA002_Stop_Lev1=220; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0.2; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=2;" +
" Orders_PendExpiration=264; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1042] =  
//A004_N2_L240_S38_P10310_D678
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=1; A004_TrendOptions=-1; A004_RemoveOnRevTrend=0; A004_MinBarPips=10; A004_MaxPipsOffset=150;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=240; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=38;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.25;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\";" +
" SA002_Stop_Lev1=120; SA002_Stop_Lev2=120; SA002_Stop_Lev3=240; SA002_Stop_Param1_Lev1=0.5; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0.1;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=2;" +
" Orders_PendExpiration=336; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";


   Systems[1043] =  
//A004_N3_L150_S43_P7370_D373
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=1; A004_TrendOptions=-1; A004_RemoveOnRevTrend=0; A004_MinBarPips=10; A004_MaxPipsOffset=150;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=150; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=43;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.5;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\";" +
" SA002_Stop_Lev1=150; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1;" +
" Orders_PendExpiration=408; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";


   Systems[1044] =  
//A004_N4_L250_S45_P9420_D486
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=1; A004_TrendOptions=-1; A004_RemoveOnRevTrend=0; A004_MinBarPips=10; A004_MaxPipsOffset=150;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=250; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=45;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.2;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1;" +
" Orders_PendExpiration=360; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";


   Systems[1045] =  
//A004_N5_L230_S43_P11369_D698
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=1; A004_TrendOptions=-1; A004_RemoveOnRevTrend=0; A004_MinBarPips=10; A004_MaxPipsOffset=150;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=230; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=45;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.2;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=2;" +
" Orders_PendExpiration=480; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1046] =  
//A004_N6_L230_S49_P11739_D599
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=1; A004_TrendOptions=-1; A004_RemoveOnRevTrend=0; A004_MinBarPips=10; A004_MaxPipsOffset=150;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=230; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=49;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.4;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=2;" +
" Orders_PendExpiration=384; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

   Systems[1047] =  
//A004_N7_L150_S31_P19161_D1027
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A004\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A004_BarsCount=6; A004_TrendOptions=3; A004_RemoveOnRevTrend=0; A004_MinBarPips=10; A004_MaxPipsOffset=150;" +
" A004_CorrZZDepth=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"H4\"; Trend_MaxLenght=0; TA001_ExtDepth=7; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=150; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=31;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.7;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H4\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\";" +
" SA002_Stop_Lev1=150; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=2; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=3;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=2; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=288; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A005
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[1051] = "";

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A006
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[1061] =   
//A006_N1_L180_S30_P14543_D572  
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A006\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A006_TrendOptions=0; A006_ZZExtDepth=1; A006_MinSignalPeak=0; A006_MaxPeaksBack=6; TrendBaseName=\"\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=180;" +
" InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=30; InitialStop_Param2=0; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.9; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=160;" +
" SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=60; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=-1;";

   Systems[1062] =   
//A006_N2_L180_S37_P9404_D487    
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A006\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A006_TrendOptions=0; A006_ZZExtDepth=6; A006_MinSignalPeak=0; A006_MaxPeaksBack=6; TrendBaseName=\"\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=180;" +
" InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=37; InitialStop_Param2=0; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.9; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=190;" +
" SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=20; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";


   Systems[1063] =   
//A006_N3_L215_S28_P10399_D541      
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A006\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A006_TrendOptions=0; A006_ZZExtDepth=2; A006_MinSignalPeak=0; A006_MaxPeaksBack=6; TrendBaseName=\"\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=215;" +
" InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=28; InitialStop_Param2=0; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.7; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=140;" +
" SA002_Stop_Lev2=150; SA002_Stop_Lev3=210; SA002_Stop_Param1_Lev1=0.7; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0.1;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";


   Systems[1064] =   
//A006_N4_L225_S28_P10389_D617   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A006\"; Signal_TimeFrameS=\"H4\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A006_TrendOptions=0; A006_ZZExtDepth=3; A006_MinSignalPeak=0; A006_MaxPeaksBack=6; TrendBaseName=\"\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TA001_ExtDepth=15; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=225;" +
" InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=28; InitialStop_Param2=0; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.7; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"PIPS\"; SA002_Stop_Lev1=90;" +
" SA002_Stop_Lev2=150; SA002_Stop_Lev3=210; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0.15;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-1;";


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A007
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[1071] = 
//A007_N1_L180_S36_P7800_D349   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A007\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A007_MinSignalBar=0; A007_MaxSearchBarsBack=4; A007_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=180; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=34; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";

   Systems[1072] =    
//A007_N2_L210_S35_P10965_D534   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A007\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A007_MinSignalBar=0; A007_MaxSearchBarsBack=4; A007_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=210; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=36; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=(NULL); ZeroStop_Param1=0.95; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=264;" +
" Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-4;";


   Systems[1073] = 
//A007_N3_L200_S40_P8800_D400   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A007\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A007_MinSignalBar=0; A007_MaxSearchBarsBack=4; A007_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=200; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=38; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";


   Systems[1074] = 
//A007_N4_L210_S40_P12033_D668   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"A007\"; Signal_TimeFrameS=\"D1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; A007_MinSignalBar=0; A007_MaxSearchBarsBack=4; A007_TrendOptions=0; TrendBaseName=\"TA001\"; Trend_TimeFrameS=\"D1\";" +
" Trend_MaxLenght=0; TA001_ExtDepth=5; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=210; InitialStop_TypeS=\"FIXPIPS\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=40; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=(NULL); ZeroStop_Param1=0.95; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=264;" +
" Orders_RemovePendReverser=0; Orders_PendingPipsOffset=-3;";

/****************************************************************************************************************************************************
  СИСТЕМИ и варианти Николай
//***************************************************************************************************************************************************/   


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N001
//----------------------------------------------------------------------------------------------------------------------------------------------------      

   Systems[2011] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=6; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0.2;" +
" N001_LevelRatio1=0.2; N001_LevelRatio2=0.3; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=1; N001_OneLimitByTrend=1;" +
" TrendBaseName=\"TN001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2;" +
" TN001_Atr_Period=2; TN001_Atr_Ratio=0.2; TN001_Bars_Break=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=1250;" +
" InitialStop_TypeS=\"ATR\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=2.1; InitialStop_Param2=35; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"FRAC;NONE;NONE;\"; SA002_Stop_Lev1=0;" +
" SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"D1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";

   Systems[2012] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=1; Signal_TimeEnd=17; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=5; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0.3;" +
" N001_LevelRatio1=0.2; N001_LevelRatio2=0.3; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=1; N001_OneLimitByTrend=0;" +
" TrendBaseName=\"TN001\"; Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2;" +
" TN001_Atr_Period=2; TN001_Atr_Ratio=0.2; TN001_Bars_Break=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=500;" +
" InitialStop_TypeS=\"ATR\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=2.1; InitialStop_Param2=35; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"FRAC;LOHI;\"; SA002_Stop_Lev1=0;" +
" SA002_Stop_Lev2=300; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=24; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"D1\"; SA002_TimeFrameS_Lev2=\"H4\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";

   Systems[2013] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N001\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=1; Signal_TimeEnd=19; Signal_Year=0;" +
" Signal_WorkByToday=0; N001_HeadFr_Bar=3; N001_MinorFr_Bar=7; N001_CountBarFindFr_Sec=5; N001_LimitRatioLevel=0.382; N001_MinCorrWaveRatio=0;" +
" N001_LevelRatio1=0; N001_LevelRatio2=0; N001_CountCloseExtremumBar=1; N001_ActiveTrendLine=1; N001_OneLimitByTrend=0; TrendBaseName=\"TN001\";" +
" Trend_TimeFrameS=\"D1\"; Trend_MaxLenght=0; TN001_MAPeriod=8; TN001_MAShift=2; TN001_MA_Env_Dev=0.2; TN001_Atr_Period=2;" +
" TN001_Atr_Ratio=0.2; TN001_Bars_Break=7; LimitBaseName=\"\"; Limit_TimeFrameS=\"D1\"; Limit_FixPips=150; InitialStop_TypeS=\"ATR\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=2.1; InitialStop_Param2=35; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=20; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"FRAC;LOHI;\"; SA002_Stop_Lev1=100; SA002_Stop_Lev2=140;" +
" SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=12; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H4\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";     


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N002
//----------------------------------------------------------------------------------------------------------------------------------------------------   

   Systems[2021] = 
" SignalBaseName=\"N002\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N002_MACrossTimeFrameS=\"H4\"; N002_MACross_BackBar=0; N002_FastPeriod=1; N002_SlowPeriod=28;" +
" N002_MABreakPeriod=26; N002_Bars_Break=7; N002_ActiveTL=1; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=270;" +
" InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=35; InitialStop_Param2=0; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.2; ZeroStop_Param2=0; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI;\"; SA002_Stop_Lev1=130;" +
" SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=7; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=2; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=1;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N003
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2031] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N003\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N003_BarsCross_TimeFrameS=\"H4\"; N003_FastPeriod=19; N003_SlowPeriod=38; N003_BarsCross_BackBar=18;" +
" N003_Bars_Break=0; N003_MAPeriod=25; N003_ActiveTL=1; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=320; InitialStop_TypeS=\"ATR\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=1.5; InitialStop_Param2=46; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.5; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=200; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=13; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=2;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=-20;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";
   

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N004
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2041] = 
" SignalBaseName=\"N004\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=11; Signal_TimeEnd=17; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N004_MAPeriod=44; N004_BiasPeriod=18; N004_ST_AtdPeriod=21; N004_ST_Multiplier=2; N004_CountCloseExtremumBar=1;" +
" LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=300; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\";" +
" InitialStop_Param1=40; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=1; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0;" +
" SA002_Stop_TypeS=\"LOHI\"; SA002_Stop_Lev1=300; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=13; SA002_Stop_Param1_Lev2=0;" +
" SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\";" +
" SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1;" +
" Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=1; Orders_CloseSame=0;" +
" Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N005
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2051] = 
" SignalBaseName=\"N005\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=13; Signal_TimeEnd=16; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N005_CountCloseExtremumBar=13; N005_BackBarsD1=31; N005_ExtremumBars_Close=0; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=170; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=40;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=2.7;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=20; Stop_MaxPips=80; Stop_OffsetPips=0;" +
" SA002_Stop_TypeS=\"ATR\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=10; SA002_Stop_Param1_Lev2=0;" +
" SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=35; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\";" +
" SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=2; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1;" +
" Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=-20; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0;" +
" Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N006
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2061] = ""; 
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N007
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2071] = ""; 
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N008
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2081] = 
" SignalBaseName=\"N008\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=2; Signal_TimeEnd=20; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N008_BollPeriod=4; N008_FractalBars=11; N008_BackBars=15; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\";" +
" Limit_FixPips=300; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=60; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=1.7; ZeroStop_Param2=0;" +
" StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"LOHI\";" +
" SA002_Stop_Lev1=210; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=6; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0;" +
" Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N009
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2091] = 
" SignalBaseName=\"N009\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N009_BeginTime=2; N009_EndTime=19; N009_AtrPeriodD1=4; N009_PercentOfRange=50; N009_PercentOfOrder=50;" +
" LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=200; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\";" +
" InitialStop_Param1=30; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=3.4; ZeroStop_Param2=50; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"ATR\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=8;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=20; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N010
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2101] =               
" SignalBaseName=\"N010\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=15; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N010_PeriodPeak=24; N010_PeriodBackPeak=11; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=380;" +
" InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=80; InitialStop_Param2=0; InitialStop_MaxPips=0;" +
" InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.9; ZeroStop_Param2=60; StopBaseName=\"SA002\";" +
" Stop_TimeFrameS=\"H1\"; Stop_MinPips=20; Stop_MaxPips=100; Stop_OffsetPips=0; SA002_Stop_TypeS=\"ATR\"; SA002_Stop_Lev1=250;" +
" SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=8; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=2;" +
" SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\";" +
" Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=30; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N011
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2111] =       
" SignalBaseName=\"N011\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0; Signal_WorkByToday=0;" +
" Expert_TimeFrameS=\"H1\"; N011_BeginHour=0; N011_EndHour=2; N011_BollPeriod=28; N011_PrevBreak=-3; N011_BollRangeMinPips=22;" +
" LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=160; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\";" +
" InitialStop_Param1=70; InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=0; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=20; Stop_MaxPips=60;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"ATR\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=2;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=59; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=1; Orders_OnPrevHalfBar=0;" +
" Orders_CloseReverser=1; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N012
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2121] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N012\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=8; Signal_TimeEnd=18; Signal_Year=0;" +
" Signal_WorkByToday=0; N012_BarsSleep=20; N012_RangePips=35; N012_RangeBarsPips=150; N012_BandPeriod=38; N012_Stop_MAPeriod=14;" +
" N012_Stop_MAShift=8; N012_BarsCrossClose=25; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=290; InitialStop_TypeS=\"ATR\";" +
" InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=2.1; InitialStop_Param2=33; InitialStop_MaxPips=0; InitialStop_MinPips=0;" +
" InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.9; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\";" +
" Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0;" +
" SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0;" +
" SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1;" +
" Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=0; Orders_SumProfitInPipsNextOrder=0;" +
" Orders_OnPrevHalfBar=0; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N013
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2131] = 
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N013\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N013_BeginTime=8; N013_AtrPeriodD1=10; N013_PercentOfRange=45; LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\";" +
" Limit_FixPips=170; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=30; InitialStop_Param2=0;" +
" InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=3; ZeroStop_Param2=0;" +
" StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"\";" +
" SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=45;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N014
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2141] =     
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N014\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=11; Signal_TimeEnd=16; Signal_Year=0;" +
" Signal_WorkByToday=0; N014_FastMAPeriod=8; N014_SlowMAPeriod=38; N014_SARStep=0.0039; N014_StochK=2; N014_StochSlow=5;" +
" LimitBaseName=\"\"; Limit_TimeFrameS=\"H1\"; Limit_FixPips=190; InitialStop_TypeS=\"ATR\"; InitialStop_TimeFrameS=\"H1\";" +
" InitialStop_Param1=1.8; InitialStop_Param2=5; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\";" +
" ZeroStop_Param1=1.4; ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0;" +
" Stop_OffsetPips=0; SA002_Stop_TypeS=\"\"; SA002_Stop_Lev1=0; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=0;" +
" SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0; SA002_Stop_Param2_Lev1=0; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0;" +
" SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\"; SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=1; Orders_MaxOpenLossCount=0;" +
" Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1; Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1;" +
" Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1; Orders_PendExpiration=0; Orders_RemovePendReverser=0;" +
" Orders_PendingPipsOffset=0;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N015
//----------------------------------------------------------------------------------------------------------------------------------------------------
   Systems[2151] =   
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N015\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=22; Signal_Year=0;" +
" Signal_WorkByToday=0; N015_Ichimoku_TimeFrameS=\"H1\"; N015_TenkanSen=6; N015_KijinSen=30; N015_SencouSpanB=49; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=190; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=40;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.3;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"ATR\";" +
" SA002_Stop_Lev1=50; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=10; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=1; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=0;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=6;";
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N016
//----------------------------------------------------------------------------------------------------------------------------------------------------

   Systems[2161] =       
" Expert_TimeFrameS=\"H1\"; SignalBaseName=\"N016\"; Signal_TimeFrameS=\"H1\"; Signal_TimeStart=0; Signal_TimeEnd=23; Signal_Year=0;" +
" Signal_WorkByToday=0; N016_MAPeriod=6; N016_WAD_MAPeriod=47; N016_MAFast=8; N016_MASlow=29; N016_MASignal=3; N016_ZoneCount=5; LimitBaseName=\"\";" +
" Limit_TimeFrameS=\"H1\"; Limit_FixPips=280; InitialStop_TypeS=\"FIXPIPS\"; InitialStop_TimeFrameS=\"H1\"; InitialStop_Param1=60;" +
" InitialStop_Param2=0; InitialStop_MaxPips=0; InitialStop_MinPips=0; InitialStop_OffsetPips=0; ZeroStop_TypeS=\"\"; ZeroStop_Param1=0.5;" +
" ZeroStop_Param2=0; StopBaseName=\"SA002\"; Stop_TimeFrameS=\"H1\"; Stop_MinPips=0; Stop_MaxPips=0; Stop_OffsetPips=0; SA002_Stop_TypeS=\"ATR\";" +
" SA002_Stop_Lev1=80; SA002_Stop_Lev2=0; SA002_Stop_Lev3=0; SA002_Stop_Param1_Lev1=9; SA002_Stop_Param1_Lev2=0; SA002_Stop_Param1_Lev3=0;" +
" SA002_Stop_Param2_Lev1=13; SA002_Stop_Param2_Lev2=0; SA002_Stop_Param2_Lev3=0; SA002_TimeFrameS_Lev1=\"H1\"; SA002_TimeFrameS_Lev2=\"H1\";" +
" SA002_TimeFrameS_Lev3=\"H1\"; Orders_MaxOpenCount=0; Orders_MaxOpenLossCount=0; Orders_MaxOpenInSignalTime=1; Orders_MaxCloseInSignalTime=1;" +
" Orders_SumProfitInPipsNextOrder=0; Orders_OnPrevHalfBar=1; Orders_CloseReverser=0; Orders_CloseSame=0; Orders_PendSingleInDir=1;" +
" Orders_PendExpiration=0; Orders_RemovePendReverser=0; Orders_PendingPipsOffset=0;";
   
}