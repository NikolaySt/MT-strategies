
bool N006_Signal_Trace = false;

void N006_Signals_Init(int settID)
{ 
   //* dymanic mappings   
   N006_ZZTimeFrame = SAN_AUtl_TimeFrameFromStr(N006_ZZTimeFrameS);   
   int paramsSize = 1;
   double params[1]; ArrayInitialize(params, 0.0);        
   params[0] = N006_ZZDepth;   
   N006_ZZIndex = ZZGetIndexForParamsOrCreate(N006_ZZTimeFrame, params, paramsSize, "SAN_A_ZigZag");            
   //*/
}

void N006_Signals_PreProcess(int settID)
{ 
}

void N006_Signals_Process(int settID)
{ 
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;   
   
   N006_Signals_PreProcess(settID);
     
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
      N006_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }      
   
   //if (IsOpenOrder(MAGIC)){
      //Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   //}   

   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);      
}

void N006_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   //*
   int trend = TA001_Trend_GetByIndex(settID, 0);   
   
   //сигнал
   double level_1 = ZZValues_Get(N006_ZZIndex, 1);  
   double level_2 = ZZValues_Get(N006_ZZIndex, 2);  
   
   double length_1 = N006_GetLenghtByIndex(settID, 1);  
   double length_2 = N006_GetLenghtByIndex(settID, 2);
   double ratio = length_1/length_2;   
   //*/
   if (N006_Signal_Trace){
      Print("[N006_Signals_Create] ", 
         " level_1 = ", level_1, 
         "; level_2 = ", level_2, 
         "; length_1 = ", length_1, 
         "; length_2 = ", length_2, 
         "; ratio = ", ratio,   
         "; trend = ", trend,   
         "; N006_sell_level = ", N006_sell_level,
         "; N006_buy_level = ", N006_buy_level
         );
   }
   //------------------------------------------SELL SIGNAL----------------------------------------------
   if (level_1 < level_2 && (trend == 1 || TA001_ExtDepth == 0)){
      if (
            iClose(NULL, Signal_TimeFrame, 1) > level_2
            &&               
            iLow(NULL, Signal_TimeFrame, 1) < level_2
            &&
            N006_sell_level == 0
            &&
            (N006_RatioFilter == 0 || (ratio > N006_RatioFilter))
         ){            
            N006_sell_level = iLow(NULL, Signal_TimeFrame, 1);                        
            if (N006_Signal_Trace)  Print("[N006_Signals_Create] ", " N006_sell_level = ", N006_sell_level );
         }                  
   }else{
      N006_sell_level = 0;   
   }
   
   if (N006_sell_level != 0){
      if (
         iClose(NULL, Signal_TimeFrame, 1)< N006_sell_level          
         && (N006_BarsOffset == 0 || iClose(NULL, Signal_TimeFrame, 1) < iClose(NULL, Signal_TimeFrame, 1+N006_BarsOffset))
         
         ){         
            signalTypes[0] = -1;
            signalTimes[0] = ZZTimes_Get(N006_ZZIndex, 2);
            if (N006_Signal_Trace) Print("[N006_Signals_Create] ", " signalTypes = SELL; Time = ", TimeToStr(signalTimes[0]));
      }
   }    
   //----------------------------------------------------------------------------------------------- 
   
   //------------------------------------------BUY SIGNAL----------------------------------------------
   if (level_1 > level_2 && (trend == -1 || TA001_ExtDepth == 0)){      
      if (
            iClose(NULL, Signal_TimeFrame, 1) < level_2
            &&               
            iHigh(NULL, Signal_TimeFrame, 1) > level_2              
            &&
            N006_sell_level == 0 
            &&
            (N006_RatioFilter == 0 || (ratio > N006_RatioFilter))                       
         ){                                   
            N006_buy_level =  iHigh(NULL, Signal_TimeFrame, 1);                      
            if (N006_Signal_Trace)  Print("[N006_Signals_Create] ", " N006_buy_level = ", N006_buy_level );
         }                         
   }else{
      N006_buy_level = 0;   
   }
   if (N006_buy_level != 0){
      if (
            iClose(NULL, Signal_TimeFrame, 1) > N006_buy_level  
            && (N006_BarsOffset == 0 || iClose(NULL, Signal_TimeFrame, 1) > iClose(NULL, Signal_TimeFrame, 1+N006_BarsOffset))
          ){            
               signalTypes[1] = 1;
               signalTimes[1] = ZZTimes_Get(N006_ZZIndex, 2);
               if (N006_Signal_Trace)  Print("[N006_Signals_Create] ", " signalTypes = BUY; Time = ", TimeToStr(signalTimes[1]));
      }
   } 
   //----------------------------------------------------------------------------------------------- 
}


int N006_GetLenghtByIndex(int settID, int index){
   double length = ZZValues_Get(N006_ZZIndex, index) - ZZValues_Get(N006_ZZIndex, index+1);
   return(MathAbs(length)/Point);   
}


