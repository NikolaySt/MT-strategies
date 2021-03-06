
bool N013_Signal_Trace = false;


void N013_Signals_Init(int settID)
{ 
   
}

void N013_Signals_PreProcess(int settID)
{ 
}

void N013_Signals_Process(int settID)
{ 
   
   N013_Signals_PreProcess(settID);
     
   //Проверка за часовото ниво на което работи системата
   //това е най-ниското часово ниво което се ползва
   if (Period() > Signal_TimeFrame){         
      Print("Грешка: ", SignalBaseName ," работи на часово ниво по-малко или равно от " + Signal_TimeFrame);
      return;
   }                 
   Common_Stop_ProcessAll(settID);
   //SN003_Stop_Process(settID);

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
      N013_Signals_Create(settID, signalTypes, signalTimes, signalLevels, signalStops);      
   }else{
      Orders_Close(settID);
   }            
        
   
   Common_Orders_ProcessEx(settID, signalTypes, signalTimes, signalLevels, signalLimits, signalStops, signalComments, ordersTickets);
   N013_RemovePendOrders(settID);         
}

   

void N013_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[], double& signalStops[]){                      

   double p1, p2, range, SellPrice, BuyPrice;
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1));
   if (hour == N013_BeginTime){        
      
      p1 = iHigh(NULL, Signal_TimeFrame, iHighest(NULL, Signal_TimeFrame, MODE_HIGH, N013_BeginTime, 1));            
      p2 = iLow(NULL, Signal_TimeFrame, iLowest(NULL, Signal_TimeFrame, MODE_LOW, N013_BeginTime, 1));            
      
      range = iATR(NULL, PERIOD_D1, N013_AtrPeriodD1, 1); 

      SellPrice = p2;
      BuyPrice  = p1;  

      if (p1 - p2 < range*N013_PercentOfRange/100){   
         
         if (!(OpenOrders_GetCount(settID) > 0)){                            
               signalTypes[0] = 1;
               signalTimes[0] = iTime(NULL, PERIOD_D1, 0);
               signalLevels[0] = BuyPrice;
               //signalStops[0] = SellPrice - Orders_PendingPipsOffset*Point; 
            
            
               signalTypes[1] = -1;
               signalTimes[1] = iTime(NULL, PERIOD_D1, 0);            
               signalLevels[1] = SellPrice;
               //signalStops[1] = BuyPrice + Orders_PendingPipsOffset*Point; 
            
         }
      }                    
                        
   }

         
   if (N013_Signal_Trace) {   
      Print("[N013_Signals_Create]: Date = ", TimeToStr(iTime(NULL, Signal_TimeFrame, 1)), ", Buy = ", 1, ", Sell = ", 1);
   }      
}


void N013_RemovePendOrders(int settID){     
  PendingOrders_RemoveBySigTime(settID, iTime(NULL, PERIOD_D1, 1));
   
  int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 0));
  if (hour < 2){                     
   Orders_Close(settID); 
  }
}




