#include <stderror.mqh>
#include <stdlib.mqh>
color clStop = Red;
bool UseSound = True;
string NameFileSound = "alert.wav";


color clOpenBuy = Lime;
color clCloseBuy = White;
color clOpenSell = Red;
color clCloseSell = Yellow;

color clSellStop = Red;
color clBuyStop = Lime;

int MinBrokerLevel(){
   return(MarketInfo(Symbol(), MODE_STOPLEVEL));
}

int DigMode(){   
   if (Digits == 4) return(1);
   if (Digits == 5) return(10);
   if (Digits == 2) return(1);
   if (Digits == 3) return(10);   
}

double PointCost() {
   double result;
   string base;
   
   if (BaseCurrency == "") base = AccountCurrency(); else base = BaseCurrency;
   
   double point = MarketInfo(Symbol(), MODE_LOTSIZE) * MarketInfo(Symbol(), MODE_POINT);
   
   if (Symbol() == "GOLD") return(MarketInfo(Symbol(), MODE_TICKVALUE));
   
   string second = StringSubstr(Symbol(), 3, 3);
   string symbol1 = base + second;
   string symbol2 = second + base;
   if (second == base){
      result = MarketInfo(Symbol(), MODE_TICKVALUE);
   }else {
      if (MarketInfo(symbol1, MODE_BID) != 0.0) 
         result = point * (1 / MarketInfo(symbol1, MODE_BID));
      else 
         result = point * MarketInfo(symbol2, MODE_ASK);
   }
   return (result);
}

void InternalViewLastError(string Info, int ErrorCode){
   if(ErrorCode == ERR_NO_ERROR) return;
   
   Print(Info, " - error(",ErrorCode,"): ", ErrorDescription(ErrorCode));
        
   string FileName = "ErrStdDev2Sys.txt";
   int file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');
   
   if (file < 1){
     Print("File " + FileName + ", the last error is ", GetLastError());     
     return;   
   }
   if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);
   string Pos = TimeToStr(Time[0]) + ": "+ Info + " - error("+ErrorCode+"): "+ ErrorDescription(ErrorCode);
   FileWrite(file, Pos);            
   FileClose(file);      
}


int PrepareOrder(int MAGIC, string SignalName, int TradeType, datetime SignalTime, 
   double SignalLevel, double PrevOrderLevel = 0, int CurrCountOrders = 0, bool Modify = false){     
    
   string comment = SignalName + "#" + SignalTime;   
   
   double ldLot = CalcLotSizeMM(MAGIC, CurrCountOrders); 
   double ldLimit = 0; 
   double ldLevel = 0; 
   int int_type = -1;
   double ldStop = 0;   
   
   if (Time[0] == StrToTime("2008.01.30 21:15")){
      Print("ldLevel = ", ldLevel,
            ", PrevOrderLevel = ", PrevOrderLevel
         );
   }   

   ldLevel =  SignalLevel; 
   RefreshRates();   
   bool instant_order = false;
   int instant_type = -1;
   if (TradeType == OP_BUYSTOP){                           
      
      if (PrevOrderLevel >0){
         ldLevel = MathMax(ldLevel, PrevOrderLevel + MinShiftOrder_pips*Point);         
      }else{
         ldLevel = MathMax(ldLevel, MAGetValue() + MinShiftOrder_pips*Point);
      }                                
                            
      if (ldLevel < (Ask + MinBrokerLevel()*Point)){
         //неможе да постави BUY_STOP, защото желаното ниво е под пазарната цена или твърде близко
         instant_order = true;
         instant_type = OP_BUY;
      }   
      if (!OnlyInstantOrders){
         if (!CheckAddNewOrder(MAGIC, OP_BUY, ldLevel, ldLot)) return(-1);
      }         
   }

   if (TradeType == OP_SELLSTOP){ 
      
      if (PrevOrderLevel > 0){        
         ldLevel = MathMin(ldLevel, PrevOrderLevel - MinShiftOrder_pips*Point);
         
      }else{      
         ldLevel = MathMin(ldLevel, MAGetValue() - MinShiftOrder_pips*Point);
      }                                            
      
      if (ldLevel > (Bid - MinBrokerLevel()*Point)){
         //неможе да постави SELL_STOP, защото желаното ниво е над пазарната цена или твърде близко
         //return(-1);
         instant_order = true;
         instant_type = OP_SELL;
      }
      if (!OnlyInstantOrders){
         if (!CheckAddNewOrder(MAGIC, OP_SELL, ldLevel, ldLot)) return(-1);
      }         
   }
   
   ldStop = NormalizeDouble(ldStop, Digits);
   ldLimit = NormalizeDouble(ldLimit, Digits);
   ldLevel = NormalizeDouble(ldLevel, Digits); 
      
   if (OnlyInstantOrders){

      
      if (TradeType == OP_BUYSTOP && Ask > ldLevel && ldLevel > 0 ){
         return(OpenOrder(MAGIC, OP_BUY, ldLot, ldStop, ldLimit, comment));             
      }
   
      if (TradeType == OP_SELLSTOP && Bid < ldLevel && ldLevel > 0 ){          
         return(OpenOrder(MAGIC, OP_SELL, ldLot, ldStop, ldLimit, comment));             
      }
      return(0);
   }
   
   datetime expiration = 0;   
   if (Modify){          
      return(ModifyPendingOrder(MAGIC, TradeType, ldLevel, ldLot, ldStop, ldLimit, comment, expiration));   
   }else{      
      if (instant_order){
         if (ErrorPend_SetInstant){
            return(OpenOrder(MAGIC, instant_type, ldLot, ldStop, ldLimit, comment));         
         }
      }else{
         return(PendingOrder(MAGIC, TradeType, ldLevel, ldLot, ldStop, ldLimit, comment, expiration));   
      }
   }
   
}

int Slippage(int Points = 2){
   return(Points*DigMode());
}

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

double PendingOrder(int MAGIC, int Type, double ldLevel, double ldLot, double ldStop, double ldLimit, string comment, datetime expiration){

   color pos_color;
   
   if (Type == OP_BUYSTOP){
      pos_color =  clBuyStop;  
   }         
   if (Type == OP_SELLSTOP){
      pos_color =  clSellStop;
   }      
   int check = OrderSend(Symbol(), Type, ldLot, ldLevel, Slippage(), ldStop, ldLimit, comment, MAGIC, expiration, pos_color);
        
   if (check > 0){      
      if (UseSound) PlaySound(NameFileSound); 
      return(check);
   }else{ 
      string info = "*** ERROR Pending " + TypeOrderToString(Type) + " *** Lot =  " + DoubleToStr(ldLot, 2);  
      info  = info +", OpenPrice = " + DoubleToStr(ldLevel, Digits);      
      info = info + ", Stop = " + DoubleToStr(ldStop,Digits) + ", Limit = " + DoubleToStr(ldLimit, Digits);      
      InternalViewLastError(info, GetLastError());
      return(-1);
   }
}

double OpenOrder(int MAGIC, int Type, double ldLot, double ldStop, double ldLimit, string comment){       
   if (!(Type == OP_BUY || Type == OP_SELL)) return (-1);
   int check;
   
   if (Type == OP_BUY){
      check = OrderSend(Symbol(), Type, ldLot, Ask, Slippage(), ldStop, ldLimit, comment, MAGIC, 0, clOpenBuy); 
   }      
   
   if (Type == OP_SELL){
      check = OrderSend(Symbol(), Type, ldLot, Bid, Slippage(), ldStop, ldLimit, comment, MAGIC, 0, clOpenSell); 
   }            
   
   if (check > 0){      
      if (UseSound) PlaySound(NameFileSound); 
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

int ModifyPendingOrder(int MAGIC, int Type, double ldLevel, double ldLot, double ldStop, double ldLimit, string comment, datetime expiration){
   color pos_color;   
   double open_price, sl_price, limit_price;
   if (Type == OP_BUYSTOP)  pos_color =  clBuyStop;  
   if (Type == OP_SELLSTOP) pos_color =  clSellStop;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {                                
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == Type) {                         
            open_price = OrderOpenPrice();
            sl_price = OrderStopLoss();
            limit_price = OrderTakeProfit();
            if  (NormalizeDouble(open_price, Digits) != NormalizeDouble(ldLevel, Digits)
                || 
                NormalizeDouble(sl_price, Digits) != NormalizeDouble(ldStop, Digits)
                ||
                NormalizeDouble(limit_price, Digits) != NormalizeDouble(ldLimit, Digits)
                ){
            
               if (!OrderModify(OrderTicket(), ldLevel, ldStop, ldLimit, expiration, pos_color)){               
                  if (GetLastError() != ERR_NO_ERROR){                  
                     string info = "*** ERROR MODIFY " + TypeOrderToString(Type) + " *** Lot =  " + DoubleToStr(ldLot, 2);  
                     info  = info +", OpenPrice = " + DoubleToStr(ldLevel, Digits);      
                     info = info + ", Stop = " + DoubleToStr(ldStop,Digits) + ", Limit = " + DoubleToStr(ldLimit, Digits);      
                     InternalViewLastError(info, GetLastError());
                     return(-1);  
                  }else{    
                     return(OrderTicket());
                  }                     
               }else{
                  return(OrderTicket());
               }
            }
         }      
      }   
   }            
}

int TimeFrameFromString( string value )
{
   //"M5 M15 H1 H4 D1 W1 MN
  int result =-1;
  if( value == "M1" ) 
  {
      result = PERIOD_M1;
  }    
  if( value == "M5" ) 
  {
      result = PERIOD_M5;
  }     
  if( value == "M15" ) 
  {
      result = PERIOD_M15;
  }     
  if( value == "M30" ) 
  {
      result = PERIOD_M30;
  }    
  if( value == "H1" ) 
  {
      result = PERIOD_H1;
  } 
  else if( value == "H4" )
  {
      result = PERIOD_H4;    
  } 
  else if( value == "D1" )
  {
      result = PERIOD_D1;    
  } 
  else if( value == "W1" )
  {
      result = PERIOD_W1;    
  }   
  else if( value == "MN" )
  {
      result = PERIOD_MN1;    
  }   
  else if( value == "" )
  {
      result = 0;    
  }
  
  return (result);
}

int Internal_OrderTotals_To_Array(int MAGIC, int& tickets[]){
   int index = 0;
   int count = OrdersTotal();   
   for (int i = 0; i < count; i++) { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) { 
            tickets[index] = OrderTicket();
            index++;
         }         
      }         
   }
   return (index);
}

void CloseAndRemoveOrders(int MAGIC) { 
   bool check = false; 
   int type = 0;
   int tickets[50];
   int count = Internal_OrderTotals_To_Array(MAGIC, tickets);
   if (count == 0) return;
      
   for (int i = 0; i < count; i++){       
      if (OrderSelect(tickets[i], SELECT_BY_TICKET, MODE_TRADES)) { 
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {                                                                                     
            type = OrderType();
            if (type == OP_BUY) {
               RefreshRates();                 
               check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), clCloseBuy);                      
            }                     
            if (type == OP_SELL){
               RefreshRates();  
               check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), clCloseSell);                      
            }              
            if (type == OP_SELLSTOP || type == OP_BUYSTOP )  check = OrderDelete(OrderTicket());

            if (check){      
               if (UseSound) PlaySound(NameFileSound); 
            }else{                     
               InternalViewLastError("ClosePositions - ClosePosition/Delete: ", GetLastError());                          
            }                      
         } 
      }else{
         InternalViewLastError("ClosePositions - OrderSelect: ", GetLastError());
      }
   }
   
}



void RemovePendingOrdersBySignalName(int MAGIC, string name){       
   int type;
   int tickets[50];
   int count = Internal_OrderTotals_To_Array(MAGIC, tickets);
   if (count == 0) return;
   for (int i = 0; i < count; i++) { 
     
       if (OrderSelect(tickets[i], SELECT_BY_TICKET, MODE_TRADES)) { 
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && name == InternalSignalName(OrderComment())) {                                                                   
            type = OrderType();
            if (type == OP_SELLSTOP || type == OP_SELLLIMIT || type == OP_BUYSTOP || type == OP_BUYLIMIT){               
               if (OrderDelete(OrderTicket())){      
                  if (UseSound) PlaySound(NameFileSound);                                     
               }else{
                  InternalViewLastError("RemovePendingOrders", GetLastError());              
               }                               
            }               
         } 
      }else{
         InternalViewLastError("RemovePendingOrders - OrderSelect", GetLastError());
      }
   } 

}

void RemovePendingOrdersByTicket(int MAGIC, int ticket){       
    if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) { 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {                                                                               
         if (OrderDelete(OrderTicket())){      
            if (UseSound) PlaySound(NameFileSound);                                     
         }else{
            InternalViewLastError("RemovePendingOrdersByTicket: ", GetLastError());              
         }                                     
      } 
   }else{
      InternalViewLastError("RemovePendingOrdersByTicket - OrderSelect", GetLastError());
   }
}

bool CalcLimitAndSL(int MAGIC, int Type){    
   double value_point, sum1 = 0, sum2 = 0;
   double ldLimit = 0, ldStop = 0;
   double tick_value = PointCost();//MarketInfo(Symbol(), MODE_TICKVALUE) 
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {                                
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == Type) {                         
            if (Type == OP_BUY || Type == OP_SELL){                                                
               value_point = tick_value * OrderLots();
               sum1 = sum1 + (OrderOpenPrice()/Point)*value_point;
               sum2 = sum2 + value_point;               
            }
         }
      }else{
         InternalViewLastError("CalcLimitAndSL_Buy - OrderSelect", GetLastError());
      }                           
   } 
   if (sum1 > 0 && sum2 > 0){
      if (Type == OP_SELL) {
         ldLimit = NormalizeDouble(((sum1 - GGoal_Limit_currency)/sum2)*Point, Digits);    
         ldStop = NormalizeDouble(((GGoal_Stop_currency + sum1)/sum2)*Point, Digits); 
      }         
      if (Type == OP_BUY) {
         ldLimit = NormalizeDouble(((GGoal_Limit_currency + sum1)/sum2)*Point, Digits); 
         ldStop = NormalizeDouble(((sum1 - GGoal_Stop_currency)/sum2)*Point, Digits); 
      }         
      
      double limit_price, stop_price;
      for(int n = 0; n < OrdersTotal(); n++){
         
         if (OrderSelect(n, SELECT_BY_POS, MODE_TRADES)) {                                
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == Type) {                         
               limit_price = OrderTakeProfit();
               stop_price = OrderStopLoss();
               if  (
                     NormalizeDouble(limit_price, Digits) != NormalizeDouble(ldLimit, Digits)
                     ||
                     NormalizeDouble(stop_price, Digits) != NormalizeDouble(ldStop, Digits)){
            
                  if (!OrderModify(OrderTicket(), OrderOpenPrice(), ldStop, ldLimit, OrderExpiration(), White)){               
                     
                        string info = "*** ERROR MODIFY LIMIT" + TypeOrderToString(Type) + 
                           " *** OpenPrice = " + DoubleToStr(OrderOpenPrice(), Digits) + 
                           ", Limit = " + DoubleToStr(ldLimit, Digits) +
                           ", Stop = " + DoubleToStr(ldStop, Digits);
                        InternalViewLastError(info, GetLastError());                        
                     
                  }
                  
               }
            }      
         } 
           
      }                  
   }
}

bool CheckAddNewOrder(int MAGIC, int Type, double level, double lots){    
   double value_point, sum1 = 0, sum2 = 0;
   double ldLimit = 0;
   double tick_value = PointCost();//MarketInfo(Symbol(), MODE_TICKVALUE);
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {                                
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == Type) {                         
            if (Type == OP_BUY || Type == OP_SELL){                                                
               value_point = tick_value * OrderLots();
               sum1 = sum1 + (OrderOpenPrice()/Point)*value_point;
               sum2 = sum2 + value_point;               
            }
         }
      }else{
         InternalViewLastError("CheckAddNewOrder - OrderSelect", GetLastError());
      }                           
   } 
   if (sum1 > 0 && sum2 > 0){
      value_point = tick_value * lots;
      sum1 = sum1 + (level/Point)*value_point;
      sum2 = sum2 + value_point;
      
      if (Type == OP_SELL) {
         ldLimit = NormalizeDouble(((sum1 - GGoal_Limit_currency)/sum2)*Point, Digits);    
         
         if (ldLimit <= level - MinBrokerLevel()*2*Point){
            return(true);
         }else{
            return(false);
         }                  
      }         
      
      if (Type == OP_BUY) {
         ldLimit = NormalizeDouble(((GGoal_Limit_currency + sum1)/sum2)*Point, Digits); 
         
         
         if (ldLimit >= level + MinBrokerLevel()*2*Point){
            return(true);
         }else{
            return(false);
         }
      }                         
   }else{
      return(true);
   }
}


//---------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//"име на сигнала # Time на сигнала"
//"s8fr#874358321"
string InternalSignalName(string signal){
   int n = StringFind(signal, "#", 0);
   if (n > 0){
      return(StringSubstr(signal, 0, n));
   }else{
      return(signal);
   }      
}
   