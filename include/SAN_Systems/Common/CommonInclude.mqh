
bool NewShift = false;
bool NewShiftH1 = false;
bool NewShiftH4 = false;
bool NewShiftD1 = false;
bool NewShiftAny = false;

bool Common_Trace = false;

void Common_Init(int settID)
{
   Expert_TimeFrame = SAN_AUtl_TimeFrameFromStr(Expert_TimeFrameS);   
}

void Common_Process(int settID)
{

   if (Expert_TimeFrame != 0 && (IsTesting() || IsOptimization())){
      CalcNewShiftForTimeFrame( Expert_TimeFrame, Shift1Time, NewShift);
      CalcNewShiftForTimeFrame( PERIOD_H1, Shift1TimeH1, NewShiftH1);
      CalcNewShiftForTimeFrame( PERIOD_H4, Shift1TimeH4, NewShiftH4);
      CalcNewShiftForTimeFrame( PERIOD_D1, Shift1TimeD1, NewShiftD1);
      NewShiftAny = NewShift || NewShiftH1 || NewShiftH4 || NewShiftD1;
   }else{

      NewShift = true;
      NewShiftH1 = true;
      NewShiftH4 = true;
      NewShiftD1 = true;
      NewShiftAny = true;
  }
}

bool Common_HasNewShift(int timeframe)
{
   bool result = true;
   if(Expert_TimeFrame != 0)
   {
      switch(timeframe)
      {
      case PERIOD_H1:
         result = NewShiftH1;
         break;
      case PERIOD_H4:
         result = NewShiftH4;
         break;
      case PERIOD_D1:
         result = NewShiftD1;
         break;
      }
   }
   return (result);
}

void CalcNewShiftForTimeFrame( int timeframe, datetime& lasttime, bool& newshift )
{
   newshift = false;   
   if( iTime(NULL, timeframe, 1) != lasttime )
   {
      newshift = true;
   }   
   lasttime = iTime(NULL, timeframe, 1);  
}

