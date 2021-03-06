
/*//-----------------------------------------------------------
//Работа с историята след приключане на експерта при оптимизация и тестове.
//-----------------------------------------------------------
//---записва сключените сделки в чурнала като последователност
void Stat_HistOrdersToJurnal(double BeginBalance = 10000);

//записва изтъргуваните сделки като пеалба от всяка сделка с датата на затваряне;
void Stat_HistOrdersToDll(string SignalBaseName);

void Stat_HistOrdersToDll_Params(string SignalBaseName, string Params);

//---записва сключените сделки в файл
void Stat_HistOrdersToFile(bool AppendFile = false, double BeginBalance = 10000, string FileName = "history.txt");

//---пресмята математичното очакване //PipsCalc - задава дали да работи с пипсове (true) или с долари (false)// 
double Stat_CalcMO(bool PipsCalc = true);

//---пресмята печалбата и възвращаемостта по години
double Stat_AvgAnnualReturn(bool beginbalance = 10000);

//Записва всички пропадания на капитала в файл, //CalcCurrBalance - указва дали да пресмята с началния баланс (false) или с максимално достигнатия (true)
void Stat_DropDownToFile(bool AppendFile = false, double BeginBalance = 10000, string FileName = "dropdown.txt");

//Записва в файл печалбата по месеци;
void Stat_SumMonthlyProfitToFile(string FileName = "monthly_profit.txt");
*/

#define STAT_SIZE_HIST_ARRAY 500

#import "StatisticsDll.dll"  
   int AddNewSystemTrades(
      string SysName, string Params,
      int& arr_type[],       
      int& arr_closetime[], int& arr_opentime[], 
      double& arr_openprice[], double& arr_closeprice[], 
      double& arr_lots[], 
      double& arr_stoploss[], double& arr_takeprofit[], 
      double& arr_profit[],
      int size
   );      
#import


void Stat_HistOrdersToJurnal(double BeginBalance = 10000){
   int i, hstTotal = HistoryTotal();
   double curr_balance = BeginBalance;      
   for(i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){
            curr_balance = curr_balance + OrderProfit();
            Print(
               OrderTicket(),", ", 
               TimeToStr(OrderOpenTime()),", " ,
               OrderSymbol(),", ",
               OrderLots(),", ",
               OrderOpenPrice(),", " ,
               OrderClosePrice(),", " ,
               TimeToStr(OrderCloseTime()),", " ,
               OrderProfit(), ", ",
               DoubleToStr(curr_balance, 2)
               );
         }            
      }
   }
}

void Stat_HistOrdersToDll_Params(string SignalBaseName, string Params){
   Internal_HistOrdersToDll(SignalBaseName, Params);
}
void Stat_HistOrdersToDll(string SignalBaseName){
   Internal_HistOrdersToDll(SignalBaseName, "");
}

void Internal_HistOrdersToDll(string SignalBaseName, string Params){      
   int i, hstTotal = HistoryTotal();     
   
   int index = 0; 
   datetime date;
   
   int 
      arr_type[STAT_SIZE_HIST_ARRAY],
      arr_closetime[STAT_SIZE_HIST_ARRAY], 
      arr_opentime[STAT_SIZE_HIST_ARRAY];
   double       
      arr_openprice[STAT_SIZE_HIST_ARRAY], 
      arr_closeprice[STAT_SIZE_HIST_ARRAY],
      arr_lots[STAT_SIZE_HIST_ARRAY],
      arr_stoploss[STAT_SIZE_HIST_ARRAY],
      arr_takeprofit[STAT_SIZE_HIST_ARRAY],      
      arr_profit[STAT_SIZE_HIST_ARRAY];
   
   ArrayInitialize(arr_type, 0);
   ArrayInitialize(arr_closetime, 0);
   ArrayInitialize(arr_opentime, 0);
   ArrayInitialize(arr_openprice, 0);
   ArrayInitialize(arr_closeprice, 0);
   ArrayInitialize(arr_lots, 0);
   ArrayInitialize(arr_stoploss, 0);   
   ArrayInitialize(arr_takeprofit, 0);
   ArrayInitialize(arr_profit, 0.0);
   index = 0;
   int arr_inc = 20;// увеличение на масива

   for(i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){                        
            arr_type[index] = OrderType();
            arr_closetime[index] = OrderCloseTime();
            arr_opentime[index] = OrderOpenTime();
            arr_openprice[index] = OrderOpenPrice();
            arr_closeprice[index] = OrderClosePrice();
            arr_lots[index] = OrderLots();
            arr_stoploss[index] = OrderStopLoss();
            arr_takeprofit[index] = OrderTakeProfit();
            arr_profit[index] =  OrderProfit();            
            index++;
            if (index >= ArraySize(arr_profit)) {
               ArrayResize(arr_type, index + arr_inc);  
               ArrayResize(arr_closetime, index + arr_inc);               
               ArrayResize(arr_opentime, index + arr_inc);               
               ArrayResize(arr_openprice, index + arr_inc);               
               ArrayResize(arr_closeprice, index + arr_inc); 
               ArrayResize(arr_lots, index + arr_inc);               
               ArrayResize(arr_stoploss, index + arr_inc);                
               ArrayResize(arr_takeprofit, index + arr_inc);                                             
               ArrayResize(arr_profit, index + arr_inc);               
            }               
         }            
      }
   }
   
   
   if(IsDllsAllowed()){    
      AddNewSystemTrades(SignalBaseName, Params, 
         arr_type, arr_closetime, arr_opentime, arr_openprice, arr_closeprice, arr_lots, arr_stoploss, arr_takeprofit, arr_profit, 
         index);      
   }      
   
}

void Stat_HistOrdersToFile(bool AppendFile = false, double BeginBalance = 10000, string FileName = "history.txt"){
   int i, hstTotal = HistoryTotal();
   string Pos;
   int file;

   if (!AppendFile) FileDelete(FileName);
   
   file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');
   
   if (file < 1){
      Stat_ViewErrorToFile("File " + FileName + ", the last error is ", GetLastError());     
      return;  
   }
   
   if (AppendFile){
      if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);   
   }
   
   double curr_balance = BeginBalance;
   if (!AppendFile){
      FileWrite(file, "Номер, Време на отваряне, Инструмент, Големина, Цена на отваряне, Цена на затваряне, Време на затваряне, Печалба, Капитал"); 
   }      
   
   for(i = 0; i < hstTotal; i++){      
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){
            curr_balance = curr_balance + OrderProfit();
            Pos = 
               OrderTicket() + ", " + 
               TimeToStr(OrderOpenTime()) + ", " + 
               OrderSymbol() + ", " + 
               DoubleToStr(OrderLots(),2) + ", " + 
               DoubleToStr(OrderOpenPrice(),4) + ", " + 
               DoubleToStr(OrderClosePrice(),4) + ", " + 
               TimeToStr(OrderCloseTime()) + ", " + 
               DoubleToStr(OrderProfit(),2) + ", " + 
               DoubleToStr(curr_balance, 2);
            FileWrite(file, Pos);            
         }            
      }
   }
   
   FileClose(file);
}


double Stat_CalcMO(bool PipsCalc = true){
   int i, hstTotal = HistoryTotal();
   int cound_all_position, count_profit, count_loss, count_zero = 0;
   double sum_loss, sum_profit = 0;
   double profit_loss = 0;
   double max_profit = 0;
   double max_loss = 0;
   for(i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){           
                       
            if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){
               cound_all_position++;
               if (PipsCalc){                  
                  profit_loss = (OrderOpenPrice() - OrderClosePrice())*(1/Point);
               }else{
                  profit_loss = OrderProfit();   
               }
               if (OrderProfit() >= 0){
                  profit_loss = MathAbs(profit_loss);
               }else{
                  if (profit_loss > 0 ){
                     profit_loss = -1*profit_loss;
                  }
               }            
               if (profit_loss > 0){
                  count_profit++;
                  sum_profit = sum_profit + MathAbs(profit_loss);
                  if (profit_loss > max_profit) max_profit = profit_loss;
               }
               if (profit_loss < 0){
                  count_loss++;
                  sum_loss = sum_loss + MathAbs(profit_loss);
                  if (MathAbs(profit_loss) > max_loss) max_loss = MathAbs(profit_loss);
               }
               if (profit_loss == 0){count_zero++;}
            } 
                               
      }
   }
   
   if ( !(count_profit == 0 || count_loss == 0 || sum_loss == 0 || cound_all_position == 0)){   
      double RR = NormalizeDouble((sum_profit/count_profit) / (sum_loss/count_loss), 5);
      double cognoscibility = NormalizeDouble(count_profit, 0)/NormalizeDouble(cound_all_position, 0); 
      double PMO = ((1 + RR) * cognoscibility) - 1;  
   }      
   Print("-------------------------------------------------");     
   Print("Чиста печалба на сдекла = ", NormalizeDouble((sum_profit - sum_loss)/cound_all_position, 2));
   Print("Коеф. 1, -> Мак. Печалба/ Средна Печалба = ", NormalizeDouble(max_profit/(sum_profit/count_profit), 2));
   Print("Коеф. 2, -> Мак. Загуба/ Средна Загуба = ", NormalizeDouble(max_loss/(sum_loss/count_loss), 2));   
   Print("-------------------------------------------------");     
   
   Print("All: ", cound_all_position, ", ", 
   "Брой печеливши сделки: ", count_profit, ", ", 
   "Бруто печалба: ", sum_profit, ", ", 
   "Брой губещи сделки: ", count_loss, ", ",
   "Бруто загуба: ", sum_loss);   
   Print("Риск/Възвръщаемост = 1/", 
   NormalizeDouble(1/( (sum_loss/count_loss)/(sum_profit/count_profit)), 2), ", ", 
      "Познаваемост = ", NormalizeDouble(cognoscibility*100,2), "%");
   Print("Mатематично Oчакване (МО) = ", NormalizeDouble(PMO*100, 2), "%", " /ако е по-малко от 60% метода е неустойчив/");
   
   return (PMO);
}



double Stat_AvgAnnualReturn(bool beginbalance = 10000){
   

   int i, hstTotal = HistoryTotal();
   
   double sum_netprofit = 0;
   double sum_profit = 0;
   double sum_loss = 0;
   datetime begintime = 9999999999;
   datetime endtime = 0;
   int ARR_YEARSPROFIT_SIZE = 50;
   double YearProfit[50][4];
   ArrayInitialize(YearProfit, 0);
   int year;
   
   double order_profit;
   
   for(i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){           
            
         if (OrderType() ==  OP_SELL  ||   OrderType() == OP_BUY){
            if (begintime > OrderCloseTime()){
               begintime = OrderCloseTime();    
            }
            if (endtime < OrderCloseTime()){
               endtime = OrderCloseTime();    
            }  
                      
            order_profit = OrderProfit();
            sum_netprofit = sum_netprofit + order_profit; 
         
            if (order_profit > 0) sum_profit = sum_profit + order_profit;
            if (order_profit < 0) sum_loss = sum_loss + order_profit;
                             
         
            year = TimeYear(OrderCloseTime());
            if (year >= 1990 && year - 1990 < ARR_YEARSPROFIT_SIZE){
               YearProfit[year - 1990][0] = YearProfit[year - 1990][0] + order_profit; // чиста печалба на година
               YearProfit[year - 1990][1] = sum_netprofit; //натрупана чиста печалба до момента
               if (order_profit < 0) 
                  YearProfit[year - 1990][2] = YearProfit[year - 1990][2] + order_profit; //бруто загуба
               if (order_profit > 0) 
                  YearProfit[year - 1990][3] = YearProfit[year - 1990][3] + order_profit; //бруто печалба
            }                                               
         } 
      }     
   }
   
   double days = (endtime - begintime)/86400;
   double AAR = ((sum_netprofit-beginbalance)/beginbalance)*(365/days);   
  
   
   double prev_year_balance = -1;               
   for (i = 0; i < ARR_YEARSPROFIT_SIZE; i++){
      
      if (YearProfit[i][1] != 0){
         
         if (prev_year_balance == -1){
            prev_year_balance = beginbalance;                     
         }else{
            prev_year_balance = YearProfit[i-1][1] + beginbalance;  
         }
          
         
         Print ("Година - ", 1990 + i, 
               ", Чиста печалба = ", NormalizeDouble(YearProfit[i][0], 2), "$",
               ", Бруто печалба = ", NormalizeDouble(YearProfit[i][3], 2), "$",
               ", Бруто Загуба = ", NormalizeDouble(YearProfit[i][2], 2), "$",
               
               
               ", Възшръщаемост = ", //NormalizeDouble((YearProfit[i][0]/(YearProfit[i][1]+beginbalance))*100, 2), " %");
               NormalizeDouble(((YearProfit[i][1]+beginbalance - prev_year_balance)/prev_year_balance ) *100, 2), " %");
      }               
   }
   Print("---Печалба по години---, ---Възшръщаемост по години---");
   Print("Общо чиста печалба = ", sum_netprofit,
         ", Общо бруто печалба = ", sum_profit,
         ", Общо бруто загуба = ", sum_loss,
         ", Печеливш фактор = ", NormalizeDouble(sum_profit/MathAbs(sum_loss), 3)  );
   Print("---Средна годишна възшръщаемост = ", NormalizeDouble(AAR*100, 2), " %");
   
   return (AAR);
   
}

void Stat_SumMonthlyProfitToFile(string FileName = "monthly_profit.txt"){

   int i, hstTotal = HistoryTotal();
   
   int ARR_MONTHLYPROFIT_SIZE = 1000;
   double MonthlyProfit[1000][3];
   ArrayInitialize(MonthlyProfit, 0);
   
   int arr_index = 0;
   int month;
   for(i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){           
            
         if (i == 0){
            month = TimeMonth(OrderCloseTime());            
            MonthlyProfit[arr_index][1] = month;        
            MonthlyProfit[arr_index][2] = TimeYear(OrderCloseTime());            
         }else{
            if (month != TimeMonth(OrderCloseTime())){
               month = TimeMonth(OrderCloseTime());
               arr_index++;
               
               MonthlyProfit[arr_index][1] = month;        
               MonthlyProfit[arr_index][2] = TimeYear(OrderCloseTime());
            }
         }  
         MonthlyProfit[arr_index][0] = MonthlyProfit[arr_index][0] + OrderProfit();        
                             
      }      
   }
   
   int file;
   file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');   
   
   if (file < 1){
     Stat_ViewErrorToFile("File " + FileName + ", the last error is ", GetLastError());     
     return(false);   
   }
   FileWrite(file, "Година,Месец,Печалба($)");       
   string row;                  
   for (i = 0; i < ARR_MONTHLYPROFIT_SIZE; i++){
      if (MonthlyProfit[i][2] > 1900){
         row = DoubleToStr(MonthlyProfit[i][2], 0) + "," + DoubleToStr(MonthlyProfit[i][1], 0) +","+ DoubleToStr(MonthlyProfit[i][0], 2);      
         FileWrite(file, row);    
      }
   }

   FileClose(file);
   return;
   
}

void Stat_DropDownToFile(bool AppendFile = false, double BeginBalance = 10000, string FileName = "dropdown.txt"){
   int i, hstTotal = HistoryTotal();
   double balance = BeginBalance;   
   double save_max = 0;
   double save_min = -1;
   double dropdown_percent_begin, dropdown_value_begin = 0;  
   double dropdown_percent_curr, dropdown_value_curr = 0;
   int count_dropdown = 0;
   double sum_dropdown_value = 0;

   string Pos = "";
   int file;
   
   if (!AppendFile) FileDelete(FileName);
   file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');
   
   if (file < 1){
     Stat_ViewErrorToFile("File " + FileName + ", the last error is ", GetLastError());     
     return(false);   
   }
   if (AppendFile){
      if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);   
   }
   FileWrite(file, "Дата на приключване на пропадането, Пропадане спрямо достигнатия максимум(%), Пропадане спрямо началния баланс(%), Пропадане($)"); 
   for(i = 0; i < hstTotal; i++){
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){     
         if ((OrderType() == OP_BUY) || (OrderType() == OP_SELL)){
            
            if (save_max < balance){
               if (save_min != -1){
                  
                 
                  if ((save_max - save_min) > 0){
                  
                     Pos = TimeToStr(OrderCloseTime()) +", "+ 
                           DoubleToStr( ((save_max - save_min)/save_max)* 100, 4) +", " + 
                           DoubleToStr( ((save_max - save_min)/BeginBalance)* 100, 4) +", " + 
                           DoubleToStr(save_max - save_min, 2); 
                     count_dropdown++;   
                     sum_dropdown_value =  sum_dropdown_value + (save_max - save_min);
                     FileWrite(file, Pos);     
                  }                     
                                               
                  if (dropdown_percent_begin < (save_max - save_min)/BeginBalance){
                     dropdown_percent_begin = (save_max - save_min)/BeginBalance;
                     dropdown_value_begin = (save_max - save_min);                     
                  }    
                  if (dropdown_percent_curr < (save_max - save_min)/save_max){
                     dropdown_percent_curr = (save_max - save_min)/save_max;
                     dropdown_value_curr = (save_max - save_min);                     
                  }                                    
               }
               
               save_max = balance;
               save_min = -1;
               
            }
            if (save_min > balance || save_min == -1){
               save_min = balance;                  
            }
            
            balance = balance + OrderProfit();                        
          
         }                     
      }
   }   
   FileClose(file);      
   Print  (NormalizeDouble(dropdown_percent_begin*100, 2), "%, ", NormalizeDouble(dropdown_value_begin, 2), "$");   
   Print  ("---Максимално пропадане спрямо началния баланс---");  
   
   Print  (NormalizeDouble(dropdown_percent_curr*100,2), "%, ", NormalizeDouble(dropdown_value_curr, 2), "$");
   Print  ("---Максимално пропадане спрямо максимално достигнат баланс---");
      
   Print  (NormalizeDouble(((sum_dropdown_value/count_dropdown)/BeginBalance)*100, 2), "%, ", NormalizeDouble(sum_dropdown_value/count_dropdown, 2), "$");
   Print  ("---Средно пропадане спрямо началния баланс---");      
}

void Stat_ViewErrorToFile(string Info, int ErrorCode, string FileName = "ErrStatisical.txt"){
   Print(Info, " - error(",ErrorCode,"): ", ErrorDescription(ErrorCode));
        
   int file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');   
   if (file < 1){
     Print("File " + FileName + ", the last error is ", GetLastError());     
     return;   
   }
   if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);
   string Pos = TimeToStr(Time[0]) + ": "+ Info + " - error("+ErrorCode+"): "+ ErrorDescription(ErrorCode);
   FileWrite(file, Pos);            
   FileClose(file);      
   return;
}