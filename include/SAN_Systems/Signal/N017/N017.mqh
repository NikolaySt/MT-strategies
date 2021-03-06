bool N017_Signal_Trace = false;

void N017_Signals_Init(int settID)
{       
   N017_Ichimoku_TimeFrame = SAN_AUtl_TimeFrameFromStr(N017_Ichimoku_TimeFrameS);
   N017_SellCross  = 0;
   N017_BuyCross = 0;
   N017_TimeBuyCross = 0;
   N017_TimeSellCross = 0;   
}

void N017_Signals_PreProcess(int settID)
{
   
}

void N017_Signals_Process(int settID)
{    
   N017_Signals_PreProcess(settID);
   
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
   

   //----------------------------------------------------------------------------------------------------------------------
   if (Common_Signals_IsActive()){   
      N017_Signals_Create(settID, signalTypes, signalTimes, signalLevels, signalStops); 
   }else{
      Orders_Close(settID);
   }      
   
   N017_CloseOrders(settID);
   
   Common_Orders_ProcessEx(settID, signalTypes, signalTimes, signalLevels, signalLimits, signalStops, signalComments, ordersTickets);     
   
   if (OpenOrders_GetCountForType(settID, OP_BUY) > 0) PendingOrders_RemoveByDir(settID, -1);
   if (OpenOrders_GetCountForType(settID, OP_SELL) > 0) PendingOrders_RemoveByDir(settID, 1);   
}

void N017_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[], double& signalStops[]){           
   //cross buy
   if (N017_GetTenkanSen(1) > N017_GetKijunSen(1) &&  N017_GetTenkanSen(2) <= N017_GetKijunSen(2)){
      N017_BuyCross = 1;
      N017_TimeBuyCross = iTime(NULL, Signal_TimeFrame, 1); 
      N017_SellCross = 0;      
   }     
      
   if (  
      N017_BuyCross == 1
      &&
      N017_GetTenkanSen(1) > N017_GetKijunSen(1)
      &&
      iClose(NULL, Signal_TimeFrame, 1) > MathMax(N017_GetSenkouSpanB(1), N017_GetSenkouSpanA(1))
      &&
      N017_GetChinkouSpan(N017_KijinSen+1) > iHigh(NULL, Signal_TimeFrame, N017_KijinSen+1)
      &&
      N017_GetChinkouSpan(N017_KijinSen+1) > MathMax(N017_GetSenkouSpanB(N017_KijinSen+1), N017_GetSenkouSpanA(N017_KijinSen+1))
   ){
      //PendingOrders_RemoveByDir(settID, -1);
      Orders_CloseByType(settID, OP_SELL);
      signalTypes[0] = 1;
      signalLevels[0] = iHigh(NULL, Signal_TimeFrame, 1);
      signalTimes[0] = N017_TimeBuyCross;
   }
         
   //cross sell
   if (N017_GetTenkanSen(1) < N017_GetKijunSen(1) &&  N017_GetTenkanSen(2) >= N017_GetKijunSen(2)){
      N017_SellCross = 1;
      N017_TimeSellCross = iTime(NULL, Signal_TimeFrame, 1); 
      N017_BuyCross = 0;      
   }
   
   if (  
      N017_SellCross == 1
      &&
      N017_GetTenkanSen(1) < N017_GetKijunSen(1)
      &&
      iClose(NULL, Signal_TimeFrame, 1) < MathMin(N017_GetSenkouSpanB(1), N017_GetSenkouSpanA(1))
      &&
      N017_GetChinkouSpan(N017_KijinSen+1) < iLow(NULL, Signal_TimeFrame, N017_KijinSen+1)
      &&
      N017_GetChinkouSpan(N017_KijinSen+1) < MathMin(N017_GetSenkouSpanB(N017_KijinSen+1), N017_GetSenkouSpanA(N017_KijinSen+1)) 
   ){
      //PendingOrders_RemoveByDir(settID, 1);
      Orders_CloseByType(settID, OP_BUY);
      signalTypes[1] = -1;
      signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);
      signalTimes[1] = N017_TimeSellCross;
   }   
}

void N017_CloseOrders(int settID){   
   double close = iClose(NULL, Signal_TimeFrame, 1);

   //double line = N017_GetKijunSen(1);   
   
      
   if (close < MathMax(N017_GetSenkouSpanA(1) , N017_GetSenkouSpanB(1))) Orders_CloseByType(settID, OP_BUY);
   if (close > MathMin(N017_GetSenkouSpanA(1) , N017_GetSenkouSpanB(1))) Orders_CloseByType(settID, OP_SELL);     
}

double N017_GetTenkanSen(int shift)
{
   return (N017_Ichimoku_GetValue(MODE_TENKANSEN, shift));
}   

double N017_GetKijunSen(int shift)
{
   return (N017_Ichimoku_GetValue(MODE_KIJUNSEN, shift));
} 

double N017_GetSenkouSpanA(int shift)
{
   return (N017_Ichimoku_GetValue(MODE_SENKOUSPANA, shift));
}  

double N017_GetSenkouSpanB(int shift)
{
   return (N017_Ichimoku_GetValue(MODE_SENKOUSPANB, shift));
}   

double N017_GetChinkouSpan(int shift)
{
   return (N017_Ichimoku_GetValue(MODE_CHINKOUSPAN, shift));
}         

double N017_Ichimoku_GetValue(int mode, int shift)
{
   return (iIchimoku(NULL, N017_Ichimoku_TimeFrame, N017_TenkanSen, N017_KijinSen, N017_SencouSpanB, mode, shift ));
}


