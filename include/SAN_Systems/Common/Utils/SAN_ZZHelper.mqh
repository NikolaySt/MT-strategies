//+------------------------------------------------------------------+
//|                                             SAV_ZigZagHelper.mq4 |
//|                                 Copyright © 2009, Andrey Kunchev |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Andrey Kunchev"
#property link      "http://www.metaquotes.net"

/*
********************************************************************************
================= функции за употреба от библиотеката ==========================

// функции за инциализация по параметрите на зигзаг индикатор
// функцията връща индекс който може да се ползва като параметър 
// на всички други функции които искат индекс
// параметрите се подават с масив като може да се подаде име на индикатор
int ZZGetIndexForParamsOrCreate( int timeframe, double params[], int paramsSize, string indName );

// функция за инциализацияна зигзаг индикатор ZigZagEx 
// функцията връща индекс който може да се ползва като параметър 
// на всички други функции които искат индекс
int ZZGetIndexForDepthOrCreate( int ExtDepth, int timeframe );

// функция за взимане на времето на връх
// 0 е последен във времето, 1 е предпоследен и т.н.
datetime ZZTimes_Get( int ZZIndex, int index );

// функция за взимане типа на върха 1 - връх (макс. ст. на бар), -1 дъно  (мин ст. на бар)
// 0 е последен във времето, 1 е предпоследен и т.н.
int ZZTypes_Get( int ZZIndex, int index );

// функция за взимане стойността на върха (реално мин или макс на бар от връх)
// 0 е последен във времето, 1 е предпоследен и т.н.
double ZZValues_Get( int ZZIndex, int index );

// взимане стойността на последният връх
// мойе би не я ползвам вече
int ZZGetLastPeakValue( int ZZIndex, double& value, int& Index, int min_shift = 0 );

// Взимане на последна тенденция от зигзаг
// int ZZIndex индекс на зигзаг
// int index индекс на връх от които да започне търсенето
// int type не се взима в предвид
// int& peaks_indexes[] връща жърховете по коиато е изчислило тенденцията
// int min_pips минимално количество на пипсове за да засече тенденцията
int ZZGetLastTendence( int ZZIndex, int index, int type, int& peaks_indexes[], int min_pips = 10);

// взимане на брой последователни тенденции аз тип 1,-1 
int ZZGetSubsequentTendenceCount( int ZZIndex, int index, int type );

//--- употреба ZZSetDebugType(ZZDBG_CORE) за да принтира в лога данни от състоянието на нещата
void ZZSetDebugType(int value);


********************************************************************************
================= функции само за вътрешна употреба от  библиотеката ===========
търсене на индекс по парамети
int ZZFindIndexFromParams( int timeframe, double params[], int paramsSize, string indName = "" );
int ZZFindIndexFromDepth( int ExtDepth, int timeframe );
вътрешна инициялизация по параметри
int ZZSetParams(int ZZIndex, int timeframe, int ExtDepth,int ExtDeviation,int ExtBackstep );
последно за кой бар е изчислен връх
datetime ZZGetLastTime( int ZZIndex );
void ZZSetLastTime( int ZZIndex, datetime value );
дали е активен индека
void ZZActivate( int ZZIndex );
bool ZZGetActive( int ZZIndex );
void ZZSetActive( int ZZIndex );
// за кой времеви интервал h1,h4,d1  се изчислява индикатора
void ZZSetTimeFrame(int ZZIndex, int timeframe);
int ZZGetTimeFrame( int ZZIndex );
 поммощна функциа завзимане н стойност от къстом индикатор
double iZigZagByIndex( int ZZIndex, int shift );
изчисление за щифт на върховете
void ZZ_Update( int current_shift, int ZZIndex );
изчисление за всички шифтове които не са изчислени
void ZZProcessShiftForIndex( int ZZIndex );

bool ZZDebugCheck(int value );

int ZZGetDebugType();
ZZDebugCheck;
*/
//structured data for 1 Zigzag
//max zizzag indicators
//максимален брой жърхове които пази като история
#define ZZHISTORYMAXCOUNT 50
//максимален брой различни индикатори
#define ZZDIFFZIGZAGMAXCOUNT 50

#define ZZPARAMSMAXCOUNT 10

// имена на индицатори които да ползжа за ZZIndex
string   ZZNames[ZZDIFFZIGZAGMAXCOUNT];
// параметри на всеки един индикатор който се ползжа и брой
double   ZZParams[ZZDIFFZIGZAGMAXCOUNT, ZZPARAMSMAXCOUNT];
int      ZZParamsSize[ZZDIFFZIGZAGMAXCOUNT];

// timeframe za kojto se izchisliava indicatora
int      ZZTimeFrames[ZZDIFFZIGZAGMAXCOUNT];

int      ZZBarsCount[ZZDIFFZIGZAGMAXCOUNT];

// дали да прави изчисления за този зигзаг
int      ZZActive[ZZDIFFZIGZAGMAXCOUNT];
// последно време на изчислен бар за точно този индикатор
datetime ZZLastTimes[ZZDIFFZIGZAGMAXCOUNT];

// last ten peaks for help for getting information about ZigZag indicator
datetime ZZTimes[ZZDIFFZIGZAGMAXCOUNT, ZZHISTORYMAXCOUNT];
// типове на върхове за последните 50 върха
int      ZZTypes[ZZDIFFZIGZAGMAXCOUNT, ZZHISTORYMAXCOUNT];//1 up -1 down
// стойностин вархове на последните 50 върха
double   ZZValues[ZZDIFFZIGZAGMAXCOUNT, ZZHISTORYMAXCOUNT];//value of the pick up or down

bool      ZZDebug[ZZDIFFZIGZAGMAXCOUNT];
// общ брой индикатори които се ползват
int      ZZIndicatorsCount=0;

#define ZZDBG_CORE 256
//#define ZZDBG_CORE_DETAILS 512

int   ZZDebugType = 0;

string    ZZDefaultIndicatorName = "ZigZagEx";

void ZZSetDebugType(int value)
{
   ZZDebugType = value;
}

int ZZGetDebugType()
{
   return (ZZDebugType);
}

bool ZZDebugCheck(int value )
{
   return ((ZZDebugType&value) == value);
}

void ZZInit()
{
   // общ брой индикатори които се ползват
   ZZIndicatorsCount=0;
   //-----------------------------------
   //МНОГО ВАЖНО
   //-----------------------------------
   if (ZZDebugType == 1) Print("[ZZInit]");
}

int ZZFindIndexFromParams( int timeframe, double params[], int paramsSize, string indName = "" )
{
   int resultIndex = -1, i,j;
   bool paramsMatch;
   for( i=0 ; i < ZZIndicatorsCount; i++ )
   {
      if( ZZGetTimeFrame(i) == timeframe && ZZNames[i] == indName && ZZParamsSize[i] == paramsSize )
      {
         paramsMatch = true;
         
         for( j = 0; j < paramsSize; j++ )
         {
            if( ZZParams[i,j] != params[j] )
            {
               paramsMatch = false;
            }  
         } 
         
         if(paramsMatch == true)
         {
            break;
         }         
      }
   }
   return (resultIndex);
}

int ZZFindIndexFromDepth( int ExtDepth, int timeframe )
{
   int resultIndex = -1;
   for( int i=0 ; i < ZZIndicatorsCount; i++ )
   {
      if( ZZParams[i,0] == ExtDepth && ZZGetTimeFrame(i) == timeframe )
      {
         resultIndex = i;
         break;
      }
   }
   return (resultIndex);
}

void ZZSetDebugForIndex(int ZZIndex, bool value)
{
   ZZDebug[ZZIndex] = value;
}

bool ZZGetDebugForIndex(int ZZIndex)
{
   return (ZZDebug[ZZIndex]);
}

void ZZResetIndex(int Index)
{
   // последно време на изчислен бар за точно този индикатор
   ZZLastTimes[Index] = 0;
   
   for (int i = 0; i < ZZHISTORYMAXCOUNT; i++)
   {
      // last ten peaks for help for getting information about ZigZag indicator
      ZZTimes[Index,i] = 0;
      // типове на върхове за последните 50 върха
      ZZTypes[Index,i] = 0;//1 up -1 down
      // стойностин вархове на последните 50 върха
      ZZValues[Index,i] = 0;//value of the pick up or down
   } 
}

int ZZGetIndexForParamsOrCreate( int timeframe, double params[], int paramsSize, string indName )
{
   int resultIndex = ZZFindIndexFromParams( timeframe, params, paramsSize, indName );
   if( resultIndex < 0 )
   {
      ZZResetIndex( resultIndex );
      
      resultIndex = ZZIndicatorsCount;
      ZZIndicatorsCount++;
      ZZParamsSize[resultIndex] = paramsSize;
      ZZSetTimeFrame(resultIndex, timeframe);
      ZZNames[resultIndex] = indName;
      for( int i=0; i < paramsSize; i ++ )
      {
         ZZParams[resultIndex,i] = params[i];
      }      
   }
   return (resultIndex);
      
}

int ZZGetIndexForDepthOrCreate( int ExtDepth, int timeframe )
{
   int resultIndex = ZZFindIndexFromDepth( ExtDepth, timeframe );
   if( resultIndex < 0 )
   {
      resultIndex = ZZIndicatorsCount;
      ZZIndicatorsCount++;
      ZZNames[resultIndex] = "";
      ZZSetParams( resultIndex, timeframe, ExtDepth, 1, 1);        
   }
   return (resultIndex);
}

datetime ZZGetLastTime( int ZZIndex )
{
   return (ZZLastTimes[ZZIndex]);
}

void ZZSetLastTime( int ZZIndex, datetime value )
{
   ZZLastTimes[ZZIndex] = value;
}

void ZZActivate( int ZZIndex )
{
   // ако искаме да се добави условие
   // върховете да се преизчисляват когато иаме дупка в баровете
   // да се помисли това ли е най-доброто решение iBars(NULL, ZZTimeFrames[ZZIndex])
   /*
   if( ZZBarsCount[ZZIndex] != iBars(NULL, ZZTimeFrames[ZZIndex]))
   {
      ZZResetIndex(ZIndex);
   }
   
   ZZBarsCount[ZZIndex] = iBars(NULL, ZZTimeFrames[ZZIndex]);
   //*/
   
   if( ZZGetActive(ZZIndex) == false )
   {
      ZZSetActive(ZZIndex); 
   }  
   
   datetime shift1time = iTime(NULL, ZZGetTimeFrame(ZZIndex), 1);
      
   if( ZZGetLastTime(ZZIndex) != shift1time )
   {
      ZZProcessShiftForIndex(ZZIndex);
   }
   
   //make process of the shift if not processed
}

bool ZZGetActive( int ZZIndex )
{
   return (ZZActive[ZZIndex] != 0);
}

void ZZSetActive( int ZZIndex )
{
   if( ZZParams[ZZIndex,0] != 0 )
   {
      ZZActive[ZZIndex] = 1;     
   }
}

void ZZSetTimeFrame(int ZZIndex, int timeframe)
{
   ZZTimeFrames[ZZIndex] = timeframe;
}

int ZZGetTimeFrame( int ZZIndex )
{
   return (ZZTimeFrames[ZZIndex]);
}

int ZZSetParams(int ZZIndex, int timeframe, int ExtDepth,int ExtDeviation,int ExtBackstep )
{
   if( ZZIndex > ZZIndicatorsCount ) return (-1);
   
   ZZParams[ZZIndex,0] = ExtDepth;
   ZZParams[ZZIndex,1] = ExtDeviation;
   ZZParams[ZZIndex,2] = ExtBackstep;
   //ZZParams[ZZIndex,3] = timeframe;
   //ZZParams[ZZIndex,4] = 0;//active
   ZZParamsSize[ZZIndex] = 1;
   ZZSetTimeFrame(ZZIndex, timeframe);
   ZZSetLastTime(ZZIndex,0);
   
   //Print( "ZZSetParams index:", ZZIndex, " Depth:",ExtDepth," Deviation:",ExtDeviation," Backstep:", ExtBackstep );
   
   return (0);
}
/*
double iZigZagParams( string izpSymbol,int izpTimeframe,int izpExtDepth,int izpExtDeviation,int izpExtBackstep,int mode, int izpShift)
{

   double result = iCustom(NULL, izpTimeframe, ZZDefaultIndicatorName, 
                           izpExtDepth, izpExtDeviation, izpExtBackstep, mode, izpShift);
                                                   
   return (result);
}
*/
double iZigZagByIndex( int ZZIndex, int shift )
{
  return  (iZigZagByIndexMode(ZZIndex,shift,0));
}

double iZigZagByIndexMode( int ZZIndex, int shift, int mode )
{
   //double result = iZigZagParams(ZZGetTimeFrame(ZZIndex),ZZParams[ZZIndex,0],
   //                 ZZParams[ZZIndex,1],ZZParams[ZZIndex,2],mode, shift);
   //return (result); 
   
     string indName = ZZNames[ZZIndex];
     if( indName == "" ) indName = ZZDefaultIndicatorName;

     double res = iCustom(NULL, ZZGetTimeFrame(ZZIndex), indName, 
                        ZZParams[ZZIndex,0],ZZParams[ZZIndex,1],ZZParams[ZZIndex,2],
                        ZZParams[ZZIndex,3],ZZParams[ZZIndex,4],ZZParams[ZZIndex,5],
                        ZZParams[ZZIndex,6],ZZParams[ZZIndex,7],ZZParams[ZZIndex,8],
                        ZZParams[ZZIndex,9], 
                        mode, shift);
     return (res);
}

void ZZ_Update( int current_shift, int ZZIndex )
{
      if( ZZGetActive(ZZIndex) == false ) return;
      
      if( ZZParams[ZZIndex,0] == 0 ) return;
       
      //Print("[ZZUpdate] ", ZZIndex,";shift=", current_shift);
      
      //the very last tick should be discarded
      //if( current_shift == 0 ) return;
      
      double   prev_value0=0,prev_value1=0;
      datetime prev_time0=0,prev_time1=0,prev_time2=0;
      int      prev_shift0,prev_shift1,prev_shift2;
         
      prev_time0 = ZZTimes[ZZIndex,0];
      
      if( prev_time0 > 0 )
      {
         prev_shift0 = iBarShift(NULL, ZZGetTimeFrame(ZZIndex), prev_time0);
      
         //vyrha veche e izchislen ili tova e syshtiat tick 
         if( current_shift >= prev_shift0 ) return; 
      }
      
      double value;
          
      value = iZigZagByIndex(ZZIndex, current_shift);
      
      if( value != 0.0 )
      {  
         //Print("[ZZUpdate] value=",value,";shift=", current_shift ); 
         int i;
         bool new_peak=false;
         prev_time1 = ZZTimes[ZZIndex,1];
         prev_time2 = ZZTimes[ZZIndex,2];
         string strNewPReason = "Unknown";
         //update the arrays
         if( (prev_time0 > 0) && (prev_time1 > 0) && (prev_time2 > 0) )
         {
            prev_value0 = iZigZagByIndex(ZZIndex, prev_shift0);
            
            prev_shift1 = iBarShift(NULL, ZZGetTimeFrame(ZZIndex), prev_time1);
            
            prev_value1 = iZigZagByIndex(ZZIndex, prev_shift1);
            
            prev_shift2 = iBarShift(NULL, ZZGetTimeFrame(ZZIndex), prev_time2);
            
            if( ZZDebugCheck(ZZDBG_CORE) )
            { 
               Print( "[ZZUpdate] prev0(val=",prev_value0,"(",ZZValues[ZZIndex,0], ");Time=", TimeToStr(iTime(NULL, ZZGetTimeFrame(ZZIndex), prev_shift0)),";shift=",prev_shift0,")",
                  "prev1(val=",prev_value1,"(",ZZValues[ZZIndex,1], ");Time=", TimeToStr(iTime(NULL, ZZGetTimeFrame(ZZIndex), prev_shift1)),";shift=",prev_shift1,")" );
            }
            
            if( prev_value0 != 0.0 && prev_value1 != 0.0 )
            {
               new_peak = true;
               strNewPReason = "prev_value0 != 0.0 && prev_value1 != 0.0";
            }
            else
            {
               int peaks_count=0;
               int shift_peaks[2];
               double shift_values[2],tmp_value;
               for( int tmp_shift = prev_shift2 - 1; tmp_shift > current_shift; tmp_shift-- )
               {
                  tmp_value = iZigZagByIndex(ZZIndex, tmp_shift); 
                  if( tmp_value != 0.0 )
                  {
                     shift_values[peaks_count] = tmp_value;
                     shift_peaks[peaks_count]  = tmp_shift;
                     peaks_count++;       
                  }   
               }
               
               if( ZZDebugCheck(ZZDBG_CORE) )
               { 
                  Print("[ZZUpdate] found peaks=", peaks_count );
               }
            
               if( peaks_count == 0 )
               {
                  for( i=1; i<ZZHISTORYMAXCOUNT-1; i++)
                  {
                     ZZTimes[ZZIndex,i] = ZZTimes[ZZIndex,i+1];
                     ZZTypes[ZZIndex,i] = ZZTypes[ZZIndex,i+1];
                     ZZValues[ZZIndex,i] = ZZValues[ZZIndex,i+1];             
                  }
                  ZZTimes[ZZIndex,ZZHISTORYMAXCOUNT-1] = 0;
                  ZZTypes[ZZIndex,ZZHISTORYMAXCOUNT-1] = 0;
                  ZZValues[ZZIndex,ZZHISTORYMAXCOUNT-1] = 0;    
               }
               else if( peaks_count == 1 )
               {
                  ZZTimes[ZZIndex,1] = iTime(NULL, ZZGetTimeFrame(ZZIndex), shift_peaks[0]);
                  ZZTypes[ZZIndex,1] = -ZZTypes[ZZIndex,2];
                  ZZValues[ZZIndex,1] = shift_values[0];    
               }
               else//peaks_count == 2
               {
                  ZZTimes[ZZIndex,1] = iTime(NULL, ZZGetTimeFrame(ZZIndex), shift_peaks[0]);
                  ZZTypes[ZZIndex,1] = -ZZTypes[ZZIndex,2];
                  ZZValues[ZZIndex,1] = shift_values[0]; 
               
                  ZZTimes[ZZIndex,0] = iTime(NULL, ZZGetTimeFrame(ZZIndex), shift_peaks[1]);
                  ZZTypes[ZZIndex,0] = ZZTypes[ZZIndex,2];
                  ZZValues[ZZIndex,0] = shift_values[1];
                  new_peak = true;
                  strNewPReason = "found peaks_count == 2";
               }
            }  
         }
         else
         {
            new_peak = true;
            strNewPReason = "not (prev_time0,1,2 > 0);" + TimeToStr(prev_time0)+";"+TimeToStr(prev_time1)+";"+TimeToStr(prev_time2);
         }
          
 
    
         if( new_peak == true )
         {    
            for( i=ZZHISTORYMAXCOUNT-2; i>=0; i--)
            {
               ZZTimes[ZZIndex,i+1] = ZZTimes[ZZIndex,i];
               ZZTypes[ZZIndex,i+1] = ZZTypes[ZZIndex,i];
               ZZValues[ZZIndex,i+1] = ZZValues[ZZIndex,i];             
            }
         }
         
         //update the last peaks   
         ZZTimes[ZZIndex,0] = iTime(NULL, ZZGetTimeFrame(ZZIndex), current_shift);
         ZZValues[ZZIndex,0] = value;
         int type = 0;

         if(ZZValues[ZZIndex,1] == 0.0 )
         {
            type = 0;  
         }
         else if( ZZValues[ZZIndex,0] > ZZValues[ZZIndex,1] )
         {
            type = 1;  
         }
         else if( ZZValues[ZZIndex,0] < ZZValues[ZZIndex,1] )
         {
            type = -1;
         }
         
         ZZTypes[ZZIndex,0] = type; 
         
         if( ZZDebugCheck(ZZDBG_CORE) )
         {                 
            Print( "[ZZUpdate] current(val=",value,";Time=", TimeToStr(iTime(NULL, ZZGetTimeFrame(ZZIndex), current_shift)),";shift=",current_shift,
            ";type=",type,";new_peak=",new_peak,
            ") prev=(val=",ZZValues[ZZIndex,1],";time=",TimeToStr(ZZTimes[ZZIndex,1]),";type=", ZZTypes[ZZIndex,1], 
            ";reason=",strNewPReason );
         } 
         
         if( ZZGetDebugForIndex(ZZIndex) == true )
         {
            string dbgNewPeaks,dbgIndicValues;
            //print last 5 peaks
            int di, dbgShift=0,dbgt=0;
            double dblzzVal = 0,dbgv;
             
            for(di = 0; di < 5; di++)
            {
               //neshto v tova ZZTypes_Get(ZZIndex,di) dava razliki???
               //za tova po-dobre napravo da se vzimat stojnostite ot masivite
               dbgt = ZZTypes[ZZIndex,di];//ZZTypes_Get(ZZIndex,di);
               dbgv = ZZValues[ZZIndex,di];//ZZValues_Get(ZZIndex,di);

               if(dbgv != 0.0)
               {
                  while( dblzzVal == 0 )
                  {
                     dblzzVal = iZigZagByIndex(ZZIndex, dbgShift);
                     dbgShift++;
                  }
               }

               dbgNewPeaks = StringConcatenate(dbgNewPeaks,";",di,
                              "=(t=",dbgt ,
                              ";v=", dbgv,
                              ";",dblzzVal, ")");
               dblzzVal = 0;                              
            }
                
            Print("[ZZDebug]Depth=",ZZParams[ZZIndex,0],";tf=",
                  ZZTFtoString(ZZGetTimeFrame(ZZIndex)),
                  ";lt=",
                  TimeToStr(ZZTimes[ZZIndex,0]),
                  dbgNewPeaks);
         } 
      }    
}

string ZZTFtoString(int timeframe)
{
   switch(timeframe){
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
      default: return("??");
   } 
}

void ZZProcessShiftForIndex( int ZZIndex )
{
   if( ZZGetActive(ZZIndex) == false ) return;
   
   int shift = 1;
   int limit = (shift);

   datetime last_time = ZZGetLastTime(ZZIndex);
   if( last_time == 0 )
   {
      limit = iBars(NULL, ZZGetTimeFrame(ZZIndex)) - 1;
   }
   else
   {
      limit = iBarShift( NULL, ZZGetTimeFrame(ZZIndex), last_time );
   }
   
   for( int shift_calc = limit; shift_calc >= shift; shift_calc-- )
   {
      ZZ_Update(shift_calc, ZZIndex );
   }
   
   ZZSetLastTime( ZZIndex, iTime(NULL,ZZGetTimeFrame(ZZIndex), shift) );
}

datetime ZZTimes_Get( int ZZIndex, int index )
{
   ZZActivate(ZZIndex);
   return (ZZTimes[ZZIndex,index]);
}

int ZZTypes_Get( int ZZIndex, int index )
{
// tova shte e osnovnata funkcia
   ZZActivate(ZZIndex);
   
   return (ZZTypes[ZZIndex,index]);
}

//value of the pick up or down
double ZZValues_Get( int ZZIndex, int index )
{
   ZZActivate(ZZIndex);
   return (ZZValues[ZZIndex,index]);
}

int ZZGetLastPeakValue( int ZZIndex, double& value, int& Index, int min_shift = 0 )
{
   int result_type = 0;
   //tova maj vaji samo za ZigZagEx
   if( min_shift == 0 )
   {
      result_type = ZZTypes_Get( ZZIndex, 0);
      value = ZZValues_Get( ZZIndex, 0);
      Index = 0;
   }
   else
   {
      double new_peak_val = 0, tmp_val;
      //mode 1 low, 2 high
      int mode = 2, type;
      type = ZZTypes_Get(ZZIndex, 0);
      if( type < 0 )
      { 
         mode = 1;
      }
      new_peak_val = ZZValues_Get(ZZIndex, 0);
      int shift_start = iBarShift( 0,ZZGetTimeFrame(ZZIndex), ZZTimes_Get(ZZIndex,0)) - 1;
      //Print("shift_start = ", shift_start );
      ///*
      int shift_count = 0;
      //string res;
      for(int shift = shift_start; shift > min_shift; shift-- )
      {
         tmp_val = iZigZagByIndexMode( ZZIndex, shift, mode );
         //res  = StringConcatenate(res,shift,"=",tmp_val,";");
         if( tmp_val != 0 )
         {
            if( type*(new_peak_val - tmp_val) > 0 )
            {
               new_peak_val = tmp_val;
               shift_count++;
            }
            else break; 
         }
      } 
      if( shift_count > 0 )
      {
         result_type = -type; 
         value = new_peak_val; 
         Index = -1; 
      }   
      /*  
      if( ZZDebugCheck(ZZDBG_CORE) )
      { 
         Print(res);
         dbg = StringConcatenate("newv=",new_peak_val,";pv=",ZZValues_Get(ZZIndex, 0), ";pt=", TimeToStr(ZZTimes_Get(ZZIndex,0)),
         ";cnt=", shift_count,"shift_cnt=",shift_start-min_shift,";type=",type );
         dbg1 = dbg1 + dbg;
         dbg0 = dbg0 + dbg;
      }*/
   }
   return (result_type); 
}

int ZZGetSubsequentTendenceCount( int ZZIndex, int index, int type )
{
   ZZActivate(ZZIndex);
   int count = 1;
   int max = 20;
   int offset = 1;
   if( (index -1) > 0 )
   {
      if( (ZZValues_Get(ZZIndex,index-1) - ZZValues_Get(ZZIndex,index+1))*type > 0 )
      {
         offset = -1;   
      }
   }
   
   while( max > 0 )
   {
      if( (ZZValues_Get(ZZIndex,index) - ZZValues_Get(ZZIndex,index+2))*type > 0 &&
             (ZZValues_Get(ZZIndex,index+offset) - ZZValues_Get(ZZIndex,index+offset+2))*type > 0 )
      {
         count++;
         index+=2;
      } 
      else break;
      max--;
   }
   //Print("[ZZGetSubsequentTendenceCount] zzIndex=",ZZIndex,";index=", index,";type=", type,";res=",count );
   return (count);
}

int ZZGetLastTendence( int ZZIndex, int index, int type, int& peaks_indexes[], int min_pips = 10)
{
   ZZActivate(ZZIndex);
   double val_shift0,val_shift2;
   int type0 = 0, type2 = 0;
   int LastTendence = 0;
   for( int i = index; i < (ZZHISTORYMAXCOUNT - 1);i++ )
   {
      val_shift0 = ZZValues[ ZZIndex, i ];
      val_shift2 = ZZValues[ ZZIndex, i + 2 ];
      type0 = ZZTypes[ ZZIndex, i];
      type2 = ZZTypes[ ZZIndex, i + 2 ];
      
      //za buy tendenciq shift0 - shift2 > 0 && type > 0   
      //(shift0 - shift2)*type0 > 0 ako type e 1 e ok, ako type e -1 
                                                         
      //za sell tendenciq shift0 - shift2 < 0 && type = -1 
      if( ((type0*type2) > 0) && ((val_shift0-val_shift2)*type0 > min_pips*Point))//0.0010) ) //minimum 10 pips sega promenih na 50
      {
         //Print( "[ZZGetLastTendence] tendence found type=", type0, ";peaks=", i,",", i+2 );
         //tendenciq
         LastTendence = type0;
         peaks_indexes[0] = i;
         peaks_indexes[1] = i + 2;
         break;
      }      
   }
   return (LastTendence);
}









