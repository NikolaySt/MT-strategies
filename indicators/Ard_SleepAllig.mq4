//+------------------------------------------------------------------+
//|                                               Ard_SleepAllig.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 White
#property indicator_width3 3
//--- input parameters
extern double       RangePips=35;
extern double       CountBars=20;
//--- buffers
double buff1[];
double buff2[];
double buff3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,buff1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,buff2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,buff3);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars;      
   
   double green, red, blue, center;
   double up_ma1, down_ma1, up_ma2, down_ma2;
   double up_level, down_level;
   int middle_bars = MathRound(CountBars / 2);
   
   int n;
   for (int i = limit; i >= 0; i--) {

           
      center = iMA(0, 0, 8, 5, MODE_SMMA, PRICE_MEDIAN, i+middle_bars);
      up_level = center + (RangePips/2)*Point;
      down_level = center - (RangePips/2)*Point;

   
      green = iMA(0, 0, 5, 3, MODE_SMMA, PRICE_MEDIAN, i);
      red = iMA(0, 0, 8, 5, MODE_SMMA, PRICE_MEDIAN, i);
      blue = iMA(0, 0, 13, 8, MODE_SMMA, PRICE_MEDIAN, i);      
      
      up_ma1 = MathMax(blue, MathMax(green, red));
      down_ma1 = MathMin(blue, MathMin(green, red));         
      
      green = iMA(0, 0, 5, 3, MODE_SMMA, PRICE_MEDIAN, i + CountBars);
      red = iMA(0, 0, 8, 5, MODE_SMMA, PRICE_MEDIAN, i + CountBars);
      blue = iMA(0, 0, 13, 8, MODE_SMMA, PRICE_MEDIAN, i + CountBars);      
      
      up_ma2 = MathMax(blue, MathMax(green, red));
      down_ma2 = MathMin(blue, MathMin(green, red));             
      
      if (Time[i] == StrToTime("2010.10.01 03:00")){
            Print("time = ", TimeToStr(Time[i]), ", i = ", i);
            Print("up_ma_1 = ", up_ma1, ", down_ma_1 = ", down_ma1);
            Print("up_ma_2 = ", up_ma2, ", down_ma_2 = ", down_ma2);
            Print("down_level = ", down_level, ", up_level = ", up_level);      
      }            
      
      if ( 
            
            up_ma1 <= up_level && down_ma1 >= down_level 
            &&
            up_ma2 <= up_level && down_ma2 >= down_level 
            
          ){
         //buff1[i] = High[i];
         buff3[i] = High[i];
         for (n = i; n <= i + CountBars; n++){
            buff1[n] = High[n];
            buff2[n] = Low[n];
         }                         
      }
          
         
    
   }
   return(0);
  }
//+------------------------------------------------------------------+