
bool N009_Signal_Trace = false;
 

void N009_Signals_Init(int settID)
{ 

}

void N009_Signals_PreProcess(int settID)
{ 
}

void N009_Signals_Process(int settID)
{ 
   
   N009_Signals_PreProcess(settID);
     
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
      N009_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   N009_RemovePendOrders(settID);
   
   if (OpenOrders_GetCount(settID) > 0){    
      N009_DeletePendOrders(settID); 
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }   
}

   

void N009_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){                      

   double p1, p2, range, SellPrice, BuyPrice;
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1));
   if (hour == N009_BeginTime){        
      
      p1 = iHigh(NULL, Signal_TimeFrame, iHighest(NULL, Signal_TimeFrame, MODE_HIGH, N009_BeginTime, 1));            
      p2 = iLow(NULL, Signal_TimeFrame, iLowest(NULL, Signal_TimeFrame, MODE_LOW, N009_BeginTime, 1));            
      
      range = iATR(NULL, PERIOD_D1, N009_AtrPeriodD1, 1); 

      SellPrice = p2 - range*N009_PercentOfOrder/100;
      BuyPrice  = p1 + range*N009_PercentOfOrder/100;  

      if (p1 - p2 < range*N009_PercentOfRange/100){   
         
         if (!(OpenOrders_GetCount(settID) > 0)){                            
               signalTypes[0] = 1;
               signalTimes[0] = iTime(NULL, PERIOD_D1, 0);
               signalLevels[0] = BuyPrice;
            
            
               signalTypes[1] = -1;
               signalTimes[1] = iTime(NULL, PERIOD_D1, 0);            
               signalLevels[1] = SellPrice;
            
         }
      }                    
                        
   }

         
   if (N009_Signal_Trace) {   
      Print("[N009_Signals_Create]: Date = ", TimeToStr(iTime(NULL, Signal_TimeFrame, 1)), ", Buy = ", 1, ", Sell = ", 1);
   }      
}


void N009_RemovePendOrders(int settID){     
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1));
   if (hour == N009_EndTime){       
      PendingOrders_RemoveBySigTime(settID, iTime(NULL, PERIOD_D1, 0));
   }                   
}

void N009_DeletePendOrders(int settID){
   PendingOrders_RemoveBySigTime(settID, iTime(NULL, PERIOD_D1, 0));
}





