
   
void Common_Limit_Init(int settID)
{
   Limit_TimeFrame = SAN_AUtl_TimeFrameFromStr(Limit_TimeFrameS);   
   Limit_FixPips = Limit_FixPips*DigMode();
}   
   
void Common_Limit_InitAll(int settID)
{
   Common_Limit_Init(settID);   
}   


double Common_Limit_Get(int settID, int signalType, double signalLevel)
{
   // пресмятане на началния лимит
   
   if( LimitBaseName == "" )
   {
      //dafault
      return(Internal_Commom_Limit_Calc(settID, signalType, signalLevel));     
   }
   //da ima neshto dori i da niama pravilni nastroiki
   return (0.1);
}

//-------------------------------------------------------------------------------------------

double Internal_Commom_Limit_Calc(int settID, int signalType, double signalLevel)
{
   RefreshRates();
   double PriceLevel = 0;
   if (signalLevel == 0){
      if (signalType == 1) PriceLevel = Ask;
      if (signalType == -1) PriceLevel = Bid;
   }else{
      PriceLevel = signalLevel;   
   }
   
   double Result = 0;

   if (Limit_FixPips > 0){         
      Result = PriceLevel + signalType*Limit_FixPips*Point; 
   }

   //Корекция на целта спрямо лимитите на брокера
   if (Result > 0){   
      if (signalType == 1 && Result > 0) Result = MathMax(Result, PriceLevel + MinBrokerLevel()*Point);            
      if (signalType == -1 && Result > 0) Result = MathMin(Result, PriceLevel - MinBrokerLevel()*Point);         
   }

   Result = NormalizeDouble(Result, Digits);        
   return(Result);
}