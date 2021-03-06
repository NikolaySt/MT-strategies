/**********************************************************************
TN001_ZigZag
Тренда се формира от два елемента:
1. Плъзгаща средна с добавен канал около нея //TrendMA//
2. Затваряне над/под определен брой барове //TrendBarsBreak//
 
 //TrendSummary// - обединява двата тренда в един
*********************************************************************/
#property copyright "Copyright © 2010, Nikolay Stoychev"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_width1 2
#property indicator_color2 Blue
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2
#property indicator_color4 Black
#property indicator_width4 0
//---- indicator parameters

extern int    Bars_Break = 6;
extern int    Atr_Period = 27;
extern double Atr_Ratio = 3;

//---- indicator buffers
double zz[];
double zzL[];
double zzH[];
double zzTrend[];

int init(){  
   SetIndexStyle(0, DRAW_SECTION);   
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexStyle(2, DRAW_ARROW);      
   SetIndexStyle(3, DRAW_LINE);  
   
   SetIndexArrow(1, 159);   
   SetIndexArrow(2, 159);   

   SetIndexBuffer(0, zz);
   SetIndexBuffer(1, zzH);
   SetIndexBuffer(2, zzL);
   SetIndexBuffer(3, zzTrend);
   
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);     
   SetIndexEmptyValue(3, 0.0);

   IndicatorShortName("TN002_ZZ("+Bars_Break+", "+Atr_Period+", "+Bars_Break+")");
   return(0);
}

datetime lasthightime = 0, lastlowtime = 0, lastcalcshifttime = 0;
int curr_trend = 0;
int last_trend = 0;
int bars_count = 0;

int start(){
   int lasthighpos, lastlowpos;
   static double lasthigh, lastlow;
     
   int i, shift, limit;   
   int min_shift = 1;
   
   //---bug fix za novata versia na MT4 4.0 build 392 16.3.2011
   bool reinitialize = false;
   reinitialize = (lasthightime == 0 || lastlowtime == 0) ||  (MathAbs(Bars - bars_count) > 1);
   
   if(lasthightime!=lastlowtime && lasthightime != 0)
   {
      //когато се стартира МТ4 изчислява правилно
      //но точно когато се свърже в интернет си нулира всички масиви на индикаторите изглежда
      //тук правя проверка дали масивът има нуйните стойности и
      //ако няма стойностите които трябва да има изчислява всичко наново
      lasthighpos = iBarShift( NULL, 0, lasthightime );
      lastlowpos = iBarShift( NULL, 0, lastlowtime );
      double max = zzH[lasthighpos];
      double min = zzL[lastlowpos];
      if(max == min) reinitialize = true;
   }
   //---bug fix za novata versia na MT4
   
   if( reinitialize )
   {
      ArrayInitialize(zz,  0.0);
      ArrayInitialize(zzL, 0.0);
      ArrayInitialize(zzH, 0.0);
   
      lasthighpos = Bars; 
      lastlowpos = Bars;
      lastlow = Low[Bars];
      lasthigh = High[Bars];     
      //INIT  
      lastcalcshifttime = 0;
      lasthightime = 0;
      lastlowtime = 0;
      curr_trend = 0;
      last_trend = 0;
        
      limit = Bars-MathMax(Atr_Period, Bars_Break);      
   }else{           
      limit = iBarShift(NULL, 0, lastcalcshifttime);      
      if (limit < min_shift)  return(0);
      
      lasthighpos = iBarShift(NULL, 0, lasthightime);
      lastlowpos = iBarShift(NULL, 0, lastlowtime);
   }
   bars_count = Bars;
   int save_high_pos =0;
   int save_low_pos =0;
   
   for(shift = limit; shift >= min_shift; shift--){
      curr_trend = TrendSummary(shift);
      //zzTrend[shift] = curr_trend; //записва: -1 , 0, +1 , вътре в индикатора не се ползва, само за външно ползване            
      //-------------------ПРОМЯНА в ТРЕНДА-----------------------------
      if (last_trend != curr_trend && curr_trend != 0){ 
         //имаме нов тренд различен от страия                 
         if (last_trend == 1){ //стария тренд е бил нагоре
            //записваме в масива
            zz[lasthighpos] = lasthigh;
            zzH[lasthighpos] = lasthigh;
            lasthighpos = -1;
            lasthigh = -1;
         }
         if (last_trend == -1){//стария тренд е бил надолу
            //записваме в масива
            zz[lastlowpos] = lastlow;
            zzL[lastlowpos] = lastlow;
            lastlowpos = -1;
            lastlow = 9999999999;            
         }            
         last_trend = curr_trend;
      }
      //----------------------------------------------------------------
      
      //--------------------ТРЕНД НАГОРЕ--------------------
      if (curr_trend == 1 || (last_trend == 1 && curr_trend == 0)){
         if (lasthighpos == -1) {
            lasthighpos = shift; 
            lasthigh = High[lasthighpos];
            zzH[lasthighpos] = lasthigh;
            save_high_pos = lasthighpos;
         }else{
            if (High[shift] > lasthigh){
               zzH[lasthighpos] = lasthigh;
               save_high_pos = lasthighpos;
               lasthighpos = shift;   
               lasthigh = High[lasthighpos];               
            }
         }  
      }
      //----------------------------------------------------------------
      
      //---------------------ТРЕНД НАДОЛУ-------------------------------      
      if (curr_trend == -1 || (last_trend == -1 && curr_trend == 0)){
         if (lastlowpos == -1) {
            lastlowpos = shift; 
            lastlow = Low[lastlowpos];
            zzL[lastlowpos] = lastlow;
            save_low_pos = lastlowpos;
         }else{
            if (Low[shift] < lastlow){
               zzL[lastlowpos] = lastlow;
               save_low_pos = lastlowpos;
               lastlowpos = shift;                  
               lastlow = Low[lastlowpos];                  
            }
         }            
      }      
      //---------------------------------------------------------------            
              
      if (shift == min_shift){
         if (last_trend == 1){
            if (curr_trend == last_trend) zz[save_high_pos] = 0;
            zz[lasthighpos] = lasthigh;
            zzH[lasthighpos] = lasthigh;
            
         }
         if (last_trend == -1){
            if (curr_trend == last_trend) zz[save_low_pos] = 0;
            zz[lastlowpos] = lastlow;
            zzL[lastlowpos] = lastlow;
            
         }  

      }      
   }
   
   lasthightime = Time[lasthighpos];
   lastlowtime = Time[lastlowpos];
   lastcalcshifttime = Time[shift];    

   return(0);
}

//---------------------------------------------------------------
int trend_bars_break = 0;
//double high_1, low_1;
int TrendBarsBreak(int shift){
   //sl = 0;
   int timeframe = Period();
   double high_0 = High[iHighest(NULL, timeframe, MODE_HIGH, Bars_Break, shift)] - Atr_Ratio * iATR(NULL, timeframe, Atr_Period, shift);
   double low_0 = Low [iLowest(NULL, timeframe, MODE_LOW , Bars_Break, shift)] + Atr_Ratio * iATR(NULL, timeframe, Atr_Period, shift);
   //*
   double high_1 = High[iHighest(NULL, timeframe, MODE_HIGH, Bars_Break, shift+1)] - Atr_Ratio * iATR(NULL, timeframe, Atr_Period, shift+1);
   double low_1 = Low [iLowest(NULL, timeframe, MODE_LOW , Bars_Break, shift+1)] + Atr_Ratio * iATR(NULL, timeframe, Atr_Period, shift+1);        
   //*/
         
   if (iClose(NULL, timeframe, shift) > low_1) trend_bars_break = 1;
   if (iClose(NULL, timeframe, shift) < high_1) trend_bars_break = -1;      
   
   if (trend_bars_break == 1) {
      if (high_0 < high_1) high_0 = high_1;      
      //sl = high_0;
      zzTrend[shift] = high_0;
   }
   
   if (trend_bars_break == -1) {
      if (low_0 > low_1) low_0 = low_1;
      //sl = low_0;         
      zzTrend[shift] = low_0;
   }         
   //high_1 = high_0;
   //low_1 = low_0;   
   return(trend_bars_break);
}  
//---------------------------------------------------------------

//---------------------------------------------------------------
int trend_summary = 0;
int TrendSummary(int shift){
   if (TrendBarsBreak(shift) == 1)
      trend_summary = 1;
   else if (TrendBarsBreak(shift) == -1)
      trend_summary = -1;
   //else trend_summary = 0;
         
   return(trend_summary);
}      
//---------------------------------------------------------------

