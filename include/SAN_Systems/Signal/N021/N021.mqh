
bool N021_Signal_Trace = false;


void N021_Signals_Init(int settID)
{ 
 
}

void N021_Signals_PreProcess(int settID)
{ 
}

void N021_Signals_Process(int settID)
{ 
   
   N021_Signals_PreProcess(settID);
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;   
       
     
   //�������� �� �������� ���� �� ����� ������ ���������
   //���� � ���-������� ������ ���� ����� �� ������
   if (Period() > Signal_TimeFrame){         
      Print("������: ", SignalBaseName ," ������ �� ������ ���� ��-����� ��� ����� �� " + Signal_TimeFrame);
      return;
   }                 
   Common_Stop_ProcessAll(settID);

   //------------------------------------������� ������ �� ������� �� ���������----------------------
   //������� �����, ��������� ������ ���� � ��������� ������ �� ������ ���� ����
   // ��� � 0 - 24 ������ ���� ����� ���
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;
   //------------------------------------------------------------------------------------------------

   //-------------------------------���������� ������� �� ����----------------------------------------   
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
      N021_Signals_Create(settID, signalTypes, signalTimes, signalLevels); 
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   N021_Close_RemoveOrders(settID);
   
   if (OpenOrders_GetCount(settID) > 0){ 
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }    
   if (OpenOrders_GetCountForType(settID, OP_BUY) > 0) PendingOrders_RemoveByDir(settID, -1);
   if (OpenOrders_GetCountForType(settID, OP_SELL) > 0) PendingOrders_RemoveByDir(settID, 1);          
}

   

void N021_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
   int trend = iCustom(NULL, Signal_TimeFrame, "SAN_IchimokuSignal", N021_TenkanSen, N021_KijinSen, N021_SencouSpanB, 0, 0, 1);
   //int trend = iCustom(NULL, Signal_TimeFrame, "SAN_AtrVolatility", N021_ST_AtdPeriod, N021_ST_Multiplier, 2, 1);
        
    
   
   double ma = iMA(NULL, Signal_TimeFrame, N021_MAExitPeriod, N021_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);
   
   double AO1 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N021_AOMAFast, N021_AOMASlow, 5, 0, 1);
   double AO2 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N021_AOMAFast, N021_AOMASlow, 5, 0, 2);
   double AO3 = iCustom(NULL, Signal_TimeFrame, "SAN_AO", N021_AOMAFast, N021_AOMASlow, 5, 0, 3);
   
   if (trend == 1){
      if (AO1 > 0 && AO2 > 0 && AO3 > 0  
         &&
         AO3 > AO2 && AO1 > AO2  
         &&
         iClose(NULL, Signal_TimeFrame, 1) > ma      
         ){
         signalTypes[0] = 1;
         signalLevels[0] = iHigh(NULL, Signal_TimeFrame, 1);
         signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);         
      }
   }
   
   if (trend == -1){
      if (AO1 < 0 && AO2 < 0 && AO3 < 0  
         &&
         AO3 < AO2 && AO1 < AO2  
         &&
         iClose(NULL, Signal_TimeFrame, 1) < ma
         ){
         signalTypes[1] = -1;
         signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);
         signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);         
      }
   }   
   
}

void N021_Close_RemoveOrders(int settID){
  
   double close = iClose(NULL, Signal_TimeFrame, 1);

   double ma = iMA(NULL, Signal_TimeFrame, N021_MAExitPeriod, N021_MAExitShift, MODE_SMMA, PRICE_MEDIAN, 1);
   
      
   if (close < ma) {
      Orders_CloseByType(settID, OP_BUY);
      //PendingOrders_RemoveByDir(settID, 1);
   }      
   if (close > ma) {
      Orders_CloseByType(settID, OP_SELL);     
      //PendingOrders_RemoveByDir(settID, -1);
   }      

}






