
void TN001_Trend_Init(int settID)
{
   int paramsSize = 6;
   double params[6]; ArrayInitialize(params, 0.0);
   params[0] = TN001_MAPeriod; 
   params[1] = TN001_MAShift;
   params[2] = TN001_MA_Env_Dev;
   params[3] = TN001_Atr_Period;
   params[4] = TN001_Atr_Ratio;
   params[5] = TN001_Bars_Break;   
   TN001_ZZIndex_Trend = ZZGetIndexForParamsOrCreate(Trend_TimeFrame, params, paramsSize, "SAN_TN001_ZigZag");   
}

int TN001_Trend_GetByIndex(int settID, int index){      
  return(ZZTypes_Get(TN001_ZZIndex_Trend, index));    
}


int TN001_Trend_GetLenghtByIndex(int settID, int index){
   double length = ZZValues_Get(TN001_ZZIndex_Trend, index) - ZZValues_Get(TN001_ZZIndex_Trend, index+1);
   return(MathAbs(length)/Point);   
}

datetime TN001_Trend_GetTimeByIndex(int settID, int index){
   return(ZZTimes_Get(TN001_ZZIndex_Trend, index));   
}


//-------------------------------------------------------------------------------------------------
//допълнителнa функции специфична само за експерт N001
//-------------------------------------------------------------------------------------------------
double TN001_MALine(int setID, int mode, int shift){ 
   int TimeFrame = Trend_TimeFrame;   
   if (mode == 0){
      return(iMA(NULL, TimeFrame, TN001_MAPeriod, TN001_MAShift, MODE_SMMA, PRICE_MEDIAN, shift));   
   }else{      
      if (mode == MODE_UPPER){
         return(
            MathMax(iMA(NULL, TimeFrame, TN001_MAPeriod, TN001_MAShift, MODE_SMMA, PRICE_MEDIAN, shift) + iATR(NULL, TimeFrame, TN001_Atr_Period, shift)*TN001_Atr_Ratio,
                    iEnvelopes(NULL, TimeFrame, TN001_MAPeriod, MODE_SMMA, TN001_MAShift, PRICE_MEDIAN, TN001_MA_Env_Dev, mode, shift)
                    )               
                );
      }else{
         if (mode == MODE_LOWER){   
            return(MathMin(
               iMA(NULL, TimeFrame, TN001_MAPeriod, TN001_MAShift, MODE_SMMA, PRICE_MEDIAN, shift) - iATR(NULL, TimeFrame, TN001_Atr_Period, shift)*TN001_Atr_Ratio,
               iEnvelopes(NULL, TimeFrame, TN001_MAPeriod, MODE_SMMA, TN001_MAShift, PRICE_MEDIAN, TN001_MA_Env_Dev, mode, shift)
                          )
                   );
         }
      }                  
   }
}


