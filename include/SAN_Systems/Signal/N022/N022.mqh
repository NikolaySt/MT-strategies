
bool N022_Signal_Trace = false;


void N022_Signals_Init(int settID)
{ 
 
}

void N022_Signals_PreProcess(int settID)
{ 
}

void N022_Signals_Process(int settID)
{ 
   
   N022_Signals_PreProcess(settID);
   
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
      N022_Signals_Create(settID, signalTypes, signalTimes, signalLevels); 
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   N022_Close_RemoveOrders(settID);
   
   if (OpenOrders_GetCount(settID) > 0){ 
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }        
   if (OpenOrders_GetCountForType(settID, OP_BUY) > 0) PendingOrders_RemoveByDir(settID, -1);
   if (OpenOrders_GetCountForType(settID, OP_SELL) > 0) PendingOrders_RemoveByDir(settID, 1);      
}

   

void N022_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   int trend = iCustom(NULL, Signal_TimeFrame, "SAN_IchimokuSignal", N022_TenkanSen, N022_KijinSen, N022_SencouSpanB, 0, 0, 1);   
   
   double ma = iMA(NULL, Signal_TimeFrame, N022_MAExitPeriod, N022_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);
   
   double AC1 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N022_ACMAFast, N022_ACMASlow, N022_ACMASignal, 1, 1);
   double AC2 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N022_ACMAFast, N022_ACMASlow, N022_ACMASignal, 1, 2);
   double AC3 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N022_ACMAFast, N022_ACMASlow, N022_ACMASignal, 1, 3);
   double AC4 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N022_ACMAFast, N022_ACMASlow, N022_ACMASignal, 1, 4);
   double AC5 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N022_ACMAFast, N022_ACMASlow, N022_ACMASignal, 1, 5);
   
   if (trend == 1){
      //PendingOrders_RemoveByDir(settID, -1);
      
      if (
            (
            
               //--------------------Signal 1-----------------------------
               (
                  AC1 > 0 && AC2 > 0 && AC3 > 0  
                  &&
                  AC3 < AC4 
                  && 
                  AC2 > AC3 && AC1 > AC2
               )
               //---------------------------------------------------------
              
         
               ||
          
               //--------------------Signal 2-----------------------------
               (
                  AC1 < 0 && AC2 < 0 && AC3 < 0 && AC4 < 0
                  &&
                  AC4 < AC5 
                  && 
                  AC3 > AC4 && AC2 > AC3 && AC1 > AC2  
               )       
               //---------------------------------------------------------
               
         
               ||
    
               //--------------------Signal 3-----------------------------
               (
                  AC1 > 0 && AC2 < 0 && AC3 < 0
                  &&
                  AC3 < AC4 
                  && 
                  AC2 > AC3 && AC1 > AC2                  
               )            
               //---------------------------------------------------------
             
            )
         
            //&&         
            //iClose(NULL, Signal_TimeFrame, 1) > ma      
         ){
         signalTypes[0] = 1;
         signalLevels[0] = iHigh(NULL, Signal_TimeFrame, 1);
         signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);         
      }
      
   }
   
   
   //*
   
   
   if (trend == -1){
      //PendingOrders_RemoveByDir(settID, 1);
      //*
      if (
            (
            
               //--------------------Signal 1-----------------------------
               (
                  AC1 < 0 && AC2 < 0 && AC3 < 0  
                  &&
                  AC3 > AC4 
                  && 
                  AC2 < AC3 && AC1 < AC2
               )
               //---------------------------------------------------------
              
         
               ||
         
               //--------------------Signal 2-----------------------------
               (
                  AC1 > 0 && AC2 > 0 && AC3 > 0 && AC4 > 0
                  &&
                  AC4 > AC5 
                  && 
                  AC3 < AC4 && AC2 < AC3 && AC1 < AC2  
               )       
               //---------------------------------------------------------
              
         
               ||

               //--------------------Signal 3-----------------------------
               (
                  AC1 < 0 && AC2 > 0 && AC3 > 0
                  &&
                  AC3 > AC4 
                  && 
                  AC2 < AC3 && AC1 < AC2                  
               )            
               //---------------------------------------------------------
             
            )      
      
            //&&
            //iClose(NULL, Signal_TimeFrame, 1) < ma
         ){
         signalTypes[1] = -1;
         signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);
         signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);         
      }
      //*/
   }  
   //*/ 
   
}

void N022_Close_RemoveOrders(int settID){
  
   double close = iClose(NULL, Signal_TimeFrame, 1);

   double ma = iMA(NULL, Signal_TimeFrame, N022_MAExitPeriod, N022_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);
   
      
   if (close < ma) {
      Orders_CloseByType(settID, OP_BUY);
   }      
   if (close > ma) {
      Orders_CloseByType(settID, OP_SELL);     
   }      

}






