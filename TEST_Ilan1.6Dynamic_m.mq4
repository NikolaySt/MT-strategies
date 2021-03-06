//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
#property copyright "" 
#property link      ""
#include <stderror.mqh>
#include <stdlib.mqh>

//���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
double Stoploss = 500.0;            // ������� ���������
double TrailStart = 10.0;
double TrailStop = 10.0;
//���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
extern double LotExponent = 1.4;   // �� ������� �������� ��� ��� ����������� ���������� ������. ������: ������ ��� 0.1, �����: 0.16, 0.26, 0.43 ...
extern bool    DynamicPips                   = true; 
extern int     DefaultPips                   = 12;
extern int Glubina = 35;
extern int DEL = 3;
extern double slip = 4.0;           // �� ������� ����� ���������� ���� � ������ ���� �� �������� ������� (� ��������� ������ ������� �������� ����)
extern double Lots = 0.1;          // ����� ���� ��� ������ ������
extern int lotdecimal = 2;          // ������� ������ ����� ������� � ���� ������������ 0 - ���������� ���� (1), 1 - �������� (0.1), 2 - ����� (0.01)
extern double TakeProfit = 10.0;    // �� ���������� �������� ������� ������� ��������� ������
//extern double PipStep = 30.0;       // ��� ����� ����������� ����� �����
extern double Drop = 500;
extern double RsiMinimum = 30.0;    // ������ ������� RSI
extern double RsiMaximum = 70.0;    // ������� ������� RSI
extern int MagicNumber = 2222;      // ��������� ����� (�������� ��������� �������� ���� ������ �� �����)
int PipStep=0;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
extern int MaxTrades = 5;                 // ����������� ���������� ������������ �������� �������
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
//extern bool UseTrailingStop = FALSE;
extern bool UseTimeOut = FALSE;            // ������������ ������� (��������� ������ ���� ��� "�����" ������� �����)
extern double MaxTradeOpenHours = 48.0;    // ����� �������� ������ � ����� (����� ������� ��������� �������� ������)
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
double PriceTarget, StartEquity, BuyTarget, SellTarget;
double AveragePrice, SellLimit, BuyLimit;
double LastBuyPrice, LastSellPrice, Spread;
bool flag;
string EAName="Ilan1.6";
int timeprev = 0, expiration;
int NumOfTrades = 0;
double iLots;
int cnt = 0, total;
double Stopper = 0.0;
bool TradeNow = FALSE, LongTrade = FALSE, ShortTrade = FALSE;
int ticket,Error;
bool  NewOrdersPlaced = FALSE, NeedModifyOrder = False;
double AccountEquityHighAmt, PrevEquity;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
int init() {
  Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  timeprev = Time[0];
  return (0);
}

int deinit() {
   return (0);
}
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
int start()
{
  double PrevCl;
  double CurrCl;

  /************************************************************/
  /* ����� ����� ����, ������� �������� ��� ������ ����� ���� */ 
  /************************************************************/
  
  //===============================================================================
  // ������� ���� �� ��������� ����� ������� ���������� ���������� � ���
  //===============================================================================
  //if (UseTrailingStop) 
  //  TrailingAlls(TrailStart, TrailStop, AveragePrice);
  
  //===============================================================================
  // ������� �������� ������� �� CCI ����� ��������� ���������� ������� ������.
  // ���� ������� ���� ����� ������� ������ ���� �����, ����� ��� �� �����, 
  // �� ��� � �������� ������ �� ���������� �15. ������ - ��������� ��������.
  //===============================================================================
  //if ((iCCI(NULL,15,55,0,0)>Drop && ShortTrade)||(iCCI(NULL,15,55,0,0)<(-Drop) && LongTrade)) 
  //{
  //  CloseThisSymbolAll();
  //  Print("Closed All due to TimeOut");
  //}

  if (timeprev == Time[0]) return(0);   //��������� ��������� ������ ����

  /*****************************************************************************/
  /* ������ ���� ����� ����, ������� �������� ������ ��� ��������� ������ ���� */ 
  /*****************************************************************************/
  timeprev = Time[0];

  //===============================================================================
  // ��� ����������� ������������ �������. ���� � ����������, �� ��������...
  //===============================================================================
  if (DynamicPips)  
  {
    double hival=High[iHighest(NULL,0,MODE_HIGH,Glubina,1)];    // calculate highest and lowest price from last bar to 24 bars ago
    double loval=Low[iLowest(NULL,0,MODE_LOW,Glubina,1)];       // chart used for symbol and time period
    PipStep=NormalizeDouble((hival-loval)/DEL/Point,0);         // calculate pips for spread between orders
    //if (PipStep<DefaultPips/DEL) PipStep = NormalizeDouble(DefaultPips/DEL,0);
    //if (PipStep>DefaultPips*DEL) PipStep = NormalizeDouble(DefaultPips*DEL,0);          // if dynamic pips fail, assign pips extreme value
    Print("PipStep = ",PipStep);

  }

  //===============================================================================
  // ����� �������������� ����������� �� ������. ����� ���� �������� ��� ����.
  //===============================================================================
  double CurrentPairProfit = CalculateProfit();   //�������� ������� ������/������ �� ����
  if (UseEquityStop)
    if (CurrentPairProfit < 0.0 && MathAbs(CurrentPairProfit) > TotalEquityRisk / 100.0 * AccountEquityHigh()) 
    {
      CloseThisSymbolAll();
      Print("Closed All due to Stop Out");
      NewOrdersPlaced = FALSE;
    }
   
  //===============================================================================
  // ����� ������������ �����������, � ������� ������� ��������.
  //===============================================================================
  total = CountOfOrders();    //������� �������� �������� ������� ����� ������ �������.
  //if (total == 0) flag = FALSE; //���������� ���������� flag �� �����, �� ���� ����� ��������
  
  // ������������� ��� ����� ������� ����� ������������
  /* ------------------------------------------------------------------------------
  for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY) {
            LongTrade = TRUE;
            ShortTrade = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            LongTrade = FALSE;
            ShortTrade = TRUE;
            break;
         }
      }
  }*///-----------------------------------------------------------------------------
  if (total > 0)  //��������� ��� ��� ������ ���� ���� ������ � �����, ����� ��� ������.
  {
    Print("total > 0");
    for (int i = 0; i < OrdersTotal(); i++) 
      if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES))
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
          switch(OrderType())
          {
            case OP_BUY:
              LongTrade = TRUE;
              ShortTrade = FALSE;
              break;
            case OP_SELL:
              LongTrade = FALSE;
              ShortTrade = TRUE;
              break;//������� �� ������ switch
          }
          break;//������� �� ����� for
        }
  //===============================================================================
  // �������������� ���������� ����� ���� �������, ���� ����� ��������� ������.
  // ����� ����������� ����� �� ��������� ��������� ������ ����� �������
  //===============================================================================
  //if (total > 0 && total <= MaxTrades) //��� ��� ��� �� �����, � MaxTrades ���
  //{                                    //���-�� �� � ���� �� � ������.
    //RefreshRates();   //��� ���� ����� � ����� �� ����
    LastBuyPrice = FindLastBuyPrice();
    LastSellPrice = FindLastSellPrice();
    if (LongTrade && LastBuyPrice - Ask >= PipStep * Point) TradeNow = TRUE;
    if (ShortTrade && Bid - LastSellPrice >= PipStep * Point) TradeNow = TRUE;
  //}
  }
  else 
  //===============================================================================
  // �������������� ���������� ����� ���� �������, ���� ����� ��������� ������.
  // �����, ���� ��� ������� � �����, ��������� ���������� ���������� ��������, ����������� 
  // ����������� �������� � �����-�� ��������������� ��������� ������.
  //===============================================================================
  {
    Print("total = 0");
    ShortTrade = FALSE;
    LongTrade = FALSE;
    TradeNow = TRUE;
    StartEquity = AccountEquity();
  }
   
  //===============================================================================
  // ����� ������������ ������, ����� � ����� ��� ���� �������� ������.
  // ����������� ������ � ������.
  // ����� �������� ��� ����������� � ������ ����.
  //===============================================================================
  /* if (TradeNow) {
      LastBuyPrice = FindLastBuyPrice();
      LastSellPrice = FindLastSellPrice();
      if (ShortTrade) {
         NumOfTrades = total;
         iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
         RefreshRates();
         ticket = OpenPendingOrder(1, iLots, Bid, slip, Ask, 0, 0, EAName + "-" + NumOfTrades + "-" + PipStep, MagicNumber, 0, HotPink);
         if (ticket < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         LastSellPrice = FindLastSellPrice();
         TradeNow = FALSE;
         NewOrdersPlaced = TRUE;
      } else {
         if (LongTrade) {
            NumOfTrades = total;
            iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
            ticket = OpenPendingOrder(0, iLots, Ask, slip, Bid, 0, 0, EAName + "-" + NumOfTrades + "-" + PipStep, MagicNumber, 0, Lime);
            if (ticket < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            LastBuyPrice = FindLastBuyPrice();
            TradeNow = FALSE;
            NewOrdersPlaced = TRUE;
         }
      }
   }*/
  if((total > 0) && !(total > MaxTrades)) 
    if(TradeNow)
    {
      //Print("PipStep = ",PipStep);
      iLots = NormalizeDouble(Lots * MathPow(LotExponent, total), lotdecimal);
      if (ShortTrade) 
      {
        ticket = SendMarketOrder(OP_SELL, iLots, 0, 0, MagicNumber, EAName + "-" + NumOfTrades + "-" + PipStep, Error);
      }
      if (LongTrade) 
      {
        ticket = SendMarketOrder(OP_BUY, iLots, 0, 0, MagicNumber, EAName + "-" + NumOfTrades + "-" + PipStep, Error);
      }
      if(ticket > 0)
      {
        TradeNow = FALSE;
        NewOrdersPlaced = TRUE;
        NeedModifyOrder = TRUE;
      }
      else
        return(0);
    }

  //===============================================================================
  // ����� ������������ ������, ����� � ����� ��� �������� �������.
  // ����������� ��� �� ������ � ������.
  // � ���� ���������� �������� ��� ����������� � ������ ����.
  //===============================================================================
  /* if (TradeNow && total < 1) {
      PrevCl = iClose(Symbol(), 0, 2);
      CurrCl = iClose(Symbol(), 0, 1);
      SellLimit = Bid;
      BuyLimit = Ask;
      if (!ShortTrade && !LongTrade) {
         NumOfTrades = total;
         iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
         if (PrevCl > CurrCl) {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > RsiMinimum ) {
               ticket = OpenPendingOrder(1, iLots, SellLimit, slip, SellLimit, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, HotPink);
               if (ticket < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastBuyPrice = FindLastBuyPrice();
               NewOrdersPlaced = TRUE;
            }
         } else {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < RsiMaximum ) {
               ticket = OpenPendingOrder(0, iLots, BuyLimit, slip, BuyLimit, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, Lime);
               if (ticket < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               LastSellPrice = FindLastSellPrice();
               NewOrdersPlaced = TRUE;
            }
         }
         if (ticket > 0) expiration = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         TradeNow = FALSE;
      }
   }*/
  if (TradeNow && total < 1)
  {
    Print("��������� ������ �����");
    ticket = 0;
    PrevCl = iClose(Symbol(), 0, 2);
    CurrCl = iClose(Symbol(), 0, 1);
    if (PrevCl > CurrCl) 
    {
      Print("��������� ������� SELL");
      if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > RsiMinimum )
      {
        Print("�������� RSI ��������");
        ticket = SendMarketOrder(OP_SELL, Lots, TakeProfit, 0, MagicNumber, EAName + "-" + total , Error);
      }
    } 
    if (PrevCl < CurrCl) 
    {
      Print("��������� ������� BUY");
      if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < RsiMaximum ) 
      {
        Print("�������� RSI ��������");
        ticket = SendMarketOrder(OP_BUY, Lots, TakeProfit, 0, MagicNumber, EAName + "-" + total , Error);
      }
    }
    if(ticket > 0)
    {
      TradeNow = FALSE;
      NewOrdersPlaced = TRUE;
      NeedModifyOrder = False;
    }
    else
      return(0);
  }
  
  AveragePrice = CalculateAveragePrice();
  //total = CountOfOrders();
   
  //===============================================================================
  // ����� ������ ��������������� ������� �� ��� ���� ������� � ����, �� ������
  // ��� ������ � ����� �������� ������� ��� � �� ������.
  // ����������� ������.
  // ���������� �������� � ������ ����.
  //===============================================================================
  if (NewOrdersPlaced) 
  {
      /*for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               PriceTarget = AveragePrice + TakeProfit * Point;
               BuyTarget = PriceTarget;
               Stopper = AveragePrice - Stoploss * Point;
               flag = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               PriceTarget = AveragePrice - TakeProfit * Point;
               SellTarget = PriceTarget;
               Stopper = AveragePrice + Stoploss * Point;
               flag = TRUE;
            }
         }
      }*/
    if(ShortTrade) 
    {
      PriceTarget = AveragePrice - TakeProfit * Point;
      NeedModifyOrder = TRUE;
    }
    if(LongTrade) 
    {
      PriceTarget = AveragePrice + TakeProfit * Point;
      NeedModifyOrder = TRUE;
    }
  }
   
  if (NewOrdersPlaced)
    if (NeedModifyOrder) 
    {
      Print("������������ ��� ������ � �����");
      for (int i1 = 0; i1 < OrdersTotal(); i1++) 
        if(OrderSelect(i1, SELECT_BY_POS, MODE_TRADES))
          if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
            ModifyOrder(PriceTarget);
      NewOrdersPlaced = FALSE;
    }
  return (0);
}
//�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
int CountOfOrders()
{
  int count = 0;
  for (int i = 0; i < OrdersTotal(); i++) 
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumber)) 
        if ((OrderType() == OP_SELL) || (OrderType() == OP_BUY)) 
          count++;
  return(count);
}

/*
int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
   }
   return (count);
}*/
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

void CloseThisSymbolAll() {
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red);
         }
         Sleep(1000);
      }
   }
}

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

//int OpenPendingOrder(int pType, double pLots, double pLevel, int sp, double pr, int sl, int tp, string pComment, int pMagic, int pDatetime, color pColor) {
//   int ticket = 0;
//   int err = 0;
//   int c = 0;
//   int NumberOfTries = 100;
//   switch (pType) {
//   case 2:
//      for (c = 0; c < NumberOfTries; c++) {
//         ticket = OrderSend(Symbol(), OP_BUYLIMIT, pLots, pLevel, sp, StopLong(pr, sl), TakeLong(pLevel, tp), pComment, pMagic, pDatetime, pColor);
//         err = GetLastError();
//         if (err == 0/* NO_ERROR */) break;
//         if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
//         Sleep(1000);
//      }
//      break;
//   case 4:
//      for (c = 0; c < NumberOfTries; c++) {
//         ticket = OrderSend(Symbol(), OP_BUYSTOP, pLots, pLevel, sp, StopLong(pr, sl), TakeLong(pLevel, tp), pComment, pMagic, pDatetime, pColor);
//         err = GetLastError();
//         if (err == 0/* NO_ERROR */) break;
//         if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
//         Sleep(5000);
//      }
//      break;
//   case 0:
//      for (c = 0; c < NumberOfTries; c++) {
//         RefreshRates();
//         ticket = OrderSend(Symbol(), OP_BUY, pLots, NormalizeDouble(Ask,Digits), sp, NormalizeDouble(StopLong(Bid, sl),Digits), NormalizeDouble(TakeLong(Ask, tp),Digits), pComment, pMagic, pDatetime, pColor);
//         err = GetLastError();
//         if (err == 0/* NO_ERROR */) break;
//         if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
//         Sleep(5000);
//      }
//      break;
//   case 3:
//      for (c = 0; c < NumberOfTries; c++) {
//         ticket = OrderSend(Symbol(), OP_SELLLIMIT, pLots, pLevel, sp, StopShort(pr, sl), TakeShort(pLevel, tp), pComment, pMagic, pDatetime, pColor);
//         err = GetLastError();
//         if (err == 0/* NO_ERROR */) break;
//         if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
//         Sleep(5000);
//      }
//      break;
//   case 5:
//      for (c = 0; c < NumberOfTries; c++) {
//         ticket = OrderSend(Symbol(), OP_SELLSTOP, pLots, pLevel, sp, StopShort(pr, sl), TakeShort(pLevel, tp), pComment, pMagic, pDatetime, pColor);
//         err = GetLastError();
//         if (err == 0/* NO_ERROR */) break;
//         if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
//         Sleep(5000);
//      }
//      break;
//   case 1:
//      for (c = 0; c < NumberOfTries; c++) {
//         ticket = OrderSend(Symbol(), OP_SELL, pLots, NormalizeDouble(Bid,Digits), sp, NormalizeDouble(StopShort(Ask, sl),Digits), NormalizeDouble(TakeShort(Bid, tp),Digits), pComment, pMagic, pDatetime, pColor);
//         err = GetLastError();
//         if (err == 0/* NO_ERROR */) break;
//         if (!(err == 4/* SERVER_BUSY */ || err == 137/* BROKER_BUSY */ || err == 146/* TRADE_CONTEXT_BUSY */ || err == 136/* OFF_QUOTES */)) break;
//         Sleep(5000);
//      }
//   }
//   return (ticket);
//}
/*������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
double StopLong(double price, int stop) {
   if (stop == 0) return (0);
   else return (price - stop * Point);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double StopShort(double price, int stop) {
   if (stop == 0) return (0);
   else return (price + stop * Point);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double TakeLong(double price, int stop) {
   if (stop == 0) return (0);
   else return (price + stop * Point);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double TakeShort(double price, int stop) {
   if (stop == 0) return (0);
   else return (price - stop * Point);
}*/
//=========================================================================
int SendMarketOrder(int Type, double Lots, int TP, int SL, int Magic, string Cmnt, int& Error)
{
  double Price, Take, Stop;
  int Ticket, Slippage, Color, Err; 
  bool Delay = False;
  Print("������� SendMarketOrder");
  while(!IsStopped())
  {
    //if(!IsExpertEnabled())
    //{
    //  Error = ERR_TRADE_DISABLED;
    //  Print("�������� ��������� ���������! ������ \"��������\" ������.");
     // return(-1);
    //}
    Print("�������� ��������� ���������");
    if(!IsConnected())
    {
      Error = ERR_NO_CONNECTION;
      Print("����� �����������!");
      return(-1);
    }
    Print("����� � �������� �����������");
    if(IsTradeContextBusy())
    {
      Print("�������� ����� �����!");
      Print("������� 3 ���...");
      Sleep(3000);
      Delay = True;
      continue;
    }
    Print("�������� ����� ��������");
    if(Delay) 
    {
      Print("��������� ���������");
      RefreshRates();
      Delay = False;
    }
    else
    {
      Print("�������� �� ����");
    }
    switch(Type)
    {
      case OP_BUY:
        Print("�������������� ��������� ��� BUY-������");
        Price = NormalizeDouble( Ask, Digits);
        Take = IIFd(TP == 0, 0, NormalizeDouble( Ask + TP * Point, Digits));
        Stop = IIFd(SL == 0, 0, NormalizeDouble( Ask - SL * Point, Digits));
        Color = Blue;
        break;
      case OP_SELL:
        Print("�������������� ��������� ��� SELL-������");
        Price = NormalizeDouble( Bid, Digits);
        Take = IIFd(TP == 0, 0, NormalizeDouble( Bid - TP * Point, Digits));
        Stop = IIFd(SL == 0, 0, NormalizeDouble( Bid + SL * Point, Digits));
        Color = Red;
        break;
      default:
        Print("��� ������ �� ������������� �����������.");
        return(-1);
    }
    Slippage = MarketInfo(Symbol(), MODE_SPREAD);
    Print("Slippage = ",Slippage);
    if(IsTradeAllowed())
    {
      Print("�������� ���������, ���������� �����...");
      Ticket = OrderSend(Symbol(), Type, Lots, Price, Slippage, Stop, Take, Cmnt, Magic, 0, Color);
      if(Ticket < 0)
      {
        Err = GetLastError();
        if (Err == 4   || /* SERVER_BUSY */
            Err == 129 || /* INVALID_PRICE */ 
            Err == 135 || /* PRICE_CHANGED */ 
            Err == 137 || /* BROKER_BUSY */ 
            Err == 138 || /* REQUOTE */ 
            Err == 146 || /* TRADE_CONTEXT_BUSY */
            Err == 136 )  /* OFF_QUOTES */
        {
          Print("������(OrderSend - ", Err, "): ", ErrorDescription(Err));
          Print("������� 3 ���...");
          Sleep(3000);
          Delay = True;
          continue;
        }
        else
        {
          Print("����������� ������(OrderSend - ", Err, "): ", ErrorDescription(Err));
          Error = Err;
          break;
        }
      }
      break;
    }
    else
    {
      Print("�������� ��������� ���������! ����� ����� � ��������� ��������.");
      //Print("������� 3 ���...");
      //Sleep(3000);
      //Delay = True;
      //continue;
      Ticket = -1;
      break;
    }
  }
  if(Ticket > 0)
    Print("����� ��������� �������. ����� = ",Ticket);
  else
    Print("������! ����� �� ���������. (ErrorCode = ", Error, ": ", ErrorDescription(Error), ")");
  return(Ticket);
}
//==================================================================
double IIFd(bool condition, double ifTrue, double ifFalse) 
{
  if (condition) return(ifTrue); else return(ifFalse);
}




//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
double CalculateProfit() 
{
  double Profit = 0;
  for (int i = 0; i < OrdersTotal(); i++) 
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumber))
        if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)) 
          Profit += OrderProfit();
  return (Profit);
}
//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
/*
void TrailingAlls(int pType, int stop, double AvgPrice) {
   int profit;
   double stoptrade;
   double stopcal;
   if (stop != 0) {
      for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
         if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  profit = NormalizeDouble((Bid - AvgPrice) / Point, 0);
                  if (profit < pType) continue;
                  stoptrade = OrderStopLoss();
                  stopcal = Bid - stop * Point;
                  if (stoptrade == 0.0 || (stoptrade != 0.0 && stopcal > stoptrade)) OrderModify(OrderTicket(), AvgPrice, stopcal, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  profit = NormalizeDouble((AvgPrice - Ask) / Point, 0);
                  if (profit < pType) continue;
                  stoptrade = OrderStopLoss();
                  stopcal = Ask + stop * Point;
                  if (stoptrade == 0.0 || (stoptrade != 0.0 && stopcal < stoptrade)) OrderModify(OrderTicket(), AvgPrice, stopcal, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}*/
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

double AccountEquityHigh() {
   if (CountOfOrders() == 0) AccountEquityHighAmt = AccountEquity();
   if (AccountEquityHighAmt < PrevEquity) AccountEquityHighAmt = PrevEquity;
   else AccountEquityHighAmt = AccountEquity();
   PrevEquity = AccountEquity();
   return (AccountEquityHighAmt);
}
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

double FindLastBuyPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
      }
   }
   return (oldorderopenprice);
}

double FindLastSellPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
      }
   }
   return (oldorderopenprice);
}
//�������������������������������������������������������������������������������������������������������������������������������������������������������������������
double CalculateAveragePrice()
{
  double AveragePrice = 0;
  double Count = 0;
  for (int i = 0; i < OrdersTotal(); i++)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
        {
           AveragePrice += OrderOpenPrice() * OrderLots();
           Count += OrderLots();
        }
  if(AveragePrice > 0 && Count > 0)
    return( NormalizeDouble(AveragePrice / Count, Digits));
  else
    return(0);
}


bool ModifyOrder( double takeprofit)
{
  while(!IsStopped())
  {
    Print("������� ModifyOrder");
    if(IsTradeContextBusy())
    {
      Print("�������� ����� �����!");
      Sleep(3000);
      continue;
    }
    Print("�������� ����� ��������");
    if(!IsTradeAllowed())
    {
      Print("�������� ��������� ���������!");
      //Sleep(3000);
      //continue;
      return(False);
    }
    Print("�������� ���������, ������������ ����� #",OrderTicket());
    if(!OrderModify(OrderTicket(), OrderOpenPrice(), 0, NormalizeDouble(takeprofit,Digits), 0, Yellow))
    {
      Print("�� ������� �������������� �����");
      int Err = GetLastError();
      Print("������(",Err,"): ",ErrorDescription(Err));
      return(False);
      //break;
      //Sleep(1000);
      //continue;
    }
    else
    {
      Print("����������� ������ ��������� �������");
      break;
    }
  }
  return(True);
}