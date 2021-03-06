

void A002_Signals_Init(int settID)
{  
   // dymanic mappings
   int paramsSize = 1;
   double params[1]; ArrayInitialize(params, 0.0);        
   params[0] = A002_ZZExtDepth;   
   A002_ZZIndex = ZZGetIndexForParamsOrCreate(Signal_TimeFrame, params, paramsSize, "SAN_A_ZigZag");       

}

void A002_Signals_Process(int settID)
{ 
  Common_Stop_ProcessAll(settID); 
   
  if( Common_HasNewShift(Signal_TimeFrame) == false ) return;
      
  int signalTypes[2];
  double signalLevels[2];
  datetime signalTimes[2];
  //int ordersMagic[2];
  int ordersTickets[2];
    
  ArrayInitialize(signalTypes,0);
  
  //1. signal
  A002_Signals_Create(settID, signalTypes, signalLevels, signalTimes);
  
  /*
  if( Signal_Trace && signalTypes[0] != 0)
  {
      Print("Orders 0 type=",signalTypes[0],";level=", signalLevels[0],
            ";1 type=",signalTypes[1],";level=", signalLevels[1] );
  }
  //*/
   
  Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels,  ordersTickets);
  
}

void A002_Signals_Create(int settID, int& signalTypes[], double& signalLevels[], datetime& signalTimes[] )
{
  int zzIndex = A002_ZZIndex;
  int Options = A002_TrendOptions;
   
   //get last peak
   int Direction[2],dir, shift, trend, res_shift[2],res_type[2];
   double price,min,max;
   Direction[0] = 1;//buy
   Direction[1] = -1;
   double res[2];
   
   int i;
   int trends[10], trend_peaks[10], trend_index;
     
   A002_Signal_Ups_Get(zzIndex,res,res_shift,res_type);
   
   /*
   if( res[0] != 0 || res[1] != 0 )
   {
      Print("Ups singal 0=",res[0],";1=",res[1],";shift0=", res_shift[0],";shift1=", res_shift[1],";type0=", res_type[0],";type1=", res_type[1]);
   }
   //*/ 
   
   Direction[0] = 1;//buy
   Direction[1] = -1;
   
   if( Options != -1 )       
      TA001_Utils_GetLastTrends( 5, trends, trend_peaks ); 
   
   for( i = 0; i < 2; i++ )
   {
      dir = Direction[i];
            
      if(Options == -1)
         trend = Common_Trend_GetByIndex(settID, 0);
      else
         trend = A002_Utils_GetTrendForDir(trends, trend_peaks, dir, Options, trend_index);      
      
      price = res[i];
      
      if( price != 0 && trend*dir > 0 )
      {
         signalTypes[i] = trend;
         signalLevels[i] = price;
         signalTimes[i] = iTime(NULL, Signal_TimeFrame, res_shift[i]);
      }
      else //if( res_type[i] == -1 )
      {
         PendingOrders_RemoveByDir( settID, dir );
      }
   }
}

void A002_Signal_Ups_Get( int zzIndex, double& result[2], int& result_shift[2], int& result_type[2] )
{
   int Direction[2],dir;
   int timeframe = Signal_TimeFrame;
   Direction[0] = 1;//buy
   Direction[1] = -1;
   
   for( int i = 0; i < 2; i++ )
   {
      dir = Direction[i];
      result[i] = 0;   
      int peak_shift = iBarShift(NULL, timeframe, ZZTimes_Get(zzIndex,0));
      double val0 = ZZValues_Get(zzIndex,0);
      double val2 = ZZValues_Get(zzIndex,2);
      int    type0 = ZZTypes_Get(zzIndex,0);
      result_type[i] = -1;
      
      if( (type0*dir < 0) 
          && ((ZZValues_Get(zzIndex,2) - ZZValues_Get(zzIndex,0))*dir > 0) 
          )
      {
         result_type[i] = 0;
         //da namerim tozi shift koito e tochno prehoden 
         int peak_max_shift = iBarShift(NULL, timeframe, ZZTimes_Get(zzIndex,1));
         while( true )
         {
            if( peak_shift >= peak_max_shift )
            {
               peak_shift = iBarShift(NULL, timeframe, ZZTimes_Get(zzIndex,0));
               break;
            }
            if( iLow( NULL, timeframe, peak_shift) < val2 && iHigh( NULL, timeframe, peak_shift) > val2 )
            {
               break;
            }
            peak_shift++;
         }
         
         double peak_min = SAN_AUtl_BarValueByDir( peak_shift, timeframe, dir );
         double peak_max = SAN_AUtl_BarValueByDir( peak_shift, timeframe, -dir );
         
         if( Signal_Trace )
           Print("[SAV_Signals_Ups_Get] type0*dir >0 dir=", dir,";peak_shift=", peak_shift, ";min=", peak_min,";max=", peak_max);
         
         
         //ako tekyshtiat bar e vyrteshen za prehodniat
         if( iLow( NULL, timeframe, 1) >= iLow( NULL, timeframe, peak_shift) && iHigh( NULL, timeframe, 1) <= iHigh( NULL, timeframe, peak_shift) )
         {
            result[i] = peak_min;
            result_shift[i] = peak_shift;
            result_type[i] = 1;            
         }
      }
   }  
}

int A002_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], int dir, int options,int& trend_index )
{
   int result = 0;
   
   //ako e  po malko to 10 originalnata versia ot predishnata logika
   if( options < 10 ) 
      result = A002_Utils_GetTrendForDir_old(trends, trend_peaks, dir, options, trend_index);
   else if( options >= 10 && options < 20 )
      result = TA001_Utils_GetTrendForDir(trends, trend_peaks, dir, options-10, trend_index);
   
   return (result);
}

int A002_Utils_GetTrendForDir_old( int& trends[],int& trend_peaks[], int dir, int options,int& trend_index )
{
   int trend;
   trend = 0;
   
   if( options == 0 )
   {
      trend = dir;
   }
   
   if( options&1 == 1 && trends[0]*dir > 0)
   {
      trend = trends[0];
      trend_index = 0;
   }
   
   if( options&2 == 2 && trends[0] != trends[1] && trends[1]*dir > 0 )
   {
      if( trends[1] == trends[2] && trends[1] == trends[3] )            
      {
         trend = trends[1];
         trend_index = 1;
      }
   }
   
   return (trend);      
}

