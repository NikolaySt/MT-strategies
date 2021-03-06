
/*
int SAN_AUtl_TimeFrameFromStr( string value );
string SAN_AUtl_TimeFrameÒîStr( int TimeFrame );
double SAN_AUtl_BarValueByDir( int shift, int timeframe, int dir );
int SAN_AUtil_BarDir( int timeframe, int shift );
int SAN_AUtl_GetLongestSequence( double& seq[], int size, int type );
bool SAN_AUtl_StrToBool( string value );
bool SAN_AUtl_StrCompare( string s1, string s2 );
*/


int SAN_AUtl_TimeFrameFromStr( string value )
{
   //"M1 M5 M15 M30 H1 H4 D1 W1 MN
  int result = Period();
  if( value == "M1" ){ result = PERIOD_M1; }
  else if( value == "M5" ){ result = PERIOD_M5; } 
  else if( value == "M15" ){ result = PERIOD_M15; }   
  else if( value == "M30" ){ result = PERIOD_M30; }    
  else if( value == "H1" ) { result = PERIOD_H1; } 
  else if( value == "H4" ){ result = PERIOD_H4; } 
  else if( value == "D1" ){ result = PERIOD_D1; } 
  else if( value == "W1" ){ result = PERIOD_W1; }   
  else if( value == "MN" ){ result = PERIOD_MN1; }     
  return (result);
}

string SAN_AUtl_TimeFrameÒîStr( int TimeFrame )
{
   switch(TimeFrame){
      case PERIOD_M1: return("1 Minute");
      case PERIOD_M5: return("5 Minutes");
      case PERIOD_M15: return("15 Minutes");
      case PERIOD_M30: return("30 Minutes");
      case PERIOD_H1: return("1 Hour");
      case PERIOD_H4: return("4 Hours");
      case PERIOD_D1: return("Daily");
      case PERIOD_W1: return("Weekly");
      case PERIOD_MN1: return("Monthly");
      default: return("");
   }  
}

// double iBarValueByDirection( int shift, int dir )
double SAN_AUtl_BarValueByDir( int shift, int timeframe, int dir )
{
   double res = 0;
   if( dir > 0 ) res = iHigh( NULL, timeframe, shift);
   else res = iLow(NULL, timeframe, shift);
   return (res);
}

int SAN_AUtil_BarDir( int timeframe, int shift )
{
  double cp = iClose( NULL,timeframe, shift );
  double op = iOpen( NULL, timeframe, shift );
  
  double diff = cp - op;
  if( diff > 0 ) return (1);
  else if( diff < 0 ) return (-1);
  else return (0);  
}

int SAN_AUtl_GetLongestSequence( double& seq[], int size, int type )
{
   static int best[100], prev[100];
   int i, j, max = 0;
   
   bool first_ok = type*(seq[1] - seq[0]) > 0;
   
   if( first_ok )
   {
      max = 2;
      for( i = 2, j=1; i < size; i++ )
      {
         if( type*(seq[i] - seq[j]) > 0 )
         {
            j=i;
            max++;
         }  
      }
   }
   
   ///*
   //de bug
   string dbg;
   for( i = 0; i < size;i++ )
   {
      dbg = dbg + seq[i] + ",";
   }
   //Print( "[GetLongestSequence] res = ", max,";input type=", type, ";size=", size, ";data=", dbg );
   //*/
   
   return (max);
   /*
   //Print("[GetLongestSequence] enter size=",size);
 
   for ( i = 0; i < size; i++ )
   {
	   best[i] = 1;
	   prev[i] = i;
   }
   
   //type 1 narashtvasha poredica ot 0 do size 
   
   if( first_ok )
   {
	   for ( i = 2; i < size ; i++ )
	   {
		  for ( j = 1; j < i; j++ )
		  {
			 //type 1 is searching for increasing seq -1 for decreasing seq
			 if( (type*(seq[i] - seq[j]) > 0) && (best[i] < best[j] + 1)  
				 && (type*(seq[i] - seq[1]) > 0))
			 {
				best[i] = best[j] + 1; 
				prev[i] = j;
			 }
		  }
	   }
   }
   
   int max_last_index; 
   for ( i = 0; i < size; i++ )
   {
      if ( max < best[i] )
	  {
         max = best[i];
         max_last_index = i;
	  }
   }
   if( max > 0 && first_ok ) max++;
   //*/
   /*
   int prev_index = max_last_index;
	static int max_sequence[100];
	for( i = max-1; i >= 0; i-- )
	{
		max_sequence[i] = prev_index;
		prev_index = prev[prev_index];
	}
	//printf( "max sequence type %d size %d:",type, max );
	string strmaxarr = StringConcatenate("size=",max,";");
	for( i = 0; i < max; i++ )
	{
	   strmaxarr = StringConcatenate( strmaxarr,max_sequence[i],"=", seq[max_sequence[i]],",");
	}
	
   Print("[GetLongestSequence] exit res=",strmaxarr);
   //*/
  
   
   return (max);
}

bool SAN_AUtl_StrToBool( string value )
{
   bool result = false;
   result = SAN_AUtl_StrCompare(value, "true");
   return (result);
}

bool SAN_AUtl_StrCompare( string s1, string s2 )
{
   bool result;
   result = false;
   
   if( StringLen(s1) == StringLen(s2) )
   {
      result = StringFind( s1, s2 ) == 0;
   }

   return (result); 
}

double iBarLoHiByDir(int timeframe, int shift, int dir)
{
   if( dir > 0 ) return (iHigh(NULL,timeframe,shift));
   else if(dir < 0) return (iLow(NULL,timeframe,shift));
   else return (iHigh(NULL,timeframe,shift));//should never happend
}