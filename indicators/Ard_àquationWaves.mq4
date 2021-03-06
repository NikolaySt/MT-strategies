//+------------------------------------------------------------------+
//|                                          Ard_NeoWave≈quation.mq4 |
//|                               Copyright © 2007, Nikolay Stoychev |
//|                                              revision 01.02.2007 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Nikolay Stoychev "
#property link      "revision 01.02.2007"

#property indicator_separate_window

#property indicator_minimum 1
#property indicator_maximum 100

#property indicator_buffers 6
#property indicator_color1 Silver
#property indicator_color2 Lavender
#property indicator_color3 Gainsboro
#property indicator_color4 Gainsboro
#property indicator_color5 Gainsboro
#property indicator_color6 Gainsboro

#property indicator_level1 25
#property indicator_level2 50
#property indicator_level3 75
#property indicator_level4 100


#property indicator_levelcolor Black
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID


 bool ExtensionLevel = true;
 double Level1 = 22;
 double Level2 = 47;
 double Level3 = 72;
 double Level4 = 97;

extern string About = "Copyright © 2007 Nikolay Stoychev";
extern string Revision = "21.03.2007";

double VerticalLinePeriod[];
double VerticalLineMedianPeriod[];

double Level1Buf[];
double Level2Buf[];
double Level3Buf[];
double Level4Buf[];



int init(){
   IndicatorShortName("≈quations") ;
   
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(0,VerticalLinePeriod);
   SetIndexEmptyValue(0, 0);
   SetIndexLabel(0, "");

   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,VerticalLineMedianPeriod);   
   SetIndexEmptyValue(1, 0);
   SetIndexLabel(1, "");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Level1Buf);
   SetIndexLabel(2, "");
      
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Level2Buf);
   SetIndexLabel(3, "");
         
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Level3Buf);   
   SetIndexLabel(4, "");

   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Level4Buf); 
   SetIndexLabel(5, "");     
   
   SetLevelStyle(STYLE_SOLID, 1, SlateGray);

   return(0);
}

int deinit(){
   return(0);
}

#include <MonoWave\CreationWaves\CalculationPeriods.mqh>
#include <MonoWave\CreationWaves\CalculationRawMonoWave.mqh>

int start(){
   int limit = Bars - IndicatorCounted();
   int period_calc = PeriodCalc();
   int save_up_time_shift, up_time_shift;
   int p1, p2, old_p1, median;
   if (period_calc == 0) return(0);

   for(int i = 0; i < 2000; i++){
      
      up_time_shift = GetShiftPosition_Period(i, period_calc); 
      
      if (ExtensionLevel){
         Level1Buf[i] = Level1;
         Level2Buf[i] = Level2;
         Level3Buf[i] = Level3; 
         Level4Buf[i] = Level4;
      }
      if (save_up_time_shift != up_time_shift || i == 0){
         CalcPostionBeginEndPeriod(period_calc, i, up_time_shift, p1, p2);
         
         VerticalLinePeriod[p1] = 101;

         median = MathRound(old_p1 + (MathAbs(p1-old_p1))/2);
         VerticalLineMedianPeriod[median] = 101;
           
         old_p1 = p1;  
         
         if (i != 0){ 
            save_up_time_shift = up_time_shift;    
         }
                         
      }
   }
   return(0);
}

