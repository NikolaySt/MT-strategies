
bool N011_Signal_Trace = false;


void N011_Signals_Init(int settID)
{ 
   N011_BollRangeMinPips = N011_BollRangeMinPips*DigMode();
   N011_PrevBreak = N011_PrevBreak*DigMode();
}

void N011_Signals_PreProcess(int settID)
{ 
}

void N011_Signals_Process(int settID)
{ 
   
   N011_Signals_PreProcess(settID);
     
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
   //int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   //if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;
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
      N011_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }            
        
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);         
   
   if (OpenOrders_GetCount(settID) > 0){
      N011_CloseOrders(settID);
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }   
}

   

void N011_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){                  
   //������� �����, ��������� ������ ���� � ��������� ������ �� ������ ���� ����
   //��� � 0 - 24 ������ ���� ����� ���
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= N011_BeginHour && hour <= N011_EndHour)) return;
      
   double PrevHigh = iHigh(NULL, Signal_TimeFrame, 1);
   double PrevLow = iLow(NULL, Signal_TimeFrame, 1); 
   double BollHigh = iBands(NULL, Signal_TimeFrame, N011_BollPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double BollLow = iBands(NULL, Signal_TimeFrame, N011_BollPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
   
   if (N011_Signal_Trace) {
      Print(
           "[N011_Signals_Create] :: ",		  
		       " BollHigh = ", BollHigh, 
		       ", BollLow = ", BollLow, 
		       ", PrevLow = ", PrevLow, 
		       ", PrevHigh = ", PrevHigh,
		       ", N011_PrevBreak = ", N011_PrevBreak,
		       ", condition1_buy = ", (BollHigh - BollLow) >= N011_BollRangeMinPips*Point,
	          ", condition2_buy = ", PrevLow < BollLow - N011_PrevBreak*Point,
		       ", condition1_sell = ", (BollHigh - BollLow) >= N011_BollRangeMinPips*Point,
	          ", condition2_sell = ", PrevHigh > BollHigh + N011_PrevBreak*Point
           );
   }
      
   if (                                      
	    	 (BollHigh - BollLow) >= N011_BollRangeMinPips*Point &&
          PrevLow < BollLow - N011_PrevBreak*Point	
       ){    
                 
      signalTypes[0] = 1;
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);                                           
   }
   
   if (    		      
	    	 (BollHigh - BollLow) >= N011_BollRangeMinPips*Point &&
          PrevHigh > BollHigh + N011_PrevBreak*Point
       ){         
      signalTypes[1] = -1;
      signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);             
   }
}

void N011_CloseOrders(int settID){   
}





