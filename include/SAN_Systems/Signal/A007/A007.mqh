

void A007_Signals_Init(int settID)
{  
   // dymanic mappings
   //int paramsSize = 1;
   //double params[1]; ArrayInitialize(params, 0.0);        
   //params[0] = A007_ZZExtDepth;   
   //A007_ZZIndex = ZZGetIndexForParamsOrCreate(Signal_TimeFrame, params, paramsSize, "SAN_A_ZigZag");   
}

void A007_Signals_Process(int settID)
{ 
  Common_Stop_ProcessAll(settID); 
   
  if( Common_HasNewShift(Signal_TimeFrame) == false ) return;
      
   int signalTypes[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersMagic[2];
   int ordersTickets[2];
    
   ArrayInitialize(signalTypes,0);
  
   //1. signal
   A007_Signals_Create(settID, signalTypes, signalTimes, signalLevels );
  
  /*
  if( Signal_Trace && signalTypes[0] != 0)
  {
      Print("Orders 0 type=",signalTypes[0],";level=", signalLevels[0],
            ";1 type=",signalTypes[1],";level=", signalLevels[1] );
  }
  //*/
  //Print("Before Common_Orders_ProcessAll");
  Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels,  ordersTickets);
  //Print("After Common_Orders_ProcessAll");
}

void A007_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[] )
{
  //int ZZIndex = 0A007_ZZIndex;
  int Options = A007_TrendOptions;
   
   //get last peak
   int Direction[2],dir, shift, trend,i, trend_index,trend_calc_index;
   int trends[10], trend_peaks[10];
   datetime mintime;

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
         trend = A007_Utils_GetTrendForDir(trends, trend_peaks, dir, Options, trend_index, trend_calc_index);
   
      //price = res[i];
      datetime signalTime =0;
      double signalLevel=0;
           
      if( trend*dir > 0 )
      {                
         A007_Signal_Get(dir, signalLevel, signalTime);

         if( signalLevel != 0 )
         {
            signalTypes[i] = trend;
            signalLevels[i] = signalLevel;
            signalTimes[i] = signalTime;           
         }
      }
      ///*
      if( trend*dir < 0 || signalLevel == 0)
      {
        PendingOrders_RemoveByDir( settID, dir );
      }
      //*/
   }
}
//v1 pyrva versia na signala 7600/500 341 orders
int A007_Signal_Get(int dir, double& signalLevel, datetime& signalTime)
{
   double lastLevel0=0,lastLevel2,v0,v1,v2,rv0,rv1,rv2;
   int d0,d1,d2;
   int timeframe = Signal_TimeFrame;
   int signalShift = -1,shift;
   for( shift = A007_MinSignalBar + 1; shift < A007_MaxSearchBarsBack + 1; shift++ )
   {
      v0 = SAN_AUtl_BarValueByDir(shift, timeframe, -dir);
      v1 = SAN_AUtl_BarValueByDir(shift+1, timeframe, -dir);
      v2 = SAN_AUtl_BarValueByDir(shift+2, timeframe, -dir);
      
      d0 = SAN_AUtil_BarDir(timeframe,shift);
      d1 = SAN_AUtil_BarDir(timeframe,shift+1);
      d2 = SAN_AUtil_BarDir(timeframe,shift+2);
      
      rv0 = SAN_AUtl_BarValueByDir(shift, timeframe, dir);
      rv1 = SAN_AUtl_BarValueByDir(shift+1, timeframe, dir);
      rv2 = SAN_AUtl_BarValueByDir(shift+2, timeframe, dir);
           
      if(  d0 == -dir && d1 == dir // && d2 == dir
           && (dir*(v0 - v1) > 0 || dir*(v0 - v2) > 0)
           && (dir*(rv0 - rv1) < 0 || dir*(rv0 - rv2) < 0))
      {
         signalShift = shift;         
         break;
      }
   }
   
   if(signalShift > 0)
   {
      for( shift =1; shift < signalShift;shift++)
      {
         if(SAN_AUtil_BarDir(timeframe,shift)*dir <= 0)
         {
            signalShift = shift;
            break;
         }
      }
   }
     
   if( signalShift > 0 )
   {
      if(Signal_Trace) 
         Print("[A007_Signal_Get] lastSignal dir=",dir,
               ";v0=",v0,";v1=",v1,
               ";t0=", TimeToStr(iTime(NULL,timeframe,signalShift)));  
      
      signalLevel = SAN_AUtl_BarValueByDir(signalShift, timeframe, dir);
      signalTime  = iTime(NULL,timeframe,signalShift);                                                                         
   }
}  
  
///*
int A007_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], 
                                 int dir, int options,
                               int& trend_index,int& trend_calc_index )
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
      // da niaa mnogo peakove obrazuvane sled posledniat trend!!
      if( trends[1] == trends[2] && (trend_peaks[1] <= trend_peaks[0] + 2) )    
      //if( trends[1] == trends[2] && (trend_peaks[1] <= trend_peaks[0] + 1) ) //originalno   
      {
         trend = trends[1];
         trend_index = 1;
      }
   }
   
   trend_calc_index = 0;
   
   if( trend != 0 )
   {
      if(trend_index==0)
      {
         trend_calc_index = trend_peaks[0]; 
         if( trend_calc_index == 0 && trends[1] != dir)
         {
            if( trends[2] == dir && trend_peaks[2] < 6 ) trend_calc_index = trend_peaks[2];
            else trend_calc_index+=2;
         } 
      }
      else
      {
         trend_calc_index = trend_peaks[0] + 1; 
         if( trends[1] == dir ) trend_calc_index = trend_peaks[1];
         else if( trends[2] == dir && trend_peaks[2] < 6 ) trend_calc_index = trend_peaks[2];
      }
   }
   
   return (trend);      
}
//*/                    