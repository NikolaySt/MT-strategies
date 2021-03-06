
bool N019_Signal_Trace = false;


void N019_Signals_Init(int settID)
{ 
 
}

void N019_Signals_PreProcess(int settID)
{ 
}

void N019_Signals_Process(int settID)
{ 
   
   N019_Signals_PreProcess(settID);
   
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
   int ordersMagic[2];
   int ordersTickets[2];
 
   ArrayInitialize(signalTypes,0);
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(ordersMagic,0);
   ArrayInitialize(ordersTickets,0);

   //----------------------------------------------------------------------------------------------------------------------
      
   
   if (Common_Signals_IsActive()){   
      N019_Signals_Create(settID, signalTypes, signalTimes, signalLevels); 
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   N019_Close_RemoveOrders(settID);
   
   if (OpenOrders_GetCount(settID) > 0){ 
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }        
   if (OpenOrders_GetCountForType(settID, OP_BUY) > 0) PendingOrders_RemoveByDir(settID, -1);
   if (OpenOrders_GetCountForType(settID, OP_SELL) > 0) PendingOrders_RemoveByDir(settID, 1);   
}

   

void N019_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   int trend = iCustom(NULL, Signal_TimeFrame, "SAN_IchimokuSignal", N019_TenkanSen, N019_KijinSen, N019_SencouSpanB, 0, 0, 1);
   
   double stoch_1 = iStochastic(NULL, Signal_TimeFrame, N019_StochK, 1, N019_StochSlow, MODE_SMA, 0, MODE_MAIN, 1);
   double stoch_2 = iStochastic(NULL, Signal_TimeFrame, N019_StochK, 1, N019_StochSlow, MODE_SMA, 0, MODE_MAIN, 2);
   double stoch_3 = iStochastic(NULL, Signal_TimeFrame, N019_StochK, 1, N019_StochSlow, MODE_SMA, 0, MODE_MAIN, 3);
   
   
   double ma = iMA(NULL, Signal_TimeFrame, N019_MAExitPeriod, N019_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);
   if (trend == 1){
      if (stoch_1 > stoch_2 && stoch_3 > stoch_2  
         &&
         N019_MathMin(stoch_1, stoch_2, stoch_3) < 80
         &&
         iClose(NULL, Signal_TimeFrame, 1) > ma      
         ){
         signalTypes[0] = 1;
         signalLevels[0] = iHigh(NULL, Signal_TimeFrame, 1);
         signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);         
      }
   }
   
   if (trend == -1){
      if (stoch_1 < stoch_2 && stoch_3 < stoch_2
         &&
         N019_MathMax(stoch_1, stoch_2, stoch_3) > 20
         &&
         iClose(NULL, Signal_TimeFrame, 1) < ma
         ){
         signalTypes[1] = -1;
         signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);
         signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);         
      }
   }   
   
}

double N019_MathMin(double val1, double val2, double val3){
   return(MathMin(val1, MathMin(val2, val3)));
}

double N019_MathMax(double val1, double val2, double val3){
   return(MathMax(val1, MathMax(val2, val3)));
}
void N019_Close_RemoveOrders(int settID){
  
   double close = iClose(NULL, Signal_TimeFrame, 1);

   double ma = iMA(NULL, Signal_TimeFrame, N019_MAExitPeriod, N019_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);
   
      
   if (close < ma) {
      Orders_CloseByType(settID, OP_BUY);
      //PendingOrders_RemoveByDir(settID, 1);
   }      
   if (close > ma) {
      Orders_CloseByType(settID, OP_SELL);     
      //PendingOrders_RemoveByDir(settID, -1);
   }      

}






