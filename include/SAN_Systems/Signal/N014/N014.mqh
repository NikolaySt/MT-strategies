bool N014_Signal_Trace = false;



void N014_Signals_Init(int settID)
{       

}

void N014_Signals_PreProcess(int settID)
{
   
}

void N014_Signals_Process(int settID)
{    
   N014_Signals_PreProcess(settID);
   
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
      N014_Signals_Create(settID, signalType, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }
  
   if (OpenOrders_GetCount(settID) > 0){
      N014_CloseOrders(settID);
   }       
   
   Common_Orders_ProcessAll(settID, signalType, signalTimes, signalLevels, ordersTickets);      
}

void N014_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){

   
   double fast_ma1 = iMA(NULL, Signal_TimeFrame, N014_FastMAPeriod, 0, MODE_LWMA, PRICE_TYPICAL, 1);    
   double fast_ma2 = iMA(NULL, Signal_TimeFrame, N014_FastMAPeriod, 0, MODE_LWMA, PRICE_TYPICAL, 2);    
   
   double slow_ma1 = iMA(NULL, Signal_TimeFrame, N014_SlowMAPeriod, 0, MODE_LWMA, PRICE_TYPICAL, 1);    
   double slow_ma2 = iMA(NULL, Signal_TimeFrame, N014_SlowMAPeriod, 0, MODE_LWMA, PRICE_TYPICAL, 2);    
   
   
   double sar_1 = iSAR(NULL, Signal_TimeFrame, N014_SARStep, 1, 1);
   double sar_2 = iSAR(NULL, Signal_TimeFrame, N014_SARStep, 1, 2);
  
   //* 
   //variant 1
   //Проверка за кръстосване по МА---------------------------------------------
   if (fast_ma1 > slow_ma1 && fast_ma2 < slow_ma2 //cross
   ){
      N014_BuyCross = 1;
      N014_BuyCrossTime = iTime(NULL, Signal_TimeFrame, 1);
   }
   
   if (fast_ma1 < slow_ma1 && fast_ma2 > slow_ma2 
   ){
      N014_SellCross = 1;
      N014_SellCrossTime = iTime(NULL, Signal_TimeFrame, 1);
   }   
   //---------------------------------------------------------------------------   
   
   if (N014_BuyCross == 1 && fast_ma1 > slow_ma1
      &&
      sar_1 < iLow(NULL, Signal_TimeFrame, 1)   
      ){
      signalTypes[0] = 1;
      signalTimes[0] = N014_BuyCrossTime;
   }    
   
   if (N014_SellCross == 1 && fast_ma1 < slow_ma1
      &&
      sar_1 > iHigh(NULL, Signal_TimeFrame, 1)
   ){
      signalTypes[1] = -1;
      signalTimes[1] = N014_SellCrossTime;
   } 
   //*/         
}

void N014_CloseOrders(int settID){
   //*
   double sar_1 = iSAR(NULL, Signal_TimeFrame, N014_SARStep, 1, 1);
   if (sar_1 > iHigh(NULL, Signal_TimeFrame, 1)){
      Orders_CloseByType(settID, OP_BUY);
   }
   if (sar_1 < iLow(NULL, Signal_TimeFrame, 1)){
      Orders_CloseByType(settID, OP_SELL);
   }   
   //*/
   //*
   double stoch1 = iStochastic(NULL, Signal_TimeFrame, N014_StochK, 1, N014_StochSlow, MODE_EMA, 1, MODE_MAIN, 1);
   double stoch2 = iStochastic(NULL, Signal_TimeFrame, N014_StochK, 1, N014_StochSlow, MODE_EMA, 1, MODE_MAIN, 2);
   
   if (stoch1 >= 80) N014_Stoch80 = 1;   
   if (stoch1 <= 20) N014_Stoch20 = 1;   
   
   if (N014_Signal_Trace){
      Print(
         "time=",TimeToStr(Time[1]),
         ", stoch1=",stoch1,
         ", stoch2=",stoch2,
         ", N014_Stoch80=",N014_Stoch80,
         ", N014_Stoch20=",N014_Stoch20
      );
   }
   
   if (N014_Stoch80 && stoch1 < 60 && stoch2 > 60 //cross
       ){
      Orders_CloseByType(settID, OP_BUY);    
      N014_Stoch80 = 0; 
   }
      
   if (N014_Stoch20 && stoch1 > 40 && stoch2 < 40 //cross
       ){
      Orders_CloseByType(settID, OP_SELL);  
      N014_Stoch20 = 0;  
   }     
   //*/           
}




