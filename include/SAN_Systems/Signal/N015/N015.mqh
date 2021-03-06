bool N015_Signal_Trace = false;

void N015_Signals_Init(int settID)
{       
   N015_Ichimoku_TimeFrame = SAN_AUtl_TimeFrameFromStr(N015_Ichimoku_TimeFrameS);
   N015_SellCross  = 0;
   N015_BuyCross = 0;
   N015_TimeBuyCross = 0;
   N015_TimeSellCross = 0;   
}

void N015_Signals_PreProcess(int settID)
{
   
}

void N015_Signals_Process(int settID)
{    
   N015_Signals_PreProcess(settID);
   
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
      N015_Signals_Create(settID, signalTypes, signalTimes, signalLevels, signalStops); 
   }else{
      Orders_Close(settID);
   }      
   
   Common_Orders_ProcessEx(settID, signalTypes, signalTimes, signalLevels, signalLimits, signalStops, signalComments, ordersTickets);     
}

void N015_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[], double& signalStops[]){        
   
   //cross buy
   if (N015_GetTenkanSen(1) > N015_GetKijunSen(1) &&  N015_GetTenkanSen(2) <= N015_GetKijunSen(2)){
      N015_BuyCross = 1;
      N015_TimeBuyCross = iTime(NULL, Signal_TimeFrame, 1); 
      N015_SellCross = 0;      
   }
   
   if (  
      N015_BuyCross == 1
      &&
      N015_GetChinkouSpan(N015_KijinSen+1) > iHigh(NULL, Signal_TimeFrame, N015_KijinSen+1)
      &&
      N015_GetChinkouSpan(N015_KijinSen+1) > MathMax(N015_GetSenkouSpanB(N015_KijinSen+1), N015_GetSenkouSpanA(N015_KijinSen+1))
   ){
      signalTypes[0] = 1;
      signalLevels[0] = iHigh(NULL, Signal_TimeFrame, 1);
      signalTimes[0] = N015_TimeBuyCross;
   }
         
   //cross sell
   if (N015_GetTenkanSen(1) < N015_GetKijunSen(1) &&  N015_GetTenkanSen(2) >= N015_GetKijunSen(2)){
      N015_SellCross = 1;
      N015_TimeSellCross = iTime(NULL, Signal_TimeFrame, 1); 
      N015_BuyCross = 0;      
   }
      
   if (  
      N015_SellCross == 1
      &&
      N015_GetChinkouSpan(N015_KijinSen+1) < iLow(NULL, Signal_TimeFrame, N015_KijinSen+1)
      &&
      N015_GetChinkouSpan(N015_KijinSen+1) < MathMin(N015_GetSenkouSpanB(N015_KijinSen+1), N015_GetSenkouSpanA(N015_KijinSen+1)) 
   ){
      signalTypes[1] = -1;
      signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);
      signalTimes[1] = N015_TimeSellCross;
   }   
}

void N015_CloseOrders(int settID){   
}

double N015_GetTenkanSen(int shift)
{
   return (N015_Ichimoku_GetValue(MODE_TENKANSEN, shift));
}   

double N015_GetKijunSen(int shift)
{
   return (N015_Ichimoku_GetValue(MODE_KIJUNSEN, shift));
} 

double N015_GetSenkouSpanA(int shift)
{
   return (N015_Ichimoku_GetValue(MODE_SENKOUSPANA, shift));
}  

double N015_GetSenkouSpanB(int shift)
{
   return (N015_Ichimoku_GetValue(MODE_SENKOUSPANB, shift));
}   

double N015_GetChinkouSpan(int shift)
{
   return (N015_Ichimoku_GetValue(MODE_CHINKOUSPAN, shift));
}         

double N015_Ichimoku_GetValue(int mode, int shift)
{
   return (iIchimoku(NULL, N015_Ichimoku_TimeFrame, N015_TenkanSen, N015_KijinSen, N015_SencouSpanB, mode, shift ));
}




