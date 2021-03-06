



double M002_MM_Init(int settID){

}

//Управление на капитала по фиксирано фракционен метод, 
//големината на позицията зависи от големината на стоплоса съобразена със процента риск с който изчисляваме рискувания капитал на сделка.              
double M002_MM_Get(int settID, int StopLoss_Pips){
   double Lots = MM_LotStep;
   if (StopLoss_Pips > 0 && M002_RiskPersent > 0){
      double RiskCapital = AccountBalance() * (M002_RiskPersent/100.0);      
      Lots = ( RiskCapital / (MM_PipsCost() * StopLoss_Pips) )/100.0;            
   }
   if (MM_Trace)
         Print("[M002_MM_Get] LotStep=", MarketInfo(Symbol(), MODE_LOTSTEP), 
               ", CapitalEquity=", AccountBalance() * (M002_RiskPersent/100.0),
               ", M002_RiskPersent=", M002_RiskPersent,
               ", AccountBalance=", AccountBalance(),
               ", PipsCost=", MM_PipsCost(),
               ", RiskCapital=", RiskCapital,
               ", Lots=", Lots,
               ", SLPoints=", StopLoss_Pips);       
             
   if (Lots > 0){
      Lots = NormalizeDouble(Lots, MM_Lots_RoundDig(MarketInfo(Symbol(), MODE_LOTSTEP)));                  
      return(MM_Lots_LimitBroker(Lots));
   }else{
      return(0);
   }
}