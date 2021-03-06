
bool N005_Signal_Trace = false;

void N005_Signals_Init(int settID)
{
}

void N005_Signals_PreProcess(int settID)
{  
}

void N005_Signals_Process(int settID)
{ 
   
   N005_Signals_PreProcess(settID);
     
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
   //int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   //if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;
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
      N005_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }      
   
   if (OpenOrders_GetCount(settID) > 0){
      N005_CloseOrders(settID);
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }   

   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);      
}

void N005_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){    
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;

   if (N005_SignalBars(settID, 1) == 1){
      signalTypes[0] = 1;
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);    
   }   
   if (N005_SignalBars(settID, -1) == -1){
      signalTypes[1] = -1;
      signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);       
   }
    
}

int N005_SignalBars(int settID, int Dir){
      if (
         (N005_CountCloseExtremumBar == 0 || CloseHiLo(Dir, Signal_TimeFrame, N005_CountCloseExtremumBar, 2, 1))    
         && Dir*(iClose(NULL, PERIOD_D1, 1) - iOpen(NULL, PERIOD_D1, 1+N005_BackBarsD1)) > 0
       )
         return(Dir);
      else{
         return(0);
      }         
}

void N005_CloseOrders(int settID){   
   if (N005_ExtremumBars_Close > 0){
      if ( CloseHiLo(-1, Signal_TimeFrame, N005_ExtremumBars_Close, 2, 1) ) Orders_CloseByType(settID, OP_BUY);  
      if ( CloseHiLo(1, Signal_TimeFrame, N005_ExtremumBars_Close, 2, 1) ) Orders_CloseByType(settID, OP_SELL);  
   }
}




