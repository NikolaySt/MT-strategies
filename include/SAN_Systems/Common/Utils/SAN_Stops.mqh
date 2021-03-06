//+------------------------------------------------------------------+
//|                                       Copyright © 2011, SAN TEAM |
//+------------------------------------------------------------------+
#define SAN_DEF_STOP_NONE              0                                                       //Без стоп лос
#define SAN_DEF_STOP_FIXED_PIPS        1  //Param1/*Pips*/       Param2/*custom_pips_offset*/    Изискава параметър указващ конкретни пипсове                                                                                     
#define SAN_DEF_STOP_PROFIT_PERCENT    2  //Param1/*stoppercent*/Param2/*custom_pips_offset*/    Изискава параметър указващ нивото на печалба и процента срямо печалбата                                                                                     
#define SAN_DEF_STOP_LO_HI             3  //Param1/*barsCount*/, Param2/*custom_pips_offset*///  Броя барове които ще се проверят за най-малка/висока стойност. Вторият параметър указва отмества                                                                                     
#define SAN_DEF_STOP_ATR               4  //Param1/*Ratio*/,     Param2/*AtrPeriod*///           Пресмята по ATR                                                                                    
#define SAN_DEF_STOP_ZZ                5  //Param1/*depth*/,     Param2/*custom_pips_offset*/    Пресмята стопа по SAN_A_ZigZag 
#define SAN_DEF_STOP_PIPS_FROMPROFIT   6  //Param1 /*pips*/      Param2/*custom_pips_offset*/    Изискава параметър указващ конкретни пипсове спрямо печалбата
#define SAN_DEF_STOP_FRACTAL           7  //Param1/ne se polzva/ Param2/*custom_pips_offset*/    Мести стопа само веднъж по първи базов фрактал.

#define SAN_DEF_STOP_ZERO              8  ////Param1 /*SLRatio или SLPips*/, Param2/custom_pips_offset/

/*-------------------------------------------------------------------------------------------------------------------------------------------------
                                                         РЕАЛИЗИРАНЕ ЛИГИКАТА за пресмятане на всеки стоп
//-----------------------------------------------------------------------------------------------------------------------------------------------*/

double SAN_STOP_FIXED_PIPS_Proccess(int TradeType, int timeFrame, 
                                    double Param1/*pips*/, double Param2/*custom_pips_offset*/, 
                                    double PriceLevel)
{   
   //Изисква параметър указващ конкретни пипсове + otmestvane /po dobre da ne se polzva/        
   return(PriceLevel - TradeType*Param1*Point + TradeType*Param2*Point);
}

double SAN_STOP_ATR_Proccess(int TradeType, int timeFrame, 
                             double Param1/*Ratio*/, double Param2/*AtrPeriod*/, 
                             double PriceLevel,
                             double openPrice,
                             int InitialStop = 0
                             )
{                                                 
   double result = 0;
   
   double levelStop = PriceLevel - TradeType*Param1*iATR(NULL, timeFrame, Param2, 1);
   
   if (InitialStop == 1){
      result = levelStop; 
   }else{
      // при динамичен стоп с АТР и ако няма зануляване е добре стопа да почне да се мести когато изчислената
      // стойност стане по голяма/малка от OpenPrice
      if( TradeType*(levelStop - openPrice) > 0) result = levelStop;        
   }      

   return (result);
}

double SAN_STOP_LO_HI_Process(int TradeType, int timeFrame, double Param1/*barsCount*/, double Param2/*custom_pips_offset*/, 
   double PriceLevel, double openPrice, int InitialStop = 0){
   //връща ниво примерно: 1.3450
   double result = 0;   
   double levelStop = 0;
   
   //ako e buy posledniat bar da syvpada po posoka t.e. nagore za ProcessSTOP
   
   if( InitialStop == 1 || (InitialStop == 0 && TradeType*(iClose(NULL, timeFrame,1) - iOpen(NULL, timeFrame,1)) > 0) )
   {   
      //Изискава параметър указващ броя барове които ще се проверят за най-малка/висока стойност     
      if(TradeType > 0)
         levelStop = iLow(NULL, timeFrame, iLowest(NULL, timeFrame, MODE_LOW, Param1, 1));
      else   
         levelStop = iHigh(NULL, timeFrame, iHighest(NULL, timeFrame, MODE_HIGH, Param1, 1)) + SAN_Broker_Spread_Pips()*Point;
         
      levelStop = levelStop + TradeType*Param2*Point;
   } 
   
   if (InitialStop == 1){
      result = levelStop; 
   }else{
       // при динамичен стоп с HILO и ако няма зануляване е добре стопа да почне да се мести когато изчислената
       // стойност стане по голяма/малка от OpenPrice
      if( TradeType*(levelStop - openPrice) > 0) result = levelStop;        
   }       
                                                                 
   return(result);
}

double SAN_STOP_ZZ_Process(int TradeType, int timeFrame, double Param1/*depth*/, double Param2/*custom_pips_offset*/)
{
   if(Param1 <= 0) return (0); 
     
   //int paramsSize = 1;
   //double params[1]; ArrayInitialize(params, 0.0);        
   //params[0] = Param1;  
   /*
   int ZZIndex = ZZGetIndexForParamsOrCreate(
                        timeFrame, 
                        params, 
                        paramsSize, 
                        "SAN_A_ZigZag"
                       );             
                       */
   int ZZIndex = Param1;                       
   double result = 0;         
   if( ZZIndex != 0 )
   {
      if( ZZTypes_Get(ZZIndex, 0) == TradeType ){
         result = ZZValues_Get(ZZIndex, 1) + TradeType*Param2*Point;                   
         if (TradeType < 0) result =  result + SAN_Broker_Spread_Pips()*Point; 
      }
   }
   return (result);
}

double STOP_PIPS_FROMPROFIT_Proccess(int TradeType, int timeFrame, 
                        double Param1/*pips*/, double Param2/*custom_pips_offset*/,
                        double openPrice, double ProfitInPips)
{
   double result = 0;   
   if( Param1 > 0 )
   {
      result = openPrice + TradeType*(ProfitInPips - Param1)*Point + TradeType*Param2*Point; 
   }

   return (result);   
}

double STOP_PROFITPERCENT_Proccess(int TradeType, int timeFrame, 
                      double Param1/*stoppercent*/, double Param2/*custom_pips_offset*/, double openPrice, double ProfitInPips)
{
   double result = 0;
   if( Param1 != 0 ) //stoppercent
   {
      result = openPrice + TradeType*(100 - Param1)*ProfitInPips*Point/100 + TradeType*Param2*Point; 
   }
   
   return (result);   
}

double SAN_STOP_FRACTAL_Process(int TradeType, int timeFrame, double Param1/*не се ползва*/, double Param2/*custom_pips_offset*/){
   
   int shift_end = iBarShift(NULL, timeFrame, Time[0]) + 1; 		       
   int shift_begin = iBarShift(NULL, timeFrame, OrderOpenTime());
   double result = 0;
   result = SAN_NUtl_CalcLevelFrSL(TradeType, timeFrame, shift_begin, shift_end);
   result = result + TradeType*Param2*Point;
   return(result);
}

double SAN_STOP_ZERO_Proccess(int TradeType, int timeFrame, 
   double Param1/*SLRatio или SLPips*/,  double Param2/*custom_pips_offset*/,
   double openPrice, double stopPrice, int BeginSLInPips, double PriceLevel)   
{
   double result = 0;
   
   if (Param1 > 0){
      double offset = Param1;//<- pipsove  
      if( Param1 < 10 ) offset = BeginSLInPips*Param1; //процент пипсове от началния стоп      
   
      //прави проверка дали стопа е бил местен вече като го сравнява с НАЧАЛНИ СТОП 
      //но с коефициент 0.3 защото може да се получи леко отклонение между записания сто в MAGIC-а и реално сложение първоначално
      //заради технологични отклонения или Slipage на поръчката.
      //Това е по надежно защото може НУЛИРАНЕТО на стопа да не е точно на 0 а на малка загуба
      double curr_SLPoint = (openPrice - stopPrice)*TradeType;            
      if (curr_SLPoint >= BeginSLInPips*Point*0.3 && curr_SLPoint > 0){ 
      
         //отклонението от позицията да е повече от изчисленото offset
         if( (PriceLevel - openPrice)*TradeType > offset*Point )
         { 
            result = openPrice + TradeType*Param2*Point;  
         
            /*------------------------------------------------------------------------------
TODO:          да обсъдим с Андрьо :
               ТОВА е допълнителна корекция която забелязах че много добре работи
               при мен като тествах различни сиситеми и за това я слагам: 
               AKO дъното/върха на текущия бар са ниско/по виско от нивото на сметнатия сто
               постова на стопа на нивото на бара дори и да не е точно на нула оказва се ефективно защото така 
               съибразява бара.
               Това се случва рядко и то при движение в които за 1 бар се налага местене на стопа на 0.               
            //*/
            //*
            double low = iLow(NULL, timeFrame, 1);
            double high = iHigh(NULL, timeFrame, 1);    
            if (TradeType > 0){
               if (low < result) result = low - SAN_Broker_Spread_Pips()*Point;                     
            }else{
               if (high > result) result = high + SAN_Broker_Spread_Pips()*Point;      
            }  
            //*/        
            //------------------------------------------------------------------------------
         
         }
      }
   }     
      
   return (result);
}







