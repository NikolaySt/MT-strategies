

//bool A005_Test_OpenRaw = true;
#define A005_TenkanKijunSenCrossT  1
#define A005_KijunSenCrossT        2
#define A005_KumoBreakoutT         3
#define A005_TenkanSenCrossT       6


void A005_Signals_Init(int settID)
{  
   A005_iChimoku_TimeFrame = SAN_AUtl_TimeFrameFromStr(A005_iChimoku_TimeFrameS); 
   
   if( A005_SignalZZDepth > 0 )
   {
      int paramsSize = 1;
      double params[1]; ArrayInitialize(params, 0.0);        
      params[0] = A005_SignalZZDepth;
      
      A005_SignalZZIndex = ZZGetIndexForParamsOrCreate(Signal_TimeFrame, params, paramsSize, "SAN_A_ZigZag");
   }
   else
   {
      A005_SignalZZIndex = 0;
   }
   
}

void A005_Signals_Process(int settID)
{ 
  Common_Stop_ProcessAll(settID); 
   
  if( Common_HasNewShift(Signal_TimeFrame) == false &&
      Common_HasNewShift(A005_iChimoku_TimeFrame) == false    ) return;
      
   int signalTypes[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersMagic[2];
   int ordersTickets[2];
   int signalsCount[2];
   signalsCount[0] = 0;
   signalsCount[1] = 0;
   for( int type = 1; type <=6; type++)
   {
      A005_Signals_Create(settID, type, signalTypes, signalTimes, signalLevels );
      
      if ( signalTypes[0] !=0 ) signalsCount[0] = signalsCount[0] + 1;
      if ( signalTypes[1] !=0 ) signalsCount[1] = signalsCount[1] + 1;
      
      Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels,  ordersTickets); 
   }
   
   if( signalsCount[0] == 0 ) PendingOrders_RemoveByDir( settID, 1 );
   if( signalsCount[1] == 0 ) PendingOrders_RemoveByDir( settID, -1 );
   /*
      else
   {
      //remove pending orders if signal not generated
      PendingOrders_RemoveByDir( settID, Direction[i] );
   } */
   
         
}

void A005_Signals_Create(int settID, int type,  int& signalTypes[], datetime& signalTimes[], double& signalLevels[] )
{
   signalTypes[0] = 0;
   signalTypes[1] = 0;  
   int Direction[2];
   Direction[0] = 1;
   Direction[1] = -1;
   
   int signalType;
   datetime signalTime;
   double signalLevel;
   
   for(int i = 0; i < 2; i++ )
   {
      signalType = 0;
      signalTime = 0;
      signalLevel = 0;
      
      A005_Signal_CreateForDir( settID, type, Direction[i], signalType, signalTime, signalLevel);
      
      if( signalType != 0 )
      {
         signalTypes[i] = signalType;
         signalTimes[i] = signalTime;
         signalLevels[i] = signalLevel;
      }  
   }
}

void A005_Signal_CreateForDir(int settID, int type, int dir, int& signalType, datetime& signalTime, double& signalLevel )
{
   int options = 0;
   switch(type)
   {
   case A005_TenkanKijunSenCrossT:
      options = A005_TenkanKijunSenCross;
      if( A005_TenkanKijunSenCross != 0 )   
         A005_TnkKijunSenCross_Create(settID, dir, signalType, signalTime, signalLevel);
      break;
   case A005_TenkanSenCrossT:
      options = A005_TenkanSenCross;
      if( A005_TenkanSenCross != 0 )
         A005_TenkanSenCross_Create(settID, dir, signalType, signalTime, signalLevel);   
      break;
   case A005_KijunSenCrossT:
      options = A005_KijunSenCross;
      if( A005_KijunSenCross != 0 )
         A005_KijunSenCross_Create(settID, dir, signalType, signalTime, signalLevel);
      break;
   case A005_KumoBreakoutT:
      //options = A005_KumoBreakout;
      if( A005_KumoBreakout != 0 )
         A005_KumoBreakout_Create(settID, dir, signalType, signalTime, signalLevel);
      break;
   case 4:
      if( A005_SenkouSpanCross != 0 )
         A005_SenkouSpanCross_Create(settID, dir, signalType, signalTime, signalLevel);
      break;
   
   }
   
   bool isStrong, isNeutral, isWeak;
   
   isStrong = false;
   isNeutral = false;
   isWeak = false;
   
   if( options&1 == 1 ) //Generate Strong Signal
   {      
   }
   if( options&2 == 2 ) //Generate Neutral Signal
   {
   }
   if( options&4 == 4 ) //Generate Weak Signal
   {
   }
   
   if( options != 0 && signalType != 0)
   {
      if( !(isStrong || isNeutral || isWeak) )
      {
         //there is signal but not for the configured type
         //so remove the signal
         //signalType = 0;
      }
   }
}

void A005_SenkouSpanCross_Create(int settID, int dir, int& signalType, datetime& signalTime, double& signalLevel )
{
   int shift = A005_SenkouSpanCross_GetLast(dir);

   if( shift > 0 )
   {
      int t = A005_KumoType_GetForBar( dir, shift, shift, A005_iChimoku_TimeFrame );
                               
      if( A005_SignalOptions_Active( A005_SenkouSpanCross, t ) )
      {  
         //ako posledniat bar e v posokata na crossa generirame signal
         if( dir*(iClose(NULL, A005_iChimoku_TimeFrame, 1) - iOpen( NULL, A005_iChimoku_TimeFrame, 1)) > 0)
         {
            signalType = dir;
            signalTime = iTime( NULL, A005_iChimoku_TimeFrame, shift );
            signalLevel = 0;  
            
            if(Signal_Trace)
               Print( "A005_SenkouSpanCross_Create signal ", dir, ";time=", TimeToStr(signalTime),
                        ";type=",A005_KumoType_toString(t) );
         }   
      }  
   } 
}

int A005_SenkouSpanCross_GetLast( int dir, int maxshift = 10 )
{ 
   return (A005_iChimokuCross_GetLast(dir,MODE_SENKOUSPANA,MODE_SENKOUSPANB,maxshift));
}


int A005_KumoCloud_GetType( int shift, double& a, double& b )
{  
   a = iChimoku_GetSenkouSpanA(shift);
   b = iChimoku_GetSenkouSpanB(shift);
   
   int kumoType = 0;
   
   if( a > b ) //bulish kumo
      kumoType = 1;
   else if( b > a ) //bearish kumo
      kumoType = -1;
      
   double b1 = iChimoku_GetSenkouSpanB(shift+1);
   double b2 = iChimoku_GetSenkouSpanB(shift+2);
   double b3 = iChimoku_GetSenkouSpanB(shift+3);
   
   //alos we can chekc for flat bottom or flash top for buulish/bear Kumo
   //if the Kumo is flas return 2 buy or -2 sell kumo
   if( b==b1 && b == b2 && b ==b3 ) kumoType = kumoType*2;
               
   return (kumoType);
}

bool A005_BarBreakoutLevel( int dir, double level, double level1, double level2, int shift, int timeframe )
{
   bool result = false;
   
   if(  dir*A005_Bar_GetDir(timeframe, shift) > 0 &&
        dir*(iClose( NULL, timeframe, shift ) - level) > 0  )
   {
      if( 
          dir*( iClose( NULL, timeframe, shift + 1 ) - level1) <= 0  &&
          dir*( iClose( NULL, timeframe, shift + 2 ) - level2) < 0
           )
      {
         //ako predishniat bar i close i open sa vytre
         //moje da se lsuchi pri preskachane na dannite sabota nedelia
         //i podobni situacii
         result = true;
      }
   }
   
   /*
   if(Signal_Trace)
      Print("A005_BarBreakoutLevel result=",result,";level=",level,";level1=",level1,
         ";open=",iOpen( NULL, A005_iChimoku_TimeFrame, shift ),
         ";close=",iClose( NULL, A005_iChimoku_TimeFrame, shift ),
         ";open1=",iOpen( NULL, A005_iChimoku_TimeFrame, shift + 1),
         ";close1=",iClose( NULL, A005_iChimoku_TimeFrame, shift + 1 ),
         ";cnd1=",dir*(iClose( NULL, A005_iChimoku_TimeFrame, shift ) - level) > 0,
         ";cnd2p1=",dir*(level - iOpen( NULL, A005_iChimoku_TimeFrame, shift + 1 )) > 0,
         ";cnd2p2=",dir*(level - iClose( NULL, A005_iChimoku_TimeFrame, shift + 1 )) > 0 
         );
   //*/          
   return (result);          
}

int A005_KumoBreakout_GetLast(int dir, double& signalLevel,double& level )
{
   int mode = MODE_SENKOUSPANA;
   int mode2 = MODE_SENKOUSPANB;

   int zzIndex ;
   return (0);
   //return (A005_LineCross_GetLast( dir, mode, mode2, false,// checkTenkanSenOver
   //                         signalLevel, level, zzIndex ));
}

int A005_KumoBreakout_GetLastOld(int dir, int maxshift = 5)
{
   double a,b,a1,b1,a2,b2, kumoHighLowVal,khlv1,khlv2;
   int resultShift = -1;
   
   for(int shift = 1; shift <= maxshift; shift++ )
   {
      int kumoType = A005_KumoCloud_GetType(shift,a,b);
      kumoHighLowVal = A005_MinMaxByDir(dir,a,b);
       
      A005_KumoCloud_GetType(shift+1,a1,b1);      
      khlv1 = A005_MinMaxByDir(dir,a1,b1);
      
      A005_KumoCloud_GetType(shift+2,a2,b2);      
      khlv2 = A005_MinMaxByDir(dir,a2,b2);
         
      if( A005_BarBreakoutLevel(dir, kumoHighLowVal, khlv1, khlv2, shift, A005_iChimoku_TimeFrame) == true)
      {
         resultShift = shift;
         ///*
         if( Signal_Trace )
         {
            Print("[A005_KumoBreakout_GetLast] SignalType=",dir,";kumotype=",kumoType,";a=",a,";b=",b,";highLowVal=",kumoHighLowVal,
               ";close=",iClose( NULL, A005_iChimoku_TimeFrame, shift ),
               ";open=",iOpen( NULL, A005_iChimoku_TimeFrame, shift ),
               ";dir=",dir,
               ";cnd1=",dir*(iClose( NULL, A005_iChimoku_TimeFrame, shift ) - kumoHighLowVal) > 0,
               ";cnd2=",dir*( kumoHighLowVal - iOpen( NULL, A005_iChimoku_TimeFrame, shift ) ) >= 0 );
         }
         //*/
         break;
      }         
   }
   
   return (resultShift);
}
   
void A005_KumoBreakout_Create(int settID, int dir, int& signalType, datetime& signalTime, double& signalLevel )
{  
   double slevel,klevel;
   int zzIndex;
   
   int mode = MODE_SENKOUSPANA;
   int mode2 = MODE_SENKOUSPANB;
   
   int shift = 0;//A005_LineCross_GetLast( dir, mode, mode2, false,// checkTenkanSenOver
                 //                       slevel, klevel, zzIndex );
   
   if( shift > 0)
   {
      double a,b;
      int t = A005_KumoCloud_GetType(shift, a,b);
      
      if( dir == t ) t = 1;//strong
      else if( dir == -t ) t = 4;// weak
      else t = 2; //neutral t = -2 or 2
                               
      if( A005_SignalOptions_Active( A005_KumoBreakout, t ) )
      {
         int signalShift = iBarShift(NULL, Signal_TimeFrame, ZZTimes_Get(A005_SignalZZIndex, zzIndex));
         A005_Signal_TryOpen(settID, dir, A005_KumoBreakoutT, t, signalShift, slevel,
                               signalType, signalTime, signalLevel ); 
      }
   }  
}

double A005_Lines_GetValue(int dir, int shift, int mode, int mode2=0)
{
   if( mode2 == 0 )
   {
      return (iChimoku_GetValue(mode, shift));
   }
   else
   {
      double v1,v2;
      double result = 0;
      
      v1 = iChimoku_GetValue(mode, shift);
      v2 = iChimoku_GetValue(mode2, shift);

      if(dir>0) result = MathMax(v1,v2);//buy
      else result = MathMin(v1,v2);
      
      return (result);      
   }
}

void A005_LineCrossBars_GetStart( int dir, 
                                  int mode, int mode2, 
                                  int barsCount, int maxshift,                                  
                                  
                                  int&    startShift,                                  
                                  double& startLevel,
                                  
                                  int&    startCrossShift,
                                  double& startCrossLevel,
                                  
                                  int&    endShift,
                                  double& endLevel                                  
                                  )
{
   int shift,so;
   int cd,matchCount,rmatchCount;
   double diff,rdiff,lv,rlv,cp,rcp,cp1,hi,lo;
   
   startShift = -1;
   startCrossShift = -1;
   endShift = -1;
   
   for(shift=1; shift <= maxshift; shift++)
   {
      matchCount = 0;
      rmatchCount = 0;
      
      so = 0;
      lv = A005_Lines_GetValue(dir, shift + so, mode, mode2);
      rlv = A005_Lines_GetValue(-dir, shift + so, mode, mode2);
      
      //pyrviat bar veceh otgovaria na uslovieto
      for(so = 0; so < barsCount; so++ )
      {         
         cp = iBarLoHiByDir( A005_iChimoku_TimeFrame, shift + so, dir );         
         diff = dir*(lv - cp);
         
         if(diff > 0) matchCount++;//niama savpadenie
         
         
         rcp = iBarLoHiByDir( A005_iChimoku_TimeFrame, shift + so, -dir );         
         rdiff = -dir*(rlv - rcp);
         
         if(rdiff > 0) rmatchCount++;
         
         if(matchCount>0 && rmatchCount>0) break;//ima v protivopolojna posoka i tekushta
          
      }
      
      if( rmatchCount >= barsCount) break;//ima syvpadenie v obratna posoka
      
      if(matchCount >= barsCount)
      {
         cp = iBarLoHiByDir( A005_iChimoku_TimeFrame, shift, dir );
         diff = dir*(lv - cp);

         if( diff <= PipsToPoints(150) )
         {
            startShift = shift;
            startLevel = lv;
         }
         break;  
      }
   }
   
   if(startShift > 1)
   {
      for(shift=startShift-1; shift >= 1; shift--)
      {
         lv = A005_Lines_GetValue(dir, shift, mode, mode2);  
         cp1 = iClose( NULL, A005_iChimoku_TimeFrame, shift );
         if( dir*(cp1 - lv) > 0 )
         {
            startCrossShift = shift;
            startCrossLevel = lv;
            break;
         }
      }
   }
   
   if(startCrossShift > 1)
   {
      for(shift=startCrossShift-1; shift >= 1; shift--)
      {
         lv = A005_Lines_GetValue(dir, shift, mode, mode2);
         cp = iBarLoHiByDir( A005_iChimoku_TimeFrame, shift, -dir ); 
         
         if(dir*(cp-lv) > 0)
         {
            endShift = shift;
            endLevel =  lv; 
            break;  
         }  
      }
   }
   
   if( Signal_Trace && startShift > 0)
   {
      string dbg=StringConcatenate("[A005_LineCrossBars_GetStart] d=",dir,";");
      dbg = StringConcatenate(dbg,"s=",
            TimeToStr(iTime(NULL,A005_iChimoku_TimeFrame,startShift)),";",startLevel);
      if(startCrossShift > 0)
      {
         dbg = StringConcatenate(dbg,"cs=",
         TimeToStr(iTime(NULL,A005_iChimoku_TimeFrame,startCrossShift)),";",startCrossLevel);      
         if(endShift > 0)
         {
            dbg = StringConcatenate(dbg,"es=",
            TimeToStr(iTime(NULL,A005_iChimoku_TimeFrame,endShift)),";",endLevel);      
         
         }
      }                          
      Print(dbg);                           
   }
}

int A005_LineCross_GetStart( int dir, int mode, int mode2, int barsCount, int maxshift )
{
   int resShift = -1;
   int cd,matchCount;
   double diff,lv,cp;
   
   for(int shift=1; shift <= maxshift; shift++)
   {
      //lv = A005_Lines_GetValue(dir, shift, mode, mode2);
         
      matchCount = 0;

      //pyrviat bar veceh otgovaria na uslovieto
      for(int so = 0; so < barsCount; so++ )
      {
         lv = A005_Lines_GetValue(dir, shift + so, mode, mode2);
         cp = iBarLoHiByDir( A005_iChimoku_TimeFrame, shift + so, dir );         
         diff = dir*(lv - cp);
         
         if(diff < 0) break;//niama savpadenie
   
         matchCount++; 
      }
      
      if(matchCount >= barsCount)
      {
         resShift = shift;
         break;  
      }
   }
   
   return (resShift);
}

int A005_LevelCross_GetZZIndex( int dir, double level, datetime minTime )
{
   int reszzi = -1;
   int ind;
   int zzi = A005_SignalZZIndex;
   double v0,v1,v00;
   
   if(ZZTypes_Get(zzi,0) == dir)
   { 
      ind = 0;
      if(ZZTypes_Get(zzi,ind) == dir) ind = 2;
   }
   else ind = 1;
        
   while( ZZTimes_Get(zzi,ind) >= minTime )
   {
      v00 = ZZValues_Get(zzi,ind-1);
      v0 = ZZValues_Get(zzi,ind);
      v1 = ZZValues_Get(zzi,ind+1);
      
      //tyrsene na presechna tochka
      if( dir*(v0 - level) > 0 && dir*(v1 - level)<=0 )
                                 //(dir*(v1 - level)<=0 || dir*(v00 - level)<=0))
      {
         reszzi = ind;
         break;   
      }
      
      ind+=2;
   }
   
   return (reszzi);
}

int A005_LineCross_GetLast( int dir, int mode, int mode2, bool checkTenkanSenOver, 
                             datetime& signalTime,
                             double& signalLevel, 
                             double& level )
{
   int result = -1,ind;
   int stage1Shift =0;
   int startShift,startCrossShift,endShift;
   double startLevel,startCrossLevel,endLevel;
   datetime stage2MinTime;
   double stage1Level,cp;
   int stage2zzi;
   
   int maxbarsInH = 3;
   /// stage 1 find x bars (3 for now) with high price below line level
   //stage1Shift = A005_LineCross_GetStart(dir, mode, mode2, 
   //                                                     maxbarsInH,//3 sequent high bars
   //                                                     maxbarsInH*2 // max Bars in history
   //                                                     ); 
   A005_LineCrossBars_GetStart(dir, mode, mode2,maxbarsInH,7*maxbarsInH,
                                 startShift,startLevel,startCrossShift,startCrossLevel,
                                 endShift,endLevel);

   if( false && endShift > 0 )
   {
      cp = iClose(NULL,PERIOD_H1,1);
      if( dir*(cp - endLevel) > 0 )
      {
         signalTime = iTime(NULL, A005_iChimoku_TimeFrame, endShift);
         signalLevel = 0;
         level = startLevel;
         result = endShift;
      }
      /*
      if( SAN_AUtil_BarDir(A005_iChimoku_TimeFrame,1) == -dir )
      {
         signalTime = iTime(NULL, A005_iChimoku_TimeFrame, endShift);
         signalLevel = SAN_AUtl_BarValueByDir(1,A005_iChimoku_TimeFrame,dir);
         level = endLevel;
         result = endShift;            
      }*/
      /*
      if( ZZTimes_Get(A005_SignalZZIndex,1) >= 
         iTime( NULL, A005_iChimoku_TimeFrame,endShift) )
      {
         ind = 1;
         if( ZZTypes_Get(A005_SignalZZIndex,0) == dir ) 
         {
            ind = 2;
            if( dir*(ZZTypes_Get(A005_SignalZZIndex,0)-ZZTypes_Get(A005_SignalZZIndex,2)) > 0 ) 
               ind = 0;//abort search
         } 
         
         cp = ZZValues_Get(A005_SignalZZIndex,ind);
         
         if(ind > 0 && dir*(cp-startCrossLevel) > 0)
         {
            signalTime = iTime(NULL, A005_iChimoku_TimeFrame, endShift);
            signalLevel = ZZValues_Get(A005_SignalZZIndex,ind);
            level = endLevel;
            result = endShift;   
            //Print("st=",TimeToStr(signalTime),";level=",signalLevel,";zzind=",ind);
         }
      }
      */
   }
   
   if( result <= 0 && startCrossShift > 0 )
   {
      if( ZZTimes_Get(A005_SignalZZIndex,1) >= 
         iTime( NULL, A005_iChimoku_TimeFrame,startCrossShift) )
      {
         ind = 1;
         if( ZZTypes_Get(A005_SignalZZIndex,0) == dir ) 
         {
            ind = 2;
            if( dir*(ZZTypes_Get(A005_SignalZZIndex,0)-ZZTypes_Get(A005_SignalZZIndex,2)) > 0 ) 
               ind = 0;//abort search
         } 
         
         cp = ZZValues_Get(A005_SignalZZIndex,ind);
         
         if(ind > 0 && dir*(cp-startCrossLevel) > 0)
         {
            signalTime = iTime(NULL, A005_iChimoku_TimeFrame, startCrossShift);
            signalLevel = ZZValues_Get(A005_SignalZZIndex,ind);
            level = startCrossLevel;
            result = startCrossShift;   
            //Print("st=",TimeToStr(signalTime),";level=",signalLevel,";zzind=",ind);
         }
      } 
   } 
                                 
   ///*                            
   if( result <= 0 && startShift > 0 && startCrossShift <= 1 )
   {
      cp = iClose(NULL,PERIOD_H1,1);
      if( dir*(cp - startLevel) > 0 )
      {
         signalTime = iTime(NULL, A005_iChimoku_TimeFrame, startShift);
         signalLevel = 0;
         level = startLevel;
         result = startShift;
      }
   }
   //*/
                                                    
   return (result);   
}

int A005_LineTouch_GetLast( int dir, int mode, int mode2, bool checkTenkanSenOver, 
                             double& signalLevel, double& level, int& zzIndex )
{
   int result = -1;
   int stage1Shift =0;
   datetime stage2MinTime;
   double stage1Level;
   int stage2zzi;
   
   int maxbarsInH = 3;
   /// stage 1 find x bars (3 for now) with low price above line level
   /// and atleast one low price below level
   //stage1Shift = A005_LineTouch_GetStart(dir, mode, mode2, 
   //                                                     maxbarsInH,//3 sequent close bars
   //                                                     maxbarsInH*2 + 1 // max Bars in history
   //                                                     ); 
   /// stage 2 find zigzag peak crossing price 
   if(stage1Shift>0)
   {
      stage2MinTime = iTime(NULL, A005_iChimoku_TimeFrame, stage1Shift+1);
      stage1Level = A005_Lines_GetValue(dir, stage1Shift, mode, mode2);
      stage2zzi = A005_LevelCross_GetZZIndex(dir, stage1Level, stage2MinTime);  
   }
                                                  
   /// stage 3 find a place for enter  tuk veceh imame vyrhyt na zigzag
   /// kojto e presekyl nivoto po liniata
   if( stage1Shift > 0 && stage2zzi > -1 )
   {
      if(Signal_Trace)
      {
         Print("A005_LineCross_GetLast dir=",dir,
               ";stage1Time=",TimeToStr(iTime(NULL, A005_iChimoku_TimeFrame, stage1Shift)),
               ";stage1Level=",stage1Level,
               ";stage2ZZi=",stage2zzi,
               ";stage2Time=",TimeToStr(ZZTimes_Get(A005_SignalZZIndex, stage2zzi)),
               ";stage2Value=", ZZValues_Get(A005_SignalZZIndex, stage2zzi)
               );
      }
      
      bool generateSignal = true;
      zzIndex = stage2zzi;
      signalLevel = ZZValues_Get(A005_SignalZZIndex, stage2zzi);
      
      if(stage2zzi == 0) generateSignal = false;
      else if(stage2zzi == 1 ) generateSignal = true;
      else if(stage2zzi == 2 )
      {
         //Print("zz0=",ZZValues_Get(A005_SignalZZIndex, 0),";zz2=",signalLevel,
         //   ";diff=",dir*(ZZValues_Get(A005_SignalZZIndex, 0) - signalLevel));
         if( dir*(ZZValues_Get(A005_SignalZZIndex, 0) - signalLevel) > 0) generateSignal = false;
      }
      else if(stage2zzi == 3)
      {
         generateSignal = false;
         if( dir*(signalLevel - ZZValues_Get(A005_SignalZZIndex, 1)) > 0)
         {
            generateSignal = true;
            signalLevel = ZZValues_Get(A005_SignalZZIndex, 1);
            zzIndex = 1;
         }    
      }
      else if(stage2zzi <= 5 )
      {
         //dopylnitelni uspovia za enerirane za signal
         generateSignal = false;
      }
      
      
      if(generateSignal)
      {
         result = stage1Shift;
         level = stage1Level;          
      }    
   }
   
   return (result);   
}

int A005_LineCross_GetLastV2( int dir, int mode, int mode2, bool checkTenkanSenOver, double& signalLevel, double& level, double& zzIndex )
{
   int result = 0;
   int zzi = A005_SignalZZIndex;
   int lbi =0;//last bottom index  for buy
   int sigi=1;
   
   if( ZZTypes_Get(zzi,0) == dir )
   {
      sigi++;
      /*
      Print("type0==dir 0=",ZZValues_Get(zzi,0),";2=",ZZValues_Get(zzi,2),
      ";cancel=",dir*(ZZValues_Get(zzi,0) - ZZValues_Get(zzi,2)) > 0
      );
      //*/
      if(dir*(ZZValues_Get(zzi,0) - ZZValues_Get(zzi,2)) > 0)
      {
         return (0);
      }
   }       
   
   double v0 = ZZValues_Get(zzi,sigi-1);
   double v1 = ZZValues_Get(zzi,sigi);
   double v2 = ZZValues_Get(zzi,sigi+1);
   
   int shift0 = iBarShift( NULL, A005_iChimoku_TimeFrame, ZZTimes_Get(zzi,sigi-1));
   int shift1 = iBarShift( NULL, A005_iChimoku_TimeFrame, ZZTimes_Get(zzi,sigi));
   int shift2 = iBarShift( NULL, A005_iChimoku_TimeFrame, ZZTimes_Get(zzi,sigi+1));
   
   if( shift0 == 0 ) shift0 = 1;   
   if( shift1 == 0 ) shift1 = 1;
   if( shift1 == 0 ) shift1 = 1;
   
   double kv0 = A005_Lines_GetValue(dir, shift0, mode, mode2);
   double kv1 = A005_Lines_GetValue(dir, shift1, mode, mode2);
   double kv2 = A005_Lines_GetValue(dir, shift2, mode, mode2);
        
   bool tkSenOk = true;
   
   if(checkTenkanSenOver) 
   {
      double tv1 = iChimoku_GetTenkanSen(shift1);
      tkSenOk = (tv1-kv1)*dir >=0;//opredeleno dobro uslovie moje i da stane neshto!!!
      //tkSenOk = (tv1-kv1)*dir < 0;
   }
   /*//originalno  
   int cnt = 0;
   if(dir*(v2 - kv2) <= 0) cnt++;
   if(dir*(v0 - kv0) <= PipsToPoints(30)) cnt++;
   //syhsto taka dobri usovia ne samod a e
   if(dir*(v2 - kv1) <= 0) cnt++;
   if(dir*(v0 - kv1) <= PipsToPoints(30)) cnt++;
   
   if( dir*(v1 - kv1) >= -PipsToPoints(10) && 
       tkSenOk && 
       (cnt >= 4)//kogato i dvata vyrha presichat otgore i otdolu e mnogo nadejdno
       )
   */
   
   if(Signal_Trace)
   {
      Print("[A005_LineCross_GetLast] dir=",dir,
              "zzv=",v0,",",v1,",",v2,";",
              "shift=",shift0,",",shift0,",",shift0,";",
              "ilv=",kv0,",",kv1,",",kv2,";"
              );
   }
   
   if( dir*(v1 - kv1) > 0 && tkSenOk && 
       (dir*(v2 - kv2) <= 0))// || dir*(v0 - kv0) <= 0))
   {
      int kt0 = A005_KumoType_GetForPoint( dir, shift0, v0);
      int kt1 = A005_KumoType_GetForPoint( dir, shift1, v1);
      int kt2 = A005_KumoType_GetForPoint( dir, shift2, v2);
      //1-strong,2-neutral,4 weak
      //if( kt1 == kt2 || 
         //kumo type neutral
      //   ( kt0 <= 2 ))
      {
         result = shift1;
         signalLevel = v1;
         level = kv1;
         zzIndex = sigi;
      }      
   }      
   
   return (result);   
}

int A005_TenkanSenCross_GetLast( int dir, double& signalLevel, double& level  )
{ 
   int mode = MODE_TENKANSEN;
   int zzIndex ;
   //int shiftCross = A005_LineCross_GetLast( dir, mode, 0, false,// checkTenkanSenOver
   //                                          signalLevel, level, zzIndex );
   int shiftTouch = A005_LineTouch_GetLast( dir, mode, 0, false,// checkTenkanSenOver
                                             signalLevel, level, zzIndex );                                             
   int shift = shiftTouch;
         
   if(shift > 0)
   {
      double ts = iChimoku_GetTenkanSen(shift);
      double ks = iChimoku_GetKijunSen(shift);
      
      //if(dir*(ts-ks) < 0) shift= 0;
   }
                               
   return (shift);                            

}

int A005_KijunSenCross_GetLastOld( int dir, double& level, int maxshift = 10 )
{ 
   int result = 0;
   
   for(int shift = 1;shift <=maxshift;shift++)
   {
      double kv1 = iChimoku_GetKijunSen(shift);     
      double tv1 = iChimoku_GetTenkanSen(shift);
      double close1 = iClose(NULL,A005_iChimoku_TimeFrame, shift);
 
      //ako baryt Open < i close >
      /*if( 
          dir*( closePrice - kv1) > 0 || 
          dir*( closePrice - tv1) > 0 
          )*/
      {
         double kv2 = iChimoku_GetKijunSen(shift + 1);
         double kv3 = iChimoku_GetKijunSen(shift + 2);      
      
         double tv2 = iChimoku_GetTenkanSen(shift + 1);
         double tv3 = iChimoku_GetTenkanSen(shift + 2);
         
         double close2 = iClose(NULL,A005_iChimoku_TimeFrame, shift + 1);
         double close3 = iClose(NULL,A005_iChimoku_TimeFrame, shift + 2);
         
         bool breakoutKijunSen = A005_BarBreakoutLevel(dir, kv1, kv2, kv3, shift, A005_iChimoku_TimeFrame);
         bool breakoutTenkanSen = A005_BarBreakoutLevel(dir, tv1, tv2, tv3, shift, A005_iChimoku_TimeFrame);
      
         double barval = iClose( NULL, A005_iChimoku_TimeFrame, shift ); 
         if( 
            (dir*(close1 - kv1) > 0 && dir*(close1 - tv1) > 0) && //da e zatvorilo na tenkansen i kijunsen
            //(dir*(close2 - kv2) <=0 || dir*(close3 - kv3) <=0) && 
            //(dir*(tv1 - kv1) > 0 && dir*(tv2 - kv2) > 0) &&
            (breakoutKijunSen || breakoutTenkanSen)
            )
         {
            level = kv1;
            result = shift;
            break;
         }         
      }
      //ako iam signal v obratna posoka napravo abortva tyrseneto
      //if( A005_BarBreakoutLevel(-dir, val1, val2, shift, A005_iChimoku_TimeFrame) == true)
      //{
      //   break;
      //}
   }
   
   return (result);
}

void A005_TenkanSenCross_Create(int settID, int dir, int& signalType, datetime& signalTime, double& signalLevel )
{  
   datetime st;
   double slevel,klevel;
   int zzIndex;
   
   int mode = MODE_TENKANSEN;
   
   int shift = A005_LineCross_GetLast( dir, mode, 0, false, 
                             st,
                             slevel, 
                             klevel );
   
   if( shift > 0)
   {
      int t = A005_KumoType_GetForPoint( dir, shift, klevel);
                               
      if( A005_SignalOptions_Active( A005_TenkanSenCross, t ) )
      {
         signalType = dir;
         signalTime = st;
         signalLevel = slevel;         
      }
   }    
}

void A005_KijunSenCross_Create(int settID, int dir, int& signalType, datetime& signalTime, double& signalLevel )
{
   datetime st;
   double slevel,klevel;
   int zzIndex;
   
   int mode = MODE_KIJUNSEN;
   
   int shift = A005_LineCross_GetLast( dir, mode, 0, false, 
                             st,
                             slevel, 
                             klevel );
   
   if( shift > 0)
   {
      int t = A005_KumoType_GetForPoint( dir, shift, klevel);
                               
      if( A005_SignalOptions_Active( A005_KijunSenCross, t ) )
      {
         signalType = dir;
         signalTime = st;
         signalLevel = slevel;         
      }
   }  
}

void A005_Signal_TryOpen( int settID, int dir, int type, int kumoType,
                           int shift, double level, 
                           int& signalType, datetime& signalTime, double& signalLevel)
{
   bool create_signal = false;
   
   
   if(A005_TrendOptions != 0)
   {
      int trend = Common_Trend_GetByIndex(settID, 0);
      if(trend*dir < 0) return;
   }
      
   if(A005_SignalZZDepth <= 0)
   //testova opcia amo za test na signala vednaga otvaria porychka
   //sled kato e generiran
   {
      if( dir*(iClose(NULL, A005_iChimoku_TimeFrame, 1) - iOpen( NULL, A005_iChimoku_TimeFrame, 1)) > 0 &&
          dir*(iClose(NULL, A005_iChimoku_TimeFrame, 1) - level) >= 0)
      {
         create_signal = true;
      }
   }
   else
   {
      create_signal = true;
   }
   
   if(create_signal == true)
   {
         signalType = dir;
         signalTime = iTime( NULL, Signal_TimeFrame, shift );
         signalLevel = level;  
         
         if( Signal_Trace )
         {
            if(Signal_Trace)
               Print( "A005t Create signal ", dir, ";time=", TimeToStr(signalTime),
                        ";signalType=",signalType,
                        ";signalLevel=",signalLevel,
                        ";kumoType=",A005_KumoType_toString(kumoType) );
         } 
   }
}

int A005_TnkKijunSenCross_GetLast( int dir, int maxshift = 10 )
{ 
   return (A005_iChimokuCross_GetLast(dir,MODE_TENKANSEN,MODE_KIJUNSEN,maxshift));
}

int A005_iChimokuCross_GetLast( int dir, int modeLine1, int modeLine2, int maxshift = 10 )
{
   int result = -1;
   bool crossFound;
   crossFound = true;
   int shiftPrev;
   for( int shift = 1; shift <= maxshift; shift++ )
   {
      double val1sh1 = iChimoku_GetValue(modeLine1, shift );
      double val1sh2 = iChimoku_GetValue(modeLine1, shift + 1 );
   
      double val2sh1 = iChimoku_GetValue(modeLine2, shift );
      double val2sh2 = iChimoku_GetValue(modeLine2, shift + 1 ); 
      
      if( dir*(val1sh1 - val2sh1) > 0  && dir*(val1sh2 - val2sh2) <= 0.0000001)
      {
         shiftPrev = shift + 1;
         if( dir*(val1sh2 - val2sh2) > -0.0000001 )
         {
            //mnogo blizko moje da ima samo dokosvane
            crossFound = false;
            for( int  i = 2; i < 5; i++ )
            {
               shiftPrev = shift + i;
               val1sh2 = iChimoku_GetValue(modeLine1, shiftPrev );
               val2sh2 = iChimoku_GetValue(modeLine2, shiftPrev ); 
               if( dir*(val1sh2 - val2sh2) < 0 )
               {
                  crossFound = true;
                  break;
               }
               else if( dir*(val1sh2 - val2sh2) > 0 ) 
               {
                  break;
               }
            }
         }
            
         if(crossFound)
         {
            //dopylnitelna proverka da ne bi da e samo edin bar
            //pone 2 bara triabva da sa otdolu
            val1sh2 = iChimoku_GetValue(modeLine1, shiftPrev + 1 );
            val2sh2 = iChimoku_GetValue(modeLine2, shiftPrev + 1); 
            if( dir*(val1sh2 - val2sh2) < 0 )
            {
               result = shift;
            }
            /*
            if(Signal_Trace)
            {
               Print("A005_iChimokuCross_GetLast dir=",dir, ";line1 1=",val1sh1, ";2=",val1sh2,
                                       ";line2 1=", val2sh1, ";2=", val2sh2, 
                                       ";Cond1=", dir*(val1sh1 - val2sh1),
                                       ";Cond2=", dir*(val1sh2 - val2sh2) ); 
            }
            //*/
         }
         break;
      }
   } 
   
   return (result);
}

void A005_TnkKijunSenCross_Create(int settID, int dir, int& signalType, datetime& signalTime, double& signalLevel )
{
   int shift = A005_TnkKijunSenCross_GetLast(dir);
   if( shift > 0 )
   {
      int t = A005_KumoType_GetForPoints( dir, shift+1, 
                        iChimoku_GetTenkanSen(shift+1),
                        iChimoku_GetKijunSen(shift+1) );
                               
      if( A005_SignalOptions_Active( A005_TenkanKijunSenCross, t ) )
      {                                
         //ako posledniat bar e v posokata na crossa generirame signal
         if( dir*(iClose(NULL, A005_iChimoku_TimeFrame, 1) - iOpen( NULL, A005_iChimoku_TimeFrame, 1)) > 0)
         {
            signalType = dir;
            signalTime = iTime( NULL, A005_iChimoku_TimeFrame, shift );
            signalLevel = 0;  
            if(Signal_Trace)
               Print( "A005_TnkKijunSenCross_Create signal ", dir, ";time=", TimeToStr(signalTime),
                        ";type=",A005_KumoType_toString(t) );
         }         
      }   
   }  
}

bool A005_SignalOptions_Active( int options, int type )
{
   if( options <=0 ) return (true);
   else return (options&type == type);
}
string A005_KumoType_toString(int type)
{
  switch(type)
  {
  case 1: return ("Kumo Strong");
  case 2: return ("Kumo Neutral");
  case 4: return ("Kumo Weak");
  default: return ("Kumo Unknown type");
  }
}
//returns 1-strong, 2-neutral, 4-weak
int A005_KumoType_GetForPoint( int dir, int shift, double p )
{
   //get kumo
   double a = iChimoku_GetSenkouSpanA(shift);
   double b = iChimoku_GetSenkouSpanB(shift);  
   
   double minV,maxV;
   
   minV = MathMin(a,b);
   maxV = MathMax(a,b);
   
   double minp = PipsToPoints(1);
   
   int kd = 0;
   //check buy
   if( (p - maxV) > minp ) kd = 1;  
   else if( (minV - p) > minp ) kd = -1;
   else kd = 0;
      
   int type;
   
   if( kd == 0 )        type = 2;  //medium
   else if( dir == kd ) type = 1;  //strong
   else                 type = 4;  //weak
   
   /*
   if( Signal_Trace )
      Print("A005_KumoType_GetForPoint Senkou type=",type,";dir=",dir,
         ";kd=",kd,
         ";a=",a,";b=",b,";p=",p,
         ";time=",TimeToStr(iTime(NULL,A005_iChimoku_TimeFrame,shift))
         );
   //*/      
         
   return (type);
}
//returns 1-strong, 2-neutral, 4-weak
int A005_KumoType_GetForPoints( int dir, int shift, double p1, double p2 )
{
   int t1 = A005_KumoType_GetForPoint(dir,shift,p1);  
   int t2 = A005_KumoType_GetForPoint(dir,shift,p2);
   
   int type;
   
   if( t1 == t2 ) type = t1;
   else type = 2;//medium     
   
   return (type);
}

int A005_KumoType_GetForBar( int dir, int shift, int barShift, int timeframe )
{  
   return (A005_KumoType_GetForPoints(dir,shift,
            iClose(NULL,timeframe,barShift),
            iOpen(NULL,timeframe,barShift)));
}

int A005_Bar_GetDir(int timeframe, int shift)
{
   int dir = 0;
   double diff = iClose(NULL,timeframe,shift ) - iOpen(NULL,timeframe,shift );
   
   if( diff > 0 ) dir = 1; else if( diff < 0) dir = -1;
   
   return (dir);
}

double A005_MinMaxByDir(int dir, double v1, double v2 )
{
   double result;
   
   if( dir > 0 ) result = MathMax(v1,v2); else result = MathMin(v1,v2);
   
   return (result);
}
double iChimoku_GetTenkanSen(int shift)
{
   return (iChimoku_GetValue(MODE_TENKANSEN, shift));
}   

double iChimoku_GetKijunSen(int shift)
{
   return (iChimoku_GetValue(MODE_KIJUNSEN, shift));
} 

double iChimoku_GetSenkouSpanA(int shift)
{
   return (iChimoku_GetValue(MODE_SENKOUSPANA, shift));
}  

double iChimoku_GetSenkouSpanB(int shift)
{
   return (iChimoku_GetValue(MODE_SENKOUSPANB, shift));
}   

double iChimoku_GetChinkouSpan(int shift)
{
   return (iChimoku_GetValue(MODE_CHINKOUSPAN, shift));
}         

double iChimoku_GetValue(int mode, int shift)
{
   return (iIchimoku(NULL, A005_iChimoku_TimeFrame, A005_TenkanSen, A005_KijinSen, A005_SencouSpanB, mode, shift ));
}