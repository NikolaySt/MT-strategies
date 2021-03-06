//+------------------------------------------------------------------+
//|                                       Copyright � 2011, SAN TEAM |
//+------------------------------------------------------------------+
#define SAN_DEF_STOP_NONE              0                                                       //��� ���� ���
#define SAN_DEF_STOP_FIXED_PIPS        1  //Param1/*Pips*/       Param2/*custom_pips_offset*/    �������� ��������� ������� ��������� �������                                                                                     
#define SAN_DEF_STOP_PROFIT_PERCENT    2  //Param1/*stoppercent*/Param2/*custom_pips_offset*/    �������� ��������� ������� ������ �� ������� � �������� ����� ���������                                                                                     
#define SAN_DEF_STOP_LO_HI             3  //Param1/*barsCount*/, Param2/*custom_pips_offset*///  ���� ������ ����� �� �� �������� �� ���-�����/������ ��������. ������� ��������� ������ ��������                                                                                     
#define SAN_DEF_STOP_ATR               4  //Param1/*Ratio*/,     Param2/*AtrPeriod*///           �������� �� ATR                                                                                    
#define SAN_DEF_STOP_ZZ                5  //Param1/*depth*/,     Param2/*custom_pips_offset*/    �������� ����� �� SAN_A_ZigZag 
#define SAN_DEF_STOP_PIPS_FROMPROFIT   6  //Param1 /*pips*/      Param2/*custom_pips_offset*/    �������� ��������� ������� ��������� ������� ������ ���������
#define SAN_DEF_STOP_FRACTAL           7  //Param1/ne se polzva/ Param2/*custom_pips_offset*/    ����� ����� ���� ������ �� ����� ����� �������.

#define SAN_DEF_STOP_ZERO              8  ////Param1 /*SLRatio ��� SLPips*/, Param2/custom_pips_offset/

/*-------------------------------------------------------------------------------------------------------------------------------------------------
                                                         ����������� �������� �� ���������� �� ����� ����
//-----------------------------------------------------------------------------------------------------------------------------------------------*/

double SAN_STOP_FIXED_PIPS_Proccess(int TradeType, int timeFrame, 
                                    double Param1/*pips*/, double Param2/*custom_pips_offset*/, 
                                    double PriceLevel)
{   
   //������� ��������� ������� ��������� ������� + otmestvane /po dobre da ne se polzva/        
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
      // ��� ��������� ���� � ��� � ��� ���� ���������� � ����� ����� �� ����� �� �� ����� ������ �����������
      // �������� ����� �� ������/����� �� OpenPrice
      if( TradeType*(levelStop - openPrice) > 0) result = levelStop;        
   }      

   return (result);
}

double SAN_STOP_LO_HI_Process(int TradeType, int timeFrame, double Param1/*barsCount*/, double Param2/*custom_pips_offset*/, 
   double PriceLevel, double openPrice, int InitialStop = 0){
   //����� ���� ��������: 1.3450
   double result = 0;   
   double levelStop = 0;
   
   //ako e buy posledniat bar da syvpada po posoka t.e. nagore za ProcessSTOP
   
   if( InitialStop == 1 || (InitialStop == 0 && TradeType*(iClose(NULL, timeFrame,1) - iOpen(NULL, timeFrame,1)) > 0) )
   {   
      //�������� ��������� ������� ���� ������ ����� �� �� �������� �� ���-�����/������ ��������     
      if(TradeType > 0)
         levelStop = iLow(NULL, timeFrame, iLowest(NULL, timeFrame, MODE_LOW, Param1, 1));
      else   
         levelStop = iHigh(NULL, timeFrame, iHighest(NULL, timeFrame, MODE_HIGH, Param1, 1)) + SAN_Broker_Spread_Pips()*Point;
         
      levelStop = levelStop + TradeType*Param2*Point;
   } 
   
   if (InitialStop == 1){
      result = levelStop; 
   }else{
       // ��� ��������� ���� � HILO � ��� ���� ���������� � ����� ����� �� ����� �� �� ����� ������ �����������
       // �������� ����� �� ������/����� �� OpenPrice
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

double SAN_STOP_FRACTAL_Process(int TradeType, int timeFrame, double Param1/*�� �� ������*/, double Param2/*custom_pips_offset*/){
   
   int shift_end = iBarShift(NULL, timeFrame, Time[0]) + 1; 		       
   int shift_begin = iBarShift(NULL, timeFrame, OrderOpenTime());
   double result = 0;
   result = SAN_NUtl_CalcLevelFrSL(TradeType, timeFrame, shift_begin, shift_end);
   result = result + TradeType*Param2*Point;
   return(result);
}

double SAN_STOP_ZERO_Proccess(int TradeType, int timeFrame, 
   double Param1/*SLRatio ��� SLPips*/,  double Param2/*custom_pips_offset*/,
   double openPrice, double stopPrice, int BeginSLInPips, double PriceLevel)   
{
   double result = 0;
   
   if (Param1 > 0){
      double offset = Param1;//<- pipsove  
      if( Param1 < 10 ) offset = BeginSLInPips*Param1; //������� ������� �� �������� ����      
   
      //����� �������� ���� ����� � ��� ������ ���� ���� �� �������� � ������� ���� 
      //�� � ���������� 0.3 ������ ���� �� �� ������ ���� ���������� ����� ��������� ��� � MAGIC-� � ������ �������� ������������
      //������ ������������ ���������� ��� Slipage �� ���������.
      //���� � �� ������� ������ ���� ���������� �� ����� �� �� � ����� �� 0 � �� ����� ������
      double curr_SLPoint = (openPrice - stopPrice)*TradeType;            
      if (curr_SLPoint >= BeginSLInPips*Point*0.3 && curr_SLPoint > 0){ 
      
         //������������ �� ��������� �� � ������ �� ����������� offset
         if( (PriceLevel - openPrice)*TradeType > offset*Point )
         { 
            result = openPrice + TradeType*Param2*Point;  
         
            /*------------------------------------------------------------------------------
TODO:          �� ������� � ������ :
               ���� � ������������ �������� ����� ��������� �� ����� ����� ������
               ��� ��� ���� ������� �������� �������� � �� ���� � ������: 
               AKO ������/����� �� ������� ��� �� �����/�� ����� �� ������ �� ��������� ���
               ������� �� ����� �� ������ �� ���� ���� � �� �� � ����� �� ���� ������ �� ��������� ������ ���� 
               ���������� ����.
               ���� �� ������ ����� � �� ��� �������� � ����� �� 1 ��� �� ������ ������� �� ����� �� 0.               
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







