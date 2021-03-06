//+------------------------------------------------------------------+
//|                                       SAN_AtrVolatility.mq4 v2.0 |
//|                                       Copyright ? 2011, SAN TEAM |
//+------------------------------------------------------------------+
#property copyright "Copyright ? 2011, SAN TEAM"

/*
//..for Experts//
//index = 2; ->Get Trend: 
double AtrTrend = iCustom(NULL, NULL, "Atr_Trend.mq4", AtdPeriod, Multiplier, 2, 1);
//AtrTrend = 1 uptrend
//AtrTrend = -1 downtrend
//*/

#property indicator_chart_window
#property indicator_buffers 4

#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 White
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 2

extern int AtdPeriod = 15;
extern double Multiplier = 3.0;

double BuffLine[];
double Trend[];
double up[];
double dn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_LINE);   
   SetIndexBuffer(0, dn);     

   SetIndexStyle(1, DRAW_LINE);   
   SetIndexBuffer(1, up);
   
   SetIndexBuffer(2, Trend);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);   
   SetIndexLabel(2, "Trend");   
   
   SetIndexBuffer(3, BuffLine);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(3, "Level");   
           
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start(){   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars-counted_bars;      
   double atr;
   double medianPrice;   
         
   for (int i = limit; i >= 0; i--) {
      atr = iATR(NULL, 0, AtdPeriod, i);
      medianPrice = (High[i] + Low[i]) / 2;   

      up[i] = medianPrice+(Multiplier*atr);
      dn[i] = medianPrice-(Multiplier*atr);    
         
      if (Close[i] < dn[i+1] ) Trend[i] = -1; 
      else if (Close[i] > up[i+1] ) Trend[i] = 1;
      else if (Trend[i+1] == -1) Trend[i] = -1;
      else if (Trend[i+1] == 1) Trend[i] = 1;      
         
      if (Trend[i] > 0 && dn[i] < dn[i+1]) dn[i] = dn[i+1];      
      if (Trend[i] < 0 && up[i] > up[i+1]) up[i] = up[i+1];            
   
      if (Trend[i] < 0 && Trend[i+1] > 0) up[i] = medianPrice + (Multiplier*atr);         
      if (Trend[i] > 0 && Trend[i+1] < 0) dn[i] = medianPrice - (Multiplier*atr);
   
      if (Trend[i] == -1) BuffLine[i] = up[i];
      if (Trend[i] == 1)  BuffLine[i] = dn[i];
   }
}

