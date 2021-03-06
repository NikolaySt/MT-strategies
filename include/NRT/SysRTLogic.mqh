void System_RT1_Init(){
   SAN_N_Systems_Init_Common();
}

void System_RT1_Process(int MAGIC){      
   //-------------------���������� �� �����--------------------------------------------------------------------------------------
    if (ActiveMngSLSave) MngStopLoss(MAGIC, Period(), MngSLZeroRatio);
   //---------------------------------------------------------------------------------------------------------------------------    
   
   //-------------------------------���������� ������� �� ����----------------------------------------   
   datetime SignalTime = 0; 
   int SignalType = -1;        
   System_RT1_CreateOpenSignal(SignalType, SignalTime);                              
   //-------------------------------------------------------------------------------------------------
   
   //-----------------------------������� ���������� ��� ������ �������-----------------------
   if (IsOpenOrder(MAGIC)){
      // � ���� ������� �� ������ �������� �� ����� �� ������� ������ �������   
      
      //�������� ��������� ��� ������ �� ��������� �� �������
      if  (CloseReverseOrder && SignalType == OP_BUY) CloseOrdersByType(MAGIC, OP_SELL);
      if  (CloseReverseOrder && SignalType == OP_SELL) CloseOrdersByType(MAGIC, OP_BUY);            
      
      if  (CloseSameOrder && SignalType == OP_BUY) CloseOrdersByType(MAGIC, OP_BUY);
      if  (CloseSameOrder && SignalType == OP_SELL) CloseOrdersByType(MAGIC, OP_SELL);   
   }
   //-------------------------------------------------------------------------------------------------   
                   
         
   //----------------------------------------������ ������� �������-----------------------------------
   if (SignalType == OP_BUY || SignalType == OP_SELL){ //                   
      if (
         //���� ������� �� ����� ������
         !IsOrderTimeSignal(MAGIC, SignalTime) 
         &&
         //���� �a������� ������� �� ����� ������ ��������� �� ������� �� �������
         //��� �������� ��� � ��������� ��������� ���� �� ������� ��� ������
         ((!History_IsOrderTimeSignal(MAGIC, SignalTime) && OneOrderCloseInSignalTime) || !OneOrderCloseInSignalTime)                      
         ){                           
         
         PrepareOpenOrder(MAGIC, SignalBaseName, SignalType, SignalTime);
      }             
   }     
   //--------------------------------------------------------------------------------------------------       
} 

void System_RT1_CreateOpenSignal(int& SignalType, datetime& SignalTime){
 
   SignalType = -1;
   ///**********************************������ ������***********************************************
   if (
        iClose(NULL, SIGNAL_TIMEFRAME, 1) < GetRatio_Level() && GetRatio_Level() != 0 
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) < GetChannel_Level() && GetChannel_Level() != 0 // �� ����� �� ������� �� ������
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) > GetChannel_Level() - GetChannel_Range()*0.5 && GetChannel_Range() != 0  // �� ����� �� ������� �� ����� + 50% ���������� �� ������
        && GetLOC_Large() > 0  //LARGE LOC �����������
        && GetChannelMark() == 1 //����� �� ������ ������ �������� ������     
        && GetChannel_Direction() == 1// ������ �� � ������� ������ �� �� ����� River
        && (GetTime_Direction() == -1 || GetBias_Direction() == -1 || GetPrice_Direction() == -1) // ���� �� ����� �������� ������ �� � otricatelen        
        && iLow(NULL, SIGNAL_TIMEFRAME, 1) > GetLargeLOC_Level()        
        && (MathAbs(GetLOC_Large()) == 3 || LargeLOCFilter == 0)
        && GetChannel_Direction() == 1
        ){
      SignalType = OP_BUY;
      SignalTime = GetLargeLOC_Shift();
   } 

   if (
        iClose(NULL, SIGNAL_TIMEFRAME, 1) > GetRatio_Level() && GetRatio_Level() != 0 // �� ������ �� ����� RETRACE
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) > GetChannel_Level() && GetChannel_Level() != 0 // �� ����� �� ������� �� ������
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) < GetChannel_Level() + GetChannel_Range()*0.5 && GetChannel_Range() != 0  // �� ����� �� ������� �� ����� + 50% ���������� �� ������
        && GetLOC_Large() < 0  //LARGE LOC �����������
        && GetChannelMark() == -1 //����� �� ������ ������ �������� ������     
        && GetChannel_Direction() == -1// ������ �� � ������� ������  �� �� ����� River
        && (GetTime_Direction() == 1 || GetBias_Direction() == 1 || GetPrice_Direction() == 1) // ���� �� ����� �������� ������ �� � ������������        
        && iHigh(NULL, SIGNAL_TIMEFRAME, 1) < GetLargeLOC_Level()
        && (MathAbs(GetLOC_Large()) == 3 || LargeLOCFilter == 0)        
        ){
      
      SignalType = OP_SELL;
      SignalTime = GetLargeLOC_Shift();
   }
   //********************************************************************************************************/
   
   /**********************************������ ��������***********************************************
   if (GetLOC_Large() > 0 && GetChannelMark() == 1){
      SignalType = OP_BUY;
      SignalTime = GetLargeLOC_Shift();      
   }
   ******************************************************************************************************/
   
   
    
}


void System_RT1_CloseOrders(int MAGIC){

}


