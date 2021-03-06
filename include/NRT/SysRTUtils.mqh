


#include <stderror.mqh>
#include <stdlib.mqh>

color clOpenBuy = Lime;
color clCloseBuy = White;
color clOpenSell = Red;
color clCloseSell = Yellow;

color clStop = Red;
bool UseSound = True;
string NameFileSound = "alert.wav";

int Slippage(int Points = 2){
   return(Points*DigMode());
}

int MinBrokerLevel(){
   return(MarketInfo(Symbol(), MODE_STOPLEVEL));
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

//проверява дали има отворена поръчка
bool IsOpenOrder(int MAGIC){   
   for (int i = 0; i < OrdersTotal(); i++) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {                       
           if (OrderType() == OP_SELL || OrderType() == OP_BUY)  {
               return(true);
	        }
        }
     }
   } 
   return(false);
} 


bool IsOrderTimeSignal(int MAGIC, string time){
   for (int i = 0; i < OrdersTotal(); i++) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        if (OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC) {            
           if (InternalGetTimeSignal(OrderComment()) == time) { 
              return(true);
	        }
        }
     }
   } 
   return(false);
} 

//проверява дали има затворена поръчка по даден сигнал който е дефинирам с точно време
//взима данните от коментара на сделката
//IsOpenPositionTimeFrHistory
bool History_IsOrderTimeSignal(int MAGIC, string time){   
   for (int i =  OrdersHistoryTotal() - 1; i >= 0; i--) {
     if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        if (OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC) {            
           if (InternalGetTimeSignal(OrderComment()) == time) { 
              return(true);
	        }
        }
     }
   } 

   return(false);
} 


void CloseOrdersByType(int MAGIC, int TradeType) { 
   bool check; 
   bool check_exit, mark_close = false;
   int i;             
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == TradeType) {                                                 
                  
                  if (TradeType == OP_BUY) { 
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage(), clCloseBuy);                      
                  }                     
                  if (TradeType == OP_SELL){
                     RefreshRates();
                     check = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage(), clCloseSell);                      
                  }                     
                  if (check){      
                     mark_close = true;
                     if (UseSound) PlaySound(NameFileSound); 
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

int PrepareOpenOrder(int MAGIC, string SignalName, int TradeType, datetime SignalTime){         
   
   string comment = SignalName + "#" + SignalTime;
   double ldLot = 0;     
   double ldLimit = TakeProfit;           
   double ldStop = GetLargeLOC_Level();
   RefreshRates(); 
   if (TradeType == OP_BUY){                                         
      ldLot = CalcLotSizeMM(MAGIC, NormalizeDouble((Ask - ldStop)/Point, 0));                         
      comment = comment + "#" + DoubleToStr(MathAbs((Ask - ldStop)/Point),0);              
      
      if (ldLimit > 0) ldLimit = Ask + ldLimit*Point;
      //Корекция на целта спрямо лимитите на брокера
      if (ldLimit > 0) ldLimit = MathMax(ldLimit, Ask + MinBrokerLevel()*Point);            
   }
   if (TradeType == OP_SELL){                            
      ldLot = CalcLotSizeMM(MAGIC, NormalizeDouble((ldStop - Bid)/Point, 0));   
      comment = comment + "#" + DoubleToStr(MathAbs((ldStop - Bid)/Point),0);
      
      if(ldLimit > 0) ldLimit = Bid - ldLimit * Point;   
      //Корекция на целта спрямо лимитите на брокера
      if(ldLimit > 0) ldLimit = MathMin(ldLimit, Bid - MinBrokerLevel()*Point);         

   }
   comment = comment + "#" + DoubleToStr(GetChannel_Range()/Point, 0);
   
   ldStop = NormalizeDouble(ldStop, Digits);
   if (TakeProfit == 0){
      ldLimit = NormalizeDouble(GetProjection_Level(), Digits);
   }else{
      ldLimit = NormalizeDouble(ldLimit, Digits);
   }
   
   return(OpenOrder(MAGIC, TradeType, ldLot, ldStop, ldLimit, comment));
        
   return(0);
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

void MngStopLoss(int MAGIC, int timeframe, double ratio = 0.1){
   double level_touch = 0;
   double stop_points = 0;
   double new_level = 0;
   
   double high = iHigh(NULL, timeframe, 1);
   double low = iLow(NULL, timeframe, 1);
   bool stop_move = false;
   double ch_range = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
	   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
		   if (OrderSymbol()==Symbol() && OrderMagicNumber() == MAGIC) {		               
	         ch_range = InternalChannelRange(OrderComment())*Point;
            stop_move = false; 	         
            if (OrderType() == OP_BUY) { 

               stop_points = OrderOpenPrice() - OrderStopLoss();
               if (stop_points > 0){                                 
                  level_touch = OrderOpenPrice() + ch_range*ratio;
                  
                  if (high >= level_touch) stop_move = true;                                   
                  if (stop_move){
                     //if (GetLOC_Small() > 0){
                        //new_level = GetSmallLOC_Level();
                     //}else{
                        new_level = OrderOpenPrice();
                     //}                                         
                  }                  
               }
            }               
            if (OrderType() == OP_SELL) { 
               stop_points = OrderStopLoss() - OrderOpenPrice();
               if (stop_points > 0){
               
                  level_touch = OrderOpenPrice() - ch_range*ratio;
                  
                  if (low < level_touch) stop_move = true;
                  
                  if (stop_move){
                     //if (GetLOC_Small() < 0){
                       // new_level = GetSmallLOC_Level();
                     //}else{
                        new_level = OrderOpenPrice();
                     //}                                         
                  }                  
               } 
            }               
            if (stop_move){
               if (OrderModify(OrderTicket(),OrderOpenPrice(),new_level,OrderTakeProfit(),0,clStop)){      
                  if (UseSound) PlaySound(NameFileSound); 
               }else{
                  InternalViewLastError("MngStopLoss - first stop = " + OrderTicket()+ ", StopLevel = " + new_level, GetLastError());
               }    
            }                                                
            
			      			      
		   }
	   }
   } 

}

void InternalViewLastError(string Info, int ErrorCode){
   if(ErrorCode == ERR_NO_ERROR) return;
   
   Print(Info, " - error(",ErrorCode,"): ", ErrorDescription(ErrorCode));
        
   string FileName = "Error.txt";
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

//Вътрешни функции за библиотеката
//---------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//"име на сигнала # Time на фрактала # начален стоп # Диапазона на канала по който влиза "
//"s8fr#874358321#33#150"
   
string InternalSignalName(string comment){
   int n = StringFind(comment, "#", 0);
   if (n > 0){
      return(StringSubstr(comment, 0, n));
   }else{
      return(comment);
   }      
}

string InternalGetTimeSignal(string comment){
   int b = StringFind(comment, "#", 0);
   int e = StringFind(comment, "#", b+1);
   if (b > 0 && e > 0){
      return(StringSubstr(comment, b+1, e - b - 1));
   }else{
      return("0");
   }    
}   

int InternalGetBeginSL(string comment){
   int b = StringFind(comment, "#", StringFind(comment, "#", 0) + 1);
   int e = StringFind(comment, "#", b+1);
   if (b > 0 && e > 0){
      return(StrToInteger(StringSubstr(comment, b+1, e - b - 1)));
   }else{
      return(0);
   }     
}   

int InternalChannelRange(string comment){
   int b = StringFind(comment, "#", 0);
   b = StringFind(comment, "#", b+1);
   b = StringFind(comment, "#", b+1);   
   if (b > 0){
      return(StrToInteger(StringSubstr(comment, b+1, StringLen(comment) - b + 1)));
   }else{
      return(0);
   }   
} 

//------------------------------------------------------------------------------------------- 