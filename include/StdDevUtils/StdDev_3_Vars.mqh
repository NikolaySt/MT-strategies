/***************���� ����������*********************************************************/
extern string Version = "3.2 ����: 08.11.2010";
extern string SignalBaseName = "SysSD";
extern int MagicNumber = 112010;
extern string SignalTimeFrame = "H1";
extern string GROUP1 = "----------------------------������������ ��������� -----------------------------";
//extern string Descr1.1 = "OnlyInstantOrders = true - ��� ��������� �� ������ ���� ��������� ������ ������� �������" ;
extern bool OnlyInstantOrders = true;
//extern string Descr1.2 = "ErrorPend_SetInstant = true - ��� ������ �� ����� �������� ������� ������ �������" ;
//extern string Descr1.3 = "������ ���� ��� OnlyInstantOrders = false" ;
extern bool ErrorPend_SetInstant = true;
extern bool FixProfitAndLimit = true;
//extern string Descr1.4 = "TimeWorkStart � TimeWorkEnd ������� �������� �� ������ � ����� �������� �� ������" ;
extern int TimeWorkStart = 0;
extern int TimeWorkEnd = 23;

extern string GROUP2 = "------------------------���� �� ���������-------------------------------";
extern double Lots = 0.1;
extern double Multiplier =1;

extern string GROUP3 = "------------------------������� ��������� �� SL � TP-------------------------------";
//extern string Descr3.1 = "��� BaseCurrency e ������ ���������� �� ������ ������ �������� �������� �� ��������,";
//extern string Descr3.2 = "��� BaseCurrency = USD ��������� �� �������� � ������" ;
extern string BaseCurrency = "";
extern double GGoal_Limit_currency = 300; //������� � ����
extern double GGoal_StopRatio = 1;
extern double GGoal_Stop_currency = 300; //������� � ����

extern string GROUP4 = "------------------------��������� �� ���������� �� �������---------------------";
extern int MinShiftOrder_pips = 25;
extern double Factor1 = 1;
extern double Factor2 = 1;
extern int TradeLimit = 3;
extern int AvrCloseBars = 1;
extern int StdDevPeriod = 20;

extern string GROUP5 = "-------------------------------����� ������--------------------------------";
//extern string Descr5.1 = "Trend_BarsBreak ��������� ��� ��������� ���� ������, ��� � /0/ � �������";
extern int Trend_BarsBreak = 8;
extern string GROUP6 = "-------------------------------������� ������--------------------------------";
//extern string Descr6.1 = "Fr_Bars - ���� ������ �� ����� �� � �������� �������� 3, 5, 7, 9, 11, 13 .. �.�.";
//extern string Descr6.2 = "Fr_Bars ��� � ����� �� 0 ��������� �� ������� � ���������";
//extern string Descr6.3 = "Fr_BackBars - ����� ���� ����� �� �� ����� �� �� ������� ���� ��� �������";
extern int Fr_Bars = 3;
extern int Fr_BackBars = 5;

extern string GROUP7 = "-------------------------------STDDEV ������--------------------------------";  
//extern string Descr7.1 = "Std_Limit = 0 ������� � ��������, Std_1_TimeFrameS = \"\" - ������ �������� ����� ����";
//extern string Descr7.2 = "Std_1_StdPeriod = 0 ������� ���������� �� ������� /StdDevPeriod/";
extern int Std_1_Limit = 0;
extern string Std_1_TimeFrameS = "H1";
extern int Std_1_StdPeriod = 20;

extern int Std_2_Limit = 0;
extern string Std_2_TimeFrameS = "H4";
extern int Std_2_StdPeriod = 20;

extern int Std_3_Limit = 0;
extern string Std_3_TimeFrameS = "D1";
extern int Std_3_StdPeriod = 20;
/****************************************************************************************/

int SIGNAL_TIMEFRAME = PERIOD_H1;

int Std_1_TimeFrame = PERIOD_H1;
int Std_2_TimeFrame = PERIOD_H4;
int Std_3_TimeFrame = PERIOD_D1;

//�������������� �� ������������
void StdDev_System_Init_Common(){
   double ratio = DigMode();
  
   MinShiftOrder_pips = MinShiftOrder_pips*ratio;    
   if (GGoal_Stop_currency == 0 && GGoal_StopRatio > 0 && GGoal_Limit_currency > 0){
      GGoal_Stop_currency = GGoal_StopRatio* GGoal_Limit_currency;  
   }
   
   Std_1_Limit = Std_1_Limit*ratio;
   Std_2_Limit = Std_2_Limit*ratio;
   Std_3_Limit = Std_3_Limit*ratio;
   
   if (Std_1_StdPeriod == 0) Std_1_StdPeriod = StdDevPeriod;   
   if (Std_2_StdPeriod == 0) Std_2_StdPeriod = StdDevPeriod;
   if (Std_3_StdPeriod == 0) Std_3_StdPeriod = StdDevPeriod;
   
   if (Std_1_TimeFrameS == "") Std_1_TimeFrame = Period();  else  Std_1_TimeFrame = TimeFrameFromString(Std_1_TimeFrameS);  
   if (Std_2_TimeFrameS == "") Std_2_TimeFrame = Period();  else  Std_2_TimeFrame = TimeFrameFromString(Std_2_TimeFrameS);  
   if (Std_3_TimeFrameS == "") Std_3_TimeFrame = Period();  else  Std_3_TimeFrame = TimeFrameFromString(Std_3_TimeFrameS);  
   
   if (SignalTimeFrame == "") SIGNAL_TIMEFRAME = Period();  else  SIGNAL_TIMEFRAME = TimeFrameFromString(SignalTimeFrame);  
}

