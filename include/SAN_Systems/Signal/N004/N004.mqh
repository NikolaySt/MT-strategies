
bool N004_Signal_Trace = false;

void N004_Signals_Init(int settID)
{           
}

void N004_Signals_PreProcess(int settID)
{  
}

void N004_Signals_Process(int settID)
{ 
   
   N004_Signals_PreProcess(settID);
     
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
   int signalType[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersMagic[2];
   int ordersTickets[2];
 
   ArrayInitialize(signalType,0);
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(ordersMagic,0);
   ArrayInitialize(ordersTickets,0);

   //----------------------------------------------------------------------------------------------------------------------
   if (Common_Signals_IsActive()){
      N004_Signals_Create(settID, signalType, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }
  
   if (OpenOrders_GetCount(settID) > 0){
      Common_Orders_CloseRemove(settID, signalType, signalLevels);      
   }       
   
   Common_Orders_ProcessAll(settID, signalType, signalTimes, signalLevels, ordersTickets);      
}

void N004_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){    
   double signal = N004_MASignalAlert(Signal_TimeFrame, 1, N004_MAPeriod);
   double trend_1, trend_2; 
   if (N004_ST_AtdPeriod > 0) trend_1 = iCustom(NULL, Signal_TimeFrame, "SAN_AtrVolatility", N004_ST_AtdPeriod, N004_ST_Multiplier, 2, 1);
   if (N004_BiasPeriod > 0)   trend_2 = iCustom(NULL, Signal_TimeFrame, "SAN_Bias", N004_BiasPeriod, 1, 1);            
        
   if (  (signal == -1 || signal == 1 )&& 
         (N004_ST_AtdPeriod == 0 || trend_1 == signal) && 
         (N004_BiasPeriod == 0 || trend_2 == signal) &&          
         (N004_CountCloseExtremumBar == 0 || CloseHiLo(signal, Signal_TimeFrame, N004_CountCloseExtremumBar, 2, 1))  
       ){                           
      signalTypes[0] = signal;
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);                  
   }       
}

int N004_MASignalAlert(int timeframe, int shift, int TPeriod = 34, int TType = MODE_LWMA, int TPrice = PRICE_CLOSE, int TShift = 0) {
   double ma_0 = iMA(NULL, timeframe, TPeriod, TShift, TType, TPrice, shift);
   double ma_1 = iMA(NULL, timeframe, TPeriod, TShift, TType, TPrice, shift+1);
   double ma_2 = iMA(NULL, timeframe, TPeriod, TShift, TType, TPrice, shift+2);            
   double result = 0;
   if (ma_0 < ma_1 && ma_1 > ma_2) result = -1;
   else if (ma_0 > ma_1 && ma_1 < ma_2) result = 1;   
   return (result);
}