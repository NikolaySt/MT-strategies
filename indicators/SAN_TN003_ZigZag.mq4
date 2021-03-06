/**********************************************************************
TN003_ZigZag
 
 //TrendSummary// - обединява двата тренда в един
*********************************************************************/
#property copyright "Copyright © 2010, Nikolay Stoychev"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Aqua
#property indicator_width1 2
#property indicator_color2 Blue
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2
#property indicator_color4 Black
#property indicator_width4 0
#property indicator_color5 DodgerBlue
#property indicator_width5 1
#property indicator_color6 Red
#property indicator_width6 2
#property indicator_color7 Lime
#property indicator_width7 2
//---- indicator parameters
extern int BiasPeriod = 3;
extern int ST_AtdPeriod = 15;
extern double ST_Multiplier = 3.0;
extern int TimeStart = 0;
extern int TimeEnd = 23;
//---- indicator buffers
double zz[];
double zzL[];
double zzH[];
double zzTrend[];
double BiasBuff[];
double TrendBuff1[];
double TrendBuff2[];

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
   
   SetIndexBuffer(4, BiasBuff);
   SetIndexStyle(4, DRAW_LINE);    
   
   SetIndexBuffer(5, TrendBuff1);   
   SetIndexStyle(5, DRAW_LINE); 
   
   SetIndexBuffer(6, TrendBuff2);   
   SetIndexStyle(6, DRAW_LINE);    

   //IndicatorShortName("TN001_ZZ("+MAPeriod+", "+MAShift+")");
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
   
   if ((lasthightime == 0 && lastlowtime == 0) )//|| (Bars - bars_count > 1))
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
        
      limit = Bars-100;      
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
int trend_summary = 0;
int TrendSummary(int shift){
   //double super_trend = iCustom(NULL, NULL, "SuperTrendExt", ST_AtdPeriod, ST_Multiplier, Signal_TimeStart, Signal_TimeEnd, 1, shift-1);
   double super_trend = iCustom(NULL, NULL, "SAN_SuperTrendNew", ST_AtdPeriod, ST_Multiplier, 1, shift);
   
   //TrendBuff2[shift] = iCustom(NULL, NULL, "SuperTrendExt", ST_AtdPeriod, ST_Multiplier, 0, shift-1);
   //TrendBuff1[shift] = iCustom(NULL, NULL, "SuperTrendExt", ST_AtdPeriod, ST_Multiplier, 1, shift-1);
   //BiasBuff[shift] = iCustom(NULL, NULL, "SuperTrendExt", ST_AtdPeriod, ST_Multiplier, 3, shift-1);
   
   //double bias_trend = iCustom(NULL, NULL, "Ard_BiasLogicExp", BiasPeriod, 150,  TimeStart, TimeEnd, 1, shift-1);
   //BiasBuff[shift] = iCustom(NULL, NULL, "Ard_BiasLogicExp", BiasPeriod, 150, 0, shift);
   //double super_trend = bias_trend;
  double bias_trend = super_trend;
   if (super_trend == 1 && bias_trend == 1)
      trend_summary = 1;
   else if (super_trend == -1 && bias_trend == -1)
      trend_summary = -1;
   //else trend_summary = 0;
         
   return(trend_summary);
}      
//---------------------------------------------------------------

 
      