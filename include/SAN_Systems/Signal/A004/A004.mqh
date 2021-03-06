

void A004_Signals_Init(int settID)
{  
   if( A004_CorrZZDepth > 0 )
   {
      int paramsSize = 1;
      double params[1]; ArrayInitialize(params, 0.0);        
      params[0] = A004_CorrZZDepth;   
      A004_CorrZZIndex = ZZGetIndexForParamsOrCreate(Signal_TimeFrame, params, paramsSize, "SAN_A_ZigZag"); 
   }
   else
   {
      A004_CorrZZIndex = 0;
   }
}

void A004_Signals_Process(int settID)
{ 
   Common_Stop_ProcessAll(settID); 
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;
   

   //------------------------------------ВРЕМЕВИ ФИЛТЪР НА СИГНАЛА НА СИСТЕМАТА----------------------
   //времеви фитър, системата работи само в зададения период от часове през деня
   // ако е 0 - 24 работи през цения ден
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;
   //------------------------------------------------------------------------------------------------   
      
   int signalTypes[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersMagic[2];
   int ordersTickets[2];
    
   ArrayInitialize(signalTypes,0);
  
   //1. signal
   A004_Signals_Create(settID, signalTypes, signalTimes, signalLevels );
  
  /*
  if( Signal_Trace && signalTypes[0] != 0)
  {
      Print("Orders 0 type=",signalTypes[0],";level=", signalLevels[0],
            ";1 type=",signalTypes[1],";level=", signalLevels[1] );
  }
  //*/
   
  Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels,  ordersTickets);
  
}

void A004_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[] )
{
  int Options = A004_TrendOptions;
   
   //get last peak
   int Direction[2],dir, shift, trend,i, trend_index,trend_calc_index;
   int trends[10], trend_peaks[10];

   Direction[0] = 1;//buy
   Direction[1] = -1;
        
   if( Options != -1 )       
      TA001_Utils_GetLastTrends( 5, trends, trend_peaks ); 
   
   for( i = 0; i < 2; i++ )
   {
      dir = Direction[i];   
      if(Options == 0)
         trend = dir;
      else if(Options == -1)
         trend = Common_Trend_GetByIndex(settID, 0);
      else         
         trend = A004_Utils_GetTrendForDir(trends, trend_peaks, dir, Options, trend_index, trend_calc_index);
   
      datetime signalTime =0;
      double signalLevel=0;
           
      if( trend*dir > 0 )
      {       
         Signal_DayBarMinMax_Get( dir, A004_BarsCount, signalLevel, signalTime);
                                                
         if(A004_CorrZZDepth > 0)
         {
            int peak_type = ZZTypes_Get(A004_CorrZZIndex,0);
            
            //ako niama korekciq mi 
            //prodyljava nagore izobshtod a premahne znaka
            if(peak_type*dir > 0)
            {
               signalLevel = 0;
            }
         }                                                
         
         if( signalLevel != 0 )
         {
            signalTypes[i] = trend;
            signalLevels[i] = signalLevel;
            signalTimes[i] = signalTime;           
         }
      }
      else if( trend*dir <= 0 && A004_RemoveOnRevTrend == 1)
      {
         PendingOrders_RemoveByDir( settID, dir );
      }
   }
}

int Signal_DayBarMinMax_Get(  // trend options input
                           int trend,
                           // signal options input
                           int barsCount, 
                           // signal results output
                           double&  signalLevel,
                           datetime&  signalTime )
{
      // pyrvo izchislivame max do koj shift shte vzemem masiva
      // sas varhove koito ni triabvat
      int timeframe = Signal_TimeFrame;      
      signalLevel = 0;
           
      if( (iOpen(NULL,timeframe,1) - iClose(NULL, timeframe, 1))*trend > PipsToPoints(A004_MinBarPips) )
      {
         int signalShift = 1;
         
         if(barsCount > 1)
         {
            if(trend > 0)
            {
               signalShift = iHighest(NULL, timeframe, MODE_HIGH, barsCount, 1);
            }
            else
            {
               signalShift = iLowest(NULL, timeframe, MODE_HIGH, barsCount, 1);
            }
         }
         
         if(trend > 0)
         {
            signalLevel = iHigh(NULL, timeframe, signalShift);
         }
         else
         {
            signalLevel = iLow(NULL, timeframe, signalShift);
         }
         
         if(A004_MaxPipsOffset > 0 && signalLevel > 0)
         {
             double curP =  iClose(NULL, timeframe,1);
             if( (signalLevel - curP)*trend > PipsToPoints(A004_MaxPipsOffset) )
             {
               signalLevel = curP + trend*PipsToPoints(A004_MaxPipsOffset);
             }
         }
         
         signalTime = iTime(NULL, timeframe, signalShift);
      }
      

      //if( Signal_Trace && longseq > 0 )//&& signalLevel != 0)
      //   Print("[Signal_SeqPeaks_Get] trend=",trend,";peaks_size=",peaks_size,";longseq=",longseq,
      //      ";level=",signalLevel,";time=",signalTime,";", TimeToStr(signalTime));
}     

int A004_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], 
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