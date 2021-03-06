//+------------------------------------------------------------------+
//|                                                      JakesEA.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      "none"

//----------------------- INCLUDES------------------------------------------------
#include <stdlib.mqh>

//----------------------- EA PARAMETER
extern string           Expert_Name          = "---------- Jakes EA v1.0---------";
extern int              MagicNumber          = 1234;
extern double           StopLoss             = 50,
                        TakeProfit           = 0;
extern string           TrailingStop_Setting = "---------- Trailing Stop Setting";
extern int              TrailingStopType     = 1,
                        TrailingStop         = 40;
extern string           Indicator_Setting    = "---------- Indicator Setting";
extern int              ChannelMAPeriodHigh  = 10,
                        ChannelMAPeriodLow   = 10,
                        WAD_MAPeriod         = 57;
extern string           Exit_Setting         = "---------- Exit Setting";
extern bool             StopAndReverse       = true;   // TURE:if signal change, exit and reverse order
extern string           Order_Setting        = "---------- Order Setting";
extern bool             ReverseCondition     = false, // TRUE:buy-sell , sell-buy
                        ConfirmedOnEntry     = true,  // TRUE:entry on the next signal bar
                        OneEntryPerBar       = true;
extern int              NumberOfTries        = 10,
                        Slippage             = 5;
extern string           OpenOrder_Setting    = "---------- Multiple Open Trade Setting";
extern int              MaxOpenTrade         = 1,
                        MinPriceDistance     = 5;
extern string           Time_Parameters      = "---------- EA Active Time";
extern bool             UseHourTrade         = false;         
extern int              StartHour            = 0,
                        EndHour              = 23;
extern string           MM_Parameters        = "---------- Money Management";
extern double           Lots                 = 1;
extern bool             MM                   = false, //Use Money Management or not
                        AccountIsMicro       = false; //Use Micro-Account or not
extern int              Risk                 = 10; //10%
extern string           Alert_Setting        = "---------- Alert Setting";
extern bool             EnableAlert          = true;
extern string           SoundFilename        = "alert.wav";


//----------------------- GLOBAL VARIABLE
static int              TimeFrame            = 0;
string                  TicketComment        = "Jakes v1.0",
                        LastAlert,
                        TradeDirection       = "NONE";
int                     LastTrade;                        
datetime                CheckTime,
                        CheckEntryTime;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{

//----------------------- GENERATE MAGIC NUMBER AND TICKET COMMENT
//----------------------- SOURCE : PENGIE
   MagicNumber    = subGenerateMagicNumber(MagicNumber, Symbol(), Period());
	TicketComment  = StringConcatenate(TicketComment, "-", Symbol(), "-", Period());


   
//----------------------- INITIALIZE PURE Stop And Reverse

//----------------------- MaxTrade ALWAYS >= 1
   if(MaxOpenTrade<=0) MaxOpenTrade = 1;
   
//+------------------------------------------------------------------+
//| CHECK LAST OPEN TRADE                                            |
//+------------------------------------------------------------------+
   LastTrade = subCheckOpenTrade();
   Print("Last Trade : ",LastTrade);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
 
//----------------------- PREVENT RE-COUNTING WHILE USER CHANGING TIME FRAME
//----------------------- SOURCE : CODERSGURU
   TimeFrame = Period(); 
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   double LastHigh;
   double LastLow;
   double LastClose;

                   
   int cnt;
   int ticket;
   int total;
   int Distance;
         
   int Direction;         
         
//----------------------- TIME FILTER
   if (UseHourTrade==true)
   {
      if(!(Hour()>=StartHour && Hour()<=EndHour))
      {
         Comment("Non-Trading Hours!");
         return(0);
      }
   }

//----------------------- CHECK CHART NEED MORE THAN 100 BARS
   if(Bars < 100)
   {
      Print("bars less than 100");
      return(0);  
   }

//----------------------- TRAILING STOP SECTION
   if (TrailingStop > 0 && subTotalTrade() > 0)
   {
      total = OrdersTotal();
      for(cnt = 0; cnt < total; cnt++)
      {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()<=OP_SELL &&
            OrderSymbol()==Symbol() &&
            OrderMagicNumber()==MagicNumber)
         {
            subTrailingStop(OrderType());
         }
      }
   }            

//----------------------- ADJUST LOTS IF USING MONEY MANAGEMENT
   if(MM==true) Lots = subLotSize();

//----------------------- SET VALUE FOR VARIABLE
   if(ConfirmedOnEntry==true)
   {
      if(CheckTime==iTime(NULL,TimeFrame,0)) return(0); else CheckTime = iTime(NULL,TimeFrame,0);   
   }
   

   Direction = subSignalDirection();                 
                     

//+------------------------------------------------------------------+
//| STOP AND REVERSE                                                 |
//+------------------------------------------------------------------+
   if(StopAndReverse==true && subTotalTrade()>0)
   {
      if((LastTrade==1 && Direction == -1) || (LastTrade==-1 && Direction==1))
      {
         subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
         if(subTotalTrade()>0) subCloseOrder();
      }
   }

//----------------------- ENTRY
//----------------------- TOTAL ORDER BASE ON MAGICNUMBER AND SYMBOL
   total = subTotalTrade();

//----------------------- IF NUMBER TRADE LESS THAN MaxTrade
   if(total < MaxOpenTrade && (Direction==1 || Direction==-1)) 
   {

//----------------------- ONE ENTRY PER BAR
      if(OneEntryPerBar==true)
      {
         if(CheckEntryTime==iTime(NULL,TimeFrame,0)) return(0); else CheckEntryTime = iTime(NULL,TimeFrame,0);
      }         

//----------------------- BUY CONDITION   
      if(Direction==1)
      {
         if(MaxOpenTrade>1 && subHighestLowest("BUY")==false) return(0);
      
         ticket = subOpenOrder(OP_BUY,StopLoss,TakeProfit);
         
         subCheckError(ticket, "BUY");
         if (ticket > 0) LastTrade = 1;
         return(0);
      }

//----------------------- SELL CONDITION   
      if(Direction==-1)
      {
         if(MaxOpenTrade>1 && subHighestLowest("SELL")==false) return(0);
         
         ticket = subOpenOrder(OP_SELL,StopLoss,TakeProfit);

         subCheckError(ticket, "SELL");
         if (ticket > 0) LastTrade = -1;
         return(0);
      }
      return(0);
   }
   
   return(0);
}

//----------------------- END PROGRAM

//+------------------------------------------------------------------+
//| FUNCTION DEFINITIONS
//+------------------------------------------------------------------+

//----------------------- MONEY MANAGEMENT FUNCTION  
//----------------------- SOURCE : CODERSGURU
double subLotSize()
{
     double lotMM = MathCeil(AccountFreeMargin() *  Risk / 1000) / 100;
	  
	  if(AccountIsMicro==false) //normal account
	  {
	     if(lotMM < 0.1)                  lotMM = Lots;
	     if((lotMM > 0.5) && (lotMM < 1)) lotMM = 0.5;
	     if(lotMM > 1.0)                  lotMM = MathCeil(lotMM);
	     if(lotMM > 100)                  lotMM = 100;
	  }
	  else //micro account
	  {
	     if(lotMM < 0.01)                 lotMM = Lots;
	     if(lotMM > 1.0)                  lotMM = MathCeil(lotMM);
	     if(lotMM > 100)                  lotMM = 100;
	  }
	  
	  return (lotMM);
}

//----------------------- NUMBER OF ORDER BASE ON SYMBOL AND MAGICNUMBER FUNCTION
int subTotalTrade()
{
   int cnt;
   int total = 0;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber) total++;
   }
   return(total);
}

//+------------------------------------------------------------------+
//| FUNCTION : CHECK OPEN ORDER BASE ON SYMBOL AND MAGIC NUMBER      |
//| SOURCE   : n/a                                                   |
//| MODIFIED : FIREDAVE                                              |
//+------------------------------------------------------------------+
int subCheckOpenTrade()
{
   int cnt = 0;
   int lasttrade = 0;      

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY ) lasttrade = 1;
         if(OrderType()==OP_SELL) lasttrade = -1;
      }         
   }
   return(lasttrade);
}

//----------------------- FIND LOWEST/HIGHEST BUY-SELL FUNCTION
bool subHighestLowest(string type)
{
   int cnt;
   int total = 0;
      
   double HighestBuy  = 0;
   double LowestBuy   = 10000;
   double HighestSell = 0;
   double LowestSell  = 10000;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL &&
         OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         if(OrderType()==OP_BUY)
         {
            if(OrderOpenPrice()<LowestBuy ) LowestBuy  = OrderOpenPrice();
            if(OrderOpenPrice()>HighestBuy) HighestBuy = OrderOpenPrice();
         }

         if(OrderType()==OP_SELL)
         {
            if(OrderOpenPrice()<LowestSell ) LowestSell  = OrderOpenPrice();
            if(OrderOpenPrice()>HighestSell) HighestSell = OrderOpenPrice();
         }

      }
   }
   
   if     (type=="BUY"  && (Ask<=LowestBuy -MinPriceDistance*Point || Ask>=HighestBuy +MinPriceDistance*Point)) return(true);
   else if(type=="SELL" && (Bid<=LowestSell-MinPriceDistance*Point || Bid>=HighestSell+MinPriceDistance*Point)) return(true);
   else return(false);
}

int subSignalDirection()
{
   double mahigh1 = iMA(NULL, TimeFrame, ChannelMAPeriodHigh, 0, MODE_LWMA, PRICE_HIGH, 1);
   double mahigh2 = iMA(NULL, TimeFrame, ChannelMAPeriodHigh, 0, MODE_LWMA, PRICE_HIGH, 2);
   
   double malow1 =  iMA(NULL, TimeFrame, ChannelMAPeriodLow, 0, MODE_LWMA, PRICE_LOW, 1);
   double malow2 =  iMA(NULL, TimeFrame, ChannelMAPeriodLow, 0, MODE_LWMA, PRICE_LOW, 2);

   
   double ad = iCustom(NULL, TimeFrame, "Williams_AD", WAD_MAPeriod, 0, 1);
   double ad_ma = iCustom(NULL, TimeFrame, "Williams_AD", WAD_MAPeriod, 1, 1);
   
   int CurrentDirection = 0;
   if (
     iLow(NULL, TimeFrame, 1) > mahigh1
     &&
     iLow(NULL, TimeFrame, 2) > mahigh2
     &&
     ad > ad_ma
   ){
      CurrentDirection = 1;  
   }
   
   if (
     iHigh(NULL, TimeFrame, 1) < malow1
     &&
     iHigh(NULL, TimeFrame, 2) < malow2
     &&
     ad < ad_ma
   ){
      CurrentDirection = -1;
   }     
   return(CurrentDirection);   
}

//----------------------- OPEN ORDER FUNCTION
//----------------------- SOURCE   : CODERSGURU
//----------------------- SOURCE   : PENGIE
//----------------------- MODIFIED : FIREDAVE
int subOpenOrder(int type, int stoploss, int takeprofit)
{
   int
         ticket      = 0,
         err         = 0,
         c           = 0;
         
   double         
         aStopLoss   = 0,
         aTakeProfit = 0,
         bStopLoss   = 0,
         bTakeProfit = 0;

   if(stoploss!=0)
   {
      aStopLoss   = NormalizeDouble(Ask-stoploss*Point,4);
      bStopLoss   = NormalizeDouble(Bid+stoploss*Point,4);
   }
   
   if(takeprofit!=0)
   {
      aTakeProfit = NormalizeDouble(Ask+takeprofit*Point,4);
      bTakeProfit = NormalizeDouble(Bid-takeprofit*Point,4);
   }
   
   if(type==OP_BUY)
   {
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,aStopLoss,aTakeProfit,TicketComment,MagicNumber,0,Green);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }
   if(type==OP_SELL)
   {   
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,bStopLoss,bTakeProfit,TicketComment,MagicNumber,0,Red);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }  
   return(ticket);
}


//----------------------- CLOSE ORDER FUNCTION
void subCloseOrder()
{
   int
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol()==Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         switch(OrderType())
         {
            case OP_BUY      :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_SELL     :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_BUYLIMIT :
            case OP_BUYSTOP  :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :
               OrderDelete(OrderTicket());
         }
      }
   }      
}


//----------------------- TRAILING STOP FUNCTION
//----------------------- SOURCE   : CODERSGURU
//----------------------- MODIFIED : FIREDAVE
void subTrailingStop(int Type)
{
   if (TrailingStopType == 0) return;
   
   if(Type==OP_BUY)   // buy position is opened   
   {
      switch(TrailingStopType)
      {
//----------------------- AFTER PROFIT TRAILING STOP      
         case 1:
            if(Bid-OrderOpenPrice()>Point*TrailingStop &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }
            break;
            
//----------------------- TRAILING STOP
         case 2:
            if(Bid>OrderOpenPrice() &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }
            break;

//----------------------- DEFAULT : AFTER PROFIT TRAILING STOP      
         default:
            if(Bid-OrderOpenPrice()>Point*TrailingStop &&
              OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
            }  
      }
   }

   if(Type==OP_SELL)   // sell position is opened   
   {
      switch(TrailingStopType)
      {
//----------------------- AFTER PROFIT TRAILING STOP      
         case 1:
            if(OrderOpenPrice()-Ask>Point*TrailingStop)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
            break;
            
//----------------------- TRAILING STOP
         case 2:
            if(OrderOpenPrice()>Ask)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
            break;

//----------------------- DEFAULT : AFTER PROFIT TRAILING STOP      
         default:
            if(OrderOpenPrice()-Ask>Point*TrailingStop)
            {
            if(OrderStopLoss()>Ask+Point*TrailingStop || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
            }
            }
      }
   }
}



//----------------------- CHECK ERROR CODE FUNCTION
//----------------------- SOURCE : CODERSGURU
void subCheckError(int ticket, string Type)
{
    if(ticket>0) 
    {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print(Type + " order opened : ",OrderOpenPrice());
    }
    else Print("Error opening " + Type + " order : (",GetLastError(),") ", ErrorDescription(GetLastError()));
}

//----------------------- GENERATE MAGIC NUMBER BASE ON SYMBOL AND TIME FRAME FUNCTION
//----------------------- SOURCE   : PENGIE
//----------------------- MODIFIED : FIREDAVE
int subGenerateMagicNumber(int MagicNumber, string symbol, int timeFrame)
{
   int isymbol = 0;
   if      (symbol == "EURUSD")  isymbol = 1;
   else if (symbol == "GBPUSD")  isymbol = 2;
   else if (symbol == "USDJPY")  isymbol = 3;
   else if (symbol == "USDCHF")  isymbol = 4;
   else if (symbol == "AUDUSD")  isymbol = 5;
   else if (symbol == "USDCAD")  isymbol = 6;
   else if (symbol == "EURGBP")  isymbol = 7;
   else if (symbol == "EURJPY")  isymbol = 8;
   else if (symbol == "EURCHF")  isymbol = 9;
   else if (symbol == "EURAUD")  isymbol = 10;
   else if (symbol == "EURCAD")  isymbol = 11;
   else if (symbol == "GBPUSD")  isymbol = 12;
   else if (symbol == "GBPJPY")  isymbol = 13;
   else if (symbol == "GBPCHF")  isymbol = 14;
   else if (symbol == "GBPAUD")  isymbol = 15;
   else if (symbol == "GBPCAD")  isymbol = 16;
   else                          isymbol = 17;
   if(isymbol<10) MagicNumber = MagicNumber * 10;
   return (StrToInteger(StringConcatenate(MagicNumber, isymbol, timeFrame)));
}



