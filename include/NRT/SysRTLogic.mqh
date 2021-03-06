void System_RT1_Init(){
   SAN_N_Systems_Init_Common();
}

void System_RT1_Process(int MAGIC){      
   //-------------------УПРАВЛЕНИЕ на СТОПА--------------------------------------------------------------------------------------
    if (ActiveMngSLSave) MngStopLoss(MAGIC, Period(), MngSLZeroRatio);
   //---------------------------------------------------------------------------------------------------------------------------    
   
   //-------------------------------ГЕНЕРИРАМЕ СИГНАЛА ЗА ВХОД----------------------------------------   
   datetime SignalTime = 0; 
   int SignalType = -1;        
   System_RT1_CreateOpenSignal(SignalType, SignalTime);                              
   //-------------------------------------------------------------------------------------------------
   
   //-----------------------------ЗАТВАРЯ ОТВОРЕНИТЕ ПРИ ДАДЕНИ УСЛОВИЯ-----------------------
   if (IsOpenOrder(MAGIC)){
      // в тази фунцкия се описва логиката по който се затваря дадена поръчка   
      
      //затваряе поръчките при сигнал за насрещана по ръръчка
      if  (CloseReverseOrder && SignalType == OP_BUY) CloseOrdersByType(MAGIC, OP_SELL);
      if  (CloseReverseOrder && SignalType == OP_SELL) CloseOrdersByType(MAGIC, OP_BUY);            
      
      if  (CloseSameOrder && SignalType == OP_BUY) CloseOrdersByType(MAGIC, OP_BUY);
      if  (CloseSameOrder && SignalType == OP_SELL) CloseOrdersByType(MAGIC, OP_SELL);   
   }
   //-------------------------------------------------------------------------------------------------   
                   
         
   //----------------------------------------ОТВАРЯ ПАЗАРНА ПОРЪЧКА-----------------------------------
   if (SignalType == OP_BUY || SignalType == OP_SELL){ //                   
      if (
         //една поръчка по даден сигнал
         !IsOrderTimeSignal(MAGIC, SignalTime) 
         &&
         //една зaрворена поръчка по даден сигнал определен от времето на сигнала
         //без значение как е затворена поручката дали на печалба или загуба
         ((!History_IsOrderTimeSignal(MAGIC, SignalTime) && OneOrderCloseInSignalTime) || !OneOrderCloseInSignalTime)                      
         ){                           
         
         PrepareOpenOrder(MAGIC, SignalBaseName, SignalType, SignalTime);
      }             
   }     
   //--------------------------------------------------------------------------------------------------       
} 

void System_RT1_CreateOpenSignal(int& SignalType, datetime& SignalTime){
 
   SignalType = -1;
   ///**********************************СИГНАЛ ПАНИКА***********************************************
   if (
        iClose(NULL, SIGNAL_TIMEFRAME, 1) < GetRatio_Level() && GetRatio_Level() != 0 
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) < GetChannel_Level() && GetChannel_Level() != 0 // по малко от Линията на тренда
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) > GetChannel_Level() - GetChannel_Range()*0.5 && GetChannel_Range() != 0  // по малко от Линията на тренд + 50% големината на канала
        && GetLOC_Large() > 0  //LARGE LOC отрицателен
        && GetChannelMark() == 1 //линия на тренда отгоре прокеция отдолу     
        && GetChannel_Direction() == 1// канала да е насочен нагоре за да имаме River
        && (GetTime_Direction() == -1 || GetBias_Direction() == -1 || GetPrice_Direction() == -1) // един от трите елемента трябва да е otricatelen        
        && iLow(NULL, SIGNAL_TIMEFRAME, 1) > GetLargeLOC_Level()        
        && (MathAbs(GetLOC_Large()) == 3 || LargeLOCFilter == 0)
        && GetChannel_Direction() == 1
        ){
      SignalType = OP_BUY;
      SignalTime = GetLargeLOC_Shift();
   } 

   if (
        iClose(NULL, SIGNAL_TIMEFRAME, 1) > GetRatio_Level() && GetRatio_Level() != 0 // по голямо от Линия RETRACE
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) > GetChannel_Level() && GetChannel_Level() != 0 // по голям от Линията на тренда
        && iClose(NULL, SIGNAL_TIMEFRAME, 1) < GetChannel_Level() + GetChannel_Range()*0.5 && GetChannel_Range() != 0  // по малко от Линията на тренд + 50% големината на канала
        && GetLOC_Large() < 0  //LARGE LOC отрицателен
        && GetChannelMark() == -1 //линия на тренда отгоре прокеция отдолу     
        && GetChannel_Direction() == -1// канала да е насочен надолу  за да имаме River
        && (GetTime_Direction() == 1 || GetBias_Direction() == 1 || GetPrice_Direction() == 1) // един от трите елемента трябва да е положителене        
        && iHigh(NULL, SIGNAL_TIMEFRAME, 1) < GetLargeLOC_Level()
        && (MathAbs(GetLOC_Large()) == 3 || LargeLOCFilter == 0)        
        ){
      
      SignalType = OP_SELL;
      SignalTime = GetLargeLOC_Shift();
   }
   //********************************************************************************************************/
   
   /**********************************СИГНАЛ КОРЕКЦИЯ***********************************************
   if (GetLOC_Large() > 0 && GetChannelMark() == 1){
      SignalType = OP_BUY;
      SignalTime = GetLargeLOC_Shift();      
   }
   ******************************************************************************************************/
   
   
    
}


void System_RT1_CloseOrders(int MAGIC){

}


