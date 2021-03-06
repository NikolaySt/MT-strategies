//+------------------------------------------------------------------+
//|                                 Copyright 2010, Николай Стойчев  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2010 Forex-Consult"
//------------------------МОДУЛИ в които се генерират и управляват сигналите -------------------------------------
#include <StdDevUtils\StdDev_3_Vars.mqh>
#include <StdDevUtils\StdDev_3_Utils.mqh>
#include <StdDevUtils\StdDev_3_Create.mqh>
//---------------------------------------------------------------------------------------------------------------
int init(){                               
   StdDev_System_2_Init();             
   return(0);  
       
}
#include <SAN_Systems\Common\Utils\SAN_Statistical.mqh>
int deinit()
{ 
   if (IsTesting()){         
      if (!IsOptimization()){
         Stat_HistOrdersToFile(false, 1000, "history_"+SignalBaseName+".txt");
         Stat_DropDownToFile(false, 1000, "dropdown_"+SignalBaseName+".txt");
         Stat_AvgAnnualReturn(1000);
         Stat_SumMonthlyProfitToFile("monthly_profit_"+SignalBaseName+".txt");
         Stat_CalcMO(true);                                   
      }                      
      Stat_HistOrdersToDll(SignalBaseName);
   }            
   return(0);
}

double CalcLotSizeMM(int MAGIC, int CountOpenOrders){      
   double value = Lots;
   for (int i = 1; i <= CountOpenOrders; i++){
      value = value*(Multiplier - 1) + value;
   }
   
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP); 
   double MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);
  
   if (Lots >  MaxLots) value = MaxLots;           
   if (Lots < MinLots) value = MinLots;   
      
   double RoundDigLots = 0;
   switch(LotStep){
      case 0.00001: RoundDigLots = 5; break;
      case 0.0001: RoundDigLots = 4; break;
      case 0.001: RoundDigLots = 3; break;
      case 0.01: RoundDigLots = 2; break;
      case 0.1: RoundDigLots = 1; break;
      case 1: RoundDigLots = 0; break;
   } 

   value = NormalizeDouble( value,  RoundDigLots);           
   return(value);   
}


int start(){      
   StdDev_System_2_Process(MagicNumber);   
}











