bool Orders_Trace = false;

void Common_Orders_Init(int settID)
{   
   Orders_PendingPipsOffset = Orders_PendingPipsOffset*DigMode();
   Orders_SumProfitInPipsNextOrder = Orders_SumProfitInPipsNextOrder*DigMode();
}


void Common_Orders_Process(int settID, int signalTypes[], datetime signalTimes[], double signalLevels[], int& ordersTickets[]){  
   //�� ������������ � ������ 2;
   double signalLimits[1];
   double signalStops[1];
   string signalComments[1];
   int size = ArraySize(signalTypes);
   
   if( size > 1 )
   {
      ArrayResize(signalLimits, size);
      ArrayResize(signalStops, size);
      ArrayResize(signalComments, size);
   }
   
   if( size > 0 )
   {
      ArrayInitialize(signalLimits,0);
      ArrayInitialize(signalStops,0);
      //dava greshka kogato se inicializira masiv ot stringove
      //ArrayInitialize(signalComments, "");
   }
   
   Common_Orders_ProcessEx(settID, signalTypes, signalTimes, signalLevels, signalLimits, signalStops, signalComments, ordersTickets);
}   


void Common_Orders_ProcessEx(int settID, 
   int      signalTypes[], 
   datetime signalTimes[], 
   double   signalLevels[], 
   
   //������������ �� ����� ���������� �� ���� ������ ��� �����
   double signalLimits[],   //��� � != 0 -> ����� ���������� ����� ������� �� ����� ������ � 
   double signalStops[],    //��� � != 0 -> ����� ���������� ������� ���� ���� �� ����� ������ ��������� � ����� ������
   string signalComments[], //AKO e != "" ������������ ��������  
   
   int& ordersTickets[])
{   
   
   int trade_type = 0,ordersOpenCount, ordersPendCount;
   bool maxOpenCountOK;
   bool maxOpenLossOK;
   bool maxOpenInSignalTimeOK;
   bool maxCloseInSignalTimeOK;
   bool sumOrdersProfitOK; 
   int total = 0;
   int openInSignalTimeCount,closeInSignalTimeCount;
   
   for (int i = 0; i < ArraySize(signalTypes); i++){
      //* OP_SELL ��� OP_BUY
      if ((signalTypes[i] == 1 || signalTypes[i] == -1) && signalLevels[i] == 0){   
         
         //������������� � ��� �� �����������
         if (signalTypes[i]==-1) trade_type = OP_SELL; else trade_type = OP_BUY;
         //RateLargerOnPrevHalfBar - ����� �������� ���� �������� ���� � ���/��� ���������� �������� ���//
         //���� �� ������ ������ ����� ����� ��� ������ �� �������� ��� ����������� � ���������� � � ������� �� �������� � ���� ������ � ��������
         //�� ������ �� �������� ��� ����� ��� � �������� ���/��� ������� �� ������ �������
         //������ ������ �� �������� ������� �� ���� � �� �� �������
         //if (Order_RateLargerOnPrevHalfBar(trade_type, Signal_TimeFrame) ){//|| Orders_OnPrevHalfBar == 0){ 
         if (Order_RateLargerOnPrevHalfBar(trade_type, Signal_TimeFrame) || Orders_OnPrevHalfBar == 0){ 
         
            
            ordersOpenCount = OpenOrders_GetCountForType(settID, trade_type);
            openInSignalTimeCount = OpenOrders_GetCountForSigTime(settID, signalTimes[i]);
            closeInSignalTimeCount = HOrders_GetCountSigTime(settID, signalTimes[i]);
            maxOpenCountOK        = Orders_MaxOpenCount == 0         || ordersOpenCount < Orders_MaxOpenCount;    
            maxOpenLossOK         = Orders_MaxOpenLossCount == 0     || OpenOrders_GetCountLoss(settID) < Orders_MaxOpenLossCount;
            maxOpenInSignalTimeOK = (openInSignalTimeCount < Orders_MaxOpenInSignalTime) || Orders_MaxOpenInSignalTime == 0 ;
            maxCloseInSignalTimeOK= (closeInSignalTimeCount < Orders_MaxCloseInSignalTime) || Orders_MaxCloseInSignalTime == 0 ;
            //��������� ������ �� ������ �������� ������� ���� � �� ������ �� ������ �����/���� �������/
            //������ �� ������ ������������ ���� �� ��� ������� ������� �� �������� �������
            //������ ���������� ���� ��� ���������� �� ������� �� ������ ������� ���������� � ON001_Orders_SumProfit                  
            sumOrdersProfitOK     =  ordersOpenCount == 0 || Orders_SumProfitInPipsNextOrder == 0 || (OpenOrders_GetProfitInPips(settID) >= Orders_SumProfitInPipsNextOrder);
            
            if( Orders_Trace ) Print("Orders Process Pending Order maxOpenCountOK=",maxOpenCountOK,
                              ";maxOpenInSignalTimeOK=",maxOpenInSignalTimeOK,
                             ";maxCloseInSignalTimeOK=",maxCloseInSignalTimeOK,
                             ";sumOrdersProfitOK=", sumOrdersProfitOK,
                             "SignalTime;open=",openInSignalTimeCount,
                             ";close=",closeInSignalTimeCount
                             );             
            
            
            if (  maxOpenCountOK && maxOpenLossOK && 
                  maxOpenInSignalTimeOK && maxCloseInSignalTimeOK && sumOrdersProfitOK ){
               if( Orders_Trace ) Print("Orders Process Prepare Open Order");                                                  
               total = OrdersTotal();
               ordersTickets[i] = Common_Orders_PrepareOpenOrder(settID, signalTypes[i], signalTimes[i], signalLevels[i], signalLimits[i], signalStops[i], signalComments[i]);                              
               if(OrdersTotal() < total + 1)
               {
                  Common_Orders_TradeInMTTerminal(ordersTickets[i]);
               }                              
            }
         }             
      } 
      //*/
      //* OP_SELLSTOP ��� OP_BUYSTOP         
      if ((signalTypes[i] == 1 || signalTypes[i] == -1) && signalLevels[i] != 0){   
         
         int ptrade_type;                         
         //������������� � ��� �� �����������
         if (signalTypes[i]==-1) ptrade_type = OP_SELLSTOP; else ptrade_type = OP_BUYSTOP; 
         if (signalTypes[i]==-1) trade_type = OP_SELL; else trade_type = OP_BUY;
         //max open count za pending orderi moej bi ne e podhodiashto!!
         //ako e podhodiashto shte triabva da e trade_type = OP_SELL ili OP_BUY

         openInSignalTimeCount = OpenOrders_GetCountForSigTimeT(settID, signalTimes[i], ptrade_type) +
                                 OpenOrders_GetCountForSigTimeT(settID, signalTimes[i], trade_type);
                                 
         closeInSignalTimeCount = HOrders_GetCountSigTimeT(settID, signalTimes[i], trade_type);
         
         ordersOpenCount               = OpenOrders_GetCountForType(settID, trade_type);
         ordersPendCount               = OpenOrders_GetCountForType(settID, ptrade_type);
         
         maxOpenCountOK            = Orders_MaxOpenCount == 0         || ordersOpenCount < Orders_MaxOpenCount;
         maxOpenLossOK             = Orders_MaxOpenLossCount == 0     || OpenOrders_GetCountLoss(settID) < Orders_MaxOpenLossCount;
         maxOpenInSignalTimeOK     = Orders_MaxOpenInSignalTime == 0  || (openInSignalTimeCount < Orders_MaxOpenInSignalTime);
         maxCloseInSignalTimeOK    = Orders_MaxCloseInSignalTime == 0 || (closeInSignalTimeCount < Orders_MaxCloseInSignalTime);
         
         //premahvane na predishniat pending order
         if( openInSignalTimeCount == 0 )
         {
            if (Orders_PendSingleInDir == 1){
               PendingOrders_RemoveByType(settID, ptrade_type);
            }
         }
         
         //��������� ������ �� ������ �������� ������� ���� � �� ������ �� ������ �����/���� �������/
         //������ �� ������ ������������ ���� �� ��� ������� ������� �� �������� �������
         //������ ���������� ���� ��� ���������� �� ������� �� ������ ������� ���������� � ON001_Orders_SumProfit                  
         sumOrdersProfitOK     =  ordersOpenCount == 0 || Orders_SumProfitInPipsNextOrder == 0 || (OpenOrders_GetProfitInPips(settID) >= Orders_SumProfitInPipsNextOrder);      
         
         if( Orders_Trace ) Print("[Orders_Process] settID=",settID,
                              ";st=",signalTimes[i],
                              ";level=", signalLevels[i],
                              ";STOrdersCount=",openInSignalTimeCount,
                              ";maxOpenCountOK=",maxOpenCountOK,
                              ";maxOInSTOK=",maxOpenInSignalTimeOK,
                              ";maxClInSTOk=",maxCloseInSignalTimeOK,
                              ";sumOProfitOK=", sumOrdersProfitOK,
                              "SignalTime;open=",openInSignalTimeCount,
                              ";close=",closeInSignalTimeCount
                             );             
            
                       
         if (  maxOpenCountOK && maxOpenLossOK &&
               maxOpenInSignalTimeOK && maxCloseInSignalTimeOK && sumOrdersProfitOK ){
            if( Orders_Trace ) Print("Orders Process Prepare Pending Order");
            total = OrdersTotal();
            ordersTickets[i] = Common_Orders_PreparePendOrder(settID, signalTypes[i], signalTimes[i], signalLevels[i], signalLimits[i], signalStops[i], signalComments[i]);       
            if(OrdersTotal() < total + 1)
            {
               Common_Orders_TradeInMTTerminal(ordersTickets[i]);
            } 
            
         }
      }  
      //*/      
   }      
   //-------------------------------------------------------------------------------------------------- 
}


int Common_Orders_PrepareOpenOrder(int settID, int signalType, datetime signalTime, double signalLevel, 
   //������������
   double signalLimit = 0, double signalStop = 0, string signalComment = "")
{        
   
   double ldLimit = signalLimit; 
   if (ldLimit == 0) ldLimit = Common_Limit_Get(settID, signalType, signalLevel);
   if (ldLimit != 0) ldLimit = NormalizeDouble(ldLimit, Digits);   

      
   int stop_pips = 0;
   double ldStop = signalStop; 
   if (ldStop == 0) ldStop = Common_InitialStop_Get(settID, signalType, signalLevel);         
   if (ldStop != 0){
      ldStop = NormalizeDouble(ldStop, Digits);
      RefreshRates(); 
      if (signalType == 1) stop_pips =  NormalizeDouble((Ask - ldStop)/Point, 0);                                                              
      if (signalType == -1) stop_pips = NormalizeDouble((ldStop - Bid)/Point, 0);               
      
   }   
   double ldLot  = Common_MM_Get(settID, stop_pips);        
   
   string comment = OrderComment_Build(settID, SignalBaseName, signalTime, stop_pips, signalComment);
   int order_magic = Magic_Create(settID, signalTime, stop_pips);    
   if (ldLot > 0){
      if( Orders_Trace ) {
         Print("[Common_Orders_PrepareOpenOrder] settID=",settID,
                              ";Type=",signalType,
                              ";ldStop=", ldStop,
                              ";ldLimit=",ldLimit,
                              ";ldLot=",ldLot,
                              ";comment=",comment
                             );           
      }
      
      if (signalType == 1) return(Order_Open(order_magic, OP_BUY, ldLot, ldStop, ldLimit, comment));
      if (signalType == -1) return(Order_Open(order_magic, OP_SELL, ldLot, ldStop, ldLimit, comment));
   }else{
      return(0);
   }           
}

int Common_Orders_PreparePendOrder(int settID, int signalType, datetime signalTime, double signalLevel,
   //������������
   double signalLimit = 0, double signalStop = 0, string signalComment = "")
{                       
   
   if( Orders_PendingPipsOffset != 0 )
   {
      signalLevel = signalLevel + signalType*Orders_PendingPipsOffset*Point;  
   }
   
   double cmd_real_price;
   
   if( signalType < 0 ) //sell
     cmd_real_price = Bid;
   else //buy
     cmd_real_price = Ask;
    
   //--------------------------------------------------------------------------------------------------------------        
   if(//���� �� ���� ������� �� � ��������� �� ��������� ��� �������� �� ������� �������
         // ��������� ��������� �� ������
         MathAbs(signalLevel-cmd_real_price) < MinBrokerLevel()*Point  
         ||               
         //BUYSTOP signalLevel � ��� ��������� ���� // �������� �� �������� � �����
         (signalType == 1 && signalLevel-cmd_real_price < 0) 
         ||             
         //SELLSTOP signalLevel � ��� ��������� ���� // �������� �� �������� � �����        
         (signalType == -1 && signalLevel-cmd_real_price > 0)
     )
   {  
      //100 pipsa � ��������� �� EURUSD �� �� ����� ����������� ���� ����� �������� �� � �� �����
      //�� � ������ ���� �� �� ������� ���� ���������, ����� �� �� �����������
      //if (MathAbs(signalLevel-cmd_real_price) < PipsToPoints(100)) {       
         // ����� ������� ������� ��� ��������� ������ �� � ��������� ������ �� signalLevel
         return (Common_Orders_PrepareOpenOrder(settID, signalType, signalTime, 0, signalLimit, signalStop, signalComment));
      //}else{      
         //��� ������� ��� �������� � ����� ������ ot 100 pipsa, �� ����� ������� ������� �� �� �����         
        // return(0);
      //}
   }
   //--------------------------------------------------------------------------------------------------------------   
   
   
   double ldLevel =  NormalizeDouble(signalLevel, Digits); 
   int cmd_type;
   cmd_type = 0;

   cmd_type = -1;
   if( signalType == 1 ) cmd_type = OP_BUYSTOP; 
   else if( signalType == -1 ) cmd_type = OP_SELLSTOP;
        
   double ldLimit = signalLimit; 
   if (ldLimit == 0) ldLimit = Common_Limit_Get(settID, signalType, signalLevel);   
   if (ldLimit != 0) ldLimit = NormalizeDouble(ldLimit, Digits);   
   
   double ldStop = signalStop; 
   int stop_pips = 0;
   if (ldStop == 0) ldStop = Common_InitialStop_Get(settID, signalType, signalLevel);      
   
   if (ldStop != 0){
      ldStop = NormalizeDouble(ldStop, Digits);       
      stop_pips = NormalizeDouble(MathAbs((ldLevel - ldStop)/Point),0);
   }      
   
   string comment = OrderComment_Build(settID, SignalBaseName, signalTime, stop_pips, signalComment);
   int order_magic = Magic_Create(settID, signalTime, stop_pips);    
   
   double ldLot = Common_MM_Get(settID, NormalizeDouble(MathAbs((ldLevel - ldStop))/Point, 0));   
                    
   datetime expiration = 0;   
   if (Orders_PendExpiration > 0) expiration = Time[1] + 3600*Orders_PendExpiration;
   if (ldLot > 0 && cmd_type >= 0)
   {   
      return(Order_OpenPending(order_magic, cmd_type, ldLevel, ldLot, ldStop, ldLimit, comment, expiration));   
   }
   else
   {
      return(0);
   }         
}

//-----------------------------------------------------------------------------------------------------------
//-------------------------------������������ �������--------------------------------------------------------
void Common_Orders_CloseRemove(int settID, int signalTypes[], double signalLevels[]){   
   //�������� ��������� ��� ������ �� ��������� �� ������� ��� //�������� ��������� ��� ������ �� ������ �������
   for (int i = 0; i < ArraySize(signalTypes); i++){
      //* OP_SELL ��� OP_BUY
      if ((signalTypes[i] == 1 || signalTypes[i] == -1) && signalLevels[i] == 0){   
         if ((signalTypes[i] == 1 && Orders_CloseReverser == 1) || (Orders_CloseSame == 1 && signalTypes[i] == -1)) Orders_CloseByType(settID, OP_SELL);
         if ((signalTypes[i] == -1 && Orders_CloseReverser == 1) || (Orders_CloseSame == 1 && signalTypes[i] == 1)) Orders_CloseByType(settID, OP_BUY);
      }
      if ((signalTypes[i] == 1 || signalTypes[i] == -1) && signalLevels[i] != 0){         
         if ((Orders_RemovePendReverser && signalTypes[i] == 1)) PendingOrders_RemoveByType(settID, OP_SELLSTOP);                  
         if ((Orders_RemovePendReverser && signalTypes[i] == -1)) PendingOrders_RemoveByType(settID, OP_BUYSTOP);          
      }
   }              
}     
//---------------------------------------------------------------------------------------------------------------------


bool Common_Orders_TradeInMTTerminal(int ticket){
//�������� ���� �������� ���� ������� �� ������� � �� ��������� � ������� �� �������� ��������
//��� ��� �� � ������� 1 ������� � ��� ��������� ������ �� ����� �� ������ �� 10 ������� ������� ������
   bool result = true;
   if (!IsTesting() && ticket > 0){
      int n = 0;
      while (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) && n < 10 ){
         Sleep(1000);
         n++;
      }
      if (n < 10){
         Print("[Common_Orders_TradesInTerminal]:��: ������� = " + n + ". �������� � � ���������");         
      }else{
         string info = "[Common_Orders_TradesInTerminal]:������: ������� = " + n + ". �������� ������ � ��������� ���� ������ ��� �������";
         Print(info);
         Alert(info);      
         result = false;           
      }
   }      
   return(result);
}

