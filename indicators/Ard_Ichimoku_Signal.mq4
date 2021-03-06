//+------------------------------------------------------------------+
//|                                          Ard_Ichimoku_Signal.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window


#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

#property indicator_width1 4
#property indicator_width2 4

extern int TenkanSen = 9, 
           KijinSen = 26, 
           SencouSpanB = 52;
//--- buffers
double BuffUpSignal[];
double BuffDownSignal[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,BuffUpSignal);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,BuffDownSignal);
   SetIndexEmptyValue(1,0.0);
   
  
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
bool up_signal = false;
bool down_signal = false;
int start()
  {
   int    counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars;      
   
   double close, high, low;         
   
   for (int i = limit; i >= 1; i--) {
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
         BuffUpSignal[i] = iHigh(NULL, NULL, i); 
         
         
         trend = 1;
         up_signal = false;
      }
      if (trend == 1){
         if (iChimoku_GetTenkanSen(i)  > iChimoku_GetKijunSen(i)  && iChimoku_GetTenkanSen(i+1)  <= iChimoku_GetKijunSen(i+1)){
            up_signal = true;
         }
         if (up_signal
            &&
            iChimoku_GetTenkanSen(i)  > iChimoku_GetKijunSen(i)
            &&
            close > MinMaxByDir(1, iChimoku_GetSenkouSpanA(i), iChimoku_GetSenkouSpanB(i))
            &&
            iChimoku_GetChinkouSpan(i+KijinSen) > MinMaxByDir(1, iChimoku_GetSenkouSpanA(i+KijinSen), iChimoku_GetSenkouSpanB(i+KijinSen))         
            &&
            high < iChimoku_GetChinkouSpan(i+KijinSen)            
            ){
               BuffUpSignal[i] = iHigh(NULL, NULL, i); 
               up_signal = false;   
            }
      }
      //--------------------------------------------------------------------------------------------------------------------------------
       
      
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
         BuffDownSignal[i] = iLow(NULL, NULL, i); 
         
         trend = -1;
         down_signal = false;
      } 
      
      if (trend == -1){
         if (iChimoku_GetTenkanSen(i)  < iChimoku_GetKijunSen(i) && iChimoku_GetTenkanSen(i+1)  >= iChimoku_GetKijunSen(i+1)){
            down_signal = true;
         }
         if (down_signal
            &&
            iChimoku_GetTenkanSen(i)  < iChimoku_GetKijunSen(i)
            &&
            close < MinMaxByDir(-1, iChimoku_GetSenkouSpanA(i), iChimoku_GetSenkouSpanB(i))
            &&
            iChimoku_GetChinkouSpan(i+KijinSen) < MinMaxByDir(-1, iChimoku_GetSenkouSpanA(i+KijinSen), iChimoku_GetSenkouSpanB(i+KijinSen))         
            &&
            low > iChimoku_GetChinkouSpan(i+KijinSen)            
            ){
               BuffDownSignal[i] = iLow(NULL, NULL, i); 
               down_signal = false;   
            }
      } 
      //--------------------------------------------------------------------------------------------------------------------------------                          
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