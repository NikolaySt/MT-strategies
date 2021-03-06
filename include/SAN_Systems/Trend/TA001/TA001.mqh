

void TA001_Trend_Init(int settID)
{
   int paramsSize = 1;
   double params[1]; ArrayInitialize(params, 0.0);        
   params[0] = TA001_ExtDepth;   
   TA001_ZZIndex_Trend = ZZGetIndexForParamsOrCreate(Trend_TimeFrame, params, paramsSize, "SAN_A_ZigZag");       
   if( Trend_Trace ) Print("[TA001_Trend_Init] TA001_ZZIndex_Trend = ", TA001_ZZIndex_Trend );      
}


int TA001_Trend_GetByIndex(int settID, int index)
{
   //Оставяме стария код за всеки случай, да виждаш къде е промяната
   //int peak[2];
   //int zzt = ZZGetLastTendence(TA001_ZZIndex_Trend, index, 0, peak); 
   //return (zzt); 
   return(ZZTypes_Get(TA001_ZZIndex_Trend, index));    
}

int TA001_Trend_GetLenghtByIndex(int settID, int index)
{
   double length = ZZValues_Get(TA001_ZZIndex_Trend, index) - ZZValues_Get(TA001_ZZIndex_Trend, index+1);
   return(MathAbs(length)/Point);   
}

datetime TA001_Trend_GetTimeByIndex(int settID, int index){
   return(ZZTimes_Get(TA001_ZZIndex_Trend, index));   
}

double TA001_Trend_GetValueByIndex(int settID, int index){
   return(ZZValues_Get(TA001_ZZIndex_Trend, index));   
}

void TA001_Utils_GetLastTrends( int count, int& trends[], int& trend_pindex[] )
{
   int trend_min_pips = 10;
   int lastPeak;
   int peaksbuf[2];
   
   lastPeak = 0;
   
   for( int i = 0; i < count; i++ )
   {
      trends[i] = ZZGetLastTendence(TA001_ZZIndex_Trend,lastPeak,0,peaksbuf, trend_min_pips);  
      trend_pindex[i] = peaksbuf[0]; 
      lastPeak = peaksbuf[0] + 1;
   }
   /*  
   string dbg;
   for( int ii=0; ii < count;ii++)
      dbg = StringConcatenate( dbg, ii, "=",trends[ii],";" );
   
   Print("[TA001_Utils_GetLastTrends] ", dbg ); 
   //*/
}

int TA001_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], int dir, int options,int& trend_index )
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
      //if( trends[1] == trends[2] )     
      // da niaa mnogo peakove obrazuvane sled posledniat trend!!
      if( trends[1] == trends[2] && (trend_peaks[1] <= trend_peaks[0] + 2) )      
      {
         trend = trends[1];
         trend_index = 1;
      }
   }
   
   return (trend);      
}