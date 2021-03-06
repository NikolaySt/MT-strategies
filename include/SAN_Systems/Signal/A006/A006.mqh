

void A006_Signals_Init(int settID)
{  
   // dymanic mappings
   int paramsSize = 1;
   double params[1]; ArrayInitialize(params, 0.0);        
   params[0] = A006_ZZExtDepth;   
   A006_ZZIndex = ZZGetIndexForParamsOrCreate(Signal_TimeFrame, params, paramsSize, "SAN_A_ZigZag");   
}

void A006_Signals_Process(int settID)
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
   A006_Signals_Create(settID, signalTypes, signalTimes, signalLevels );
  
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

void A006_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[] )
{
  int ZZIndex = A006_ZZIndex;
  int Options = A006_TrendOptions;
   
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
         trend = A006_Utils_GetTrendForDir(trends, trend_peaks, dir, Options, trend_index, trend_calc_index);
   
      //price = res[i];
      datetime signalTime =0;
      double signalLevel=0;
           
      if( trend*dir > 0 )
      {                
         A006_Signal_Get(dir, ZZIndex, signalLevel, signalTime);
         //A006_Signal_GetFirstTry(dir, ZZIndex, signalLevel, signalTime);
         
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

int A006_Signal_Get(int dir, int ZZIndex, double& signalLevel, datetime& signalTime)
{
   //namirane na pyrviat obraten vryh
   int rpi = A006_MinSignalPeak;

   if( ZZTypes_Get(ZZIndex, rpi) == dir ) rpi+=1;
   
   double lastLevel0=0,lastLevel2,v0,v2,v4,lastIndex=-1;
   
   for( int index = rpi; index < A006_MaxPeaksBack; index+=2 )
   {
      v0 = ZZValues_Get(ZZIndex,index);
      v2 = ZZValues_Get(ZZIndex,index+2); 
      v4 = ZZValues_Get(ZZIndex,index+4);
      if( dir*(v0 - v2) > 0 )
      {
         lastIndex = index;
         lastLevel0 = v0;
         lastLevel2 = v2;
         break; 
      }
   }
   
   bool signalOK = false;
   
   //double sv1,sv3,sv5,sv7;   
   //sv1 = ZZValues_Get(ZZIndex,rpi+1);
   //sv3 = ZZValues_Get(ZZIndex,rpi+3);
   //sv5 = ZZValues_Get(ZZIndex,rpi+5);
   //sv7 = ZZValues_Get(ZZIndex,rpi+7);
      
   //if(lastIndex >= 2)
   //{
   //   //tova e dobre niama smisyl da ima drugi uslovia tuk
   //   signalOK = true;
   //}
   //else //0,1
   //{      
      //signalOK = false;
      //if(dir*(sv1 - sv3) > 0) signalOK = true; //4400/850/253 orders 
      //if(dir*(sv1 - sv3) < 0) signalOK = true;   //1000/1000/155 orders
      //if(dir*(sv3 - sv5) > 0) signalOK = true;   //3700/110/229 orders
      //if(dir*(sv3 - sv5) < 0) signalOK = true;   //2100/700/179 orders
      //if(dir*(sv1 - sv5) > 0) signalOK = true;//3200/1050/245 orders
      //if(dir*(sv1 - sv5) < 0) signalOK = true;//2700/550/161 orders
      //signalOK = true;//5900/1250/409 orders      
   //}
   
   //maj naj-dobre e bez drugi uslovia
   signalOK = true;//9000/950/571 orders
   
   if( lastIndex >= A006_MinSignalPeak 
       && signalOK     
       )
   {
      if(Signal_Trace) 
         Print("[A006_Signal_Get] lastSignal dir=",dir,
               ";l0=",lastLevel0,";l2=",lastLevel2,
               ";t0=", TimeToStr(ZZTimes_Get(ZZIndex,lastIndex)));  
      
      signalLevel = ZZValues_Get(ZZIndex,rpi+1);
      signalTime  = ZZTimes_Get(ZZIndex,rpi+1);                                                                         
   }
}
  
///*
int A006_Utils_GetTrendForDir( int& trends[],int& trend_peaks[], 
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