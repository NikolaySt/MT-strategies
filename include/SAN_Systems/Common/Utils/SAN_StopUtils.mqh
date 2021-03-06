//+------------------------------------------------------------------+
//|                                       Copyright © 2011, SAN TEAM |
//+------------------------------------------------------------------+
/*
void SAN_Stop_Process(
         int settID, int StopTimeFrame,          
         
         int& StopType[], 
         int& pipsLevels[], 
         int pipsLevelsSize, 
         double& params1[], 
         double& params2[], 
         int& timeframes[],
         
         int MinStopInPips,
         int MaxStopInPips,
         int offsetPips
         
     )
void SAN_Stop_ProcessLevel(
         int settID, int StopTimeFrame, 
         
         int StopType,
         double param1, 
         double param2, 
         int timeframe,
         
         int MinStopInPips,
         int MaxStopInPips,
         int offsetPips         
     ) 
     
double SAN_Stop_GetInitialStopLoss(
         int TradeType,
         double SignalLevel,
         
         int timeFrame,          
         int StopType,
         double param1, 
         double param2,         
         
         int MinStopInPips,
         int MaxStopInPips,
         
         int offsetPips         
)     

int SAN_Broker_MinLevel_Pips()
int SAN_Broker_Spread_Pips()
void SAN_Stop_GetLastError(string Info, int ErrorCode)
double SAN_Stop_GetMinMaxValueSh1(int timeFrame, int tradeType)
int SAN_Stop_GetLevelIndex(int& pipsLevels[], int pipsLevelsSize, int currentProfitPips )
double SAN_Stop_Normalize(int TradeType, double levelStop, int MinStopInPips, int MaxStopInPips, int offsetPips, double sh1Value, double current_price)          
*/

bool SAN_Stop_Trace = false;
color SAN_Stop_Color = Red;
bool SAN_Stop_Sound = True;
string SAN_Stop_FileSound = "stops.wav";

int SAN_Broker_MinLevel_Pips(){
   return((MarketInfo(Symbol(), MODE_STOPLEVEL)+1*DigMode()));
}

int SAN_Broker_Spread_Pips(){
   return((MarketInfo(Symbol(), MODE_SPREAD)+1*DigMode()));
}

void SAN_Stop_GetLastError(string Info, int ErrorCode){
   if(ErrorCode == ERR_NO_ERROR) return;
   
   Print(Info, " - error(",ErrorCode,"): ", ErrorDescription(ErrorCode));
        
   string FileName = "Error_STOPProcess.txt";
   int file = FileOpen(FileName, FILE_WRITE|FILE_READ, ',');
   
   if (file < 1){
     Print("File " + FileName + ", the last error is ", GetLastError());     
     return;   
   }
   if (FileSize(file) > 0) FileSeek(file, 0, SEEK_END);
   string Pos = TimeToStr(Time[0]) + " : "+ Info + " - error("+ErrorCode+"): "+ ErrorDescription(ErrorCode);
   FileWrite(file, Pos);            
   FileClose(file);      
}

int SAN_StopTypes_Parse( string types, int& stopTypes[], int typesSize )
{
   string typesList[],tmp;
   
   int i;
   int size = SAV_Settings_SplitValues(types, typesList);
   
   if( size == 0 )
   {
      int st = SAN_StopType_Parse(types);
      for(i=0;i<typesSize;i++)
      {
         stopTypes[i] = st;
      }
   }
   else
   {
      for(i=0;i<size;i++)
      {
         tmp = typesList[i];
         tmp = StringSubstr(tmp,0,StringLen(tmp)-1);
         typesList[i] = StringTrimRight(tmp);
      
         stopTypes[i] = SAN_StopType_Parse(typesList[i]);
      }
   
   
      //slagame poslednata stojnost na vsichki koito sa ostanali i ne sa nastroeni
      for(i=size;i<typesSize;i++)
      {
         stopTypes[i] = stopTypes[size-1];
      }
   }
   
   /*
   if(SAN_Stop_Trace)
      Print("[SAN_StopTypes_Parse] input=",types,
            ";output=",stopTypes[0],",",stopTypes[1],",",stopTypes[2],
            ";split=",typesList[0],",",typesList[1],",",typesList[2]);
   //*/
   return (size);
}

int SAN_StopType_Parse(string type)
{
   int result = 0;
   
   if( type == "" ) result = 0;
   else if( type == "NONE" ) result = 0;
   else if( type == "FIXPIPS" ) result = SAN_DEF_STOP_FIXED_PIPS;
   else if( type == "PER" ) result = SAN_DEF_STOP_PROFIT_PERCENT;
   else if( type == "LOHI" ) result = SAN_DEF_STOP_LO_HI;
   else if( type == "ATR" ) result = SAN_DEF_STOP_ATR;
   else if( type == "ZZ" ) result = SAN_DEF_STOP_ZZ;
   else if( type == "PIPS" ) result = SAN_DEF_STOP_PIPS_FROMPROFIT;
   else if( type == "FRAC" ) result = SAN_DEF_STOP_FRACTAL;
   else if( type == "ZERO" ) result = SAN_DEF_STOP_ZERO;
   
   return (result);
}

string SAN_StopType_toString(int type)
{
   string result = 0;
   
   switch(type)
   {
   case 0: result ="NONE"; break;
   case SAN_DEF_STOP_FIXED_PIPS: result ="FIXPIPS"; break;
   case SAN_DEF_STOP_PROFIT_PERCENT: result ="PER"; break;
   case SAN_DEF_STOP_LO_HI: result ="LOHI"; break;
   case SAN_DEF_STOP_ATR: result ="ATR"; break;
   case SAN_DEF_STOP_ZZ: result ="ZZ"; break;
   case SAN_DEF_STOP_PIPS_FROMPROFIT: result ="PIPS"; break;
   case SAN_DEF_STOP_ZERO: result ="ZERO"; break;  
   }
   
   return (result);
}

double SAN_Stop_GetMinMaxValueSh1(int timeFrame, int tradeType)
{  
   if (tradeType == 1) 
      // добавя среда защото истинкия връх е BID + SPRED
      return (iHigh(NULL, timeFrame, 1) /*+ SAN_Broker_Spread_Pips()*Point*/);
   else
      return (iLow(NULL, timeFrame, 1));  
}

int SAN_Stop_CalcLevel(double level, int currentLimitPips)
{
   int result = 0;
//TODO: ako level = 0 to sledovatelno upravlenieto e postoianno bez niva
   if (level == 0) return(result);
      
   if( MathAbs(level) <= 1 ) //presmiata se po procenti koeficient do 1
   {
      if( level > 0 )
      {
         result = level*currentLimitPips;
      } 
      else
      {
         //level e otricatelno za tova se sybira
         result = (1.0 + level)*currentLimitPips;
      } 
   }
   else if( level < 0 ) //presmiata  se po pipsove blizko do limita
   {
      result = currentLimitPips + level;//level e otricatelen zatove se sybira
   }
   else
   {
      //defaultnoto povedenie pipsove otmestvane ot OpenPrice
      result = level;
   }
   
   return (result);
}

void SAN_Stop_CalcLevels(double& stopLevels[], int size, 
                         int currentLimitPips, int& pipsLevels[] )
{
   for( int i=0; i < size; i++ )
   {
      pipsLevels[i] = SAN_Stop_CalcLevel(stopLevels[i], currentLimitPips);
   }
}  

void SAN_Stop_Process(

         int settID, int StopTimeFrame, 
         
         int& StopTypes[], 
         double& stopLevels[], 
         int stopLevelsSize, 
         double& params1[], 
         double& params2[], 
         int& timeframes[],
         
         int MinStopInPips,
         int MaxStopInPips,
         int offsetPips
         
     )
     
{   
   static int pipsLevels[10];
   
   int currentProfitPips, currentLimitPips;

   int TradeType = 0;
   
   RefreshRates();

   for(int i = 0; i < OrdersTotal(); i++)
   {
      //-------------------------------------------------------------
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
      if( OrderType_IsPending( OrderType() ) ) continue;
      if( Magic_GetSettingsID(OrderMagicNumber()) != settID ) continue;
      //-------------------------------------------------------------
      
      TradeType = OrderType_GetDirection(OrderType());
      
      double sh1Value = SAN_Stop_GetMinMaxValueSh1(StopTimeFrame, TradeType);
 
      currentProfitPips = (sh1Value - OrderOpenPrice())*TradeType/Point;
      currentLimitPips  = (OrderTakeProfit() - OrderOpenPrice())*TradeType/Point;
      
      //-------------------------------------------------------------------------------------------
      //preobrazuvane ot koeficienti v pipsove na nivata
      //i ot tuk natatyk veche se boravi kakto predi s pipsove
      SAN_Stop_CalcLevels(stopLevels, stopLevelsSize, currentLimitPips, pipsLevels);
      
             
      int levelIndex = SAN_Stop_GetLevelIndex( pipsLevels, stopLevelsSize, currentProfitPips );
          
      
      if( levelIndex < 0 ) continue;
      
      if( SAN_Stop_Trace )
      {
         Print(
            "[SAN_Stop_Process()]::",
               "TradeType=", TradeType,
               ";StopType=", StopTypes[levelIndex],":",SAN_StopType_toString(StopTypes[levelIndex]),
               ";levelIndex=", levelIndex,
               ";param1=", params1[levelIndex],
               ";param2=",params2[levelIndex],
               ";level=",pipsLevels[levelIndex],
               ";profit=",currentProfitPips        
            );  
      }                
      
      SAN_Stop_ProcessInternal(settID, StopTimeFrame,
                                 StopTypes[levelIndex],
                                 params1[levelIndex], params2[levelIndex],
                                 timeframes[levelIndex],
                                 MinStopInPips,
                                 MaxStopInPips,
                                 offsetPips,
                                 TradeType,
                                 sh1Value,
                                 currentProfitPips );         
    } 
}

void SAN_Stop_ProcessLevel(

         int settID, int StopTimeFrame, 
         
         int StopType,
         double param1, 
         double param2, 
         int timeframe,
         
         int MinStopInPips,
         int MaxStopInPips,
         int offsetPips         
     )
     
{   
   int currentProfitPips;

   int TradeType = 0;
   
   RefreshRates();
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      //-------------------------------------------------------------
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
      if( OrderType_IsPending( OrderType() ) ) continue;
      if( Magic_GetSettingsID(OrderMagicNumber()) != settID ) continue;
      //-------------------------------------------------------------
      
      TradeType = OrderType_GetDirection(OrderType());
      
      double sh1Value = SAN_Stop_GetMinMaxValueSh1(StopTimeFrame, TradeType);
 
      currentProfitPips = (sh1Value - OrderOpenPrice())*TradeType/Point;

      //-------------------------------------------------------------------------------------------
     
      SAN_Stop_ProcessInternal(settID, StopTimeFrame,
                                 StopType,
                                 param1,param2,
                                 timeframe,
                                 MinStopInPips,
                                 MaxStopInPips,
                                 offsetPips,
                                 TradeType,
                                 sh1Value,
                                 currentProfitPips );         
    } 
}


int SAN_Stop_GetLevelIndex(int& pipsLevels[], int pipsLevelsSize, int currentProfitPips )
{      
   if( pipsLevelsSize <=0 ) return (-1);
   else if( pipsLevelsSize == 1 )
   {
      if( currentProfitPips > pipsLevels[0] ) return (0);//pyvata stypka
      else return(-1);//ne se upravliava predi pyrvata stypka
   }
   else if( pipsLevels[0] == 0 && pipsLevels[1] == 0 ) return (0);//ako pyrvite dve niva sa 0 togava niama da se smiata po stypki
   else if( pipsLevels[0] >= currentProfitPips ) return (-1);//tova e predi pyrvoto niva oshte niama upravlenie na stopa
   
   int result = pipsLevelsSize - 1;
   
   for( int i=0; i < pipsLevelsSize-1; i++ )
   {   
      /*
      if(SAN_Stop_Trace)   
         Print("[SAN_Stop_GetLevelIndex] i=",i,";pipsLevels[i]=",pipsLevels[i],";pl[i+1]=",pipsLevels[i+1],
                  "cnd1=",currentProfitPips > pipsLevels[i],
                  ";cnd2=",currentProfitPips <= pipsLevels[i+1],
                  ";cnd3=",pipsLevels[i+1] == 0);
      //*/                  
      if (currentProfitPips > pipsLevels[i] && 
		  (currentProfitPips <= pipsLevels[i+1] || pipsLevels[i+1] == 0))
      {
         result = i;
         break;  
      }
   }
   
   return (result);
 }

double SAN_Stop_Normalize(int TradeType, double levelStop,
                  int MinStopInPips,int MaxStopInPips, int offsetPips,
                                       double sh1Value, double current_price)
{
   if(offsetPips !=0)
   {
      levelStop = levelStop + TradeType*offsetPips*Point;
   }
   //-------------------------------------------------------------------------------------         
   //Корекция на стопа спрямо максимална и минимална зададена стойност             
   if(MaxStopInPips > 0){         
      if (TradeType > 0) 
         levelStop = MathMax(levelStop, sh1Value - MaxStopInPips*Point);  
      else 
         levelStop = MathMin(levelStop, sh1Value + MaxStopInPips*Point);
   }         
   if (MinStopInPips > 0){      
      if (TradeType > 0) 
         levelStop = MathMin(levelStop, sh1Value - MinStopInPips*Point);    
      else
         levelStop = MathMax(levelStop, sh1Value + MinStopInPips*Point);
   } 
   //------------------------------------------------------------------------          
           
   //Корекция на стопа спрямо минималния лимит на брокерa за поставяне на стоп от ТЕКУЩАТА ЦЕНА
   if(TradeType > 0){
      levelStop = MathMin(levelStop, current_price - SAN_Broker_MinLevel_Pips()*Point);      
   }else{         
      levelStop = MathMax(levelStop, current_price + SAN_Broker_MinLevel_Pips()*Point);
   } 
   //------------------------------------------------------------------------------------- 
    
   return (levelStop);
}

void SAN_Stop_ProcessInternal(
         int settID, int StopTimeFrame, 
         
         int StopType,  
         double param1, double param2, 
         int timeframe,
         
         int MinStopInPips,
         int MaxStopInPips,
         int offsetPips,
         
         int TradeType,
         double sh1Value,
         int currentProfitPips         
     )
{
      double levelStop = SAN_Stop_ProcessForSelOrder(
                              StopType, timeframe, 
                              TradeType, OrderOpenPrice(), OrderStopLoss(), currentProfitPips,
                              Magic_GetStop(OrderMagicNumber()),
                              param1, param2, 
                              sh1Value
                            );                        
      

      //-------------------------------------------------------------------------------------------          
      //ако върне "0" стопа не трябва да се пипа/                   
      //при някои стопове може да върне 0 защото примерно не е образуван фрактал или липсва все още условие
      //за да се мести стипа
      if (levelStop <= 0) return;
      
      double current_price;
      //преди началото на цикъла трябва да се извика RefreshRates(); 
      if (TradeType < 0)/*sell*/current_price = Ask; else/*buy*/current_price = Bid;// 
       
      levelStop = SAN_Stop_Normalize(TradeType, levelStop, 
                           MinStopInPips, MaxStopInPips, offsetPips,
                           sh1Value,current_price);
        
      if( SAN_Stop_Trace )
      {
         Print(
            "[SAN_Stop_Process()]::"+
               "Ticket = " + OrderTicket() + 
               ", OpenPrice = " + OrderOpenPrice() + 
               ", NewStop = " + NormalizeDouble(levelStop, Digits) +  
               ", OldStop = " + NormalizeDouble(OrderStopLoss(), Digits)+ 
               ", CurrentPrice = " + current_price            
            );  
      }      
                
      //проверка:: дали изчисления стоп е различене от текущия
      if (
          TradeType*(NormalizeDouble(levelStop, Digits) -  
                     NormalizeDouble(OrderStopLoss(), Digits)) > 0
         )
      {                                 
   
         //промяна на стопа
         if (OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(levelStop, Digits), OrderTakeProfit(), 0, SAN_Stop_Color)){      
            if (SAN_Stop_Sound) PlaySound(SAN_Stop_FileSound); 
         }else{
            SAN_Stop_GetLastError("[SAN_Stop_Process()] :: " +
               "Ticket = " + OrderTicket() + 
               ", OpenPrice = " +OrderOpenPrice() + 
               ", NewStop = " + NormalizeDouble(levelStop, Digits) +  
               ", OldStop = " + NormalizeDouble(OrderStopLoss(), Digits)+ 
               ", CurrentPrice = " + current_price,  
               GetLastError());               
         }       
      
      }
      //------------------------------------------------------------------------------------------------------------------------------------------                             
}

double SAN_Stop_GetInitialStopLoss(
         int TradeType,
         double SignalLevel,
         
         int timeFrame,          
         int StopType,
         double param1, 
         double param2,         
         
         int MinStopInPips,
         int MaxStopInPips,
         
         int offsetPips         
){
   //Началния стоп за момента може да работи само с тези 
   if (! (StopType == SAN_DEF_STOP_FIXED_PIPS || StopType == SAN_DEF_STOP_ATR || StopType == SAN_DEF_STOP_LO_HI) ) return(0);
   
   double OrderPriceLevel = 0;
   if (SignalLevel == 0){
      RefreshRates();
      if( TradeType > 0) { OrderPriceLevel = Bid; }else{ OrderPriceLevel = Ask; }
   }else{
      OrderPriceLevel = SignalLevel;   
   }
         
   double levelStop = SAN_Stop_ProcessForSelOrder(
                              StopType, timeFrame, 
                              TradeType, 0, 0, 0, 0,
                              param1, param2, 
                              OrderPriceLevel,
                              1 // 1 - InitialStop, Default: 0 - ProcessStop 
                            ); 
                                   
                                
   if (levelStop <= 0) return(0);
   
    
   levelStop = SAN_Stop_Normalize(TradeType, levelStop, 
                        MinStopInPips, MaxStopInPips, offsetPips,
                        OrderPriceLevel, OrderPriceLevel);     
                     
   if( SAN_Stop_Trace )
      {
         Print(
            "[SAN_Stop_GetInitialStopLoss()]::"+
               "TradeType = " + TradeType + 
               ", param1 = " + param1 + 
               ", param2 = " + param2 +  
               ", InitStopLoss = " + NormalizeDouble(levelStop, Digits)+ 
               ", OrderPrice = " + OrderPriceLevel            
            );  
      }
      
   return(NormalizeDouble(levelStop, Digits));     
} 

