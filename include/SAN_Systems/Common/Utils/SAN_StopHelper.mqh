/*//+------------------------------------------------------------------+
  //| ��������� �������� ���� ���� ����� �� �� ��������/��������       |  
  //+------------------------------------------------------------------+   
#define DEF_STOP_FIXED_PIPS  1  //�������� ��������� ������� ��������� �������  
#define DEF_STOP_NONE        2  //��� ���� ���
#define DEF_STOP_ATR         3  //�������� ��������� ������� ���� ���������� ATR, ���������� � ���������� �� ������ ATR
#define DEF_STOP_LO_HI       4  //�������� ��������� ������� ���� ������ ����� �� �� �������� �� ���-�����/������ ��������. ������� ��������� ������ ��������� ������ �� ����� � �������.
#define DEF_STOP_SAR         5  //�� parabolic SAR. ������� ��������� ������ ������ - �� ������������ � 0.02, ������� ���������� - �� ������������ � 0.2
#define DEF_STOP_STDDEV      6  //���������� ����������. ������� ��������� ������ StdDevPeriod - �� ������������ � 20, ������� ������ �������� �� ����� �� �������� StdDev - �� ������������ 1;
���������: #define DEF_STOP_ZZ          7  //�������� �� ����� �� �� /// 

int MinBrokerLevel(); //��������� ������ ���������� �� �������� ���� ������ ��������� �� ������� �� ����� ���� �� �� ����� SL, Limit ��� ������ �������

// SignalLevel - ������ �� ������ ����������� ���� ���� �� �������� �������
// ��� SignalLevel != 0 �������� ���� ���� ����
// ���������� ���� MaxStopLoss ��� � "0" �� �� ������
// ���������  ���� MinStopLoss ��� � "0" �� �� ������
double SL_Calculate(int TradeType, int TimeFrame, int StopType, double StopParam1, double StopParam2, double SignalLevel, int MaxStopLoss = 0, int MinStopLoss = 0);

//OffsetTimeMinutes - ����� � ������ �� ���������� �� ��������� ���� ����� �� �������� ��������� �� ����-�, ��� � "0" �� �� ������
//TPDistancePoints - ���������� �� ������ ���� ����� �� ��������� �����, ��� � "0" �� �� ������
//OpenPriceDistancePoints - ������ ���� ����� ���������� ������ ������ �� �������� � ������ ������� �� ��������� ��������� �� �����
void SL_ProcessTrailing(int settID, int StopTimeFrame, int OffsetTimeMinutes, int TPDistancePoints, int OpenPriceDistancePoints, int StopType, 
   double StopParam1, double StopParam2, int MaxStopLoss, int MinStopLoss);                         

//����� ������������ ����� �� 0 � ���� ���� �� �������
//OffsetTimeMinutes - ����� � ������ �� ���������� �� ��������� ���� ����� �� �������� ��������� �� ����-�, ��� � "0" �� �� ������
void SL_MngSave(int settID, int TimeFrame, int OffsetTimeMinutes, 
               int StopLossZeroOffset = 3, int StopLossProfitOffset = 3, 
               double MngSLRatio = 1, double MngSLZeroRatio = 0.7);
//����������� ������� �� ����� ������ ������� �� ������               
void SL_MngSteps(int settID, int TimeFrame, double StepsPips[], double StepsPercent[]);
// ����� ���� ���� �� �������
void SL_MngFractalProfit(int settID, int period);
//*/

color SL_clStop = Red;
bool SL_UseSound = True;
string SL_FileSound = "alert.wav";

#define DEF_STOP_FIXED_PIPS  1  //�������� ��������� ������� ��������� �������
#define DEF_STOP_NONE        2  //��� ���� ���
#define DEF_STOP_ATR         3  //�������� ��������� ������� ���� ���������� ATR, ���������� � ���������� �� ������ ATR
#define DEF_STOP_LO_HI       4  //�������� ��������� ������� ���� ������ ����� �� �� �������� �� ���-�����/������ ��������. ������� ��������� ������ ��������� ������ �� ����� � �������.
#define DEF_STOP_SAR         5  //�� parabolic SAR. ������� ��������� ������ ������ - �� ������������ � 0.02, ������� ���������� - �� ������������ � 0.2
#define DEF_STOP_STDDEV      6  //���������� ����������. ������� ��������� ������ StdDevPeriod - �� ������������ � 20, ������� ������ �������� �� ����� �� �������� StdDev - �� ������������ 1;


int MinBrokerLevel(){
   return(MarketInfo(Symbol(), MODE_STOPLEVEL)+1*DigMode());
}

void SL_ViewLastErrorToFile(string Info, int ErrorCode){
   if(ErrorCode == ERR_NO_ERROR) return;
   
   Print(Info, " - error(",ErrorCode,"): ", ErrorDescription(ErrorCode));
        
   string FileName = "ErrorSTOP.txt";
   int file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');
   
   if (file < 1){
     Print("File " + FileName + ", the last error is ", GetLastError());     
     return;   
   }
   if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);
   string Pos = TimeToStr(Time[0]) + ": "+ Info + " - error("+ErrorCode+"): "+ ErrorDescription(ErrorCode);
   FileWrite(file, Pos);            
   FileClose(file);      
}

// SignalLevel - ������ �� ������ ����������� ���� ���� �� �������� �������
// ��� SignalLevel != 0 �������� ���� ���� ����
double SL_Calculate(int TradeType, int TimeFrame, int StopType, double StopParam1, double StopParam2, double SignalLevel, int MaxStopLoss = 0, int MinStopLoss = 0){
   double Result;      
   double PriceLevel = 0;
   int shift = 1;  
   RefreshRates();

   if(TradeType == OP_BUY) PriceLevel = Bid;
   if(TradeType == OP_SELL) PriceLevel = Ask;   

   if (SignalLevel == 0) {
      if(TradeType == OP_BUYSTOP) PriceLevel = iClose(NULL, TimeFrame, 1);
      if(TradeType == OP_SELLSTOP) PriceLevel = iClose(NULL, TimeFrame, 1);
   }else{
      if(TradeType == OP_BUYSTOP || TradeType == OP_SELLSTOP) PriceLevel = SignalLevel;   
   }   
   
   if(StopType == DEF_STOP_FIXED_PIPS){    //������� ��������� ������� ��������� �������
      if(TradeType == OP_BUY || TradeType == OP_BUYSTOP)
         Result = PriceLevel - StopParam1*Point;
      else   
         Result = PriceLevel + StopParam1*Point;
   }
      
   if(StopType == DEF_STOP_NONE) Result = 0;  
   
   if(StopType==DEF_STOP_ATR){           //�������� ��������� ������� ���� ���������� ATR, ���������� � ���������� �� ������ ATR
      if(StopParam1 <= 0) StopParam1=2;
      if(StopParam2 <= 0) StopParam2=33;                  
      
      //double StopInPoints = StopParam1*AvgRangeEx(StopTimeFrame, StopParam2); 
      double StopInPoints = StopParam1*iATR(NULL, TimeFrame, StopParam2, shift);                             
      
      if(TradeType == OP_BUY || TradeType == OP_BUYSTOP){      
         Result = PriceLevel - StopInPoints;
      }else{
         Result = PriceLevel + StopInPoints;                  
      }         
   }         
   
   if(StopType == DEF_STOP_LO_HI){           //�������� ��������� ������� ���� ������ ����� �� �� �������� �� ���-�����/������ ��������     
      if(TradeType == OP_BUY || TradeType == OP_BUYSTOP)
         Result = MathMin(
                           PriceLevel - StopParam2*Point,
                           MathMin(
                                    PriceLevel,
                                    iLow(NULL, TimeFrame, iLowest(NULL, TimeFrame, MODE_LOW, StopParam1, shift))
                                  )
                        );
      else   
         Result = MathMax(
                           PriceLevel + StopParam2*Point,
                           MathMax(
                                    PriceLevel, 
                                    iHigh(NULL, TimeFrame, iHighest(NULL, TimeFrame, MODE_HIGH, StopParam1, shift)) + Ask - Bid
                                   )
                        );
   }           
   
   if(StopType == DEF_STOP_SAR) {             //������� ��������� ������ ������ - �� ������������ � 0.02, ������� ���������� - �� ������������ � 0.2
     
      if(StopParam1 <= 0) StopParam1 = 0.02;
      if(StopParam2 <= 0) StopParam2 = 0.2;
      
      double sar = iSAR(NULL, TimeFrame, StopParam1, StopParam2, shift);
      if ((TradeType == OP_BUY  || TradeType == OP_BUYSTOP) && sar < PriceLevel) Result = sar;      
      if ((TradeType == OP_SELL  || TradeType == OP_SELLSTOP) && sar > PriceLevel) Result = sar + Ask - Bid + 1*DigMode()*Point;
   }
   
   
   if(StopType == DEF_STOP_STDDEV){
      if(StopParam1 <= 0) StopParam1 = 20;
      if(StopParam2 <= 0) StopParam2 = 1;      
            
      double dev = iStdDev(NULL, TimeFrame, StopParam1, 0, MODE_SMA, PRICE_CLOSE, shift)*StopParam2;    
      if (TradeType == OP_BUY  || TradeType == OP_BUYSTOP ) Result = PriceLevel - dev;      
      if (TradeType == OP_SELL  || TradeType == OP_SELLSTOP) Result = PriceLevel + dev + Ask - Bid + 1*DigMode()*Point;      
   }

   
   //-------------------------------------------------------------------------------------------------------------------------------------
   //�������� �� ����� ������ ���������� �������� ��������   
   if(Result > 0 && MaxStopLoss > 0){       
      if (TradeType == OP_BUY || TradeType == OP_BUYSTOP) Result = MathMax(Result, PriceLevel - MaxStopLoss*Point) - 1*DigMode()*Point; 
      if (TradeType == OP_SELL || TradeType == OP_SELLSTOP) Result = MathMin(Result, PriceLevel + MaxStopLoss*Point) + Ask - Bid + 1*DigMode()*Point;         
   }      
   //�������� �� ����� ������ ��������� �������� ��������   
   if(Result > 0 && MinStopLoss > 0){       
     if (TradeType == OP_BUY || TradeType == OP_BUYSTOP) Result = MathMin(Result, PriceLevel - MinStopLoss*Point) - 1*DigMode()*Point; 
     if (TradeType == OP_SELL || TradeType == OP_SELLSTOP) Result = MathMax(Result, PriceLevel + MinStopLoss*Point) + Ask - Bid + 1*DigMode()*Point;         
   }     
   //-------------------------------------------------------------------------------------------------------------------------------------
   
     
   //�������� �� ����� ������ ��������  �� ������a (��������� ��������)
   //da go obsydim s nikito neshto tuk ne raboti pri men !!!!!!!!!!!!
   if(Result > 0){           
     if(TradeType == OP_BUY /*|| TradeType == OP_BUYSTOP*/) Result = MathMin(Result, PriceLevel - MinBrokerLevel()*Point);      
     if(TradeType == OP_SELL /*|| TradeType == OP_SELLSTOP*/) Result = MathMax(Result, PriceLevel + MinBrokerLevel()*Point);
   }           
   
   //������������� �� ����������   
   Result = NormalizeDouble(Result, Digits);
   return(Result);
}


// �������� ���� �� ���������
void SL_ProcessTrailing(int settID, int StopTimeFrame, int OffsetTimeMinutes, int TPDistancePoints, int OpenPriceDistancePoints, int StopType, 
   double StopParam1, double StopParam2, int MaxStopLoss, int MinStopLoss){
   double ldStop;
   bool move_sl = false;
   double offset = 0;
   
   RefreshRates();
   for (int i = 0; i < OrdersTotal(); i++) {
	   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol()==Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID){
            
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               move_sl = false;
               
               //������� ������ ���� �� ������� ��������� �� ���� ���� � ������ ���� ���������� �� ���������
               //if ((Time[0] - OrderOpenTime())/60 > OffsetTimeMinutes || OffsetTimeMinutes == 0){
               
                  ldStop = SL_Calculate(OrderType(), StopTimeFrame, StopType, StopParam1, StopParam2, MaxStopLoss, MinStopLoss);
                  Print("[SL_ProcessTrailing] :: StopTimeFrame = ", StopTimeFrame, ", StopParam1 = ", StopParam1, ", StopParam2 = ", StopParam2,  ", ldStop = ", ldStop);
                  //������ �� ����� ���� ������ ������ �� ������� ���������
                  //�.�. ��� ������ � ����� ������ �� ������ �������� ��-����� �� 20 ������ ������ ��� �� ������ ���������
                  //�� ���� ����
                  //offset = MathAbs(OrderTakeProfit() - Ask);
                  //if ((offset > 0 && offset < TPDistancePoints*Point) || OrderTakeProfit() == 0 || TPDistancePoints == 0){                                                               
                     
                     //������ ���� ����� ���������� ������ ������ �� �������� � ������ ������� �� ���������
                     //��������� �� �����
                     //offset = MathAbs(OrderOpenPrice() - Ask);
                     //if ((/*OrderPrint() > 0 &&*/ offset > OpenPriceDistancePoints*Point) || OpenPriceDistancePoints == 0){
                        
                        if (OrderType() == OP_BUY){                                                                                             
                           if (ldStop > NormalizeDouble(OrderOpenPrice(), Digits) && ldStop >  NormalizeDouble(OrderStopLoss(), Digits)){                                       
                              move_sl = true;   
                           }                                       
                        }else{ 
                           if (ldStop < NormalizeDouble(OrderOpenPrice(), Digits) && ldStop < NormalizeDouble(OrderStopLoss(), Digits)){
                              move_sl = true;
                           }                  
                       // }
                        
                     //}
                     
                  //}                     
               }                  
                    
               if (move_sl){
                  if (OrderModify(OrderTicket(),OrderOpenPrice(),ldStop, OrderTakeProfit(),0,SL_clStop)){      
                     if (SL_UseSound) PlaySound(SL_FileSound); 
                  }else{
                     SL_ViewLastErrorToFile("ProcessTrailingStops - " + ldStop + ", ", GetLastError());
                  }     
               }           
                                                  		
            }                                                                                                                                                     
		   }
      }		   
   }   		    
}

void SL_MngSave(int settID, int TimeFrame, int OffsetTimeMinutes, int StopLossZeroOffset = 3, int StopLossProfitOffset = 3, double MngSLRatio = 1, double MngSLZeroRatio = 0.7){
   //���������� �� ����� ������ ��������� ������� �� �������----------------
   //����� ����� ����� �� 0 (+10 �����)
   //���� ���� ����� ��o�� �� 25 �����
   
   double level_zero = 0;
   double stop_points = 0;
   double begin_stop = 0;   
   double high = iHigh(NULL, TimeFrame, 1);
   double low = iLow(NULL, TimeFrame, 1);
   double value;
   bool TimeFilter;
   for (int i = 0; i < OrdersTotal(); i++) {
	   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
		   if (OrderSymbol()==Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {		   
            
            TimeFilter = false;
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {		    
               begin_stop = OrderComment_GetStop(OrderComment())*Point;
                  
               if ((Time[0] - OrderOpenTime())/60 > OffsetTimeMinutes || OffsetTimeMinutes == 0){
                  TimeFilter = true;
               }
		      }
	         
            if (OrderType() == OP_BUY && TimeFilter) { 
               stop_points = OrderOpenPrice() - OrderStopLoss();
               /*
               Print("[MngSLSave]: stop_points = ", stop_points);
               Print("[MngSLSave]: begin_stop = ", begin_stop, " OrderComment() = ", OrderComment());
               Print("[MngSLSave]: begin_stop*MngSLZeroRatio = ", begin_stop*MngSLZeroRatio);
               Print("[MngSLSave]: high = ", high);
               Print("[MngSLSave]: stop_points*MngSLRatio = ", stop_points*MngSLRatio);
               Print("[MngSLSave]: OrderOpenPrice() + (stop_points*MngSLRatio) = ", OrderOpenPrice() + (stop_points*MngSLRatio));
               Print("--------------------------------------------------------------------------------------------------------");
               //*/
               if (stop_points > begin_stop*MngSLZeroRatio && stop_points > 0 && high >= (OrderOpenPrice() + (stop_points*MngSLRatio))){                                  
                   
                  level_zero = OrderOpenPrice() + StopLossProfitOffset*Point;
                                                    
                  //--------------------------------------------------------------------------
                  if (low < level_zero){
                     level_zero = low - (StopLossZeroOffset + MarketInfo(Symbol(), MODE_SPREAD))*Point;                     
                  }
                  //--------------------------------------------------------------------------                   
                  
 
                  //�������� �� ����� ������ ��������  �� ������a (��������� ��������)                    
                  level_zero = MathMin(level_zero, Bid - MinBrokerLevel()*Point);               
                  
                  //������������� �� ����������
                  level_zero = NormalizeDouble(level_zero, Digits);                    
                  value = NormalizeDouble(OrderStopLoss(), Digits);
                  if (level_zero > value && level_zero != value){
                     if (OrderModify(OrderTicket(),OrderOpenPrice(),level_zero,OrderTakeProfit(),0,SL_clStop)){      
                        
                        if (SL_UseSound) PlaySound(SL_FileSound); 
                     }else{
                        SL_ViewLastErrorToFile("MngSLSave - Buy Order = " + OrderTicket()+ ", StopLevel = " + level_zero + " tmp = " + value, GetLastError());
                     } 
                  }                
               } 
	         }
	   
            if (OrderType() == OP_SELL && TimeFilter) {                                                                      
               stop_points = OrderStopLoss() - OrderOpenPrice();               
               if (stop_points > begin_stop*MngSLZeroRatio && stop_points > 0 && low <= (OrderOpenPrice() - (stop_points*MngSLRatio))){                                                  
                     
                  
                  level_zero = OrderOpenPrice() - StopLossProfitOffset*Point;   
                  
                  //--------------------------------------------------------------------------
                  if (high > level_zero){
                     level_zero = high + (MarketInfo(Symbol(), MODE_SPREAD) + StopLossZeroOffset)*Point;
                  }
                  //--------------------------------------------------------------------------                                    
 
                  //�������� �� ����� ������ ��������  �� ������a (��������� ��������)                 
                  level_zero = MathMax(level_zero, Ask + MinBrokerLevel()*Point);
                  
                  //������������� �� ����������               
                  level_zero = NormalizeDouble(level_zero, Digits);                    
                  value = NormalizeDouble(OrderStopLoss(), Digits);
                  if (level_zero < value && level_zero != value){                      
                     if (OrderModify(OrderTicket(),OrderOpenPrice(),level_zero,OrderTakeProfit(),0,SL_clStop)){      
                        if (SL_UseSound) PlaySound(SL_FileSound); 
                     }else{
                        SL_ViewLastErrorToFile("MngSLSave - Sell Order = " + OrderTicket()+ ", StopLevel = " + level_zero + " tmp = " + value, GetLastError());
                     }                                  
                  }
               }                                         
	         }			      			      
		   }
	   }
   } 

}

void SL_MngSteps(int settID, int TimeFrame, double StepsPips[], double StepsPercent[]){

   double stop = 0;
   double high = iHigh(NULL, TimeFrame, 1);
   double low = iLow(NULL, TimeFrame, 1);
   double value, limit;
   int n = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
	   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
		   if (OrderSymbol() == Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {		   
		      stop = 0;
            if (OrderType() == OP_BUY) {
               limit = OrderTakeProfit() - OrderOpenPrice(); 
               value = high - OrderOpenPrice();
               for(n = 0; n < ArraySize(StepsPercent); n++){
                  if (value > limit*(StepsPercent[n]/100)) stop = OrderOpenPrice() + StepsPips[n]*Point; 
                  
               }
               if (stop > 0){
                  
                  //�������� �� ����� ������ ��������  �� ������a (��������� ��������)                                                                        
                  stop = MathMin(stop, Bid - MinBrokerLevel()*Point);   
                  stop  = NormalizeDouble(stop, Digits);
                  value = NormalizeDouble(OrderStopLoss(), Digits);
                  if (stop < value + 1*DigMode()*Point) stop = 0;                  
               }                                                
	         }
	   

            if (OrderType() == OP_SELL) {             
               limit = OrderOpenPrice() - OrderTakeProfit();
               value = OrderOpenPrice() - low;
               for(n = 0; n < ArraySize(StepsPercent); n++){
                  if (value < limit*(StepsPercent[n]/100)) stop = OrderOpenPrice() - StepsPips[n]*Point; 
               }
               if (stop > 0){
                  //�������� �� ����� ������ ��������  �� ������a (��������� ��������)                                      
                  stop = MathMax(stop, Ask + MinBrokerLevel()*Point);
                  stop  = NormalizeDouble(stop, Digits);
                  value = NormalizeDouble(OrderStopLoss(), Digits);                                                     
                  if (stop > value - 1*DigMode()*Point) stop = 0;                                                            
               }  
               
	         }
	         if (stop > 0){
               //������������� �� ����������
               if (OrderModify(OrderTicket(), OrderOpenPrice(), stop, OrderTakeProfit(), 0, SL_clStop)){      
                  if (SL_UseSound) PlaySound(SL_FileSound); 
               }else{
                  SL_ViewLastErrorToFile("MngSLSteps: " + OrderTicket()+ ", newStop = " + stop + " CurrStop = " + OrderStopLoss(), GetLastError());
               } 
            }                                            	         
	         
	         			      			      
		   }
	   }
   } 

}


void SL_MngFractalProfit(int settID, int period){
   //���������� �� �����-----------------------------------
   //����� ���� ���� �� ������ �� ������ �� ������ �� ������� �� 5 ���� ��� ������ �� 
   // ���������
   
   double level_zero = 0;
   //double stop_points = 0;
   double stop_level = 0;
   int shift_begin = 0;
   int shift_end = 0;   
   double price = 0;
   double value;
   shift_end = iBarShift(NULL, period, Time[0]) + 1;
   for (int i = 0; i < OrdersTotal(); i++) {
	   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
		   if (OrderSymbol()==Symbol() && Magic_GetSettingsID(OrderMagicNumber()) == settID) {
		   
		       
		      shift_begin = iBarShift(NULL, period, OrderOpenTime());
            
	         
            if (OrderType() == OP_BUY) { 


               stop_level = SL_InternalLevelFrStopLoss(1, period, shift_begin, shift_end);
               
               if (stop_level > 0){

                    
                  //�������� �� ����� ������ ��������  �� ������a (��������� ��������)                    
                  stop_level = MathMin(stop_level, Bid - MinBrokerLevel()*Point) - MarketInfo(Symbol(), MODE_SPREAD)*Point*2;    
                  
                  //������������� �� ����������
                  stop_level = NormalizeDouble(stop_level, Digits);                   
                  value = NormalizeDouble(OrderStopLoss(), Digits);
                  if (stop_level > value && stop_level != value && stop_level != 0 && stop_level < Bid){                
                     if (OrderModify(OrderTicket(),OrderOpenPrice(),stop_level,OrderTakeProfit(),0,SL_clStop)){            
                        if (SL_UseSound) PlaySound(SL_FileSound); 
                        return(true);
                     }else{                 
                        SL_ViewLastErrorToFile("MngSLFractalProfit, Buy Order = " + OrderTicket()+ ", StopLevel = " + stop_level + " tmp = "+ value, GetLastError());
                        return(false);
                     }      
                  } 
               }                  
                
            }

            if (OrderType() == OP_SELL) {                                                       
            
               stop_level = SL_InternalLevelFrStopLoss(-1, period, shift_begin, shift_end);
               
               if (stop_level > 0){    
                  //�������� �� ����� ������ ��������  �� ������a (��������� ��������)                   
                  stop_level = MathMax(stop_level, Ask + MinBrokerLevel()*Point) + MarketInfo(Symbol(), MODE_SPREAD)*Point*2 ;                
                  
                  //������������� �� ����������               
                  stop_level = NormalizeDouble(stop_level, Digits);                   
                  value = NormalizeDouble(OrderStopLoss(), Digits);
                  if (stop_level < value && stop_level != value && stop_level > Ask){                                                                 
                     if (OrderModify(OrderTicket(),OrderOpenPrice(),stop_level,OrderTakeProfit(),0,SL_clStop)){            
                        if (SL_UseSound) PlaySound(SL_FileSound); 
                        return(true);
                     }else{                        
                        SL_ViewLastErrorToFile("MngSLFractalProfit, Sell Order = " + OrderTicket()+ ", StopLevel = " + stop_level + " tmp = "+ value, GetLastError());
                        return(false);
                     }              
                  } 
               } 
                                                 

            }			      			      

		   }
	   }
   } 

}

int SL_FractalBars = 5;
double SL_InternalLevelFrStopLoss(int begin_trend, int period,  int shift_begin, int shift_end){     
   int trend = begin_trend;
   int shift_begin_wave = -1;
   int n = 0;
   double fr = 0;
   double save_fr_up = 0;
   double save_fr_down = 99999999;

   double master_wave_down = 99999999;
   int master_wave_down_shift = 0;
   double master_wave_up = 0;
   int master_wave_up_shift = 0;
   
   bool check_new = false;
   bool find_correction = false;
   
   for(int i = shift_begin; i >= shift_end; i--){
      
      
      //�������� �� ������ ��� ������ �� ���� ��� ���� 
      if (trend == -1){ 
         if (save_fr_up != 0 && iClose(NULL, period, i) > save_fr_up){
            trend = 1;     
            check_new = true;  
            save_fr_down = master_wave_down;   
            
               master_wave_down = 99999999;
               master_wave_down_shift = 0;    
                          
         }
      }else{
         if (trend == 1){
            if (save_fr_down != 99999999 && iClose(NULL, period, i) < save_fr_down){
               trend = -1;  
               check_new = true;      
               save_fr_up = master_wave_up;   
               
               master_wave_up = 0;
               master_wave_up_shift = 0;                           
            }
         }      
      }
      
      //����������� �� ������ � ��������� �� ���� ���� �� ����������
      if (trend == -1){
         if (iClose(NULL, period, i) < master_wave_down){
            find_correction = true;
         }
         fr = SL_InternalFractals(period, SL_FractalBars, MODE_LOWER, i+1);
         if (fr != 0){
            if (fr < master_wave_down){
               master_wave_down = fr;
               master_wave_down_shift = i;
               //save_fr_up = 0;
               check_new = true;
            }            
         }
      }
      
      if (trend == 1){
         if (iClose(NULL, period, i) > master_wave_up){
            find_correction = true;
         }      
         fr = SL_InternalFractals(period, SL_FractalBars, MODE_UPPER, i+1);
         if (fr != 0){
            if (fr > master_wave_up){
               master_wave_up = fr;
               master_wave_up_shift = i;
               //save_fr_down = 9999999999;  
               check_new = true;
            }            
         }
      }   
      /*
      //if (StrToTime("1980.05.11 00:00") == Time[i]){
         Print("master_wave_up = ", master_wave_up);         
         Print("master_wave_up_shift = ", TimeToStr(Time[master_wave_up_shift]));
         Print("master_wave_down = ", master_wave_down);
         Print("master_wave_down_shift = ", TimeToStr(Time[master_wave_down_shift]));         
         Print("check_new = ", check_new);
         Print("save_fr_down = ", save_fr_down);
         Print("save_fr_up = ", save_fr_up);
      //}
      */
      //-------------------------������� ������ �� ������������ �����-------------------------
      if (find_correction){
         fr = 0;
         if (trend == 1) shift_begin_wave = master_wave_up_shift;
         if (trend == -1) shift_begin_wave = master_wave_down_shift;
      
         if (shift_begin_wave != 0){
            for (n = i; n <= shift_begin_wave; n++) {
            
               if (trend== -1){
               
                  fr = SL_InternalFractals(period, SL_FractalBars, MODE_UPPER, n+1);
               
                  if (fr != 0){    
                     if (check_new) {
                        save_fr_up = fr;
                        check_new = false;
                     }
                     if (fr > save_fr_up){                     
                        save_fr_up = fr;
                     }
                  }
               }
         
               if (trend== 1){
                  fr = SL_InternalFractals(period, SL_FractalBars, MODE_LOWER, n+1);
                  if (fr != 0){
                     if (check_new) {
                        save_fr_down = fr;
                        check_new = false;
                     }               
                     if (fr < save_fr_down){
                        save_fr_down = fr;
                     }
                  }
               }         
            }
         }   
         find_correction = false;
      }         
      //---------------------------------------------------------------
      
      if (trend == -1){
         if (save_fr_up != 99999999 && save_fr_up != 0){         
            return(save_fr_up);
         }                      
      }         
      if (trend == 1){
         if (save_fr_down != 99999999 && save_fr_down != 0){         
            return(save_fr_down);
         }
         
      }               
          
   }

   return(0);
  }
//------------------------------------------------------------------+


double SL_InternalFractals(int period, int bars, int MODE, int shift){   
   if (bars == 5){
      return(iFractals(NULL, period, MODE, shift));
   }   
}