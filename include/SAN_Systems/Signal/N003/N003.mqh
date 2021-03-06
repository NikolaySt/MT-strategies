

void N003_Signals_Init(int settID)
{       
   N003_BarsCross_TimeFrame =  SAN_AUtl_TimeFrameFromStr(N003_BarsCross_TimeFrameS);
}

void N003_Signals_PreProcess(int settID)
{
  
}

void N003_Signals_Process(int settID)
{ 
      
   N003_Signals_PreProcess(settID);
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;
   
   if (N003_FastPeriod >= N003_SlowPeriod) return;
     
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
      N003_Signals_Create(settID, signalType, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }
  
   
   Common_Orders_ProcessAll(settID, signalType, signalTimes, signalLevels, ordersTickets);      
}

void N003_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){
                       
   int signal_shift;   
   int result = N003_SignalBarsCross(N003_BarsCross_TimeFrame, N003_FastPeriod, N003_SlowPeriod, N003_BarsCross_BackBar, signal_shift);
   
   double ma = iMA(NULL, Signal_TimeFrame, N003_MAPeriod, 0, MODE_SMMA, PRICE_MEDIAN, 1);                         
   double close = iClose(NULL, Signal_TimeFrame, 1);
   
   double LoHi = 0;
   if (result == 1) 
      LoHi = iLow(NULL, Signal_TimeFrame, 1); 
   else 
      LoHi = iHigh(NULL, Signal_TimeFrame, 1);   
   
   if (  
       (( result*(close - ma) >= 0  && result*(LoHi - ma) <= 0 ) || N003_MAPeriod == 0)   
       && 
       (CloseHiLo(result, Signal_TimeFrame, N003_Bars_Break, 1, 1) || N003_Bars_Break == 0)            
       && 
       (result*(close - TrendLineLevelTwoPoint(result, Signal_TimeFrame, 3, 1, 3, false, false)) > 0 || N003_ActiveTL == 0) 
       && 
       (result == 1 || result == -1)  
      ){     
         
      signalTypes[0] = result;  
      signalTimes[0] = iTime(NULL, N003_BarsCross_TimeFrame, signal_shift);      
   }      

   
}

int N003_SignalBarsCross(int TimeFrame, int FastPeriod, int SlowPeriod, int CountBackBar, int& signal_shift){               
   int signal = 0;
   signal_shift = 0;      
   for(int i = 1; i <= CountBackBar; i++){
      if (  
          iClose(NULL, TimeFrame, i) < iClose(NULL, TimeFrame, i + FastPeriod)    
          && iClose(NULL, TimeFrame, i) > iClose(NULL, TimeFrame, i + SlowPeriod)
         ){     
         signal_shift = i;
         signal = 1;
         break;
      }      
      if (  
          iClose(NULL, TimeFrame, i) > iClose(NULL, TimeFrame, i + FastPeriod)    
          && iClose(NULL, TimeFrame, i) < iClose(NULL, TimeFrame, i + SlowPeriod)                                 
         ){  
         signal_shift = i;          
         signal = -1;
         break;
      } 
   }
     
   return(signal);
}