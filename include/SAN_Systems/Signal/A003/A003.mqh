

void A003_Signals_Init(int settID)
{  
   // dymanic mappings
   int paramsSize = 1;
   double params[1]; ArrayInitialize(params, 0.0);        
   params[0] = A003_ZZExtDepth;   
   A003_ZZIndex = ZZGetIndexForParamsOrCreate(Signal_TimeFrame, params, paramsSize, "SAN_A_ZigZag");   
}

void A003_Signals_Process(int settID)
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
   A003_Signals_Create(settID, signalTypes, signalTimes, signalLevels );
  
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

void A003_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[] )
{
  int ZZIndex = A003_ZZIndex;
  int seqPeaks = A003_SeqPeaks;
  int Options = A003_TrendOptions;
   
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
         trend = A003_Utils_GetTrendForDir(trends, trend_peaks, dir, Options, trend_index, trend_calc_index);
   
      //price = res[i];
      datetime signalTime =0;
      double signalLevel=0;
           
      if( trend*dir > 0 )
      {
         mintime = ZZTimes_Get(TA001_ZZIndex_Trend,  trend_calc_index);
                 
         int seqpRes = Signal_SeqPeaks_Get(dir, mintime, ZZIndex, seqPeaks, signalLevel, signalTime);
         
         if( signalLevel != 0 )
         {
            signalTypes[i] = trend;
            signalLevels[i] = signalLevel;
            signalTimes[i] = signalTime;           
         }
      }
      else if( trend == 0 )
      {
         PendingOrders_RemoveByDir( settID, dir );
      }
   }
}

int Signal_SeqPeaks_Get(  // trend options input
                           int trend, datetime minstarttime, 
                           // signal options input
                           int ZZIndex, int seqPeaks, 
                           // signal results output
                           double&  signalLevel,
                           datetime&  signalTime )
{
      // pyrvo izchislivame max do koj shift shte vzemem masiva
      // sas varhove koito ni triabvat
      int timeframe = Signal_TimeFrame;      
      static double peaks[50];
      // potencialno maksimalniat masiv shte e 2 pyti po goliam ot seqPeaks
      int peaks_size=0,peakIndex;
      signalLevel = 0;

      A003_Signal_SeqPeaksPrepare(trend, minstarttime, ZZIndex, seqPeaks*3 + 1, peakIndex, peaks, peaks_size );
      

      // ok veche imame peaks masiva napylnen veche
      // moje da prebroim ima li dostatychno posledovatelni 
      // vyrhove da ni zadovoli usovieto 
      int longseq = 0;
      if( peaks_size >= seqPeaks )
      {
         longseq = SAN_AUtl_GetLongestSequence( peaks, peaks_size, trend); 
         if( longseq >= seqPeaks )
         {
            signalLevel = ZZValues_Get(ZZIndex, peakIndex);
            signalTime = ZZTimes_Get(ZZIndex, peakIndex);
         } 
      }

      if( Signal_Trace && longseq > 0 )//&& signalLevel != 0)
         Print("[Signal_SeqPeaks_Get] trend=",trend,";peaks_size=",peaks_size,";longseq=",longseq,
            ";level=",signalLevel,";time=",signalTime,";", TimeToStr(signalTime));
}     

bool A003_Signal_SeqPeaksPrepare( int dir, datetime minstarttime, int ZZIndex, int maxsize, int& startPeakIndex, double& peaks[], int& size )
{
   string dbg;
   bool result=false;
   
   int peakIndex = 1;
   
   size = 0;
   
   if( (ZZTypes_Get( ZZIndex, peakIndex )*dir) < 0) peakIndex++;
   
   //if( peakIndex != 1 ) return (false);
      
   if( peakIndex == 2 )
   {
      //akopolednita nezavyrshen vryh veche e zadminal predishniat
      //veche nishto ne moje da se napravi
      if( dir*(ZZValues_Get(ZZIndex,peakIndex) - ZZValues_Get(ZZIndex,peakIndex-2)) < PipsToPoints(2) )
      {
         return (false);
      }
   }
   else 
   {
      //ako vryh edno e zadminal vryh 3 t.e. veche see vkluchil signal
      //i sega niama da iam uslovia za signalsas sigurnots da povtori
      //predishniat signal akos e e zatvoril da ima shans da go vkluchi pak
      if( dir*(ZZValues_Get(ZZIndex,peakIndex) - ZZValues_Get(ZZIndex,peakIndex+2)) > 0
          && dir*(ZZValues_Get(ZZIndex,3) - ZZValues_Get(ZZIndex,0)) > PipsToPoints(10) )
      {
         peakIndex = 3;
      }
   }
   
   startPeakIndex = peakIndex;
      
   double val0,val2;
   datetime val0time,val2time;
   int loop;
   loop = maxsize - 1;
   
   datetime times[50];
      
   while( loop > -1 )
   {
      val0 = ZZValues_Get( ZZIndex, peakIndex );
      val2 = ZZValues_Get( ZZIndex, peakIndex+2);
      
      val0time = ZZTimes_Get( ZZIndex, peakIndex);
      val2time = ZZTimes_Get( ZZIndex, peakIndex+2);
      
      peaks[size] = val0;
      times[size] = val0time;     
      
      if( loop != 0 && minstarttime !=0 && minstarttime > val0time )
      {
         //break on next iteration
         loop = 1;
      }
      
      //------
      loop--;
      size++;
      peakIndex += 2;
   }
   ///*
   if( Signal_Trace )
   {
      dbg="";
      for( int i = 0; i < size; i ++ )
         dbg = StringConcatenate(dbg,TimeToStr(times[i]),"=",peaks[i],";");
      Print("[A003_Signal_SeqPeaksPrepare] ", dbg );
   }
   //*/
   ///*
   if( Signal_Trace )
   {
      dbg="";
      for(i=0; i<4;i++)
         dbg = StringConcatenate(dbg,TimeToStr(ZZTimes_Get(ZZIndex,i)),"=",ZZValues_Get(ZZIndex,i),";");
      Print("[A003_Signal_SeqPeaksPrepare] zigzag 4p ", dbg ); 
   }  
   //*/
   // Print("[A003_Signal_SeqPeaksPrepare] valotime=",TimeToStr(val0time),";val0=",val0,";val2=", val2);
   
   if( size > 0 ) result = true;
   
   return (result);
}   

int A003_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], 
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