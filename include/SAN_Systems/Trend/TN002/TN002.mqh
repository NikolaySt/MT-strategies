
void TN002_Trend_Init(int settID)
{
   int paramsSize = 3;
   double params[3]; ArrayInitialize(params, 0.0);
   params[0] = TN002_Bars_Break;
   params[1] = TN002_Atr_Period;
   params[2] = TN002_Atr_Ratio;   
   TN002_ZZIndex_Trend = ZZGetIndexForParamsOrCreate(Trend_TimeFrame, params, paramsSize, "SAN_TN002_ZigZag");   
}

int TN002_Trend_GetByIndex(int settID, int index){      
  return(ZZTypes_Get(TN002_ZZIndex_Trend, index));    
}


int TN002_Trend_GetLenghtByIndex(int settID, int index){
   double length = ZZValues_Get(TN002_ZZIndex_Trend, index) - ZZValues_Get(TN002_ZZIndex_Trend, index+1);
   return(MathAbs(length)/Point);   
}

datetime TN002_Trend_GetTimeByIndex(int settID, int index){
   return(ZZTimes_Get(TN002_ZZIndex_Trend, index));   
}


