
bool N008_Signal_Trace = false;

void N008_Signals_Init(int settID)
{ 

}

void N008_Signals_PreProcess(int settID)
{ 
}

void N008_Signals_Process(int settID)
{ 
   
   N008_Signals_PreProcess(settID);
     
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
   int ordersMagic[2];
   int ordersTickets[2];
 
   ArrayInitialize(signalTypes,0);
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(ordersMagic,0);
   ArrayInitialize(ordersTickets,0);

   //----------------------------------------------------------------------------------------------------------------------
      
   
   if (Common_Signals_IsActive()){
      N008_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   if (OpenOrders_GetCount(settID) > 0){
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }   
}

void N008_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   
   double band_up = iBands(NULL, Signal_TimeFrame, N008_BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double band_low = iBands(NULL, Signal_TimeFrame, N008_BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);   
   datetime time;
   
   
   if (
         iHigh(NULL, Signal_TimeFrame, 1) > band_low && iLow(NULL, Signal_TimeFrame, 1) < band_low
         
      ) 
      
   {  
      double fr_down = SearchFractalInPeriod(-1, Signal_TimeFrame, N008_FractalBars, N008_BackBars, time);      
      if (fr_down > 0 && (iHigh(NULL, Signal_TimeFrame, 1) > fr_down && iLow(NULL, Signal_TimeFrame, 1) < fr_down)
          && iClose(NULL, Signal_TimeFrame, 1) > fr_down
         ){
         signalTypes[0] = 1;                    
         signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);                
      }
   }    
   
   if (   
         iHigh(NULL, Signal_TimeFrame, 1) > band_up && iLow(NULL, Signal_TimeFrame, 1) < band_up
         
      ){      
      double fr_up = SearchFractalInPeriod(1, Signal_TimeFrame, N008_FractalBars, N008_BackBars, time);
      if (fr_up > 0 && (iHigh(NULL, Signal_TimeFrame, 1) > fr_up && iLow(NULL, Signal_TimeFrame, 1) < fr_up)
         && iClose(NULL, Signal_TimeFrame, 1) < fr_down
         ){
         signalTypes[1] = -1;                    
         signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);                      
      }
   }      
}





