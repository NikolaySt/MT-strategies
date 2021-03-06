
bool N023_Signal_Trace = false;


void N023_Signals_Init(int settID)
{ 
 
}

void N023_Signals_PreProcess(int settID)
{ 
}

void N023_Signals_Process(int settID)
{ 
   
   N023_Signals_PreProcess(settID);
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;   
       
     
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
   
   double signalLimits[2];
   double signalStops[2];
   string signalComments[2];
 
   ArrayInitialize(signalTypes,0);   
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(signalTimes,0);
   ArrayInitialize(ordersTickets,0);
   
   ArrayInitialize(signalLimits,0);   
   ArrayInitialize(signalStops,0); 

   //----------------------------------------------------------------------------------------------------------------------
      
   
   if (Common_Signals_IsActive()){   
      N023_Signals_Create(settID, signalTypes, signalTimes, signalLevels, signalStops); 
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessEx(settID, signalTypes, signalTimes, signalLevels, signalLimits, signalStops, signalComments, ordersTickets);              
   
   N023_Close_Orders(settID);
   //if (OpenOrders_GetCountForType(settID, OP_BUY) > 0) PendingOrders_RemoveByDir(settID, -1);
   //if (OpenOrders_GetCountForType(settID, OP_SELL) > 0) PendingOrders_RemoveByDir(settID, 1); 
}

      

void N023_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[], double& signalStops[]){             
   int trend = iCustom(NULL, Signal_TimeFrame, "SAN_IchimokuSignal", N023_TenkanSen, N023_KijinSen, N023_SencouSpanB, 0, 0, 1);    
  //int trend = iCustom(NULL, Signal_TimeFrame, "SAN_AtrVolatility", N023_ST_AtdPeriod, N023_ST_Multiplier, 2, 1); 

   if (trend != 0){
      PendingOrders_RemoveByDir(settID, (-1)*trend);
   }             
   
   int zoneCount;
   datetime zoneTime;
   int zone = N023_Zone(settID, zoneCount, zoneTime);
   
   if (            
      //---------------AOAC - ZONA /зелена зона/------------
       zoneCount <= N023_ZoneCount
       &&
       zone == trend && trend != 0 && zone != 0       
       && 
       zone*(iClose(NULL, Signal_TimeFrame, 1) - iClose(NULL, Signal_TimeFrame, 2)) > 0     
      //-------------------------------            
      ){
      signalTypes[0] = zone;
      signalLevels[0] = SAN_AUtl_BarValueByDir(1, Signal_TimeFrame, zone);
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);   
      
   }   
  
 
}


void N023_Close_Orders(int settID){
  
   double close = iClose(NULL, Signal_TimeFrame, 1);

   double ma = iMA(NULL, Signal_TimeFrame, N023_MAExitPeriod, N023_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);   
      
   if (close < ma) Orders_CloseByType(settID, OP_BUY);
   if (close > ma) Orders_CloseByType(settID, OP_SELL);     
}

int N023_Zone(int settID, int &zoneCount, datetime &zoneTime){
   int curr_zone = iCustom(NULL, Signal_TimeFrame, "SAN_AOACZone", N023_ZoneMAFast, N023_ZoneMASlow, N023_ZoneMASignal, 2, 1);
   if (curr_zone == 0){
      zoneCount = 0;
      zoneTime = 0;
      return(0);
   }
   
   int zone = 0;
   bool bl_exit = false;
   int i = 2;
   zoneCount = 1;
   zoneTime = iTime(NULL, Signal_TimeFrame, 1);
   while (!bl_exit){
      zone = iCustom(NULL, Signal_TimeFrame, "SAN_AOACZone", N023_ZoneMAFast, N023_ZoneMASlow, N023_ZoneMASignal, 2, i);   
      if (zone == curr_zone){
         zoneCount++;
         zoneTime = iTime(NULL, Signal_TimeFrame, i);  
      }else{
         bl_exit = true;  
         zoneCount++;
         zoneTime = iTime(NULL, Signal_TimeFrame, i);               
      }
      i++;
   }
   return(curr_zone);
}


/*
void N023_Stop_Process(int settID){   
   
   int TradeType = 0;
   double levelStop = 0;
   

   for(int i = 0; i < OrdersTotal(); i++)
   {
      //-------------------------------------------------------------
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
      if( Magic_GetSettingsID(OrderMagicNumber()) != settID ) continue;
      //-------------------------------------------------------------
      
      TradeType = OrderType_GetDirection(OrderType());     
      
      //-------------------------------------------------------------------------------------------                            
      
      levelStop = N023_STOP_LOHI(TradeType, Signal_TimeFrame, 1, -8*DigMode());
      
      if (
          TradeType*(NormalizeDouble(levelStop, Digits) -  
                     NormalizeDouble(OrderStopLoss(), Digits)) > 0
         )
      {                                    
         //промяна на стопа
         if (OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(levelStop, Digits), OrderTakeProfit(), 0, SAN_Stop_Color)){      
            if (SAN_Stop_Sound) PlaySound(SAN_Stop_FileSound); 
         }else{
            SAN_Stop_GetLastError("[SAN_Stop_Process()] :: " +
               "Ticket = " + OrderTicket() + 
               ", OpenPrice = " +OrderOpenPrice() + 
               ", NewStop = " + NormalizeDouble(levelStop, Digits) +  
               ", OldStop = " + NormalizeDouble(OrderStopLoss(), Digits),
               GetLastError());               
         }       
      
      }       
   } 
}

double N023_GetInitialStop(int settID, int zoneSignal){   
   
   double result = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      //-------------------------------------------------------------
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
      if( Magic_GetSettingsID(OrderMagicNumber()) != settID ) continue;
      //-------------------------------------------------------------
            
      if (zoneSignal == OrderType_GetDirection(OrderType())){
         result = OrderStopLoss();
         break;
      }             
   } 
   if (result == 0){
      result = N023_STOP_LOHI(zoneSignal, Signal_TimeFrame, 1, 0);   
   }
   return(NormalizeDouble(result, Digits));
}

double N023_STOP_LOHI(int TradeType, int timeFrame, double Param1, double Param2){
   //връща ниво примерно: 1.3450
   double result = 0;   
   double levelStop = 0;   
  
   //Изискава параметър указващ броя барове които ще се проверят за най-малка/висока стойност     
   if(TradeType > 0)
      levelStop = iLow(NULL, timeFrame, iLowest(NULL, timeFrame, MODE_LOW, Param1, 1));
   else   
      levelStop = iHigh(NULL, timeFrame, iHighest(NULL, timeFrame, MODE_HIGH, Param1, 1)) + SAN_Broker_Spread_Pips()*Point;
      
   levelStop = levelStop + TradeType*Param2*Point;                                                                          
   return(levelStop);
}
//*/