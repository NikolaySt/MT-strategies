/*//+------------------------------------------------------------------+
  //| Дефиниции указващи вида стоп който ще се използва/поддържа       |  
  //+------------------------------------------------------------------+   
#define DEF_STOP_FIXED_PIPS  1  //Изискава параметър указващ конкретни пипсове  
#define DEF_STOP_NONE        2  //Без стоп лос
#define DEF_STOP_ATR         3  //Изискава параметър указващ броя използвани ATR, следващият е параметъра на самият ATR
#define DEF_STOP_LO_HI       4  //Изискава параметър указващ броя барове които ще се проверят за най-малка/висока стойност. Вторият параметър указва минимален размер на стопа в пипсове.
#define DEF_STOP_SAR         5  //По parabolic SAR. Първият параметър указва стъпка - по подразбиране е 0.02, вторият отклонение - по подразбиране в 0.2
#define DEF_STOP_STDDEV      6  //Стандартно Отклонение. Първият параметър указва StdDevPeriod - по подразбиране е 20, вторият задава множител по който се умножава StdDev - по подразбиране 1;
НЕРАЗВИТО: #define DEF_STOP_ZZ          7  //Движение на стопа по ЗЗ /// 

int MinBrokerLevel(); //минимално ценово отместване от кещущата цена според границите на брокера на което може да се сложи SL, Limit или висяща поръчка

// SignalLevel - ползва се когато изчисляваме стоп лоса за отложена поръчка
// ако SignalLevel != 0 използва него като ниво
// максимален стоп MaxStopLoss ако е "0" не се ползва
// минимален  стоп MinStopLoss ако е "0" не се ползва
double SL_Calculate(int TradeType, int TimeFrame, int StopType, double StopParam1, double StopParam2, double SignalLevel, int MaxStopLoss = 0, int MinStopLoss = 0);

//OffsetTimeMinutes - време в минути от отварянето на поръчката след което да задества местенето на стоп-а, ако е "0" не се ползва
//TPDistancePoints - отместване от Лимита след което да задейства стопа, ако е "0" не се ползва
//OpenPriceDistancePoints - филтър след какво отместване спрямо цената на отваряне в посока печелба да задейства местенето на стопа
void SL_ProcessTrailing(int settID, int StopTimeFrame, int OffsetTimeMinutes, int TPDistancePoints, int OpenPriceDistancePoints, int StopType, 
   double StopParam1, double StopParam2, int MaxStopLoss, int MinStopLoss);                         

//мести първоначално стопа на 0 и след това на печалба
//OffsetTimeMinutes - време в минути от отварянето на поръчката след което да задества местенето на стоп-а, ако е "0" не се ползва
void SL_MngSave(int settID, int TimeFrame, int OffsetTimeMinutes, 
               int StopLossZeroOffset = 3, int StopLossProfitOffset = 3, 
               double MngSLRatio = 1, double MngSLZeroRatio = 0.7);
//стъпковидно местене на стопа според процент от лимита               
void SL_MngSteps(int settID, int TimeFrame, double StepsPips[], double StepsPercent[]);
// мести стоп лоса по фрактал
void SL_MngFractalProfit(int settID, int period);
//*/

color SL_clStop = Red;
bool SL_UseSound = True;
string SL_FileSound = "alert.wav";

#define DEF_STOP_FIXED_PIPS  1  //Изискава параметър указващ конкретни пипсове
#define DEF_STOP_NONE        2  //Без стоп лос
#define DEF_STOP_ATR         3  //Изискава параметър указващ броя използвани ATR, следващият е параметъра на самият ATR
#define DEF_STOP_LO_HI       4  //Изискава параметър указващ броя барове които ще се проверят за най-малка/висока стойност. Вторият параметър указва минимален размер на стопа в пипсове.
#define DEF_STOP_SAR         5  //По parabolic SAR. Първият параметър указва стъпка - по подразбиране е 0.02, вторият отклонение - по подразбиране в 0.2
#define DEF_STOP_STDDEV      6  //Стандартно Отклонение. Първият параметър указва StdDevPeriod - по подразбиране е 20, вторият задава множител по който се умножава StdDev - по подразбиране 1;


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

// SignalLevel - ползва се когато изчисляваме стоп лоса за отложена поръчка
// ако SignalLevel != 0 използва него като ниво
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
   
   if(StopType == DEF_STOP_FIXED_PIPS){    //Изисква параметър указващ конкретни пипсове
      if(TradeType == OP_BUY || TradeType == OP_BUYSTOP)
         Result = PriceLevel - StopParam1*Point;
      else   
         Result = PriceLevel + StopParam1*Point;
   }
      
   if(StopType == DEF_STOP_NONE) Result = 0;  
   
   if(StopType==DEF_STOP_ATR){           //Изискава параметър указващ броя използвани ATR, следващият е параметъра на самият ATR
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
   
   if(StopType == DEF_STOP_LO_HI){           //Изискава параметър указващ броя барове които ще се проверят за най-малка/висока стойност     
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
   
   if(StopType == DEF_STOP_SAR) {             //Първият параметър указва стъпка - по подразбиране е 0.02, вторият отклонение - по подразбиране в 0.2
     
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
   //Корекция на стопа спрямо максимална зададена стойност   
   if(Result > 0 && MaxStopLoss > 0){       
      if (TradeType == OP_BUY || TradeType == OP_BUYSTOP) Result = MathMax(Result, PriceLevel - MaxStopLoss*Point) - 1*DigMode()*Point; 
      if (TradeType == OP_SELL || TradeType == OP_SELLSTOP) Result = MathMin(Result, PriceLevel + MaxStopLoss*Point) + Ask - Bid + 1*DigMode()*Point;         
   }      
   //Корекция на стопа спрямо Минимална зададена стойност   
   if(Result > 0 && MinStopLoss > 0){       
     if (TradeType == OP_BUY || TradeType == OP_BUYSTOP) Result = MathMin(Result, PriceLevel - MinStopLoss*Point) - 1*DigMode()*Point; 
     if (TradeType == OP_SELL || TradeType == OP_SELLSTOP) Result = MathMax(Result, PriceLevel + MinStopLoss*Point) + Ask - Bid + 1*DigMode()*Point;         
   }     
   //-------------------------------------------------------------------------------------------------------------------------------------
   
     
   //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)
   //da go obsydim s nikito neshto tuk ne raboti pri men !!!!!!!!!!!!
   if(Result > 0){           
     if(TradeType == OP_BUY /*|| TradeType == OP_BUYSTOP*/) Result = MathMin(Result, PriceLevel - MinBrokerLevel()*Point);      
     if(TradeType == OP_SELL /*|| TradeType == OP_SELLSTOP*/) Result = MathMax(Result, PriceLevel + MinBrokerLevel()*Point);
   }           
   
   //Нормализиране на стойността   
   Result = NormalizeDouble(Result, Digits);
   return(Result);
}


// Подвижен стоп на позициите
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
               
               //времеви филтър кога да започне местенето на стоп лоса в минути след отварянето не поръчката
               //if ((Time[0] - OrderOpenTime())/60 > OffsetTimeMinutes || OffsetTimeMinutes == 0){
               
                  ldStop = SL_Calculate(OrderType(), StopTimeFrame, StopType, StopParam1, StopParam2, MaxStopLoss, MinStopLoss);
                  Print("[SL_ProcessTrailing] :: StopTimeFrame = ", StopTimeFrame, ", StopParam1 = ", StopParam1, ", StopParam2 = ", StopParam2,  ", ldStop = ", ldStop);
                  //филтър от какво ниво спрямо лимита да започне местенето
                  //т.е. ако цената е много близко до Лимита примерно по-малко от 20 пункта тогава чак да включи местенето
                  //на стоп лоса
                  //offset = MathAbs(OrderTakeProfit() - Ask);
                  //if ((offset > 0 && offset < TPDistancePoints*Point) || OrderTakeProfit() == 0 || TPDistancePoints == 0){                                                               
                     
                     //филтър след какво отместване спрямо цената на отваряне в посока печелба да задекства
                     //местенето на стопа
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
   //Управление на стопа когато позицията излезне на печалба----------------
   //първо мести стопа на 0 (+10 пипса)
   //след това мести стoпа на 25 пипса
   
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
                  
 
                  //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)                    
                  level_zero = MathMin(level_zero, Bid - MinBrokerLevel()*Point);               
                  
                  //Нормализиране на стойността
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
 
                  //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)                 
                  level_zero = MathMax(level_zero, Ask + MinBrokerLevel()*Point);
                  
                  //Нормализиране на стойността               
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
                  
                  //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)                                                                        
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
                  //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)                                      
                  stop = MathMax(stop, Ask + MinBrokerLevel()*Point);
                  stop  = NormalizeDouble(stop, Digits);
                  value = NormalizeDouble(OrderStopLoss(), Digits);                                                     
                  if (stop > value - 1*DigMode()*Point) stop = 0;                                                            
               }  
               
	         }
	         if (stop > 0){
               //Нормализиране на стойността
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
   //Управление на стопа-----------------------------------
   //мести стоп лоса по посока на тренда на дъното на фрактал от 5 бара при пробив на 
   // екстремум
   
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

                    
                  //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)                    
                  stop_level = MathMin(stop_level, Bid - MinBrokerLevel()*Point) - MarketInfo(Symbol(), MODE_SPREAD)*Point*2;    
                  
                  //Нормализиране на стойността
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
                  //Корекция на стопа спрямо лимитите  на брокерa (минимална стойност)                   
                  stop_level = MathMax(stop_level, Ask + MinBrokerLevel()*Point) + MarketInfo(Symbol(), MODE_SPREAD)*Point*2 ;                
                  
                  //Нормализиране на стойността               
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
      
      
      //Обръщане на тренда при пробив на дъно или връх 
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
      
      //Пордължение по тренда с формиране на ново ниво от корекцията
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
      //-------------------------Открива дъното на корективната вълна-------------------------
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