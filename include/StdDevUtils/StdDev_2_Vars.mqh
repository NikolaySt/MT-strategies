/***************���� ����������*********************************************************/
extern string SignalBaseName = "SysSD";
//extern string GROUP = "-------------������� ����� �� ������ �� ���������-------------------";
extern string SignalTimeFrame = "H1";

//extern string GROUP0 = "------------------------������� ������-------------------------------";
extern int TimeWorkStart = 0;
extern int TimeWorkEnd = 24;

//extern string GROUP2 = "------------------------���� �� ���������-------------------------------";
extern double Lots = 0.1;
extern double Multiplier =1;

//extern string GROUP3 = "------------------------������� ��������� �� SL � TP-------------------------------";
extern string SLTimeFrame = "H1"; //�������� ���� �� ����� �� �������� ���� ����
extern double SL_StdDevPeriod = 20;
extern double SL_StdDevRatio = 2.5;
extern int MaxStopLoss_pips = 80;
extern int StopLoss_pips = 80;
extern int Limit_pips = 0;
//extern string info6 = "��� BaseCurrency e ������ ���������� �� ������ ������ �������� �������� �� ��������, ��� BaseCurrency = USD ��������� �� �������� � ������" ;
extern string BaseCurrency = "";
extern double GGoal_Limit_currency = 300; //������� � ����
extern double GGoal_StopRatio = 1;
extern double GGoal_Stop_currency = 300; //������� � ����
//
extern int    SN002_Stop_Save = true;
extern int    SN002_Stop_ZeroOffset = 0;
extern int    SN002_Stop_ProfitOffset = 3;
extern double SN002_Stop_Ratio = 0.9;
extern double SN002_Stop_ZeroRatio = 0.4;
//


//extern string GROUP6 = "------------------------��������� �� ���������� �� �������---------------------";
extern int MinShiftOrder_pips = 25;
extern double Factor1 = 1;
extern double Factor2 = 1;
extern int TradeLimit = 3;
extern int AvrCloseBars = 1;
extern bool ActiveAtr = true;
extern int StdDevPeriod = 20;
//extern string GROUP7 = "----------------------------������������ ��������� -----------------------------";
//extern string info7 = "��� InstantOrder = true, ������ ������� ������� ������ ������ �� ����� ������� �����." ;
extern bool ActiveInstantOrder = true;
//extern string GROUP8 = "-------------------------------������ �� �������--------------------------------";
extern bool FilterTrend = false;
extern int FrBars = 3;
extern int CountBackBars = 3;
extern int TrendBarsBreak = 8;
extern bool FilterStdLimit = false;  
extern int Std_H1_Limit = 10;
extern int Std_H4_Limit = 50;
extern int Std_D1_Limit = 100;
/****************************************************************************************/

int SIGNAL_TIMEFRAME = PERIOD_H1;
int SL_TIMEFRAME = PERIOD_H1;

//�������������� �� ������������
//������ ������ �� �� ����
void StdDev_System_Init_Common(){
   double ratio = DigMode();
  
   MinShiftOrder_pips = MinShiftOrder_pips*ratio; 
   MaxStopLoss_pips = MaxStopLoss_pips*ratio;   
   StopLoss_pips = StopLoss_pips*ratio;
   if (GGoal_Stop_currency == 0 && GGoal_StopRatio > 0 && GGoal_Limit_currency > 0){
      GGoal_Stop_currency = GGoal_StopRatio* GGoal_Limit_currency;  
   }
   
   Std_H1_Limit = Std_H1_Limit*ratio;
   Std_H4_Limit = Std_H4_Limit*ratio;
   Std_D1_Limit = Std_D1_Limit*ratio;
   
   SIGNAL_TIMEFRAME = SAV_TimeFrameFromString(SignalTimeFrame);
   SL_TIMEFRAME = SAV_TimeFrameFromString(SLTimeFrame);
}

