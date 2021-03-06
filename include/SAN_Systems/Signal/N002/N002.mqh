

void N002_Signals_Init(int settID)
{       
   N002_MACrossTimeFrame = SAN_AUtl_TimeFrameFromStr(N002_MACrossTimeFrameS);

}

void N002_Signals_PreProcess(int settID)
{
   
}

void N002_Signals_Process(int settID)
{    
   N002_Signals_PreProcess(settID);
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;
   
   if (N002_FastPeriod >= N002_SlowPeriod) return;
        
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
      N002_Signals_Create(settID, signalType, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }
  
   if (OpenOrders_GetCount(settID) > 0){
      Common_Orders_CloseRemove(settID, signalType, signalLevels);      
   }       
   
   Common_Orders_ProcessAll(settID, signalType, signalTimes, signalLevels, ordersTickets);      
}

void N002_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){

   
   int result = N002_InternalCreateSignal(N002_MACrossTimeFrame, N002_FastPeriod, N002_SlowPeriod, N002_MACross_BackBar);         
   N002_Check(settID);
   //int result = N002_InternalExPoint(N002_MACrossTimeFrame, N002_FastPeriod, N002_SlowPeriod, N002_MACross_BackBar);
   
   double ma = iMA(NULL, Signal_TimeFrame, N002_MABreakPeriod, 0, MODE_SMMA, PRICE_MEDIAN, 1);                         
   double close = iClose(NULL, Signal_TimeFrame, 1);
   
   double LoHi = 0;
   if (result == 1) 
      LoHi = iLow(NULL, Signal_TimeFrame, 1); 
   else 
      LoHi = iHigh(NULL, Signal_TimeFrame, 1);   
   
   if (  
       (( result*(close - ma) >= 0  && result*(LoHi - ma) <= 0 ) || N002_MABreakPeriod == 0)                   
       && 
       (CloseHiLo(result, Signal_TimeFrame, N002_Bars_Break, 3, 1) || N002_Bars_Break == 0)       
       //&& 
       //(result*(close - TrendLineLevelTwoPoint(result, Signal_TimeFrame, 3, 1, 3, false, false)) > 0 || N002_ActiveTL == 0) 
       && 
       (result == 1 || result == -1)
      ){                      
         signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);
         signalTypes[0] = result;                  
         N002_Signal_Result = 0;
   } 
     
}

int N002_CrossClose(int dir, int TimeFrame, int FastPeriod, int SlowPeriod, int shift){
   
   double ma_slow = iMA(NULL, TimeFrame, SlowPeriod, 0, MODE_SMA, PRICE_CLOSE, shift);
   double ma_fast = iMA(NULL, TimeFrame, FastPeriod, 0, MODE_SMA, PRICE_CLOSE, shift);    
   if (  
       dir*(ma_slow - ma_fast) > 0 
       &&  
       dir*(iClose(NULL, TimeFrame, shift) - iClose(NULL, TimeFrame, shift + FastPeriod)) < 0
       && 
       dir*(iClose(NULL, TimeFrame, shift) - iClose(NULL, TimeFrame, shift + FastPeriod + SlowPeriod)) > 0
      ){
      return(dir);
   }
   return(0);
}

int N002_InternalCreateSignal(int TimeFrame, int FastPeriod, int SlowPeriod, int Count){                     
   if (N002_CrossClose(1,  TimeFrame, FastPeriod, SlowPeriod, 1) == 1)   {
      N002_Signal_Result = 1;
   }else{
      if (N002_CrossClose(-1, TimeFrame, FastPeriod, SlowPeriod, 1) == -1)  {
         N002_Signal_Result = -1;
      }   
   }
   SetText(iLow(NULL, TimeFrame,1)-50*Point, iTime(NULL, TimeFrame, 1), N002_Signal_Result, Lime);  
   return(N002_Signal_Result);      
}

/*

int N002_InternalExPoint(int TimeFrame, int FastPeriod, int SlowPeriod, int Count){                     
   int value = 0;
   int i = 1;
   while (value == 0 && i < 200){
      if (N002_CrossClose(1,  TimeFrame, FastPeriod, SlowPeriod, i) == 1)   {
         value = 1;
      }
      if (N002_CrossClose(-1, TimeFrame, FastPeriod, SlowPeriod, i) == -1)  {
         value = -1;
      }
      i++;  
   }   
   SetText(iHigh(NULL, TimeFrame, 1)+50*Point, iTime(NULL, TimeFrame, 1), value, White);        
   return(value);
}


*/
//-----------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------
int N002_Result = 0;
int N002_inc_view_test = 0;

int N002_Check(int settID){
   int shift_h4;
   //ObjectsDeleteAll();
   N002_Result = 0;
   for(int i = 400; i > 0; i--){
      N002_Signals_BackCheck(settID, i);
   }
   return(0);
   //return(N002_Signal_Result);
}

void N002_Signals_BackCheck(int settID, int shift_h1){  
   int shift_h4 = iBarShift(NULL, N002_MACrossTimeFrame, iTime(NULL, Signal_TimeFrame, shift_h1))+1;    
     
   N002_CreateSignal_backcheck(N002_MACrossTimeFrame, N002_FastPeriod, N002_SlowPeriod, N002_MACross_BackBar, shift_h4);
   
   double ma = iMA(NULL, Signal_TimeFrame, N002_MABreakPeriod, 0, MODE_SMMA, PRICE_MEDIAN, 1+shift_h1);                         
   double close = iClose(NULL, Signal_TimeFrame, 1+shift_h1);
   
   double LoHi = 0;
   if (N002_Result == 1) 
      LoHi = iLow(NULL, Signal_TimeFrame, 1+shift_h1); 
   else 
      LoHi = iHigh(NULL, Signal_TimeFrame, 1+shift_h1);   
   
   if (  
       (( N002_Result*(close - ma) >= 0  && N002_Result*(LoHi - ma) <= 0 ) || N002_MABreakPeriod == 0)                   
       && 
       (CloseHiLo(N002_Result, Signal_TimeFrame, N002_Bars_Break, 3, 1+shift_h1) || N002_Bars_Break == 0)       
       //&& 
       //(N002_Result*(close - TrendLineLevelTwoPoint(N002_Result, Signal_TimeFrame, 3, shift_h1, 3, false, true)) > 0 || N002_ActiveTL == 0) 
       && 
       (N002_Result == 1 || N002_Result == -1)
      ){                                      
         
         if (N002_Result == 1)
            SetText(iOpen(NULL, Signal_TimeFrame, shift_h1)+100*Point, iTime(NULL, Signal_TimeFrame, shift_h1), "BUY", Lime);        
         else  
            SetText(iOpen(NULL, Signal_TimeFrame, shift_h1)+100*Point, iTime(NULL, Signal_TimeFrame, shift_h1), "SELL", Red);        
            
         N002_Result = 0;   
   }   
   
}

int N002_CrossCloseEx(int dir, int TimeFrame, int FastPeriod, int SlowPeriod, int shift){
   
   double ma_slow = iMA(NULL, TimeFrame, SlowPeriod, 0, MODE_SMA, PRICE_CLOSE, shift);
   double ma_fast = iMA(NULL, TimeFrame, FastPeriod, 0, MODE_SMA, PRICE_CLOSE, shift);    
   if (  
       dir*(ma_slow - ma_fast) > 0 
       &&  
       dir*(iClose(NULL, TimeFrame, shift) - iClose(NULL, TimeFrame, shift + FastPeriod)) < 0
       && 
       dir*(iClose(NULL, TimeFrame, shift) - iClose(NULL, TimeFrame, shift + FastPeriod + SlowPeriod)) > 0
      ){
      //SetText(iOpen(NULL, TimeFrame, shift)+100*Point, iTime(NULL, TimeFrame, shift), dir, White);                 
      return(dir);
   }
   //SetText(iOpen(NULL, TimeFrame, shift)+100*Point, iTime(NULL, TimeFrame, shift), "0", White);                 
   return(0);
}

int N002_CreateSignal_backcheck(int TimeFrame, int FastPeriod, int SlowPeriod, int Count, int index){                     
   if (N002_CrossCloseEx(1,  TimeFrame, FastPeriod, SlowPeriod, index) == 1)   {
      N002_Result = 1;
   }
   if (N002_CrossCloseEx(-1, TimeFrame, FastPeriod, SlowPeriod, index) == -1)  {
      N002_Result = -1;
   }   
   
   SetText(iOpen(NULL, TimeFrame, index)+100*Point, iTime(NULL, TimeFrame, index), N002_Result, Yellow);        
   //SetText(iOpen(NULL, TimeFrame, index)+150*Point, iTime(NULL, TimeFrame, index), TimeToStr(iTime(NULL, TimeFrame, index)), DeepSkyBlue);        
   return(N002_Result);      
}