//Order smart management
//OrderSmartManagement.mqh
//all options about
//simuation of trades statistics
//information for orders like it is on real trading system

//all function should be with prefix OSM
//all data about Orders should be with prefix OSMD

string OSMD_Symbol[];
int    OSMD_Type[];//OP_BUY, OP_SELL will be supported
double OSMD_Lots[];
double OSMD_OpenPrice[];
double OSMD_ClosePrice[];
double OSMD_StopLoss[];
double OSMD_Limit[];
string OSMD_Comment[];
int    OSMD_Magic[];
int    OSMD_Ticket[];//
#define OSMD_ORDER_OPENED 1
#define OSMD_ORDER_CLOSED 2
#define OSMD_ORDER_REAL   4 //if order has not this flag t will be considered as simulation only
#define OSMD_TICKET_NOTREAL 1048576  //2^20
int     OSMD_State[];//Opened Closed 
datetime OSMD_OpenTime[];
datetime OSMD_CloseTime[];
//buffer for active orders
//contains id of a order 
int  OSMD_ActiveOrders[];
int  OSMD_ActiveOrdersSize;

int OSMD_MaxOrdersPeriodBars = 0;
int OSMD_MaxOrdersForPeriod = 0;

int OSMD_Capacity;
int OSMD_LastIndex;

int OSMD_CloseAllOrdersPips = 0;
int OSMD_StopTradePips = 0;
int OSMD_StartTradePips = 0;

//selection data
int OSMD_SelectedType;//mode history,mode trade
int OSMD_SelectedIndex;

#define OSMD_TRADE_STAT                1
#define OSMD_TRADE_REAL                2
#define OSMD_TRADE_REAL_FORWARD        4
int OSMD_TradeMode;

datetime tlastshift;

double OSMA_Balance;

#define OSM_TRACE_CORE   1
#define OSM_TRACE_ORDERS 2

#include <stdlib.mqh>
//#include <stderror.mqh> //samo definirani kodove na greshki

int SyncSingleOrder( int Index )
{
   int InputIndex = Index;
   if( Index < 0 ) Index = OSMD_Insert();
   OSMD_OpenPrice[Index] = OrderOpenPrice();
   OSMD_Type[Index] = OrderType();
   OSMD_StopLoss[Index] = OrderStopLoss();
   OSMD_ClosePrice[Index] = OrderClosePrice();
   OSMD_OpenTime[Index] = OrderOpenTime();
   OSMD_CloseTime[Index] = OrderCloseTime();
   OSMD_Limit[Index] = OrderTakeProfit();
   Print("[SyncSingleOrder] Index=",Index,",",InputIndex,";ticket=", OrderTicket(),";OrderOpenPrice=",OrderOpenPrice(),
   ";OrderStopLoss=",OrderStopLoss(),";OrderClosePrice=",OrderClosePrice(), ";OrderTakeProfit=",OrderTakeProfit(),
   ";OrderCloseTime=", TimeToStr(OSMD_CloseTime[Index]),",",OSMD_CloseTime[Index]); 
   
   if( OSMD_CloseTime[Index] != 0 )
   {
      OSMD_State[Index] = OSMD_ORDER_CLOSED | OSMD_ORDER_REAL;
      //may be remove from active orders
      OSMD_ActiveOrders_Remove(Index);
   }
   else
   {
      OSMD_State[Index] = OSMD_ORDER_OPENED|OSMD_ORDER_REAL;
      OSMD_ActiveOrders_Add(Index);
   }
   
      
   return (Index); 
}
void OSM_SyncOrders()
{
   //return ;
   int i,Index;
   
   int count = OrdersTotal();

   for( i = 0; i < OSMD_ActiveOrdersSize; i++ )
   {
      Index = OSMD_ActiveOrders[i];
      if( (OSMD_Ticket[Index]&OSMD_TICKET_NOTREAL) == OSMD_TICKET_NOTREAL ) 
      {
         //close it some error may happend
         OSMD_Remove( Index, "delete.sync", 0, true  );
         continue;
      }
      
      if( OrderSelect(OSMD_Ticket[Index],SELECT_BY_TICKET ) == false ) continue;
      SyncSingleOrder( Index );  
   }  

   OSM_Trace(StringConcatenate("[OSM_SyncOrders] LiveCount=",count,";count=",OSMD_ActiveOrdersSize), OSM_TRACE_ORDERS );
   OSMD_ActiveOrdersSize = 0;
   //return;
   for( i = 0; i < count; i++ )
   {
       if( OrderSelect(i,SELECT_BY_POS ) == false ) continue;  
       Index = SyncSingleOrder(OSM_FindOrderFromTicket(OrderTicket()));
   }

   count = OrdersHistoryTotal();
   //samo poslednite 20 operacii max da updatva
   for( i = 0; i < 20; i++ )
   {
      Print("[SyncHistory] i=",i);
      if( i >= count ) break;
      if( OrderSelect(count - i - 1,SELECT_BY_POS, MODE_HISTORY ) == false ) continue; 
      SyncSingleOrder(OSM_FindOrderFromTicket(OrderTicket()));
   } 
 
}
int OSM_OrdersTotal()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD )  return (OrdersTotal());
   int count = 0;
   count = OSMD_ActiveOrdersSize;
   
   if( OSMD_TradeMode&OSMD_TRADE_REAL == OSMD_TRADE_REAL )
   {
      if( OrdersTotal() != count )
      {
         OSM_SyncOrders();  
         count = OSMD_ActiveOrdersSize;
      }   
   }
   
   //Print("[OSM_OrdersTotal] res=", count);
  
   return (count);
}
int OSM_OrdersHistoryTotal()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD )  return (OrdersHistoryTotal());
   
   int count = OSMD_LastIndex + 1 - OSMD_ActiveOrdersSize;
   /*
   if( OSMD_TradeMode&OSMD_TRADE_REAL )
   {
      if( OrdersHistoryTotal() != count )
      {
         OSM_SyncOrders();  
         count = OSMD_ActiveOrdersSize;
      }   
   }
   */
   Print("[OSM_OrdersHistoryTotal] res=", (count));
   return (count);
}
bool OSM_OrderSelect( int index, int select, int pool=MODE_TRADES) 
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD )  return (OrderSelect( index, select, pool ));
   bool res = false;
   
   OSMD_SelectedType = 0;
   OSMD_SelectedIndex = -1;
   //Print("[OSM_OrderSelect] index=",index,";select=",select,";pool=",pool,";res=",OSMD_SelectedIndex);
   
   switch( select )
   {
   case SELECT_BY_TICKET:
      OSMD_SelectedIndex = OSM_FindActiveOrderFromTicket(index);
      if( OSMD_SelectedIndex < 0 )
          OSMD_SelectedIndex = OSM_FindOrderFromTicket(index);
      OSMD_SelectedType = MODE_HISTORY;
      break;
   case SELECT_BY_POS:
      switch( pool )
      {
      case MODE_TRADES:
         if( index < OSMD_ActiveOrdersSize )
         {
            OSMD_SelectedIndex = OSMD_ActiveOrders[index]; 
            OSMD_SelectedType = pool;     
         }
         break;
      case MODE_HISTORY:
         //Print("[OSM_OrderSelect] MODE_HISTORY Not implemented!!");
         if( index < OSM_OrdersHistoryTotal() && (index > -1) )
         {
            int i = 0, cnt = -1;
            while( cnt  < index )
            {
               //Print("[OSM_OrderSelect] MODE_HISTORY i=", i,";closed=",(OSMD_State[i] & OSMD_ORDER_CLOSED) != 0); 
               if( (OSMD_State[i] & OSMD_ORDER_CLOSED) != 0 )
               {
                  cnt++;
               }
               i++;
            }  
            OSMD_SelectedIndex = i-1;
            OSMD_SelectedType = pool;      
         }

         break;
      }
      break;
   }
   
   //Print("[OSM_OrderSelect] index=",index,";select=",select,";pool=",pool,";res=",OSMD_SelectedIndex);
   
   return (OSMD_SelectedIndex > -1);
}
string OSM_OrderSymbol( ) 
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return(OrderSymbol());
   string res="";
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_Symbol[OSMD_SelectedIndex];
   }   
   return (res);
}
int OSM_OrderMagicNumber()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return (OrderMagicNumber());
   int res=-1;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_Magic[OSMD_SelectedIndex];
   }   
   return (res);
}
int OSM_OrderType()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return (OrderType());
   int res=-1;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_Type[OSMD_SelectedIndex];
   }   
   return (res);
}
int OSM_OrderTicket()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return(OrderTicket());
   int res=-1;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_Ticket[OSMD_SelectedIndex];
   }   
   return (res);
}
double OSM_OrderOpenPrice()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return (OrderOpenPrice());
   double res=-1;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_OpenPrice[OSMD_SelectedIndex];
   }   
   return (res);
}

double OSM_OrderTakeProfit()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return (OrderTakeProfit());
   double res=-1;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_Limit[OSMD_SelectedIndex];
   }   
   return (res);
}

double OSM_OrderStopLoss()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return (OrderStopLoss());
   double res=-1;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_StopLoss[OSMD_SelectedIndex];
   }   
   return (res);
}

datetime OSM_OrderOpenTime()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return(OrderOpenTime());
   datetime res;
   if( OSMD_SelectedIndex > -1 )
   {
      res = OSMD_OpenTime[OSMD_SelectedIndex];
   }     
   return (res);
}

double OSM_GetActiveOrdersProfitPips()
{
   double profit=0,pips;
   int dir,Index;
   double priceBid=Bid,priceAsk=Ask, price;
   
   for( int i = 0; i < OSMD_ActiveOrdersSize; i++ )
   {
      Index = OSMD_ActiveOrders[i];
      dir = OSM_Type_GetDirection( OSMD_Type[Index] );
      price = OSM_GetOrderClosePrice(OSMD_Type[Index],priceBid,priceAsk, true);
     
      pips = (price - OSMD_OpenPrice[Index])*dir*1000;
      profit += OSMD_Lots[Index]*100*pips;         
   }
   return (profit); 
}

string OSM_Type_toString( int type )
{
   string res = "OP_Type?";
   switch( type )
   {
   case OP_BUY:
      res = "OP_BUY";
      break;
   case OP_SELL:
      res = "OP_SELL";
      break;
   case OP_BUYLIMIT:
      res = "OP_BUYLIMIT";
      break;
   case OP_BUYSTOP:
      res = "OP_BUYSTOP";
      break;  
   case OP_SELLLIMIT:
      res = "OP_SELLLIMIT";
      break;
   case OP_SELLSTOP:
      res = "OP_SELLSTOP";
      break;                
   }
   return (res);
}

double OSM_CalcClosePrice( int type, double price, bool profit )
{
   switch( type )
   {
   case OP_BUY:
         price -= 0.0005;
      break;
   case OP_SELL:
         price += 0.0005;
      break;
   }  
   return (price);
}
double OSM_GetOrderClosePrice( int type, double priceBid=0, double priceAsk=0, bool profit=true )
{
   double res = 0;
   if( priceBid == 0 )
   {
      priceBid = Bid;
      priceAsk = Ask;  
   }
   
   switch( type )
   {
   case OP_BUYLIMIT:
   case OP_BUYSTOP:
   case OP_BUY:
      if( profit )
         res = priceBid;// - 0.0003;
      else //stop
         res = priceBid;// + 0.0002;
      break;
   case OP_SELLSTOP:
   case OP_SELLLIMIT:
   case OP_SELL:
      if( profit )
         res = priceAsk;// + 0.0003;
      else
         res = priceAsk;// - 0.0002;
      break;
   }
   return (res);  
}
int OSM_Type_GetDirection( int type )
{
   int res = 0;
   switch( type )
   {
   case OP_BUY:
   case OP_BUYLIMIT:
   case OP_BUYSTOP:
      res = 1;
      break;
   case OP_SELL:
   case OP_SELLLIMIT:
   case OP_SELLSTOP:
      res = -1;
      break;
   }
   return (res);
}
bool OSM_Type_IsPending( int type )
{
   bool res = false;
   switch( type )
   {
   case OP_BUY:
   case OP_SELL:
      res = false;
      break;
   case OP_BUYLIMIT:
   case OP_BUYSTOP:   
   case OP_SELLLIMIT:
   case OP_SELLSTOP:
      res = true;
      break;
   }
   return (res);
}
void OSM_Init( int MaxPeriodBars, int MaxCount )
{
   OSMD_SelectedIndex = -1;
   OSMD_SelectedType = 0;
   OSMD_LastIndex = -1;
   OSMD_Capacity = 0;
   OSMA_Balance = AccountBalance();
   ArrayResize( OSMD_ActiveOrders, 100 );
   ArrayInitialize( OSMD_ActiveOrders, -1);
   OSMD_ActiveOrdersSize = 0;
   //OSMD_TradeMode = OSMD_TRADE_REAL;
   OSMD_TradeMode = OSMD_TRADE_REAL_FORWARD;
 
   OSM_Trace( StringConcatenate("[OSM_Init] ActiveOrdersMax=", ArraySize(OSMD_ActiveOrders),
                                 "Initial Balance=",OSMA_Balance), OSM_TRACE_CORE );
   OSMD_MaxOrdersPeriodBars =  MaxPeriodBars;
   OSMD_MaxOrdersForPeriod = MaxCount;
                                   
}
void OSM_SetTradeParams(  int maxloss, int stop, int start )
{
   OSMD_CloseAllOrdersPips = maxloss;
   OSMD_StopTradePips = stop;
   OSMD_StartTradePips = start;
}

void OSM_DeInit()
{
   //close all active orders
   double price = Bid;
   int count = OSMD_ActiveOrdersSize;
      
   Print("[OSM_DeInit] count=", count);
   
   //if this os not zero this can cause
   //removeallorders to be called
   
   while( count > 0 )
   {
      OSMD_Remove(OSMD_ActiveOrders[count-1],"close.deinit", price, true );
      count--;
   }
}

void OSM_CloseAllOrders()
{
   int count,i,Index,dir;
   double price, priceBid=Bid, priceAsk=Ask;
   
   count = OSMD_ActiveOrdersSize;
   OSM_Trace(StringConcatenate("[OSM_CloseAllOrders] count=",count ), OSM_TRACE_ORDERS);
   
   for( i = count - 1; i > -1; i-- )
   {
      Index = OSMD_ActiveOrders[i]; 
      dir = OSM_Type_GetDirection( OSMD_Type[Index] );
      price = OSM_GetOrderClosePrice(OSMD_Type[Index], priceBid, priceAsk, true );
      //true = tre;
      OSM_OrderClose( OSMD_Ticket[Index], OSMD_Lots[Index], price, 3, true );
   }    
}

void OSM_ProcessAutoTradesOpen()
{
   static double last_min_profit=0;
   double cur_profit;
   if( OSMD_TradeMode == OSMD_TRADE_STAT )
   {
      cur_profit = OSMA_Balance;// + OSM_GetActiveOrdersProfitPips();
      if( cur_profit == 0 )
      {
         last_min_profit = 0;
         //Print( "[CloseAllOrdersPipsCheck] last_max_profit reset ", TimeToStr(TimeCurrent()) );
      }
      else if( cur_profit < last_min_profit || last_min_profit == 0)
      {
         last_min_profit = cur_profit; 
         Print( "[OpenAllOrdersPipsCheck] last_min_profit update to ",last_min_profit );  
      }
      double diff_open = cur_profit - last_min_profit;
      //int OSMD_StartTradePips = 0;
      if( diff_open > OSMD_StartTradePips && OSMD_StartTradePips > 0 )
      {
        OSM_Trace(StringConcatenate("[StartRealTrade] going back tp real mode diff=",diff_open,
                        ";last_min_profit=", last_min_profit, ";cur=", cur_profit  ), OSM_TRACE_ORDERS ); 
        OSMD_TradeMode = OSMD_TRADE_REAL; 
        last_min_profit = 0;
      }
   }
}

void OSM_ProcessAutoTradesClose()
{
   int count,i,Index,dir;
   static double last_max_profit=0;

   double cur_profit;
   cur_profit = OSMA_Balance;// + OSM_GetActiveOrdersProfitPips();
   
   //if( OSMD_ORDER_REAL
   if( OSMD_TradeMode == OSMD_TRADE_REAL )
   {
      if( last_max_profit != -1 && (OSMD_CloseAllOrdersPips > 0 || OSMD_StopTradePips > 0))
      {   
         
      
         if( cur_profit == 0 )
         {
            last_max_profit = 0;
            //Print( "[CloseAllOrdersPipsCheck] last_max_profit reset ", TimeToStr(TimeCurrent()) );
         }
         else if( cur_profit > last_max_profit || last_max_profit == 0 )
         {
            last_max_profit = cur_profit; 
            Print( "[CloseAllOrdersPipsCheck] last_max_profit update to ",last_max_profit );  
         }
         
         double diff_close = last_max_profit - cur_profit;
         
         if( last_max_profit > 0 && diff_close >= OSMD_CloseAllOrdersPips && OSMD_CloseAllOrdersPips > 0 )
         {
            //cur_profit is smaller than last_max_profit     
            OSM_Trace(StringConcatenate("[CloseAllOrdersPipsCheck] CloseAllOrders diff=", diff_close,
                        ";lastmax=",last_max_profit,
                        ";cur_profit=",cur_profit ), OSM_TRACE_ORDERS);
            last_max_profit = -1;
            OSM_CloseAllOrders(); 
            last_max_profit = 0; 
         }

         if( diff_close >= OSMD_StopTradePips && OSMD_StopTradePips > 0 )
         {
            OSM_Trace(StringConcatenate("[StopRealTrade] going only to simulation CloseAllOrders diff=", diff_close,
                        ";lastmax=",last_max_profit,
                        ";cur_profit=",cur_profit ), OSM_TRACE_ORDERS);
            last_max_profit = -1;
            OSM_CloseAllOrders(); 
            last_max_profit = 0; 
            OSMD_TradeMode = OSMD_TRADE_STAT;   
         }
      }  
    } 
}
 
int OSM_GetLastError()
{
   return (GetLastError());
}

string OSM_GetLastErrorDescription()
{
   int err = OSM_GetLastError();
   return (StringConcatenate("Error No ", err, " : ", ErrorDescription(err)));  
}

void OSM_ProcessShift()
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return;
   int Index, dir, i, count;
   double price_profit,price_stop,priceBid = Bid, priceAsk = Ask;
   bool ActiveDeleted;
   
   bool new_shift = (tlastshift != Time[0]);
   
   if( new_shift )
   {
       //OSM_ProcessAutoTradesClose();
       OSM_ProcessAutoTradesOpen();
   }
   
   //Print( "[OSM_ProcessShift]" ); 
            //                           ";cp=", price_profit,";op=",OSMD_OpenPrice[Index]  );
   //if( new_shift )//much small processor load only on new shift received calc the stops
   {
      count = OSMD_ActiveOrdersSize;
   
      for( i = 0; i < count; i++ )
      {
         Index = OSMD_ActiveOrders[i]; 
         dir = OSM_Type_GetDirection( OSMD_Type[Index] );
      
        //    OSM_Trace( StringConcatenate("[OSM_Init] ActiveOrdersMax=", ArraySize(OSMD_ActiveOrders),
        //                            "Initial Balance=",OSMA_Balance), OSM_TRACE_CORE );
     
         price_profit = OSM_GetOrderClosePrice(OSMD_Type[Index], priceBid, priceAsk, true );
         price_stop   = OSM_GetOrderClosePrice(OSMD_Type[Index], priceBid, priceAsk, false );
        
         ActiveDeleted = false;
         
         if( OSM_Type_IsPending(OSMD_Type[Index]) )
         {
            //buy sell limit stop
            //only pending orders 
            //that are waiting to be switched on
            bool ready_for_open = false;
            int new_type=0;
            double diff;

            diff = dir*(price_profit - OSMD_OpenPrice[Index]);
            
            if( OSM_Type_GetDirection( OSMD_Type[Index] ) > 0 )
            {
               new_type = OP_BUY;  
            }
            else
            {
               new_type = OP_SELL;   
            }
            switch( OSMD_Type[Index] )
            {
            case OP_BUYLIMIT:
            case OP_SELLLIMIT:
               diff = -diff;
               break;
            }
            
            ready_for_open = diff > -0.0001;
            
            //Print( "[ProcessPendOrder] ticket #", OSMD_Ticket[Index], " diff = ", diff, 
            //                           ";cp=", price_profit,";op=",OSMD_OpenPrice[Index]  );
            
            if( ready_for_open )
            {
               OSMD_Type[Index] = new_type;
               OSMD_OpenTime[Index] = Time[0];
               //OSMD_OpenPrice[Index] = price_profit;
               OSM_Trace( StringConcatenate("[OSM_OrderOpen] order #",OSMD_Ticket[Index],
                     " ", OSM_Type_toString(OSMD_Type[Index]), 
                     " is opened at ", OSMD_OpenPrice[Index] ), OSM_TRACE_ORDERS );  
                   
            }     
         }
         else
         {
            if(  (OSMD_StopLoss[Index] != 0) &&
                  (dir*(OSMD_StopLoss[Index] - price_stop) > 0))//-0.0001))
            {
               //stop loss activation close the order
               OSMD_Remove( Index, "stoploss", OSM_CalcClosePrice( OSMD_Type[Index], OSMD_StopLoss[Index], false) );  
               ActiveDeleted = true;
            }  
            else if((OSMD_StopLoss[Index] != 0) &&
                  (dir*(price_profit - OSMD_Limit[Index]) > -0.0001))
            {
               OSMD_Remove( Index, "takeprofit", OSM_CalcClosePrice( OSMD_Type[Index], OSMD_Limit[Index], false) );  
               ActiveDeleted = true;           
            }
         } 
      
         if( ActiveDeleted ) i--;            
      }
   }
   tlastshift = Time[0];
}

bool OSM_OrderClose( int ticket, double lots, double price, int slippage, color Color=CLR_NONE, bool multipledelete=false) 
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) 
            return (OrderClose( ticket, lots, price, slippage, Color ));
            
   bool res = false;

   int Index = OSM_FindActiveOrderFromTicket(ticket);
   
   //if( OSMD_TradeMode == OSMD_TRADE_REAL )
     
   if( Index > -1 )
   {
      if( (OSMD_State[Index]&OSMD_ORDER_REAL) != 0 )     
      res = OrderClose( ticket, lots, price, slippage, Color );
   }      
   
   OSMD_Remove( Index, "close", price, multipledelete );
   
   return (res);
}

bool OSM_OrderDelete( int ticket )
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) return (OrderDelete( ticket ));
   
   bool res = false;

   int Index = OSM_FindActiveOrderFromTicket(ticket);
   
   //if( OSMD_TradeMode == OSMD_TRADE_REAL )  
   if( Index > -1 )
   {
      if( (OSMD_State[Index]&OSMD_ORDER_REAL) != 0 )     
      res = OrderDelete( ticket );
   }      
   
   OSMD_Remove( Index, "delete", 0, false );
   
   return (res);
}

bool OSMD_Remove( int Index, string reason, double price, bool multipledelete = false )
//reason == stoploss,limit,close
{
   bool res = false;
   
   if( Index == -1 )
   {
      OSM_Trace("OSMD_Remove Error wrong index -1",OSM_TRACE_ORDERS);
      return (false);
   }
   
   //open   #1 sell 0.10 EURUSD at 0.8917 sl: 0.9037 tp: 0.8117 ok
   //modify #1 sell 0.10 EURUSD at 0.8917 sl: 0.8798 tp: 0.8117 ok
   //Tester: stop loss #1 at 0.8798 (0.8799 / 0.8802)
           
   OSMD_ActiveOrders_Remove(Index);    
   
   int old_state = OSMD_State[Index]&OSMD_ORDER_REAL;
   
   if( price == 0 ) price = OSMD_OpenPrice[Index]; // da e na nula
   
   OSMD_State[Index] = OSMD_ORDER_CLOSED |  old_state;//(OSMD_State[Index]&OSMD_ORDER_OPENED);  
   OSMD_ClosePrice[Index] = price;    
   OSMD_CloseTime[Index] = TimeCurrent();
   
   double diff =  (OSMD_ClosePrice[Index] - OSMD_OpenPrice[Index])*OSM_Type_GetDirection( OSMD_Type[Index] );
   
   double profit = diff*OSMD_Lots[Index]*100000;
   
   OSMA_Balance += profit; 
   
   OSM_Trace( StringConcatenate("[OrderClose] ", reason," ",OSM_Type_toString( OSMD_Type[Index] ) , 
               " #", OSMD_Ticket[Index],";i=", Index,
               " at ", DoubleToStr( OSMD_ClosePrice[Index],4), ";(", Bid," / ", Ask,") open=",OSMD_OpenPrice[Index],
               ";profit=",profit,
               ";balance=",OSMA_Balance, ";asize=", OSMD_ActiveOrdersSize,";aprofit=",OSM_GetActiveOrdersProfitPips() ), 
               OSM_TRACE_ORDERS); 
               
   if( multipledelete == false )
   {            
      OSM_ProcessAutoTradesClose();            
   }
    
   return (res);
}

void OSM_Trace( string msg, int type )
{
   Print(msg);
}

int OSMD_OrdersCountForPeriod( datetime from )
{
   int Index = OSMD_LastIndex;
   int count = 0, countnl = 0;
   bool update_count;
   int dir;
   while( Index > -1 )
   {
      if( OSMD_OpenTime[Index] < from ) break;
      update_count = true;
      
      //ako ordera e zatvoren na pechalba
      dir = OSM_Type_GetDirection( OSMD_Type[Index] );    
      
      if( dir*(OSMD_StopLoss[Index] - OSMD_OpenPrice[Index]) > 0)
      {
         update_count = false;
         countnl++;
      }  
      
      if( update_count )
         count++; 
      
      Index--;
   }
   return (count);
}

bool OSMD_IsOrdersLimitReached()
{
   if( OSMD_MaxOrdersPeriodBars <= 0 ) return (false);
   
   bool res = false;
   int count = OSMD_OrdersCountForPeriod( Time[OSMD_MaxOrdersPeriodBars] );
   if( count >= OSMD_MaxOrdersForPeriod )
   {
      res = true; 
      OSM_Trace( StringConcatenate("[OSMD_IsOrdersLimitReached] current count=",count, ";limit=", 
                  OSMD_MaxOrdersForPeriod, ";"), OSM_TRACE_ORDERS );
   }
   return (res);
}

int OSM_OrderSend( string symbol, int cmd, double volume, 
               double price, int slippage, double stoploss, 
               double takeprofit, string comment, int magic,
               datetime expiration, color arrow_color) 
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) 
      return (OrderSend(symbol, cmd, volume, price,slippage, 
                           stoploss, takeprofit, comment,magic,0, arrow_color ));
   string errdesc;
   if( OSMD_IsOrdersLimitReached() ) return (-1);
   int Index = OSMD_Insert();
   //internal sedn order data
   OSMD_Symbol[Index] = symbol;
   OSMD_Type[Index] = cmd;
   OSMD_Lots[Index] = volume;
   OSMD_OpenPrice[Index] = price;
   OSMD_StopLoss[Index] = stoploss;
   OSMD_Limit[Index] = takeprofit;
   OSMD_Comment[Index] = comment;
   OSMD_Magic[Index] = magic;
   OSMD_OpenTime[Index] = TimeCurrent();
   OSMD_Ticket[Index] = OSMD_TICKET_NOTREAL + Index;//ako e po malko to nula kojto vika moje da pomisli che e greshka
   OSMD_State[Index] = OSMD_ORDER_OPENED;
   if( OSMD_TradeMode == OSMD_TRADE_REAL )
   {
      OSMD_State[Index] = OSMD_ORDER_OPENED|OSMD_ORDER_REAL;
            
      OSMD_Ticket[Index] = (OrderSend(symbol, cmd, volume, price,slippage, 
                           stoploss, takeprofit, comment,magic,0, arrow_color )); 
      if( OSMD_Ticket[Index]  <= 0 )
      {
         errdesc = StringConcatenate( OSM_GetLastErrorDescription(), " (", Bid,",",Ask,")");
      }
   }                          
                            
   
   OSM_Trace( StringConcatenate("[OSM_OrderSend] open #",OSMD_Ticket[Index], ";i=", Index, ";",
   OSM_Type_toString(OSMD_Type[Index]),"=",DoubleToStr( OSMD_Lots[Index], 2 ),
    ";", OSMD_Symbol[Index], " at ", DoubleToStr(OSMD_OpenPrice[Index], 4) , 
    ";sl=", DoubleToStr( OSMD_StopLoss[Index],4),
    ";tp=", DoubleToStr( OSMD_Limit[Index], 4), ";", OSMD_Ticket[Index], errdesc,
    ";balance=", OSMA_Balance, ";asize=", OSMD_ActiveOrdersSize,";aprofit=",OSM_GetActiveOrdersProfitPips() ),
      OSM_TRACE_ORDERS );

   OSMD_ActiveOrders_Add(Index);
                                              
   return (OSMD_Ticket[Index]);
}
int OSM_FindOrderFromTicket( int ticket )
{
   int Index = -1;
   Print("[OSM_FindOrderFromTicket]");
   for( int i = OSMD_LastIndex; i >=0; i-- )
   {
      if( OSMD_Ticket[i] == ticket )
      {
         Index = i;
         break;
      }
   }
   return (Index);
}
int OSM_FindActiveOrderFromTicket( int ticket )
{
   int Index = -1;
   for( int i = 0; i < OSMD_ActiveOrdersSize; i++ )
   {
      if( OSMD_Ticket[OSMD_ActiveOrders[i]] == ticket )
      {
         Index = OSMD_ActiveOrders[i];
         break;
      }
   }
   return (Index);
}
//void OrderModify(OrderTicket(),OrderOpenPrice(),stoploss ,OrderTakeProfit(),0,oColor); 
bool OSM_OrderModify( int ticket, double price, double stoploss, double takeprofit, datetime expiration, color arrow_color=CLR_NONE) 
{
   if( OSMD_TradeMode&OSMD_TRADE_REAL_FORWARD == OSMD_TRADE_REAL_FORWARD ) 
      return (OrderModify( ticket, price, stoploss, takeprofit, expiration, arrow_color ));
   //search by ticket
   int Index = OSM_FindActiveOrderFromTicket(ticket);
   bool res = false;
   if( Index > -1 )
   {
      if( price != 0 && OSM_Type_IsPending( OSMD_Type[Index] ) )
      {
         OSMD_OpenPrice[Index] = price;
      } 
      
      OSMD_StopLoss[Index] = stoploss;
      OSMD_Limit[Index] = takeprofit;
      
      res = true;
      string errdesc;
      
      if( OSMD_TradeMode == OSMD_TRADE_REAL )
      {
         res = OrderModify( ticket, price, stoploss, takeprofit, expiration, arrow_color );
         if( res == false )
         {
            errdesc = StringConcatenate( OSM_GetLastErrorDescription(), " (", Bid,",",Ask,")");
            //SYnc the order 
            //OSM_SyncOrders();
         }       
      }

      // modify #8 sell 0.10 EURUSD at 0.8811 sl: 0.8780 tp: 0.8011 ok
       OSM_Trace( StringConcatenate("[OSM_OrderModify] modify #",OSMD_Ticket[Index] ,";i=", Index,";",
               OSM_Type_toString(OSMD_Type[Index]),"=",DoubleToStr( OSMD_Lots[Index], 2 ),
                ";", OSMD_Symbol[Index], " at ", DoubleToStr(OSMD_OpenPrice[Index], 4) , 
                ";sl=", DoubleToStr( OSMD_StopLoss[Index],4),
                ";tp=", DoubleToStr( OSMD_Limit[Index], 4),";", res," ", errdesc), OSM_TRACE_ORDERS );   

   }
   else
   {
      OSM_Trace( StringConcatenate("[OSM_OrderModify] order with ticket #",ticket," not found!!!!!" ), OSM_TRACE_ORDERS );   
   }
   return (res);   
}

void OSMD_IncreaseCapacity()
{
   OSMD_Capacity+=100;
   ArrayResize(OSMD_Symbol, OSMD_Capacity);
   ArrayResize(OSMD_Type, OSMD_Capacity);
   ArrayResize(OSMD_Lots, OSMD_Capacity);
   ArrayResize(OSMD_OpenPrice, OSMD_Capacity);
   ArrayResize(OSMD_ClosePrice, OSMD_Capacity);
   ArrayResize(OSMD_StopLoss, OSMD_Capacity);
   ArrayResize(OSMD_Limit, OSMD_Capacity);
   ArrayResize(OSMD_Comment, OSMD_Capacity);
   ArrayResize(OSMD_Magic, OSMD_Capacity);
   ArrayResize(OSMD_Ticket, OSMD_Capacity);
   ArrayResize(OSMD_State, OSMD_Capacity);
   ArrayResize(OSMD_OpenTime, OSMD_Capacity);
   ArrayResize(OSMD_CloseTime, OSMD_Capacity);         
   OSM_Trace( StringConcatenate("[OSMD_IncreaseCapacity] Capacity=",OSMD_Capacity,";size=",ArraySize(OSMD_Symbol)), OSM_TRACE_CORE );
}
 
int OSMD_Insert()
{
   OSMD_LastIndex++;
   if( OSMD_LastIndex >= OSMD_Capacity )
   {
      OSMD_IncreaseCapacity();
   }
   return (OSMD_LastIndex);
}

int OSMD_ActiveOrders_Find( int OrderIndex )
{
   int res = -1;
   for( int i = 0; i <  OSMD_ActiveOrdersSize; i++ )
   {
      if( OSMD_ActiveOrders[i] == OrderIndex )
      {
         res = i;  
      }
   }
   return (res);
}

int OSMD_ActiveOrders_Add( int OrderIndex )
{
   if( OSMD_ActiveOrdersSize < ArraySize(OSMD_ActiveOrders) )
   {
      Print("[OSMD_ActiveOrders_Add] OrderIndex=", OrderIndex,",OSMD_ActiveOrdersSize=", OSMD_ActiveOrdersSize );
      if( OSMD_ActiveOrders_Find(OrderIndex) < 0 )
      {
         OSMD_ActiveOrders[OSMD_ActiveOrdersSize] = OrderIndex;  
         OSMD_ActiveOrdersSize++;
      }
   }
   else
   {
      OSM_Trace(StringConcatenate( "[OSMD_ActiveOrders_Add] too many active operations!!!!",
      OSMD_ActiveOrdersSize,",#", OrderIndex ), 0xFFFF );
   }
   return (OSMD_ActiveOrdersSize);
}

int OSMD_ActiveOrders_Remove( int OrderIndex )
{
   //search for the Order
   bool OrderFound = false;
   for( int i = 0; i <  OSMD_ActiveOrdersSize; i++ )
   {
      if( OrderFound == false && OSMD_ActiveOrders[i] == OrderIndex )
      {
         OrderFound = true;  
      }
      if( OrderFound == true )
      {
         OSMD_ActiveOrders[i] = OSMD_ActiveOrders[i+1];   
      }
   }
   if( OrderFound && OSMD_ActiveOrdersSize >= 0 )
   {
      OSMD_ActiveOrdersSize--;  
   }
   //Print( "[OSMD_ActiveOrders_Remove] ", OrderIndex, " ", OrderFound );
   return (OrderFound);
}


