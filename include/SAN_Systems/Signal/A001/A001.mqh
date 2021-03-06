
void A001_Signals_Init(int settID)
{  
   // dymanic mappings
}


void A001_Signals_Process(int settID)
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
  A001_Signals_Create(settID, signalTypes, signalLevels, signalTimes);
  
  /*
  if( Signal_Trace && signalTypes[0] != 0)
  {
      Print("Orders 0 type=",signalTypes[0],";level=", signalLevels[0],
            ";1 type=",signalTypes[1],";level=", signalLevels[1] );
  }
  //*/
   
  Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels,  ordersTickets);
  
}

void A001_Signals_Create(int settID, int& signalTypes[], double& signalLevels[], datetime& signalTimes[] )
{
   int SignalCnt = A001_InnerBars;
   int Options =   A001_TrendOptions;
   int timeframe = Signal_TimeFrame;
   
   int trends[10], trend_peaks[10], Direction[2];   
   Direction[0] = 1;//buy
   Direction[1] = -1;
   
   double price;
   int shift = 1,trend_index,dir;
          
   if( Options != -1 )       
      TA001_Utils_GetLastTrends( 5, trends, trend_peaks );            

   int shift_sign = A001_Signal_GetForInnerBars(SignalCnt);
   
   if( shift_sign > 0 )
   {
    //make some orders 
      int trend; 
      for( int i = 0; i < 2; i++ )
      {
         dir = Direction[i];       
         
         if(Options == -1)
            trend = Common_Trend_GetByIndex(settID, 0);
         else        
            trend = A001_Utils_GetTrendForDir(trends, trend_peaks, dir, Options, trend_index);
            
         if( trend*dir > 0 )
         {
            price = SAN_AUtl_BarValueByDir( shift_sign, timeframe, trend);
            signalTypes[i] = trend;
            signalLevels[i] = price;
            signalTimes[i] = iTime(NULL,timeframe,shift);
         }
      }   
   } 
}

int A001_Signal_GetForInnerBars( int SignalCnt )
{
   int result = 0;
   double min,max,bmin,bmax;
   int timeframe = PERIOD_H4;
   
   min = iLow(NULL, timeframe, SignalCnt+1);
   max = iHigh(NULL, timeframe, SignalCnt+1);
   
   bmin = iClose(NULL, timeframe, iLowest( NULL, timeframe, MODE_CLOSE, SignalCnt, 1));
   bmax = iClose(NULL, timeframe, iHighest( NULL, timeframe, MODE_CLOSE, SignalCnt, 1));
   
   //tova e po dobre kato  cialo
   //bmin = Low[iLowest( NULL, 0, MODE_CLOSE, SignalCnt, 0)];
   //bmax = High[iHighest( NULL, 0, MODE_CLOSE, SignalCnt, 0)];
   
   //bmin = Low[iLowest( NULL, 0, MODE_LOW, SignalCnt, 0)];
   //bmax = High[iHighest( NULL, 0, MODE_HIGH, SignalCnt, 0)];
   
   if(Signal_Trace) Print("[GetSignalForInnerBars] SignalCnt=",SignalCnt,";time=",
      TimeToStr(iTime(0,timeframe,SignalCnt+1)),
      ";result=", (bmin > min && max > bmax), 
      ";min=", min, ";max=", max, ";bmin=", bmin, ";bmax=", bmax );     

   if( bmin > min && max > bmax )
   {
      result = SignalCnt +1;
      if( Signal_Trace ) 
      {
         Print("[A001_Signal_GetForInnerBars] result=",result,";dt=", TimeToStr( Time[1] ),
                  ";min=", min,";max=",max);
      }
   }
   
   return (result);
}

int A001_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], int dir, int options,int& trend_index )
{
   int result = 0;
   
   //ako e  po malko to 10 originalnata versia ot predishnata logika
   if( options < 10 ) 
      result = A001_Utils_GetTrendForDir_old(trends, trend_peaks, dir, options, trend_index);
   else if( options >= 10 && options < 20 )
      result = TA001_Utils_GetTrendForDir(trends, trend_peaks, dir, options-10, trend_index);
   
   return (result);
}

int A001_Utils_GetTrendForDir_old( int& trends[],int& trend_peaks[], int dir, int options,int& trend_index )
{
   int trend;
   trend = 0;
   
   if( options == 0 )
   {
      trend = dir;
   }
   
   if( options&1 == 1 )
   {
      trend = trends[0];
      trend_index = 0;
   }
   
   if( options&2 == 2 && trends[0] != trends[1] )
   {    
      if( trends[1] == trends[2] && 
            (trends[1] == trends[3] || trends[1] == trends[4]) )      
      {
         trend = trends[1];
         trend_index = 1;
      }
   }
   
   if(trend!=0 && trend*dir <0)
   {
      trend = 0;
   }
   
   return (trend);      
}