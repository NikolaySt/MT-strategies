
/*//*********************************************
помощни функций за управлението на капитала
//***********************************************
int    MM_Lots_RoundDig(double LotStep);
double MM_Lots_LimitBroker(double Lots);     
double MM_FP_Level(double Profit, double Delta);
double MM_FF_Level(double balance, double BeginBalance);
double MM_FP_Level_DownLimit(int Level, double BeginBalance, double Delta);
double MM_FF_Level_DownLimit(int Level, double BeginBalance);
double MM_PipsCost();

double MM_History_MaxBalance(double BeginBalance, double AvailableBalance, double TimeStart, double& Withdrawal[1]);
double MM_History_MaxBalance_SortByCT(double BeginBalance, double AvailableBalance, double TimeStart, int &Tickets[], double& Withdrawal[1]);
double MM_History_Find_MaxLoss();
//*/

int MM_Lots_RoundDig(double LotStep){
   double RoundDig = 0;
   switch(LotStep){
      case 0.00001: RoundDig = 5; break;
      case 0.0001: RoundDig = 4; break;
      case 0.001: RoundDig = 3; break;
      case 0.01: RoundDig = 2; break;
      case 0.1: RoundDig = 1; break;
      case 1: RoundDig = 0; break;
   } 
   return(RoundDig); 
}     

double MM_Lots_LimitBroker(double Lots){      
   double MaxLots = MarketInfo(Symbol(),MODE_MAXLOT);
   if (Lots >  MaxLots) return(MaxLots);
        
   double MinLots = MarketInfo(Symbol(),MODE_MINLOT);
   if (Lots < MinLots) return(MinLots);
   
   return(Lots);
}      

double MM_FP_Level(double Profit, double Delta){
   double n = 1;      
   if (Delta > 0 && Profit > 0){         
      double up_level_profit = Delta*((n+1)/2)*n;      
      while (Profit > up_level_profit){ 
         n = n + 1; 
         up_level_profit = Delta*((n+1)/2)*n;
      }            
   }   
   return(n);
}

double MM_FF_Level(double balance, double BeginBalance){     
   return(MathFloor(balance/BeginBalance));
}

double MM_FP_Level_DownLimit(int Level, double BeginBalance, double Delta){
   double n = Level - 1;   
   return(BeginBalance + Delta*((n+1)/2)*n);
}

double MM_FF_Level_DownLimit(int Level, double BeginBalance){
   return(Level*BeginBalance);
}

double MM_History_MaxBalance(double BeginBalance, double AvailableBalance, double TimeStart, double &Withdrawal[1]){
   int total = OrdersHistoryTotal();
   double balance = MathMax(BeginBalance, AvailableBalance);         
   double max = MathMax(balance, AccountBalance());   
   Withdrawal[0] = 0;
   int type;
   for(int i = 0; i < total; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if (TimeStart == 0 || OrderOpenTime() >= TimeStart){
            type = OrderType();
            if ((type == OP_BUY) || (type == OP_SELL) ){                                                    
               balance = balance + OrderProfit() + OrderSwap() + OrderCommission();    
               max = MathMax(NormalizeDouble(max, 2),  NormalizeDouble(balance, 2));
            }else{                   
               if (!(type == OP_BUYLIMIT || type == OP_BUYSTOP || type == OP_SELLLIMIT || type == OP_SELLSTOP)){                        
                  if (OrderProfit() < 0)  Withdrawal[0] = Withdrawal[0] + OrderProfit();            
               }                  
            }     
         }      
      }
   }
   
   return(max);      
}

double MM_History_MaxBalance_SortByCT(double BeginBalance, double AvailableBalance, double TimeStart, int &Tickets[], double &Withdrawal[1]){   
   double balance = MathMax(BeginBalance, AvailableBalance);         
   double max = MathMax(balance, AccountBalance());    
   
   MM_History_SortByCloseTime(Tickets);
   
   int total = ArraySize(Tickets); 
   Withdrawal[0] = 0;
   int type;
   for (int i = 0; i < total; i++) {
      if (OrderSelect(Tickets[i], SELECT_BY_TICKET, MODE_HISTORY)){
         if (TimeStart == 0 || OrderOpenTime() >= TimeStart){
            type = OrderType();            
            if ((type == OP_BUY) || (type == OP_SELL) ){                                                    
               balance = balance + OrderProfit() + OrderSwap() + OrderCommission();    
               max = MathMax(NormalizeDouble(max, 2),  NormalizeDouble(balance, 2));
            }else{                  
               if (!(type == OP_BUYLIMIT || type == OP_BUYSTOP || type == OP_SELLLIMIT || type == OP_SELLSTOP)){                        
                  if (OrderProfit() < 0)  Withdrawal[0] = Withdrawal[0] + OrderProfit();            
               }                  
            }     
         }                  
      }
   }   
   
   return(max);      
}
 
double MM_History_Find_MaxLoss(){
   int total = OrdersHistoryTotal();      
   double max_loss = 0; 
   double order_result;           
   for(int i = 0; i < total; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){                                                        
            order_result = OrderProfit() + OrderSwap() + OrderCommission();    
            if (order_result < 0) max_loss = MathMax(max_loss, MathAbs(order_result));
         }                     
      }
   }     
   return(max_loss);      
}

double MM_PipsCost() {
   double result;
   string base = AccountCurrency();
   
   double point = MarketInfo(Symbol(), MODE_LOTSIZE) * MarketInfo(Symbol(), MODE_POINT);
   
   if (Symbol() == "GOLD") return(MarketInfo(Symbol(), MODE_TICKVALUE)*MarketInfo(Symbol(), MODE_LOTSTEP));
   
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
   return (result*MarketInfo(Symbol(), MODE_LOTSTEP));
}

void MM_History_SortByCloseTime(int &Tickets[]) {
   int pos = 0;  
   int total = HistoryTotal();
   ArrayResize(Tickets, total);
   ArrayInitialize(Tickets, 0);
  
   for (int i = 0; i < total; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
         //if (OrderType() == OP_SELL || OrderType() == OP_BUY){
            Tickets[pos] = OrderTicket();
            pos++;
         //}
      }
   }  
   
   ArrayResize(Tickets, pos);   
   int res, ticket;
   for (i=0; i < pos; i++) {
      for (int j=i+1; j < pos; j++) {
         res = MM_History_Compare_Tickets(Tickets[i], Tickets[j]);
         if (res == -1) {
            ticket = Tickets[i];
            Tickets[i] = Tickets[j];
            Tickets[j] = ticket;        
         }
      }
   } 
}

int MM_History_Compare_Tickets(int ticket1, int ticket2) {
   OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
   datetime time1 = OrderCloseTime();
   OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
   datetime time2 = OrderCloseTime();
   if (time1 < time2) return(1);
   if (time1 > time2) return(-1);
   return(0);
}