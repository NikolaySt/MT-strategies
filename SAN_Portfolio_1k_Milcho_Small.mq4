//+------------------------------------------------------------------+
//|                                              SAN_Portfolio_1.mq4 |
//|                                        Copyright � 2011, SANTeam |
//|                                Nikolay Stoychev & Andrey Kunchev |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2011, SANTeam /Nikolay Stoychev & Andrey Kunchev/"
#property link      ""

#include <SAN_Systems\Common\CommonUtilsInclude.mqh>
#include <SAN_Systems\Common\CommonHeaderVarsAll.mqh>
#include <SAN_Systems\Common\CommonIncludeAll.mqh>

extern string Description = "SANTeam.Portfolio.1k.Milcho.Small";
extern string MM_Portfolio_Descr = "MM_FP_FF, MM_FF";  
extern string MM_Portfolio_BaseName = "MM_FP_FF";
extern string MM_Portfolio_Descr1 = "MM:����� ���� �����";
extern double MM_Portfolio_LotStep = 0.1;
extern double MM_Portfolio_BeginBalance = 2600;
extern double MM_Portfolio_AvailableBalance = 0;
extern double MM_Portfolio_MaxDD = 500;
extern double MM_Portfolio_Delta = 250;
extern double MM_Portfolio_PersentDD = 10;
extern string MM_Portfolio_Descr2 = "������� �� ������ ������ �� �: yyyy.mm.dd, ��� � ������ ����� �� �� ������";
extern string MM_Portfolio_TimeStartS = "2011.01.01";
string MM_Portfolio_Descr3 = "MM:�������� ���� ���� ������� ������� �� �������� � �������� �� �����";
double MM_Portfolio_RiskPersent = 1;

extern int System1 = 1103;
extern int System2 = 1212;
extern int System3 = 1601;
int System4 = 0;
int System5 = 0;
int System6 = 0;
int System7 = 0;
int System8 = 0;
int System9 = 0;
int System10 = 0;
int System11 = 0;
int System12 = 0;
int System13 = 0;
int System14 = 0;

#define SETTINGS_SIZE 14

#define SYSTEMS_SIZE 2000

string Systems[SYSTEMS_SIZE];

string SETTINGS[SETTINGS_SIZE];
bool   SETTINGS_ENABLED[SETTINGS_SIZE];
int    SETTINGS_ID[SETTINGS_SIZE];

int Portfolio_Init(int settID){
   //������ �� �� ������������ � ����() ����� Common_InitAll()
   //�� �� ���� �� �� �������� ������������ ����� �� ����������   
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
         Comment("\n", " ������ : ��������� ������ ���� �� EURUSD");
         Alert("������ : ��������� ������ ���� �� EURUSD");
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
         Common_UpdateCalcVarsAll( settID );          
      }
   }   
   
   if (!IsTesting()) AddComment();
   return(0);
}

void AddComment(){
   //������ 0 �� ��������� ������ ����� �������������� ������ �� ��������
   //������������ ��� � ������ ������� �� �������� �� �� ����� oradertype = 6     
   string hist_info = "������: ��������� � �������.";   
   if (OrderSelect(0, SELECT_BY_POS, MODE_HISTORY)){
      if (OrderType() == 6 && OrderProfit() > 0){
         hist_info = "��������� � ��";
      }else{
         Alert(hist_info);
      }
   }else{
      Alert(hist_info);
   }   
   
   Comment(
      "\n", "  EURO-PORTFOLIO - Copyright � 2011, SAN Team",
      "\n", "  ========================================",
      "\n", 
      "\n", "   �� ���������",  
      "\n", "      ����: ",  M001_Comment_Level, " ���� ���� ", M001_Comment_Risk*100, "%",
      "\n", "      ���� 1 ", M001_Comment_Limit1, 
      "\n", "      ���� 2 ", M001_Comment_Limit21, " ���� 2(30%) ", M001_Comment_Limit22, 
      "\n", "      ���� 3 ", M001_Comment_Limit3, 
      "\n", "  --------------------------------------------------------------------------------------",      
      "\n",       
      "\n", "    ������ ��������� ", M001_Comment_DD, " (", M001_Comment_DD_Percent*100, " %)",
      "\n", "  --------------------------------------------------------------------------------------", 
      "\n", "    ����� ������        : ", AccountBalance(), 
      "\n", "    ��������� ������ : ", M001_Comment_VB,      
      "\n", "    �����                   : ", AccountEquity(),       
      "\n", "    �������               : ", AccountProfit(), 
      "\n", "  --------------------------------------------------------------------------------------", 
      "\n", "    ������ �������        : ", OrdersTotal(),       
      "\n", "    ���������� ������� : ", OrdersHistoryTotal(), "/", hist_info, "/",
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
         Print("[init_system]: ��������� ����� System"+index+" = "+id);         
         Alert("[init_system]: ��������� ����� System"+index+" = "+id);
      }
   }  
}

string GetSystemConfiguration( int id )
{      
   return (Systems[id]);
}



void init_systems(){  
   //������������ ������ � ������ ��������� ����� �� ������� �������
   for(int i = 0; i < SYSTEMS_SIZE; i++ ) { Systems[i] = "";}   
   
   Systems[0] = "";            
/****************************************************************************************************************************************************
  ������� � �������� ������
//***************************************************************************************************************************************************/   
   
//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A001
//----------------------------------------------------------------------------------------------------------------------------------------------------   

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A002
//----------------------------------------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               A003
//----------------------------------------------------------------------------------------------------------------------------------------------------

/****************************************************************************************************************************************************
  ������� � �������� �������
//***************************************************************************************************************************************************/   


//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N001
//----------------------------------------------------------------------------------------------------------------------------------------------------      
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

//----------------------------------------------------------------------------------------------------------------------------------------------------
//                               N003
//----------------------------------------------------------------------------------------------------------------------------------------------------

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