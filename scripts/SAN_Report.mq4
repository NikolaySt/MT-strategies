
#property copyright "Copyright © 2011, SANTeam"
#property link      ""




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int init() {
}

void deinit(){
  return(0);
}

int Tickets[];
int start() {
   int pos = 0;  
   int total = HistoryTotal();
   ArrayResize(Tickets, total);
   ArrayInitialize(Tickets, 0);
  
   for (int i = 0; i < total; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
         if (OrderType() == OP_SELL || OrderType() == OP_BUY){
            Tickets[pos] = OrderTicket();
            pos++;
         }
      }
   }  
   ArrayResize(Tickets, pos);
   SortByCloseTime();
 
   total = ArraySize(Tickets); 
   for (i = 0; i < total; i++) {
      OrderSelect(Tickets[i], SELECT_BY_TICKET, MODE_HISTORY);    
   } 
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


void SortByCloseTime() {
   int res, ticket;
   int size = ArraySize(Tickets);
   for (int i=0; i < size; i++) {
      for (int j=i+1; j < size; j++) {
         res = Compare(Tickets[i], Tickets[j]);
         if (res == -1) {
            ticket = Tickets[i];
            Tickets[i] = Tickets[j];
            Tickets[j] = ticket;        
         }
      }
   } 
}

int Compare(int ticket1, int ticket2) {
   OrderSelect(ticket1, SELECT_BY_TICKET, MODE_HISTORY);
   string time1 = TimeToStr(OrderCloseTime());
   OrderSelect(ticket2, SELECT_BY_TICKET, MODE_HISTORY);
   string time2 = TimeToStr(OrderCloseTime());
   if (time1 < time2) return(1);
   if (time1 > time2) return(-1);
   return(0);
}