
bool N012_Signal_Trace = false;


void N012_Signals_Init(int settID)
{ 
   N012_RangePips = DigMode()*N012_RangePips;  
   N012_RangeBarsPips = DigMode()*N012_RangeBarsPips;      
}

void N012_Signals_PreProcess(int settID)
{ 
}

void N012_Signals_Process(int settID)
{ 
   
   N012_Signals_PreProcess(settID);
     
   //Проверка за часовото ниво на което работи системата
   //това е най-ниското часово ниво което се ползва
   if (Period() > Signal_TimeFrame){         
      Print("Грешка: ", SignalBaseName ," работи на часово ниво по-малко или равно от " + Signal_TimeFrame);
      return;
   }                 
   Common_Stop_ProcessAll(settID);
         

   //------------------------------------ВРЕМЕВИ ФИЛТЪР НА СИГНАЛА НА СИСТЕМАТА----------------------
   //времеви фитър, системата работи само в зададения период от часове през деня
   // ако е 0 - 24 работи през цения ден
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;
   //------------------------------------------------------------------------------------------------

   //-------------------------------ГЕНЕРИРАМЕ СИГНАЛА ЗА ВХОД----------------------------------------   
   int signalTypes[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersTickets[2];
 
   ArrayInitialize(signalTypes,0);
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(signalTimes,0);
   ArrayInitialize(ordersTickets,0);

   //----------------------------------------------------------------------------------------------------------------------
   
   N012_LastCross_RemovePending(settID);   
   
   if (Common_Signals_IsActive()){
      N012_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);            
   
   if (OpenOrders_GetCount(settID) > 0) N012_CloseOrders(settID);      
   
}

   

void N012_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
          
   int sleep_index = N012_SleepAlligator_Shift(settID);
   
   if (sleep_index > 0){
      
      int LL_index = iLowest(NULL, Signal_TimeFrame, MODE_LOW, sleep_index, 1);       
      int HH_index = iHighest(NULL, Signal_TimeFrame, MODE_HIGH, sleep_index, 1);
      
      double HH = iHigh(NULL, Signal_TimeFrame, HH_index);            
      double LL = iLow(NULL, Signal_TimeFrame, LL_index);                    
      
      double range = HH-LL;
      
      double bb_hh = iBands(0, Signal_TimeFrame, N012_BandPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, HH_index);
      double bb_ll = iBands(0, Signal_TimeFrame, N012_BandPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, LL_index);
      
      if (
         (N012_RangeBarsPips == 0 || range <= N012_RangeBarsPips*Point)
            &&
         (N012_BandPeriod == 0 || iClose(NULL, Signal_TimeFrame, 1) < bb_hh)
            &&
         (N012_BandPeriod == 0 || iClose(NULL, Signal_TimeFrame, 1) > bb_ll)         
         ){         

         signalTypes[0] = 1;
         signalTimes[0] = iTime(NULL, Signal_TimeFrame, sleep_index);                       
         signalLevels[0] = HH;     

         signalTypes[1] = -1;
         signalTimes[1] = iTime(NULL, Signal_TimeFrame, sleep_index);             
         signalLevels[1] = LL; 
         
      }                         
   }   
}

void N012_CloseOrders(int settID){   
   double close1 = iClose(NULL, Signal_TimeFrame, 1);
   double ma1 = iMA(NULL, Signal_TimeFrame, N012_Stop_MAPeriod, N012_Stop_MAShift, MODE_SMMA, PRICE_MEDIAN, 1);
      
   if (close1 < ma1 ) N012_CloseByTypeTimeBar(settID, OP_BUY, iTime(NULL, Signal_TimeFrame, 0));
   if (close1 > ma1 ) N012_CloseByTypeTimeBar(settID, OP_SELL, iTime(NULL, Signal_TimeFrame, 0));        
}

int N012_SleepAlligator_Shift(int settID){
   
   double center, up_level, down_level;
   double green, red, blue;
   double up_ma_1, down_ma_1, up_ma_2, down_ma_2;
   
   double middle_range_points = (N012_RangePips*Point)/2;
   int middle_bars = MathRound(N012_BarsSleep / 2);
   bool exit = false;
   int i = 0;
   int index = N012_BarsSleep;   
   int begin_sleep_index = 0;
      
   while (index > 0){
      center = N012_Alligator(8, 5, middle_bars + i);
      
      up_level   = center + middle_range_points;
      down_level = center - middle_range_points;
      
      //----------------------------------------------------------------------------------
      green = N012_Alligator(5,  3, i);
      red   = N012_Alligator(8,  5, i);
      blue  = N012_Alligator(13, 8, i);          
      
      up_ma_1 = MathMax(blue, MathMax(green, red));
      down_ma_1 = MathMin(blue, MathMin(green, red));      
      //----------------------------------------------------------------------------------
      
      green = N012_Alligator(5, 3, N012_BarsSleep+i);
      red = N012_Alligator(8, 5, N012_BarsSleep+i);
      blue = N012_Alligator(13, 8, N012_BarsSleep+i);    
        
      up_ma_2 = MathMax(blue, MathMax(green, red));
      down_ma_2 = MathMin(blue, MathMin(green, red));       
      
      
      if (up_ma_1 <= up_level && down_ma_1 >= down_level && up_ma_2 <= up_level && down_ma_2 >= down_level){                
         index = N012_BarsSleep;
         begin_sleep_index = N012_BarsSleep + i;      
         
         if (N012_Signal_Trace){
            if (IsVisualMode()){
               SetPoint(High[0], Time[0], Red, 5);                 
               Print("sleep = ", begin_sleep_index);
               Print("N012_BarsSleep+i = ", N012_BarsSleep+i);
               Print("i = ", i);
               Print("up_ma_1 = ", up_ma_1, ", down_ma_1 = ", down_ma_1);
               Print("up_ma_2 = ", up_ma_2, ", down_ma_2 = ", down_ma_2);
               Print("down_level = ", down_level, ", up_level = ", up_level);
            }
         }
         
      }
            
      index--;
      i++;
         
   }
   return(begin_sleep_index);
}

void N012_LastCross_RemovePending(int settID){
   int ticket = HOrders_GetLastCloseTicket(settID);
   
   if (ticket == 0) return;
   if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_HISTORY)){
      datetime timeclose = OrderCloseTime();
      datetime timesignal = SelectedOrder_GetSignalTime();
      int dir = OrderType_GetDirection(OrderType());      
   
      int shift = iBarShift(0, Signal_TimeFrame, timeclose);
      if (shift >= N012_BarsCrossClose ){
         //премахва обратната поръчка само ако са минали определен брой барове след затварянето и 
         //при положение че висящата пиръчка е сложена по рано от датата на затваряне         
         if (dir == 1) N012_RemoveByTymeType(settID, OP_SELLSTOP, timeclose);
         if (dir == -1) N012_RemoveByTymeType(settID, OP_BUYSTOP, timeclose);
      }      
   }
}


void N012_RemoveByTymeType(int settID, int type, datetime TimeSignal){       
   bool check; 
   bool check_exit, mark_close = false;
   int i;     
   
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {                                                                   

               if (type == OrderType() && OrderOpenTime() <= TimeSignal) {                                         
                  if (OrderDelete(OrderTicket())){      
                     mark_close = true;
                     if (SANO_UseSound) PlaySound(SANO_NameFileSound); 
                                       
                  }else{
                     InternalViewLastError("[N012_RemoveByTymeType]", GetLastError());              
                  }                               
               }                                                     
            } 
         }else{
            InternalViewLastError("[N012_RemoveByTymeType]::OrderSelect -", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }             
}

double N012_Alligator(int MAPeriod, int MAShift, int shift){
   return(
         iMA(NULL, Signal_TimeFrame, MAPeriod, MAShift, MODE_SMMA, PRICE_MEDIAN, shift) 
         );  
}


void N012_CloseByTypeTimeBar(int settID, int TradeType, datetime timeBar) { 
   bool check; 
   bool check_exit, mark_close = false;
   int i;             
           
   while (!check_exit){
      mark_close = false;
      for (i = 0; i < OrdersTotal(); i++) { 
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
            if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID && OrderType() == TradeType
               && OrderOpenTime() < timeBar
               ) {                                                 
                  
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
                     InternalViewLastError("N012_CloseByTypeTimeBar - ClosePosition", GetLastError());                       
                  }                                    
            } 
         }else{
            InternalViewLastError("N012_CloseByTypeTimeBar - OrderSelect", GetLastError());
         }
      } 
      if (!mark_close) check_exit = true;
   }   
} 