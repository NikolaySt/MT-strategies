
bool N010_Signal_Trace = false;

 

void N010_Signals_Init(int settID)
{ 
 
}

void N010_Signals_PreProcess(int settID)
{ 
}

void N010_Signals_Process(int settID)
{ 
   
   N010_Signals_PreProcess(settID);
     
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
      N010_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   if (OpenOrders_GetCount(settID) > 0){
      N010_CloseOrders(settID);
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }   
}

   

void N010_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){             
      
       
   double high_peak_index = iHighest(NULL, Signal_TimeFrame, MODE_HIGH, N010_PeriodPeak, 2);
   double low_peak_index = iLowest(NULL, Signal_TimeFrame, MODE_LOW, N010_PeriodPeak, 2);
   
   if (               
       
       iHigh(NULL, Signal_TimeFrame, 1) > iHigh(NULL, Signal_TimeFrame, high_peak_index)
       && high_peak_index > N010_PeriodBackPeak
       
       //���� �� ���������� 2
       //&& iClose(NULL, Signal_TimeFrame, 1) > iHigh(NULL, Signal_TimeFrame, high_peak_index)
       ){               
      signalTypes[0] = -1;
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, high_peak_index);                  
      
      //���� �� ���������� 1
      signalLevels[0] = iHigh(NULL, Signal_TimeFrame, high_peak_index);
      
      //���� �� ���������� 2
      //signalLevels[1] = iLow(NULL, Signal_TimeFrame, 1);             
   }
   
   if (     
      iLow(NULL, Signal_TimeFrame, 1) < iLow(NULL, Signal_TimeFrame, low_peak_index)
      && low_peak_index > N010_PeriodBackPeak
      
      //���� �� ���������� 2
      //&& iClose(NULL, Signal_TimeFrame, 1) < iLow(NULL, Signal_TimeFrame, high_peak_index)
       ){         
      signalTypes[1] = 1;
      signalTimes[1] = iTime(NULL, Signal_TimeFrame, low_peak_index);     
      
      //���� �� ���������� 1
      signalLevels[1] = iLow(NULL, Signal_TimeFrame, low_peak_index);             
      
      //���� �� ���������� 2
      //signalLevels[1] = iHigh(NULL, Signal_TimeFrame, 1);             
   }
}

void N010_CloseOrders(int settID){   
                
}





