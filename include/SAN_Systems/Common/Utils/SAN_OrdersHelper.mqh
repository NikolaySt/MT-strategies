//|                                           SAN_OrdersHelper.mqh   |
//|                   #include <SAV_Framework/SAN_OrdersHelper.mqh>  |
//|                            Copyright © 2011, SAN Andrey&Nikolai. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

//SAN_OrdersHelper ще премахне в крайният вариант OrdersHelper lilbrarito
//Всяка една функция дефинирана в OrdersHelper ще се разпише тук до като
//напълно се покрият всички функции като промяната ще бъде
//do kyde sme stignalis prenapisvaneto izbroiavane an funkciite
//OpenOrder    -- Order_Open,
//PendingOrder -- Order_OpenPending,
//RateLargerOnPrevHalfBar -- Order_RateLargerOnPrevHalfBar
//CloseOrdersByTypeInProfit -- Orders_CloseByTypeInProfit
//CloseOrdersByType -- Orders_CloseByType
//CloseOrders -- Orders_Close
//CloseAllOrders -- Orders_CloseAll;
//CloseOrdersByTimeSignal - Orders_CloseByTimeSignal
//RemovePendingOrderbyType -- PendingOrders_RemoveByType
//PendingOrder_RemoveByDir -- PendingOrders_RemoveByDir
//RemovePendingOrders      -- PendingOrders_Remove
//RemovePendingByLevel     -- PendingOrders_RemoveByLevel
//RemovePendingByTimeSignal -- PendingOrders_RemoveBySigTime
//CountTradeOrders          -- OpenOrders_GetCountForType
//CountOpenOrders           -- OpenOrders_GetCount
//CountAllOpenOrders        -- OpenOrders_GetCountAll
//CountTradeOrders_TimeSignal -- OpenOrders_GetCountForSigTime
//CountTradeOrders_TimeSignalT -- OpenOrders_GetCountForSigTimeT
//Order_CountLoss              -- OpenOrders_GetCountLoss  
                                //OpenOrders_GetProfitByType(int settID, int orderType);
//SumOrdersProfitInPips        -- OpenOrders_GetProfitInPips
//SumOrdersProfitInPipsCurr    -- OpenOrders_GetProfitInPipsAll
//History_CountOrderTimeSignal -- HOrders_GetCountSigTime
//History_CountOrderTimeSignalT -- HOrders_GetCountSigTimeT
//History_CloseWithLimit_Time   -- HOrders_CloseWithLimit_Time
//History_CloseWithLimit_Ticket -- HOrders_CloseWithLimit_Ticket
//History_IsOrderClose    -- HOrders_IsOrderClose
//History_IsOpenCloseInCurrentBar -- HOrders_IsOpenCloseInCurrentBar

//-------NEW---------------
//HOrders_GetLastCloseTicket
//

//--------------function description
//Тази функция се ползва само когато експерта работи реално или теста е на всички тикове
//проверява текущото ценово ниво да е по голямо от средата на предишен бар зададен чрез часово ниво и Дата на бара
//bool Order_RateLargerOnPrevHalfBar(int Type, int TimeFrame);
/*
//затваря поръчката само ако е на печалва по голяма от зададената чрез ProfitPoints 
void CloseOrdersByTypeInProfit(int MAGIC, int TradeType, int ProfitPips = 0);
void CloseOrdersByType(int MAGIC, int TradeType);
void CloseOrders(int MAGIC);
void CloseAllOrders(); //затваря всички отворени ордери от дадения инструмент 
//затваря ордерите от дадена система по зададен тип и време на гренериране на сигнала
void CloseOrdersByTimeSignal(int MAGIC, int TradeType, datetime TimeSignal);
*/

//В коментара на всеки ордер кодирам
/*
string OrderComment_Build( int settID, string name, datetime ctime, int stopPips );
string OrderComment_GetName( string comment );
datetime OrderComment_GetTime( string comment );
int OrderComment_GetStop( string comment );
int OrderComment_GetSettID( string comment );
*/

// 1. функциите ще се преименуватда започват със SAN_Order Префикс или SANO или друг префикс
// 2. Навсякъде където има параметър MAGIK  ще се подава settID
// 3. Където се налага използване на SignalTime ще се взима от OrderMagic вместо от Коментара !!!!

//------------------ Constants
color SANO_clOpenBuy = Lime;
color SANO_clCloseBuy = White;
color SANO_clOpenSell = Red;
color SANO_clCloseSell = Yellow;

color SANO_clSellStop = Red;
color SANO_clBuyStop = Lime;

color SANO_clModifyBuy = Silver;
color SANO_clModifySell = Pink;

color SANO_clStop = Red;

bool SANO_UseSound = True;
string SANO_NameFileSound = "alert.wav";
//------------------- 
// function headers
//-------------------
//by default now signal time is encoded in magic
bool SANO_UseMagicFOROT = true;
datetime SelectedOrder_GetSignalTime()
{
   datetime result; 
   if(SANO_UseMagicFOROT) // get signaltime from magic
      result = Magic_GetSignalTime(OrderMagicNumber(),OrderOpenTime());
   else
      result = OrderComment_GetTimeInt(OrderComment());
   return (result);
}

int DigMode(){
   if (Digits == 4) return(1);
   if (Digits == 5) return(10);
   if (Digits == 2) return(1);
   if (Digits == 3) return(10);   
}

double PipsToPoints(int pips){ return (pips*DigMode()*Point); }

/*//При конвертиране от points до пипсове не трябва да се умножава по DigMode();
//Пример: 
   1.23450 - 1.12342 = 0.11108 points
   pri koeto imeme 11108 pipsa
   
   vsiaka drugo promenliva ot vhodia6tite se umniojava po DigMode();
   
   pri koeto ako imame A004_OffsetPips = 50;
   realno 6te e A004_OffsetPips = A004_OffsetPips * DigMode() = 500;
   
   i togava 11108 > 500

   ina4e 6te stane 1110 > 500 koeto ne e korekno       

int PointsToPips(double points){ return (points/Point); }
//*/ 

int Slippage(int Points = 2){  return (Points*DigMode()); }

string TypeOrderToString(int type){
   switch (type){
      case OP_SELL: return("OP_SELL"); break;
      case OP_BUY: return("OP_BUY"); break;
      case OP_SELLSTOP: return("OP_SELLSTOP"); break;      
      case OP_BUYSTOP: return("OP_BUYSTOP"); break;
      case OP_BUYLIMIT: return("OP_BUYLIMIT"); break;
      case OP_SELLLIMIT: return("OP_SELLLIMIT"); break;
   }
}

bool OrderType_IsPending( int type )
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

int OrderType_GetDirection( int type )
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

int InternalViewLastError(string Info, int ErrorCode){
   Print(Info, " - error(",ErrorCode,"): ", ErrorDescription(ErrorCode));
        
   string FileName = "ErrorOperations.txt";
   int file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');
   
   if (file < 1){
     Print("File " + FileName + ", the last error is ", GetLastError());     
     return(false);   
   }
   if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);
   string Pos = TimeToStr(Time[0]) + ": "+ Info + " - error("+ErrorCode+"): "+ ErrorDescription(ErrorCode);
   FileWrite(file, Pos);            
   FileClose(file);      
   return(0);
}

double Order_Open(int MAGIC, int Type, double ldLot, double ldStop, double ldLimit, string comment){       
   if (!(Type == OP_BUY || Type == OP_SELL)) return (-1);
   int check = 0;   
   
   if (Type == OP_BUY){
      check = OrderSend(Symbol(), Type, ldLot, Ask, Slippage(), ldStop, ldLimit, comment, MAGIC, 0, SANO_clOpenBuy); 
   }      
   
   if (Type == OP_SELL){
      check = OrderSend(Symbol(), Type, ldLot, Bid, Slippage(), ldStop, ldLimit, comment, MAGIC, 0, SANO_clOpenSell); 
   }            
   
   if (check > 0){      
      if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
      return(check);
   }else{      
      string info = "*** ERROR OpenOrder " + TypeOrderToString(Type) + " *** Lot =  " + DoubleToStr(ldLot, 2);  
      if (Type == OP_SELL){ 
         info  = info +", OpenPrice = " + DoubleToStr(Bid, Digits);
      }else{
         info  = info + ", OpenPrice = " + DoubleToStr(Ask, Digits);
      }
      info = info + ", Stop = " + DoubleToStr(ldStop,Digits) + ", Limit = " + DoubleToStr(ldLimit, Digits);
      InternalViewLastError(info, GetLastError());
      return(-1);
   }
}

double Order_OpenPending(int MAGIC, int Type, double ldLevel, double ldLot, double ldStop, double ldLimit, string comment, datetime expiration){

   color pos_color;
   
   if (Type == OP_BUYSTOP){
      pos_color =  SANO_clBuyStop;  
   }         
   if (Type == OP_SELLSTOP){
      pos_color =  SANO_clSellStop;
   }   
   int check = OrderSend(Symbol(), Type, ldLot, ldLevel, Slippage(), ldStop, ldLimit, comment, MAGIC, expiration, pos_color);
        
   if (check > 0){      
      if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
      return(check);
   }else{ 
      string info = "*** ERROR Pending " +TypeOrderToString(Type) + " *** Lot =  " + DoubleToStr(ldLot, 2);  
      info  = info +", OpenPrice = " + DoubleToStr(ldLevel, Digits);      
      info = info + ", Stop = " + DoubleToStr(ldStop,Digits) + ", Limit = " + DoubleToStr(ldLimit, Digits);      
      InternalViewLastError(info, GetLastError());
      return(-1);
   }
}

//проверява текущото ценово ниво да е по голямо от средата на предишен бар зададен чрез часово ниво и Дата на бара
bool Order_RateLargerOnPrevHalfBar(int Type, int TimeFrame){   
   double low = iLow(NULL, TimeFrame, 1);
   double high = iHigh(NULL, TimeFrame, 1);           
   RefreshRates();
   if (Type == OP_SELL){ return( !(Bid > low + (high - low)/2) ); }            
   if (Type == OP_BUY){ return( !(Ask < low + (high - low)/2) ); }
}

#define COMMENT_TIME_OFFSET 1293840000 //2011.01.01 00:00:00 Time = 1293840000
string OrderComment_Build( int settID, string name, datetime time, int stopPips, string CustComment = "")
{
   string str_timesig = "t="+time;
   
   if (SANO_UseMagicFOROT)
   {
      if( IsTesting() )
      {
         str_timesig = "t=" + TimeToStr(time);
      }
      else
      {
      //--------------------------------------------------------
      // записва се във вида: YYMMDDHH
      string year, month, day, hour;
      year = TimeYear(time);    if (StringLen(year) == 1) year = "0"+year;    
      month = TimeMonth(time);  if (StringLen(month) == 1) month = "0"+month;    
      day = TimeDay(time);      if (StringLen(day) == 1) day = "0"+day;         
      hour = TimeHour(time);    if (StringLen(hour) == 1) hour = "0"+hour;
      //--------------------------------------------------------                  
      year = StringSubstr(year, 2, 2);
      str_timesig = "t="+year+month+day+hour; 
      }     
   }
   if (!IsTesting()){
      if(!SANO_UseMagicFOROT)
      {
         //намаляване на дължината на коментара при реална търговия
         time = time - COMMENT_TIME_OFFSET;      
         //Пример : t=259200;s=468;n=A2:3; за намален коментар
         //Пример : t=1262577600;s=468;n=А002:3; дълъг пълен коментар
         str_timesig = "t="+time;
      }
      // премахва нулите в името примерно: А001 става А1; N010 става N10
      name = StringSubstr(name, 0, 1) + DoubleToStr(StrToInteger(StringSubstr(name, 1, StringLen(name))), 0);   
   }               
   //Print("[OrderComment_Build.TRACE] :: " + StringConcatenate(str_timesig,";s=",stopPips,";n=",name,":",settID,";"));   
   if (StringLen(CustComment) > 0){
      return (StringConcatenate(str_timesig,";s=",stopPips,";n=",name,":",settID,";c=",CustComment,";"));         
   }else{
      return (StringConcatenate(str_timesig,";s=",stopPips,";n=",name,":",settID,";"));         
   }
   
}
 
string OrderComment_GetName( string comment )
{
   return (SAV_Settings_GetNamedValue(comment,"n"));
}
 
datetime OrderComment_GetTimeInt( string comment )
{
   datetime time = StrToDouble(SAV_Settings_GetNamedValue(comment,"t"));
   if (!IsTesting()){
      time = time + COMMENT_TIME_OFFSET; 
   }
   return (time);
}

int OrderComment_GetStop( string comment )
{
   return (StrToInteger(SAV_Settings_GetNamedValue(comment,"s")));
} 

int OrderComment_GetSettID( string comment )
{
   string name = SAV_Settings_GetNamedValue(comment,"n");
   int index = StringFind(name, ":", 0);   
   int id = -1;
   if (index != -1) id = StrToInteger(StringSubstr(name, index+1, StringLen(name) - index - 1));   
   return (id);   
}

void Orders_CloseByTypeInProfit(int settID, int TradeType, int ProfitPips = 0) { 
   bool check; 
   bool check_exit, mark_close = false;
   int i;  
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == TradeType) {                                                 
                  
                  if (TradeType == OP_BUY) { 
                     RefreshRates();     
                     if ((Bid - OrderOpenPrice() > ProfitPips*Point)|| ProfitPips == 0)
                        check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), SANO_clCloseBuy);                      
                  }                     
                  if (TradeType == OP_SELL){
                     RefreshRates();     
                     if ((OrderOpenPrice() - Ask > ProfitPips*Point)|| ProfitPips == 0)
                        check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), SANO_clCloseSell);                      
                  }                     
                  if (check){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                  }else{
                     InternalViewLastError("CloseOrdersByTypeInProfit", GetLastError());
                     
                  }                                    
            } 
         }else{
            InternalViewLastError("CloseOrdersByTypeInProfit - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }   
} 

void Orders_CloseByType(int settID, int TradeType) { 
   bool check; 
   bool check_exit, mark_close = false;
   int i;             
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == TradeType) {                                                 
                  
                  if (TradeType == OP_BUY) { 
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), SANO_clCloseBuy);                      
                  }                     
                  if (TradeType == OP_SELL){
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), SANO_clCloseSell);                      
                  }                     
                  if (check){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                  }else{
                     InternalViewLastError("CloseOrdersByType - ClosePosition", GetLastError());                       
                  }                                    
            } 
         }else{
            InternalViewLastError("CloseOrdersByType - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }   
} 

void Orders_Close(int settID) { 
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                                                 
                  
                  if (OrderType() == OP_BUY) {
                     RefreshRates();    
                     check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), SANO_clCloseBuy);                      
                  }                     
                  if (OrderType() == OP_SELL){
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), SANO_clCloseSell);                      
                  }                     
                  if (check){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                  }else{
                     InternalViewLastError("ClosePositions - ClosePosition", GetLastError());                          
                  }                                    
            } 
         }else{
            InternalViewLastError("ClosePositions - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }   
} 

void Orders_CloseAll() { 
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {                                                 
                  
                  if (OrderType() == OP_BUY) {
                     RefreshRates();    
                     check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), SANO_clCloseBuy);                      
                  }                     
                  if (OrderType() == OP_SELL){
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), SANO_clCloseSell);                      
                  }                     
                  if (check){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                  }else{
                     InternalViewLastError("CloseAllOrders - ClosePosition", GetLastError());                          
                  }                                    
            } 
         }else{
            InternalViewLastError("CloseAllOrders - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }   
}

void Orders_CloseByTimeSignal(int settID, int TradeType, datetime TimeSignal){
   bool check; 
   bool check_exit, mark_close = false;
   int i;             
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == TradeType
               && SelectedOrder_GetSignalTime() == TimeSignal) {                                                 
                  
                  if (TradeType == OP_BUY ) { 
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), SANO_clCloseBuy);                      
                  }                     
                  if (TradeType == OP_SELL){
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), SANO_clCloseSell);                      
                  }                     
                  if (check){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                  }else{
                     InternalViewLastError("CloseOrdersByTimeSignal - ClosePosition", GetLastError());                       
                  }                                    
            } 
         }else{
            InternalViewLastError("CloseOrdersByTimeSignal - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }
}

void PendingOrders_RemoveByType(int settID, int type){       
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
   
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                                                                   

               if (type == OrderType() ) {                                         
                  if (OrderDelete(OrderTicket())){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                                       
                  }else{
                     InternalViewLastError("RemovePendingOrder", GetLastError());              
                  }                               
               }                                                     
            } 
         }else{
            InternalViewLastError("RemovePendingOrder - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }             
}

void PendingOrders_RemoveByDir( int settID, int dir )
{
  int op_type;
  if( dir > 0 ) op_type = OP_BUYSTOP; else op_type = OP_SELLSTOP;

// TODO: may be little bit improve this or add to orders library
  PendingOrders_RemoveByType( settID, op_type );
}

void PendingOrders_Remove(int settID){       
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
   int type;

   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                                                                   
               type = OrderType();
               if (type == OP_SELLSTOP || type == OP_SELLLIMIT || type == OP_BUYSTOP || type == OP_BUYLIMIT){
                  if (OrderDelete(OrderTicket())){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound);                                     
                  }else{
                     InternalViewLastError("RemovePendingOrders", GetLastError());              
                  }                               
               }               
            } 
         }else{
            InternalViewLastError("RemovePendingOrders - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }          
}

void PendingOrders_RemoveByLevel(int settID, int type, double level){       
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
   
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                                                                   
               
               if (type == OrderType() && NormalizeDouble(OrderOpenPrice(), Digits) != NormalizeDouble(level, Digits) && NormalizeDouble(level, Digits) > 0) {                                         
                  if (OrderDelete(OrderTicket())){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                                       
                  }else{
                     InternalViewLastError("RemovePendingOrder", GetLastError());              
                  }                               
               }                                                     
            } 
         }else{
            InternalViewLastError("RemovePendingOrder - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }             
}

void PendingOrders_RemoveBySigTime(int settID, datetime TimeSignal){
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
   
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID &&
                (OrderType() == OP_SELLSTOP || OrderType() == OP_BUYSTOP)) {                                                                   
               
               if ( SelectedOrder_GetSignalTime() == TimeSignal ) {                                         
                  if (OrderDelete(OrderTicket())){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                                       
                  }else{
                     InternalViewLastError("RemovePendingByTimeSignal", GetLastError());              
                  }                               
               }                                                     
            } 
         }else{
            InternalViewLastError("RemovePendingByTimeSignal - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   } 
}

int OpenOrders_GetCountForType(int settID, int trade_type){
   int count = 0;
   for (int i=0; i < OrdersTotal(); i++) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == trade_type) {
           count++;
        }
     }
   } 
   return(count);   
}

int OpenOrders_GetCount(int settID){
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID
            && (OrderType()==OP_SELL || OrderType()==OP_BUY)) {           
            count++;	        
         }
      }
   } 
   return(count);
}

int OpenOrders_GetCountAll(){
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && (OrderType()==OP_SELL || OrderType()==OP_BUY)) {           
            count++;	        
         }
      }
   } 
   return(count);
}

int OpenOrders_GetCountForSigTime(int settID, datetime time){   
   int count_order = 0;
   datetime dt;
   for (int i =  OrdersTotal() - 1; i >= 0; i--) 
   {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
     {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) 
        {   
           dt = SelectedOrder_GetSignalTime();  
           //Print("[CountTradeOrders_TimeSignal] dt=",dt,";time=",time,";dt==time=", dt == time );         
           if ( dt == time ) 
           { 
              count_order++;              
	        }
        }
     }
   } 
   //Print("[CountTradeOrders_TimeSignal] count=", count_order);
   return(count_order);
} 

int OpenOrders_GetCountForSigTimeT(int settID, datetime time, int orderType)
{   
   int count_order = 0;
   datetime dt;
   for (int i =  OrdersTotal() - 1; i >= 0; i--) 
   {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
     {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == orderType) 
        {   
           dt = SelectedOrder_GetSignalTime(); 
           //Print("[CountTradeOrders_TimeSignal] dt=",dt,";time=",time,";dt==time=", dt == time,";magic=",OrderMagicNumber() );         
           if ( dt == time ) 
           { 
              count_order++;              
	        }
        }
     }
   } 
   //Print("[CountTradeOrders_TimeSignal] count=", count_order);
   return(count_order);
}

int OpenOrders_GetCountLoss(int settID)
{
   int type = 0;
   double profit;
   int total;
   int noloss =0;
   int loss = 0;
 
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) continue;
     
      type = 0;
      switch( OrderType() )
      {
      case OP_SELL:
         type = -1;
         break;
      case OP_BUY:
         type = 1;
         break;
      } 
          
      if( type != 0 && Magic_GetSettingsID(OrderMagicNumber()) == settID )
      {
         total++;
         profit = (OrderStopLoss() - OrderOpenPrice())*type;
         
         if( profit < 0 )//possible loss
         {      
            loss++;
         }
         else if( profit > 30)
         {
            noloss++;
         }   
      }    
   }
   return (loss);
}

//събира печалбата на всички отворени поръчки чрез техния стоп
int OpenOrders_GetProfitInPips(int settID){   

   double profit = 0;  
   for (int i = 0; i < OrdersTotal(); i++) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                       
           if (OrderType() == OP_SELL){
               profit = profit + OrderOpenPrice() - OrderStopLoss();
           }
           if (OrderType() == OP_BUY)  {
               profit = profit + OrderStopLoss() - OrderOpenPrice();
	        }
        }
     }
   } 
   return(profit/Point);
} 

double OpenOrders_GetProfitByType(int settID, int orderType){   
   double profit = 0;  
   for (int i = 0; i < OrdersTotal(); i++) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderSymbol() == Symbol() &&  Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == orderType) {                                  
            profit = profit + OrderProfit();
        }
     }
   } 
   return(profit);
} 

//събира печалбата на всички отворени поръчки от всички системи по дадения инструмент
int OpenOrders_GetProfitInPipsAll(){   
   RefreshRates();
   double profit = 0;  
   for (int i = 0; i < OrdersTotal(); i++) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderSymbol() == Symbol()) {                                   
           if (OrderType() == OP_SELL) profit = profit + (OrderOpenPrice() - Bid);
           if (OrderType() == OP_BUY) profit = profit + (Ask - OrderOpenPrice());
	        
        }
     }
   } 
   return(profit/Point);
}

//връща броя затворени поръчки по един сигнал дефинирам от времето на сигнала
int HOrders_GetCountSigTime(int settID, datetime time){   
   int count_limit = 0;
   int count_order = 0;
   for (int i =  OrdersHistoryTotal() - 1; i >= 0; i--) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {            
           if (SelectedOrder_GetSignalTime() == time) { 
              count_order++;              
	        }
	        count_limit++;
	        //не повече от 10 поръчки назад, не е необходимо да прави проверка в цялата история цалата история
	        if (count_limit > 10) break;
        }
     }
   } 

   return(count_order);
} 

int HOrders_GetCountSigTimeT(int settID, datetime time, int orderType)
{   
   int count_limit = 0;
   int count_order = 0;
   for (int i =  OrdersHistoryTotal() - 1; i >= 0; i--) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == orderType) {            
           if (SelectedOrder_GetSignalTime() == time) { 
              count_order++;              
	        }
	        count_limit++;
	        //не повече от 10 поръчки назад, не е необходимо да прави проверка в цялата история цалата история
	        if (count_limit > 10) break;
        }
     }
   } 

   return(count_order);
}

int HOrders_GetLastCloseTicket(int settID){
//връща Ticket на последния затворен ордер от дадена система 
   int result = 0;
   for (int i =  OrdersHistoryTotal() - 1; i >= 0; i--) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID 
            && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {            
           result = OrderTicket();
           break;
        }
     }
   } 
   return(result);   
}

bool HOrders_CloseWithLimit_Time(int settID, datetime TimeLimit, int type){
   //проверява дали позицията е затворена с Лимит който се намира в доверителен интервал от 25% от цената
   //на затваряне защото понякога когато имаме дупки цената на затваряне се различава от зададения лимит
   int count = 0;
   bool result = false;
   double profit_offset = 0;
   for (int i =  OrdersHistoryTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderSymbol()==Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) { 
            if (type == OrderType()){                           
               if (type == OP_SELL) profit_offset = (OrderOpenPrice() - OrderClosePrice())*0.25;                             
               if (type == OP_BUY)  profit_offset = (OrderClosePrice() - OrderOpenPrice())*0.25;               
               if ( 
                     profit_offset > 0
                     &&
                     (//ClosePrice da se namira v granicite +/- 25% okolo Limita
                       OrderClosePrice() >= (OrderTakeProfit() - profit_offset)
                       &&
                       OrderClosePrice() <= (OrderTakeProfit() + profit_offset)
                     )
                   ){
                   result = true;
               }
            }
            if (OrderOpenTime() < TimeLimit || count > 10){
                result = false;
                break;               
            }
            if (result) break;
            
            count++;                
         }            
      }      
   }   
   return(result);
}

bool HOrders_CloseWithLimit_Ticket(int ticket, int type){
   //проверява дали позицията е затворена с Лимит който се намира в доверителен интервал от 25% от цената
   //на затваряне защото понякога когато имаме дупки цената на затваряне се различава от зададения лимит 
   if (OrderSelect(ticket, SELECT_BY_TICKET , MODE_HISTORY)) {      
      if (OrderType() == OP_SELL || OrderType() == OP_BUY){
         double profit_offset = 0;
         if (type == OP_SELL) profit_offset = (OrderOpenPrice() - OrderClosePrice())*0.25;                             
         if (type == OP_BUY)  profit_offset = (OrderClosePrice() - OrderOpenPrice())*0.25;                               
         if ( 
               profit_offset > 0
               && OrderClosePrice() >= (OrderTakeProfit() - profit_offset)
               && OrderClosePrice() <= (OrderTakeProfit() + profit_offset)
             ){
             return(true);
         }                           
      }
   } 
   return(false);
} 

bool HOrders_IsOrderClose(int ticket){  
   if (OrderSelect(ticket, SELECT_BY_TICKET , MODE_HISTORY)) {
      return(true);
   }   
   return(false);
} 

//проверява дали има отворена и затворена поръчка в текущия бар
//ако има то тя е затворена от SL или ТП
// работи за H1, H4, Day, Month
bool HOrders_IsOpenCloseInCurrentBar(int settID, int TimeFrame){
   int count = 0;
   datetime curr_time = iTime(NULL, TimeFrame, 0);
   datetime time_close, time_open;
   int order_hour = -1;
   
   int hour = TimeHour(curr_time);
   int day = TimeDay(curr_time);
   int month = TimeMonth(curr_time);
   int year = TimeYear(curr_time);
               
   for (int i =  OrdersHistoryTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderSymbol()==Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                                  
            time_close = OrderCloseTime();
            time_open = OrderOpenTime();
            switch(TimeFrame){       
               case PERIOD_H1:{
                        if ( (TimeYear(time_close) == year && TimeMonth(time_close) == month && TimeDay(time_close) == day && TimeHour(time_close) == hour)
                              && 
                             (TimeYear(time_open) == year && TimeMonth(time_open) == month && TimeDay(time_open) == day && TimeHour(time_open) == hour) 
                            ) {
                           return(true);
                        }
                        break;
                     }    
               case PERIOD_H4:{
                        if ( (TimeYear(time_close) == year && TimeMonth(time_close) == month && TimeDay(time_close) == day) 
                              &&
                              (TimeYear(time_open) == year && TimeMonth(time_open) == month && TimeDay(time_open) == day)
                              ) {
                           order_hour = TimeHour(time_close);                                                      
                           if (
                              (order_hour >= 0 && order_hour < 4 && hour  >= 0 && hour  < 4) ||
                              (order_hour >= 4 && order_hour < 8 && hour  >= 4 && hour  < 8) ||
                              (order_hour >= 8 && order_hour < 12 && hour  >= 8 && hour  < 12) ||
                              (order_hour >= 12 && order_hour < 16 && hour  >= 12 && hour  < 16) ||
                              (order_hour >= 16 && order_hour < 20 && hour  >= 16 && hour  < 20) ||
                              (order_hour >= 20 && order_hour < 24 && hour  >= 20 && hour  < 24) ){
                              return(true);
                           }
                        }
                        break;
                     }                                           
               case PERIOD_D1:{
                        if ( (TimeYear(time_close) == year && TimeMonth(time_close) == month && TimeDay(time_close) == day) 
                              &&
                              (TimeYear(time_open) == year && TimeMonth(time_open) == month && TimeDay(time_open) == day)) {
                           return(true);
                        }
                        break;               
                     }                        
               case PERIOD_MN1:{
                        if ( (TimeYear(time_close) == year && TimeMonth(time_close) == month) 
                              &&
                              (TimeYear(time_open) == year && TimeMonth(time_open) == month) ) {
                           return(true);
                        }
                        break;               
                     }                                                                                       
            }               
         }
      }
   } 
   return(false);
} 
 