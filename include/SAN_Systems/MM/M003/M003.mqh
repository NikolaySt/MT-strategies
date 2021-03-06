
double M003_MM_Init(int settID){

}


double M003_MM_Get(int settID){
   double Lots = MM_LotStep;  
   
   Lots = ((AccountBalance()*(M003_RiskPersent/100))  / MathMax(MM_History_Find_MaxLoss(), M003_MaxLoss_Currency)) * MM_LotStep;     
   
   if (MM_Trace)
         Print("[M002_MM_Get] AccountBalance()=", AccountBalance(), 
               ", M003_RiskPersent=", M003_RiskPersent,
               ", MM_Find_MaxLoss=", MM_History_Find_MaxLoss(),
               ", M003_MaxLoss_Currency=", M003_MaxLoss_Currency,
               ", MM_LotStep=", MM_LotStep,
               ", Lots=", Lots);       
             
   if (Lots > 0){
      Lots = NormalizeDouble(Lots, MM_Lots_RoundDig(MarketInfo(Symbol(), MODE_LOTSTEP)));                  
      return(MM_Lots_LimitBroker(Lots));
   }else{
      return(0);
   }
}