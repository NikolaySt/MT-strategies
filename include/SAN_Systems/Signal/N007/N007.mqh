
bool N007_Signal_Trace = false;

void N007_Signals_Init(int settID)
{ 
 
}

void N007_Signals_PreProcess(int settID)
{ 
}

void N007_Signals_Process(int settID)
{ 
   
   N007_Signals_PreProcess(settID);
     
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
      N007_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   if (OpenOrders_GetCount(settID) > 0){
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }   
}

void N007_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   
   double cci_1 = iCCI(NULL, Signal_TimeFrame, N007_CCIPeriod, PRICE_CLOSE, 1);
   double cci_2 = iCCI(NULL, Signal_TimeFrame, N007_CCIPeriod, PRICE_CLOSE, 2);
   double ma_1 = iMA(NULL, Signal_TimeFrame, N007_MAPeriod,0, MODE_SMA, PRICE_CLOSE, 1);
   double ma_2 = iMA(NULL, Signal_TimeFrame, N007_MAPeriod,0, MODE_SMA, PRICE_CLOSE, 2);
   
   if (  
         cci_1 > -100 && cci_2 < -100
         && iClose(NULL, Signal_TimeFrame, 1) > ma_1 && ma_1 > ma_2
         && CloseOverHighest(Signal_TimeFrame, N007_Bars_Break, 2)        
         //&& (N007_Bars_Break == 0 || CloseHiLo(1, Signal_TimeFrame, N007_Bars_Break, 2, 1))  
         && iClose(NULL, PERIOD_D1, 1) > iClose(NULL, PERIOD_D1, 1+N007_BackBarsD1) 
      ){     
         
      signalTypes[0] = 1;  
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);      
   }      
   if (  
         cci_1 < 100 && cci_2 > 100  
         && iClose(NULL, Signal_TimeFrame, 1) < ma_1 && ma_1 < ma_2
         && CloseUnderLowest(Signal_TimeFrame, N007_Bars_Break, 2)
         //&& (N007_Bars_Break == 0 || CloseHiLo(-1, Signal_TimeFrame, N007_Bars_Break, 2, 1))  
         && iClose(NULL, PERIOD_D1, 1) < iClose(NULL, PERIOD_D1, 1+N007_BackBarsD1)                      
      ){  
         
      signalTypes[1] = -1;                    
      signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);      
   } 
}





