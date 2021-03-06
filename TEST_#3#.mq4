//+------------------------------------------------------------------+
//|                                                          #3#.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//#include <StatisticalHeader.mqh>
//=====================================   
extern int    MinPips     = 1; // Минимално разстояние на което може да бъде поставен стоп ордер
extern int    Time1       = 1; //след колко часа да се затвори ордера
extern int    FirstTP     = 75;
extern int    StopLoss    = 30;
//extern int    l1          = 1;
extern int    a1          = 7;
extern int    a2          = 4;
extern int    R           = 10;//Риск  
extern double MinLot      = 0.1;
extern int    FilterBegHour    = 8;
extern int    FilterEndHour    = 20;
int    Round       = 2;
int    MagicNumber = 566578; 
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  /*
     if (IsTesting()){
      HistoryClosePositionToFile(false, 10000, "history.txt");
      DropDownToFile(false, 10000, "dropdown.txt");
      AverageAnnualReturn(10000);
      SumMonthlyProfitToFile("monthly_profit.txt");
      MOSystem(true);
   }
   */
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   static int LastBarTime=0;
   int ticket, total;
//=====================================
   double PipsMull=0.0001;
   double L=iLow(Symbol(),PERIOD_H1,1);
   double H=iHigh(Symbol(),PERIOD_H1,1);
   double C=iClose(Symbol(),PERIOD_H1,0);
   double O=iOpen(Symbol(),PERIOD_H1,0);
//=====================================
   double FreeAccount=NormalizeDouble(AccountBalance()-AccountMargin(),Round);
   double Risk=NormalizeDouble((FreeAccount/100),Round);
   double Lot=NormalizeDouble(Risk/R*0.1,Round);
   if(Lot>10)     Lot=10;
   if(Lot<MinLot) Lot=MinLot;

   double Check1=H-C;
   double Check2=C-L;
   double l1=FilterBegHour*2;
   double MaxPrice=iHigh(Symbol(),PERIOD_M30,iHighest(Symbol(),PERIOD_M30,MODE_HIGH,l1,1));
   double MinPrice=iLow(Symbol(),PERIOD_M30,iLowest(Symbol(),PERIOD_M30,MODE_LOW,l1,1));
   
   double EntryBuy=NormalizeDouble(MaxPrice+a1*PipsMull, Digits);
   double EntrySell=NormalizeDouble(MinPrice-a2*PipsMull, Digits);
   
   double StopB=NormalizeDouble(EntrySell-StopLoss*PipsMull, Digits);
   double StopS=NormalizeDouble(EntryBuy+StopLoss*PipsMull, Digits);
   
   double TakeB=NormalizeDouble(EntryBuy+FirstTP*PipsMull, Digits);
   double TakeS=NormalizeDouble(EntrySell-FirstTP*PipsMull, Digits);
   
   int TimeExp=Time1*3600;
   int TimeExpiration=iTime( Symbol(), PERIOD_H1, 0 ) + TimeExp;
//=====================================
//Print("Lot:",Lot,"Risk:",Risk);
//Print("MaxPrice:",MaxPrice,"MinPrice:",MinPrice);
//Print("EntryBuy:",EntryBuy,"EntrySell:",EntrySell);
//Print("StopB:",StopB,"StopS:",StopS);
//Print("TakeB:",TakeB,"TakeS:",TakeS);
//Print("Check1:",Check1,"Check2:",Check2);
//Print("StopB:",StopB,"StopS:",StopS);
//Print("TimeExpiration:",TimeExpiration);
//=====================================
   if(LastBarTime==iTime(Symbol(), PERIOD_H1, 0))
       return(0);
   else   
      LastBarTime=iTime(Symbol(), PERIOD_H1, 0);
   if(!((FilterBegHour<=FilterEndHour && TimeHour(TimeCurrent())>=FilterBegHour && TimeHour(TimeCurrent())<=FilterEndHour)))
       return(0);
   if(FilterBegHour>FilterEndHour)
       return(0);
      
   if(AccountBalance()<=500)
      return(0);

   total=OrdersTotal();
   if(total<4) 
     {

      // check for long position (BUY) possibility
       if(Check1 >= MinPips*PipsMull && Check2 >= MinPips*PipsMull && O<H)
        {
         ticket=OrderSend(Symbol(), OP_BUYSTOP, MinLot, EntryBuy, 1, StopB, TakeB, "", MagicNumber, TimeExpiration, Blue); 
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))   LastBarTime=0;  
           } 
        }
      // check for short position (SELL) possibility
       if (Check1 >= MinPips*PipsMull && Check2 >= MinPips*PipsMull && O>L)
        {
         ticket=OrderSend(Symbol(), OP_SELLSTOP, MinLot, EntrySell, 1, StopS, TakeS, "", MagicNumber, TimeExpiration, Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))  LastBarTime=0; 
           }
        }
      return(0);
     }
//----
   return(0);
  }
// the end.