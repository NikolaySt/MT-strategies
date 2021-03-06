bool M005_MM_Trace = false;

void M005_MM_SetTrace(bool value){
   M005_MM_Trace = value;
   if (M005_MM_Trace){   
      FileDelete("M005_MM_trace.csv");
      int file = FileOpen("M005_MM_trace.csv", FILE_WRITE|FILE_READ, ",");                 
      FileWrite(file, "Balance,Virtual,Limit21,Limit22,Lots");
      FileClose(file);      
   }  
}

double M005_MM_Init(int settID){

}

double M005_MM_Get(int settID){
   double Lots = MM_LotStep;  
   double Withdrawal[1];
   double max_balance = MM_History_MaxBalance(M005_BeginBalance, M005_BeginBalance, MM_TimeStart, Withdrawal); 
   double Limit21 = max_balance-M005_MaxDD;
   double Limit22 = max_balance;//Limit21 + M005_MaxDD * 0.3;
   double virtual_balance = 0;
   if (M005_MM_Trace){
      Print("[M005_MM_Get]: Limit21 = ", Limit21, ", Limit22 = ", Limit21);
   }
   if (Limit21  > 0 && Limit22 > 0){
      bool check_virtual = false;
      virtual_balance = M005_Get_VirtBalance(settID, M005_BeginBalance, MM_LotStep, check_virtual);                                                           
      if (virtual_balance < Limit21 || (virtual_balance < Limit22 && check_virtual)){
         //ако пропадането е по малко от границата не играем с реалните лотове/
         //веднъж е пробит Лимит21 от текущия спад но след това баланса е над него
         //но е по малко от 30% коменсация. Проверяваме дали е достигнат Лимит22 ако е така
         //би трябвало да има вируални ордери с 0.01 следователно продължаваме да играем с 0.01
         //иначе с лотовете за нивото които са сметнати по нагоре                
         Lots = 0.01;                                                                                
      }                                   
   }
   if (M005_MM_Trace){    
      int file = FileOpen("M005_MM_trace.csv", FILE_WRITE|FILE_READ, ";");     
      if (file > 0){
         FileSeek(file, 0, SEEK_END);  
         FileWrite(file, 
            DoubleToStr(AccountBalance(), 2)+","+
            DoubleToStr(virtual_balance, 2)+","+
            DoubleToStr(Limit21, 2)+","+
            DoubleToStr(Limit22, 2)+","+
            DoubleToStr(Lots, 2)
         );
         FileClose(file);               
      }
   }   
   return(Lots);
}


double M005_Get_VirtBalance(int settID, double BeginBalance, double ContractStep, bool& ch_virtual_trade){
   
   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);   
   int hstTotal = OrdersHistoryTotal();
   double balance = BeginBalance;      
      
   double max_balance = MathMax(BeginBalance, AccountBalance());      
   double virt_balance = max_balance;      
   ch_virtual_trade = false;   
   
   double order_result = 0, level; 
   int ID;   
      
   if (M005_MM_Trace){
      string filename = "M005_MM_trace_virtual.csv";         
      FileDelete(filename);
      int file = FileOpen(filename, FILE_WRITE|FILE_READ, ",");                 
      FileWrite(file, "Virtual,VirtualProfit,Virtuallevel");
   }         
   
   
   for(int i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){                                   
            order_result = OrderProfit() + OrderSwap() + OrderCommission();                        
            balance = balance + order_result;                           
            if (NormalizeDouble(max_balance, 2) <= NormalizeDouble(balance, 2)){
               max_balance = balance;
               virt_balance = balance; 
               ch_virtual_trade = false;
            }else{                              
               if (OrderLots() == MinLots && ContractStep != MinLots){                                                 
                  ch_virtual_trade = true;   
                  level = 1;                                                
                  virt_balance = virt_balance + order_result*((level * 0.1)/0.01);                                                                                                                                                                                  
                  if (M005_MM_Trace){                         
                     if (file > 0){
                        FileSeek(file, 0, SEEK_END);  
                        FileWrite(file, ID+"," +DoubleToStr(virt_balance, 2)+","+DoubleToStr(virt_balance - BeginBalance, 2)+","+DoubleToStr(level, 0));                        
                     }
                  } 
                                                                        
               }else{                  
                  virt_balance = virt_balance + order_result;
               }                              
            }                       
         }                     
      }
   }            
   if (M005_MM_Trace) {
      if (file > 0) FileClose(file);       
   }      
   return(virt_balance);
}


