
bool N024_Signal_Trace = false;


void N024_Signals_Init(int settID)
{ 
 
}

void N024_Signals_PreProcess(int settID)
{ 
}

void N024_Signals_Process(int settID)
{ 
   
   N024_Signals_PreProcess(settID);
   
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
      N024_Signals_Create(settID, signalTypes, signalTimes, signalLevels); 
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   N024_Orders_CloseRemove(settID);
   
   if (OpenOrders_GetCount(settID) > 0){ 
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }        
}

   

void N024_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   
   double rsi_1 = iCustom(NULL, Signal_TimeFrame, "SAN_RSIMA", N024_RSIPeriod, N024_MAPeriod, 0, 1);
   double rsi_2 = iCustom(NULL, Signal_TimeFrame, "SAN_RSIMA", N024_RSIPeriod, N024_MAPeriod, 0, 2);

   double ma_1 = iCustom(NULL, Signal_TimeFrame, "SAN_RSIMA", N024_RSIPeriod, N024_MAPeriod, 1, 1);
   double ma_2 = iCustom(NULL, Signal_TimeFrame, "SAN_RSIMA", N024_RSIPeriod, N024_MAPeriod, 1, 2);      
   
      
   if (rsi_1 > ma_1 && rsi_2 < ma_2
      ){
      signalTypes[0] = 1;
      //signalLevels[0] = iHigh(NULL, Signal_TimeFrame, 1);
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);         
      Orders_CloseByType(settID, OP_SELL);
   }


   if (rsi_1 < ma_1 && rsi_2 > ma_2
      ){
      signalTypes[1] = -1;
      //signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);
      signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);         
      Orders_CloseByType(settID, OP_BUY);
   }
   
   
}

void N024_Orders_CloseRemove(int settID){  
 /*
   
   if (OpenOrders_GetCountForType(settID, OP_BUY) > 0) {
      PendingOrders_RemoveByDir(settID, -1);
       
   }   
      
   if (OpenOrders_GetCountForType(settID, OP_SELL) > 0) {
      PendingOrders_RemoveByDir(settID, 1);      
      
   }           
*/
}






