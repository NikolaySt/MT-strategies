//--------------------------ДЕФЕНИРАНЕ НА ЛОКАЛНИ ПРОМЕНЛИВИ ЗА СИСТЕМАТА-------------------
#define TD_NONE 0
#define TD_UP 1
#define TD_DOWN -1
datetime time_close_order = 0;
int AlternativeTrend = TD_NONE;
//------------------------------------------------------------------------------------------


void StdDev_System_2_Init(){
   StdDev_System_Init_Common();
}

void StdDev_System_2_Process(int MAGIC){  

   if (Period() > SIGNAL_TIMEFRAME){   
      //Проверка за часовото ниво на което работи системата //това е най-ниското часово ниво което се ползва      
      Print("Грешка: ", SignalBaseName ," работи на часово ниво по-малко или равно от " + SignalTimeFrame);
      return;
   }
   
   //------------------------------------ВРЕМЕВИ ФИЛТЪР НА СИГНАЛА НА СИСТЕМАТА----------------------
   //времеви фитър, системата работи само в зададения период от часове през деня
   // ако е 0 - 23 работи през цения ден
   int hour = TimeHour(iTime(NULL, PERIOD_H1, 1)); 
   if (!(hour >= TimeWorkStart && hour <= TimeWorkEnd)) return;   
   //------------------------------------------------------------------------------------------------   

   System_StopAndLimit_Process();
        
   //--------------------------------------------------------------------------------------------------         
   double profit = 0;  
   double max_level = 0;
   double min_level = 100000000; 
   bool IsOpenOrder = false;  
   int OpenOrderType = -1;
   int type = 0;
   int CountOrders = 0;
   
   bool IsPendingOrder_Sell = false;  
   bool IsPendingOrder_Buy = false;  
   bool IsPendingOrder_Base = false;
   int ticket_sell_stop = 0;
   int ticket_buy_stop = 0;
   string base_name = SignalBaseName+"0";
   string second_name = SignalBaseName+"1";
   double order_profit;
   double tick_value = PointCost(); //MarketInfo(Symbol(), MODE_TICKVALUE);
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {                       
            type = OrderType();               
            if (type == OP_SELL || type == OP_BUY){
               OpenOrderType = type;
               if (type == OP_SELL){
                  order_profit = ((OrderOpenPrice() - Ask)/Point) * tick_value * OrderLots();
               }else{
                  order_profit = ((Bid - OrderOpenPrice())/Point) * tick_value * OrderLots();
               }
               profit = profit + order_profit;//OrderProfit();
               
               if (type == OP_SELL)  min_level = MathMin(OrderOpenPrice(), min_level);
               if (type == OP_BUY)  max_level = MathMax(OrderOpenPrice(), max_level);              
               CountOrders++;
               IsOpenOrder = true;     
               time_close_order = iTime(NULL, SIGNAL_TIMEFRAME, 0);   
            } 
	         if (type == OP_SELLSTOP || type == OP_BUYSTOP) {	         
	           IsPendingOrder_Base = true;
            }	           
	         if (type == OP_SELLSTOP) {
	           IsPendingOrder_Sell = true;
	           if (base_name == InternalSignalName(OrderComment()))  ticket_sell_stop = OrderTicket();
            }	           
            if (type == OP_BUYSTOP) {
               IsPendingOrder_Buy = true;
               if (base_name == InternalSignalName(OrderComment())) ticket_buy_stop = OrderTicket();
            }	           

         }
      }
   }    
   if (max_level == 0) max_level = 0;
   if (min_level == 100000000) min_level = 0;        
   //--------------------------------------------------------------------------------------------------
   
   /*
   //-----------------------премахване на отложените поръчки---------------------------------------------- 
   if (IsOpenOrder){
      //имаме отворени поръчки
      //ако за първи път отваря една от двете поръчки трябва да премахна другата насрещна поръчка
      if (OpenOrderType == OP_BUY && ticket_sell_stop > 0 ) RemovePendingOrdersByTicket(MAGIC, ticket_sell_stop);
      if (OpenOrderType == OP_SELL && ticket_buy_stop > 0 ) RemovePendingOrdersByTicket(MAGIC, ticket_buy_stop);              
   }else{      
      //ако няма отворени поръчки прави провека и премахва всички останали вторични поръчки
      if (IsPendingOrder_Base) {
         RemovePendingOrdersBySignalName(MAGIC, SignalBaseName+"1");          
      }         
   }   
   //------------------------------------------------------------------------------------------------------   
   //*/

   if ((time_close_order == iTime(NULL, SIGNAL_TIMEFRAME, 0) && CountOrders == 0) || System_CloseOrders(MAGIC, profit)){//затварянето на поръчките става при достигане на опрделена печалба или загуба   
      // този начин на запис на времето не е устойчивост ако се наложи рестартиране на експерта
      // ще загуби стойността трябва да се инициализира отново но това е рядко събитие и няма да окажи влияние на системата      
      
      //всички поръчки са затворени и премахнати
      max_level = 0;   
      min_level = 0;
      CountOrders = 0;
      OpenOrderType = -1;
      profit = 0;
      IsOpenOrder = false;
      
      IsPendingOrder_Buy = false;
      IsPendingOrder_Sell = false;
      IsPendingOrder_Base = false;
      ticket_sell_stop = 0;
      ticket_buy_stop = 0;      
   }
   
   double SignalLevel[2]; ArrayInitialize(SignalLevel, 0);
   datetime SignalTime = 0; 
   int SignalType[2];  ArrayInitialize(SignalType, -1);
            
   //-------------------------------ГЕНЕРИРАМЕ СИГНАЛА ЗА ВХОД----------------------------------------   
   if (IsOpenOrder){            
      System_CreateSignal(1, SignalType, SignalTime, SignalLevel, Factor2, max_level, min_level); 
   }else{
      System_CreateSignal(0, SignalType, SignalTime, SignalLevel, Factor1);   
   }        
   //-------------------------------------------------------------------------------------------------   
   
   //*
   //-----------------------премахване на отложените поръчки---------------------------------------------- 
   if (IsOpenOrder){
      //имаме отворени поръчки
      //ако за първи път отваря една от двете поръчки трябва да премахна другата насрещна поръчка
      if (OpenOrderType == OP_BUY && ticket_sell_stop > 0 ) RemovePendingOrdersByTicket(MAGIC, ticket_sell_stop);
      if (OpenOrderType == OP_SELL && ticket_buy_stop > 0 ) RemovePendingOrdersByTicket(MAGIC, ticket_buy_stop);              
   }else{      
      //ако няма отворени поръчки прави провека и премахва всички останали вторични поръчки
      if (IsPendingOrder_Base) {
         RemovePendingOrdersBySignalName(MAGIC, SignalBaseName+"1");          
      }         
   }   
   //------------------------------------------------------------------------------------------------------   
   //*/   
            
   //----------------------------------------ПОСТАВЯ ОТЛОЖЕНА ПОРЪЧКА-----------------------------------                                                                                          
   if (!IsOpenOrder){//няма отворена поръчка                               
      if (time_close_order != iTime(NULL, SIGNAL_TIMEFRAME, 0)){
      //if (!History_IsOpenCloseInCurrentBar(MAGIC, SIGNAL_TIMEFRAME)){
         time_close_order = 0;
         if (SignalType[0] == OP_BUYSTOP){
            if (!IsPendingOrder_Buy){
               //няма висяща - поставя нова
               PrepareOrder(MAGIC, SignalBaseName+"0", SignalType[0], SignalTime, SignalLevel[0]);       
            }else{
               //има висяща купува затова прави промяма
               PrepareOrder(MAGIC, SignalBaseName+"0", SignalType[0], SignalTime, SignalLevel[0], 0, 0, true);
            }      
         }     
         if (SignalType[1] == OP_SELLSTOP){       
            if (!IsPendingOrder_Sell){
               //няма висяща - поставя нова
               PrepareOrder(MAGIC, SignalBaseName+"0", SignalType[1], SignalTime, SignalLevel[1]);            
            }else{
               //има висяща продава затова прави промяма
               PrepareOrder(MAGIC, SignalBaseName+"0", SignalType[1], SignalTime, SignalLevel[1], 0, 0, true);            
            }   
         }
      }      
   }else{
      //НЯМА ОТЛОЖЕНИ ПОРУЧКИ ИМА САМО ПАЗАРНИ      
      if (CountOrders < TradeLimit){
        //отворените поръчки са по-малко от зададения лимит затова поставя още една висяща                      
        //------------------------------------------------------------------------------------------------------------------------------        
         if (SignalType[0] == OP_BUYSTOP && OpenOrderType == OP_BUY){
            if (!IsPendingOrder_Buy){
               //няма висяща - поставя нова
               PrepareOrder(MAGIC, SignalBaseName+"1", OP_BUYSTOP, SignalTime, SignalLevel[0], max_level, CountOrders);          
            }else{
               //има висяща купува затова прави промяма
               PrepareOrder(MAGIC, SignalBaseName+"1", OP_BUYSTOP, SignalTime, SignalLevel[0], max_level, CountOrders, true);          
            }                   
         }
         //-------------------------------------------------------------------------------------------------------------------------------
         //-------------------------------------------------------------------------------------------------------------------------------                              
         if (SignalType[1] == OP_SELLSTOP && OpenOrderType == OP_SELL){
            if (!IsPendingOrder_Sell){
               //няма висяща - поставя нова
               PrepareOrder(MAGIC, SignalBaseName+"1", OP_SELLSTOP, SignalTime, SignalLevel[1], min_level, CountOrders);                            
            }else{
               //има висяща затова прави промяма
               PrepareOrder(MAGIC, SignalBaseName+"1", OP_SELLSTOP, SignalTime, SignalLevel[1], min_level, CountOrders, true);                            
            }                   
         }  
         //-------------------------------------------------------------------------------------------------------------------------------                                          
      }                          
   }                        
   //--------------------------------------------------------------------------------------------------
} 


double MAGetValue(int index = 1){   
   if (AvrCloseBars <= 0){
      return(iMA(NULL, SIGNAL_TIMEFRAME, StdDevPeriod, 0, MODE_SMA, PRICE_CLOSE, index)); 
   }else{
      return(iMA(NULL, SIGNAL_TIMEFRAME, AvrCloseBars, 0, MODE_SMA, PRICE_CLOSE, index));   
   }      
}

void System_CreateSignal(int SignalIndex, int& SignalType[], datetime& SignalTime, double& SignalLevel[], double& factor, double max_level = 0, double min_level = 0){
   SignalTime = iTime(NULL, SIGNAL_TIMEFRAME, 1);
   
   double MA = MAGetValue();     
   
   
   /*
   double sd   = iStdDev(NULL, SIGNAL_TIMEFRAME, StdDevPeriod, 0, 0, 0, 1);
   double sd_1 = iStdDev(NULL, Std_1_TimeFrame, Std_1_StdPeriod, 0, 0, 0, 1);    
   double sd_2 = iStdDev(NULL, Std_2_TimeFrame, Std_2_StdPeriod, 0, 0, 0, 1);    
   double sd_3 = iStdDev(NULL, Std_3_TimeFrame, Std_3_StdPeriod, 0, 0, 0, 1);     
   //*/
   //*   
   double sd = iATR(NULL, SIGNAL_TIMEFRAME,   StdDevPeriod, 1);
   double sd_1 = iATR(NULL, Std_1_TimeFrame,  Std_1_StdPeriod, 1);
   double sd_2 = iATR(NULL, Std_2_TimeFrame,  Std_2_StdPeriod, 1);
   double sd_3 = iATR(NULL, Std_3_TimeFrame,  Std_3_StdPeriod, 1);      
   //*/
     
   bool std_filter_1_ok = Std_1_Limit == 0 || (sd_1 < Std_1_Limit*Point);
   bool std_filter_2_ok = Std_2_Limit == 0 || (sd_2 < Std_2_Limit*Point);
   bool std_filter_3_ok = Std_3_Limit == 0 || (sd_3 < Std_3_Limit*Point);
   
   
   int trend = TD_NONE;
   datetime timefr;
   bool FilterTrend_ok = false;
   bool FilterFractal_ok = false;
     
   //----------------------------------------SIGNAL BUYSTOP------------------------------------------------------------------------
   if (SignalIndex  == 0){
      if (std_filter_1_ok && std_filter_2_ok && std_filter_3_ok){      
         
         FilterTrend_ok = Trend_BarsBreak == 0 || System_TrendDirection(SIGNAL_TIMEFRAME) == TD_UP;
         FilterFractal_ok = Fr_Bars == 0 || SearchFractalInPeriod(MODE_UPPER, SIGNAL_TIMEFRAME, Fr_Bars, Fr_BackBars) > 0;
         
         if (FilterTrend_ok && FilterFractal_ok){            
            SignalType[0] = OP_BUYSTOP;            
            //if (max_level == 0) 
               SignalLevel[0] = MA + sd*factor;      
            //else 
               //SignalLevel[0] = max_level + sd*factor;            
         }
      } 
   }else{
      //за втората поръчка не ползва филтър
      SignalType[0] = OP_BUYSTOP;
      //if (max_level == 0) 
         //SignalLevel[0] = MA + sd*factor;      
      //else 
         SignalLevel[0] = max_level + sd*factor;    
   }    
   //--------------------------------------------------------------------------------------------------------------------------------    
   
   //----------------------------------------SIGNAL SELLSTOP------------------------------------------------------------------------
   if (SignalIndex  == 0){
      if (std_filter_1_ok && std_filter_2_ok && std_filter_3_ok){   
         
         FilterTrend_ok = Trend_BarsBreak == 0 || System_TrendDirection(SIGNAL_TIMEFRAME) == TD_DOWN;
         FilterFractal_ok = Fr_Bars == 0 || SearchFractalInPeriod(MODE_LOWER, SIGNAL_TIMEFRAME, Fr_Bars, Fr_BackBars) > 0;
         
         if (FilterTrend_ok && FilterFractal_ok){          
            SignalType[1] = OP_SELLSTOP;             
            //if (min_level == 0) 
               SignalLevel[1] = MA - sd*factor;   
            //else 
              // SignalLevel[1] = min_level - sd*factor;          
         }            
               
      }
   }else{                 
      //за втората поръчка не ползва филтър
      SignalType[1] = OP_SELLSTOP; 
      //if (min_level == 0) 
        // SignalLevel[1] = MA - sd*factor;   
      //else 
         SignalLevel[1] = min_level - sd*factor;        
   }  
   //--------------------------------------------------------------------------------------------------------------------------------    
}

int System_TrendDirection(int timeframe){      
  if (CloseOverHighestEx(timeframe, Trend_BarsBreak, 1)) AlternativeTrend = TD_UP;   
  if (CloseUnderLowestEx(timeframe, Trend_BarsBreak, 1)) AlternativeTrend = TD_DOWN;
  return(AlternativeTrend);    
}

double SearchFractalInPeriod(int mode, int period, int fr_bars, int count){
   int shift = MathRound(fr_bars / 2) + 1;
   double fr = 0;   
   int i;   
   for(i = shift; i <= shift + count; i++)
   {
      if (mode == MODE_UPPER) fr = UpFractalFloat(fr_bars, period, i);                    
      if (mode == MODE_LOWER) fr = DownFractalFloat(fr_bars, period, i);                             
      if (fr != 0) {
         return(fr);                     
      }             
   }     
   return(0);
}


bool CloseOverHighestEx(int period, int count, int bar_begin = 2){
   double offset = 0;
   
   int shift = iBarShift(NULL, period, Time[0])+1;         
   //sravniava ot 3-ti bar нататък ako bar_begin = 2
   int index = iHighest(NULL, period, MODE_HIGH, count, shift+bar_begin);
   double HH = iHigh(NULL, period, index);
   
   double c = iClose(NULL, period, shift);
   double o = iOpen(NULL, period, shift);
   double h = iHigh(NULL, period, shift);
   double l = iLow(NULL, period, shift);   
          
   return(
         c >= HH && // цената на затваряне да е над N-брой бара
         (c > o && c > (h - l)*(2/3) + l)     // затворелия бар да е над 2/3 от дъното си.
      );
}

bool CloseUnderLowestEx(int period, int count, int bar_begin = 2){
   double offset = 0;
   
   int shift = iBarShift(NULL, period, Time[0])+1;   
   //sravniava ot 3-ti bar нататък ako bar_begin = 2
   int index = iLowest(NULL, period, MODE_LOW, count, shift+bar_begin);
   double LL = iLow(NULL, period, index);
   
   double c = iClose(NULL, period, shift);
   double o = iOpen(NULL, period, shift);
   double h = iHigh(NULL, period, shift);
   double l = iLow(NULL, period, shift);   
      
   return(
         c <= LL && // цената на затваряне да е под N-брой бара
         (c < o && c < h - (h - l)*(2/3))     // затворелия бар да е под 2/3 от върха си.
      );
}

double UpFractalFloat(int bars_count, int period,  int i){   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      if (!(iHigh(NULL, period, i) >= iHigh(NULL, period, i+n))){
         return(0);         
      }
      if (!(iHigh(NULL, period, i) >= iHigh(NULL, period, i-n))){
         return(0);       
      }            
   }
   return(iHigh(NULL, period, i)); 
}


double DownFractalFloat(int bars_count, int period,  int i){   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      if (!(iLow(NULL, period, i) <= iLow(NULL, period, i+n))){
         return(0);              
      }
      if (!(iLow(NULL, period, i) <= iLow(NULL, period, i-n))){
         return(0);              
      }      
   }   
   return(iLow(NULL, period, i)); 
}


bool System_CloseOrders(int MAGIC, double profit){
   //ако няма стоп или лимит в пари нищо не прави
   //return(false);
   if (GGoal_Limit_currency == 0 && GGoal_Stop_currency == 0) return(false);
   
   double stop = 0;
   if (GGoal_Stop_currency != 0){
      stop = GGoal_Stop_currency *(-1);
   }else{   
      stop = GGoal_Limit_currency*GGoal_StopRatio *(-1);
   }   
   
   if (profit >= GGoal_Limit_currency || //Активира при достигната печалба
      profit <= stop // Активира при достигната загуба
      ){
      CloseAndRemoveOrders(MAGIC); //затваря и премахва отворените и висящи поручки
      return(true);
   }else{
      return(false);
   }   
}


bool System_StopAndLimit_Process(){
   if (FixProfitAndLimit){
      CalcLimitAndSL(MagicNumber, OP_BUY);
      CalcLimitAndSL(MagicNumber, OP_SELL);   
   }
}