//+------------------------------------------------------------------+
//|                                       Copyright © 2011, SAN TEAM |
//+------------------------------------------------------------------+
/*
int SAN_Stop_InitAZigZag(int timeframe, int depth)
void SAN_Stop_InitializeLevel( int stopType, int timeframe, int levelIndex, 
                               int pipsLevel, double& param1, double& param2 )
                               
double SAN_Stop_ProcessForSelOrder( int stopType, int timeFrame, int TradeType, double openPrice, double stopPrice, 
         int ProfitInPips, int BeginSLInPips, double Param1, double Param2 , double currentPrice,
         int InitialStop = 0 //Default: 0 - ProcessStop, 1 - InitialStop
         );                            
*/

int SAN_Stop_InitAZigZag(int timeframe, int depth)
{
   if(depth <= 0) return (0);
   
   int paramsSize = 1;
   double params[1]; ArrayInitialize(params, 0.0);        
   params[0] = depth;  

   int index = ZZGetIndexForParamsOrCreate(timeframe, 
                                                   params, 
                                                   paramsSize, "SAN_A_ZigZag"); 
   return (index);                                                   
}

void SAN_Stop_InitializeLevel( int stopType, int timeframe, int levelIndex, 
                               double& pipsLevel, double& param1, double& param2 )
{        
   if( MathAbs(pipsLevel) > 1 )
   {
      pipsLevel = pipsLevel*DigMode();
   }
   
   if (stopType != SAN_DEF_STOP_ATR) param2 = param2*DigMode();  
      
   switch(stopType)
   {
      case SAN_DEF_STOP_PIPS_FROMPROFIT:
         param1 = param1*DigMode();
         break;
      case SAN_DEF_STOP_FIXED_PIPS:
         param1 = param1*DigMode();
         break;      
      case SAN_DEF_STOP_ZZ://pri niakoi stopove kato pri zigzaga triabva inicializaiq
                           //da izchisli zigzagindeksa da mojed a se izoplzva napravo sled tova
         param1 = SAN_Stop_InitAZigZag(timeframe, param1);
         break;
      case SAN_DEF_STOP_ZERO:         
         if (param1 > 10) param1 = param1*DigMode(); 
         break;
   }                             
}

double SAN_Stop_ProcessForSelOrder( int stopType, int timeFrame, int TradeType, double openPrice, double stopPrice, 
         int ProfitInPips, int BeginSLInPips, double Param1, double Param2 , double currentPrice,
         int InitialStop = 0 /*Default: 0 - ProcessStop, 1 - InitialStop, */)
{
   switch( stopType )
   {
     //връща ниво примерно: 1.0254
     
      case SAN_DEF_STOP_FIXED_PIPS:         
         //tuk niama nujda ot PARAM2 no za da e ednakvo s vsi4ki funkcii go slagam
         return(SAN_STOP_FIXED_PIPS_Proccess(TradeType, timeFrame, Param1/*Pips*/, Param2/*custom_pips_offset*/, currentPrice));
         
      case SAN_DEF_STOP_PROFIT_PERCENT:
         return (STOP_PROFITPERCENT_Proccess(TradeType, timeFrame, Param1/*stoppercent*/, Param2/*custom_pips_offset*/, openPrice, ProfitInPips));               
         
      case SAN_DEF_STOP_PIPS_FROMPROFIT:
         return (STOP_PIPS_FROMPROFIT_Proccess(TradeType, timeFrame, Param1/*stoppercent*/, Param2/*custom_pips_offset*/, openPrice, ProfitInPips));
         
      case SAN_DEF_STOP_ATR:         
         return(SAN_STOP_ATR_Proccess(TradeType, timeFrame, Param1/*Ratio*/, Param2/*AtrPeriod*/, currentPrice, openPrice, InitialStop));
         
      case SAN_DEF_STOP_LO_HI:
         return(SAN_STOP_LO_HI_Process(TradeType, timeFrame, Param1/*barsCount*/, Param2/*custom_pips_offset*/, currentPrice, openPrice, InitialStop));
         
      case SAN_DEF_STOP_ZZ:
         return(SAN_STOP_ZZ_Process(TradeType, timeFrame, Param1/*depth*/, Param2/*custom_pips_offset*/));                                  
         
      case SAN_DEF_STOP_FRACTAL:
         return(SAN_STOP_FRACTAL_Process(TradeType, timeFrame, Param1/*ne se polzva*/, Param2/*custom_pips_offset*/));                                                             
         

      //-------------------------------------------НУЛИРАНЕ на ордерите------------------------------------------------------------
      case  SAN_DEF_STOP_ZERO:
         return(SAN_STOP_ZERO_Proccess(TradeType, timeFrame, Param1/*ZeroLossPips*/, Param2/*custom_pips_offset*/, 
                                                   openPrice, stopPrice, BeginSLInPips, currentPrice));              
      //---------------------------------------------------------------------------------------------------------------------------      
      default:     
         return (0);                
   }
}

