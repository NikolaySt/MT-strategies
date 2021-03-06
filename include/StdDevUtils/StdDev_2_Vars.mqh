/***************ÎÁÙÈ ÏÐÎÌÅÍËÈÂÈ*********************************************************/
extern string SignalBaseName = "SysSD";
//extern string GROUP = "-------------ÂÐÅÌÅÂÈ ÐÀÌÊÈ ÍÀ ÐÀÁÎÒÀ ÍÀ ÑÈÑÒÅÌÀÒÀ-------------------";
extern string SignalTimeFrame = "H1";

//extern string GROUP0 = "------------------------ÂÐÅÌÅÂÈ ÔÈËÒÚÐ-------------------------------";
extern int TimeWorkStart = 0;
extern int TimeWorkEnd = 24;

//extern string GROUP2 = "------------------------ÎÁÅÌ ÍÀ ÏÎÐÚ×ÊÈÒÅ-------------------------------";
extern double Lots = 0.1;
extern double Multiplier =1;

//extern string GROUP3 = "------------------------ÍÀ×ÀËÍÈ ÏÀÐÀÌÅÒÐÈ ÍÀ SL è TP-------------------------------";
extern string SLTimeFrame = "H1"; //÷àñîâîòî íèâî íà êîåòî ñå ïðåñìÿòà ñòîï ëîñà
extern double SL_StdDevPeriod = 20;
extern double SL_StdDevRatio = 2.5;
extern int MaxStopLoss_pips = 80;
extern int StopLoss_pips = 80;
extern int Limit_pips = 0;
//extern string info6 = "Àêî BaseCurrency e ïðàçíà ïðîìåíëèâà çà áàçîâà âàëóòà èçïîëçâà âàëóòàòà íà ñìåòêàòà, àêî BaseCurrency = USD ïå÷àëâàòà ñå ïðåñìÿòà â äîëàðè" ;
extern string BaseCurrency = "";
extern double GGoal_Limit_currency = 300; //åäèíèöè â ïàðè
extern double GGoal_StopRatio = 1;
extern double GGoal_Stop_currency = 300; //åäèíèöè â ïàðè
//
extern int    SN002_Stop_Save = true;
extern int    SN002_Stop_ZeroOffset = 0;
extern int    SN002_Stop_ProfitOffset = 3;
extern double SN002_Stop_Ratio = 0.9;
extern double SN002_Stop_ZeroRatio = 0.4;
//


//extern string GROUP6 = "------------------------ÏÀÐÀÌÅÒÐÈ ÇÀ ÃÅÍÅÐÈÐÀÍÅ ÍÀ ÑÈÃÍÀËÀ---------------------";
extern int MinShiftOrder_pips = 25;
extern double Factor1 = 1;
extern double Factor2 = 1;
extern int TradeLimit = 3;
extern int AvrCloseBars = 1;
extern bool ActiveAtr = true;
extern int StdDevPeriod = 20;
//extern string GROUP7 = "----------------------------ÄÎÏÚËÍÈÒÅËÍÀ ÏÀÐÀÌÅÒÐÈ -----------------------------";
//extern string info7 = "Àêî InstantOrder = true, îòâàðÿ ïàçàðíà ïîðú÷êà êîãàòî íåìîæå äà ñëîæè îòëîæåí îðäåð." ;
extern bool ActiveInstantOrder = true;
//extern string GROUP8 = "-------------------------------ÔÈËÒÐÈ ÍÀ ÑÈÃÍÀËÀ--------------------------------";
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

//Èíèöèàëèçèðàíå íà ïðîìåíëèâèòå
//Âèíàãè òðÿáâà äà ñå âèêà
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

