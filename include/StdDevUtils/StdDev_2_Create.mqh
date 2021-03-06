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
      System_CreatePendSignal(1, SignalType, SignalTime, SignalLevel, Factor2, max_level, min_level); 
   }else{
      System_CreatePendSignal(0, SignalType, SignalTime, SignalLevel, Factor1);   
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
               PreparePendingOrder(MAGIC, SignalBaseName+"0", SignalType[0], SignalTime, SignalLevel[0]);       
            }else{
               //има висяща купува затова прави промяма
               PreparePendingOrder(MAGIC, SignalBaseName+"0", SignalType[0], SignalTime, SignalLevel[0], 0, 0, true);
            }      
         }     
         if (SignalType[1] == OP_SELLSTOP){       
            if (!IsPendingOrder_Sell){
               //няма висяща - поставя нова
               PreparePendingOrder(MAGIC, SignalBaseName+"0", SignalType[1], SignalTime, SignalLevel[1]);            
            }else{
               //има висяща продава затова прави промяма
               PreparePendingOrder(MAGIC, SignalBaseName+"0", SignalType[1], SignalTime, SignalLevel[1], 0, 0, true);            
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
               PreparePendingOrder(MAGIC, SignalBaseName+"1", OP_BUYSTOP, SignalTime, SignalLevel[0], max_level, CountOrders);          
            }else{
               //има висяща купува затова прави промяма
               PreparePendingOrder(MAGIC, SignalBaseName+"1", OP_BUYSTOP, SignalTime, SignalLevel[0], max_level, CountOrders, true);          
            }                   
         }
         //-------------------------------------------------------------------------------------------------------------------------------
         //-------------------------------------------------------------------------------------------------------------------------------                              
         if (SignalType[1] == OP_SELLSTOP && OpenOrderType == OP_SELL){
            if (!IsPendingOrder_Sell){
               //няма висяща - поставя нова
               PreparePendingOrder(MAGIC, SignalBaseName+"1", OP_SELLSTOP, SignalTime, SignalLevel[1], min_level, CountOrders);                            
            }else{
               //има висяща затова прави промяма
               PreparePendingOrder(MAGIC, SignalBaseName+"1", OP_SELLSTOP, SignalTime, SignalLevel[1], min_level, CountOrders, true);                            
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

void System_CreatePendSignal(int SignalIndex, int& SignalType[], datetime& SignalTime, double& SignalLevel[], double& factor, double max_level = 0, double min_level = 0){
   SignalTime = iTime(NULL, SIGNAL_TIMEFRAME, 1);
   
   double MA = MAGetValue();  
   double sd_1, sd_2, sd_3;
   
   if (ActiveAtr){
      sd_1 = iATR(NULL, SIGNAL_TIMEFRAME,  StdDevPeriod, 1);
      sd_2 = iATR(NULL, PERIOD_H4,  StdDevPeriod, 1);
      sd_3 = iATR(NULL, PERIOD_D1,  StdDevPeriod, 1);   
   }else{
      sd_1 = iStdDev(NULL, SIGNAL_TIMEFRAME, StdDevPeriod, 0, 0, 0, 1);    
      sd_2 = iStdDev(NULL, PERIOD_H4, StdDevPeriod, 0, 0, 0, 1);    
      sd_3 = iStdDev(NULL, PERIOD_D1, StdDevPeriod, 0, 0, 0, 1);    
   }   
   
   int trend = TD_NONE;
   datetime timefr;
   double fr = 0;   
   if (FilterTrend && SignalIndex == 0){     
      trend = System_TrendDirection(SIGNAL_TIMEFRAME);
   }
   
   //----------------------------------------SIGNAL BUYSTOP------------------------------------------------------------------------
   if (SignalIndex  == 0){
      if (!FilterStdLimit || (FilterStdLimit && sd_1 < Std_H1_Limit*Point && sd_2 < Std_H4_Limit*Point && sd_3 < Std_D1_Limit*Point)){      
         fr = SearchFractalInPeriod(MODE_UPPER, SIGNAL_TIMEFRAME, FrBars, CountBackBars, timefr);      
         
         if (!FilterTrend || (FilterTrend && trend == TD_UP && fr > 0  )){
            
            SignalType[0] = OP_BUYSTOP;
            
            if (max_level == 0) 
               SignalLevel[0] = MA + sd_1*factor;      
            else 
               SignalLevel[0] = max_level + sd_1*factor;            
         }
      } 
   }else{
      //за втората поръчка не ползва филтър
      SignalType[0] = OP_BUYSTOP;
      if (max_level == 0) 
         SignalLevel[0] = MA + sd_1*factor;      
      else 
         SignalLevel[0] = max_level + sd_1*factor;    
   }    
   //--------------------------------------------------------------------------------------------------------------------------------    
   
   //----------------------------------------SIGNAL SELLSTOP------------------------------------------------------------------------
   if (SignalIndex  == 0){
      if (!FilterStdLimit || (FilterStdLimit && sd_1 < Std_H1_Limit*Point && sd_2 < Std_H4_Limit*Point && sd_3 < Std_D1_Limit*Point)){ 
         fr = SearchFractalInPeriod(MODE_LOWER, SIGNAL_TIMEFRAME, FrBars, CountBackBars, timefr);              
         
         if (!FilterTrend || (FilterTrend && trend == TD_DOWN && fr > 0  )){
            
            SignalType[1] = OP_SELLSTOP; 
            
            if (min_level == 0) 
               SignalLevel[1] = MA - sd_1*factor;   
            else 
               SignalLevel[1] = min_level - sd_1*factor;          
         }            
               
      }
   }else{                 
      //за втората поръчка не ползва филтър
      SignalType[1] = OP_SELLSTOP; 
      if (min_level == 0) 
         SignalLevel[1] = MA - sd_1*factor;   
      else 
         SignalLevel[1] = min_level - sd_1*factor;        
   }  
   //--------------------------------------------------------------------------------------------------------------------------------    
}

int System_TrendDirection(int timeframe){      
  if (CloseOverHighestEx(timeframe, TrendBarsBreak, 1)) AlternativeTrend = TD_UP;   
  if (CloseUnderLowestEx(timeframe, TrendBarsBreak, 1)) AlternativeTrend = TD_DOWN;
  return(AlternativeTrend);  
  
}

double SearchFractalInPeriod(int mode, int period, int fr_bars, int count, datetime& timefr){
   int shift = MathRound(fr_bars / 2) + 1;
   double fr = 0;   
   int i;   
   timefr = 0;
   for(i = shift; i <= shift + count; i++)
   {
      if (mode == TD_UP) fr = UpFractalFloat(fr_bars, period, i);                    
      if (mode == TD_DOWN) fr = DownFractalFloat(fr_bars, period, i);  
      if (mode == MODE_UPPER) fr = UpFractalFloat(fr_bars, period, i);                    
      if (mode == MODE_LOWER) fr = DownFractalFloat(fr_bars, period, i);                             
      if (fr != 0) {
         timefr = iTime(NULL, period, i);
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

