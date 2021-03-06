//+------------------------------------------------------------------+
//|                                          Ard_Ichimoku_Signal.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

//#property indicator_chart_window
#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 White
#property indicator_width3 1
extern int TenkanSen = 9, 
           KijinSen = 26, 
           SencouSpanB = 52;
extern double PointOffset = 0.0010;
//--- buffers
double BuffExtSignal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BuffExtSignal);
   SetIndexEmptyValue(0,0.0);   
   SetIndexLabel(0, "SignalBreak");
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
int trend = 0;
double up_level_signal = 0;
double down_level_signal = 0;
int start(){
   int    counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars;      
   
   double close, high, low;         
   
   for (int i = limit; i >= 0; i--) {
      close = iClose(NULL, NULL, i);
      high = iHigh(NULL, NULL, i+KijinSen);
      low = iLow(NULL, NULL, i+KijinSen);
      
      //--------------------------------------------------------------------------------------------------------------------------------
      if (
         iChimoku_GetTenkanSen(i)  > iChimoku_GetKijunSen(i)
         &&
         close > MinMaxByDir(1, iChimoku_GetSenkouSpanA(i), iChimoku_GetSenkouSpanB(i))
         &&
         iChimoku_GetChinkouSpan(i+KijinSen) > MinMaxByDir(1, iChimoku_GetSenkouSpanA(i+KijinSen), iChimoku_GetSenkouSpanB(i+KijinSen))         
         &&
         high < iChimoku_GetChinkouSpan(i+KijinSen)          
         && 
         (trend == 0 || trend == -1)
      ){                  
         up_level_signal = iHigh(NULL, NULL, i) + PointOffset;
         down_level_signal = 0;  
         
         trend = 1;
      }       
      
      //--------------------------------------------------------------------------------------------------------------------------------
      if (
         iChimoku_GetTenkanSen(i)  < iChimoku_GetKijunSen(i)
         &&
         close < MinMaxByDir(-1, iChimoku_GetSenkouSpanA(i), iChimoku_GetSenkouSpanB(i))
         &&
         iChimoku_GetChinkouSpan(i+KijinSen) < MinMaxByDir(-1, iChimoku_GetSenkouSpanA(i+KijinSen), iChimoku_GetSenkouSpanB(i+KijinSen))         
         &&
         low > iChimoku_GetChinkouSpan(i+KijinSen)                     
         &&
         (trend == 0 || trend == 1)
      ){         
         down_level_signal = iLow(NULL, NULL, i) - PointOffset; 
         up_level_signal = 0;         
         trend = -1;        
      } 
                          
      if (trend == 1){
         if (iHigh(NULL, NULL, i) > up_level_signal){
            BuffExtSignal[i] = 1; 
         }else{
            BuffExtSignal[i] = BuffExtSignal[i+1];
         }         
      }else{
         if (trend == -1){         
            if (iLow(NULL, NULL, i) < down_level_signal){
               BuffExtSignal[i] = -1;          
            }else{
               BuffExtSignal[i] = BuffExtSignal[i+1];
            }
         }else{
            BuffExtSignal[i] = 0;   
         }
         
      }         
   }
   return(0);
}
//+------------------------------------------------------------------+


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
   return (iIchimoku(NULL, NULL, TenkanSen, KijinSen, SencouSpanB, mode, shift));
}

double MinMaxByDir(int dir, double v1, double v2 )
{
   double result;   
   if( dir > 0 ) result = MathMax(v1,v2); else result = MathMin(v1,v2);   
   return (result);
}