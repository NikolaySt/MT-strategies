//+------------------------------------------------------------------+
//|                                                           #2.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color2  Green
#property  indicator_color4  Gray
#property  indicator_level1  0
#property  indicator_width2  1
#property  indicator_width4  2


double ChangeHigh[];
double ChangeClose[];
double ChangeLow[];
double ChangeMid[];

extern int PR_Period = 60;

int init()
{
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);

   SetIndexBuffer(1, ChangeClose);
   SetIndexBuffer(3, ChangeMid);

   IndicatorDigits(Digits + 1);

   IndicatorShortName("#2(" + PR_Period + ")");
   SetIndexLabel(1, "Close");
   SetIndexLabel(2, "Middle");
   return(0);
}

double price_change_high = 0;
double price_change_low = 0;
double price_change_close = 0;

void ComputePriceRange(int period, int shift)
{
   int high_shift = iHighest(Symbol(), 0, MODE_HIGH, period, shift);
   int low_shift = iLowest(Symbol(), 0, MODE_LOW, period, shift);
   double price_open = iClose(Symbol(), 0, period + shift);
   double price_high = iClose(Symbol(), 0, high_shift);
   double price_low = iClose(Symbol(), 0, low_shift);
   double price_close = iClose(Symbol(), 0, shift);
   
   price_change_high = (price_high - price_open) / Point;
   price_change_low = (price_low - price_open) / Point;
   price_change_close = (price_close - price_open) / Point;
}

int start()
{
   int i, limit;
   int counted_bars=IndicatorCounted();


   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;


   for(i = 0; i < limit; i++)
   {
      ComputePriceRange(PR_Period, i);
      ChangeHigh[i] = price_change_high;
      ChangeClose[i] = price_change_close;
      ChangeLow[i] = price_change_low;
      ChangeMid[i] = (price_change_high+price_change_low)/2;
   }
   
   return(0);
}