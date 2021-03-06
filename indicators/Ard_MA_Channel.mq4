//+------------------------------------------------------------------+
//|                                               Ard_MA_Channel.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 18.11.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 18.11.2009"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
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
   double ma, range = 0;
   for(int i = Bars; i >= 0; i --){
      ma = iMA(NULL, NULL, 8, 2, MODE_SMMA, PRICE_MEDIAN, i);
      range = iATR(NULL, Period(), 2, i);
      ExtMapBuffer1[i] = ma;
      ExtMapBuffer2[i] = MATrendLine(MODE_UPPER, i);//ma + range*0.25;
      ExtMapBuffer3[i] =  MATrendLine(MODE_LOWER, i);//ma - range*0.25;
   }
   return(0);
  }
//+------------------------------------------------------------------+



double MATrendLine(int mode, int shift){ 
   int TimeFrame = 0;
   
   if (mode == 0){
      return(iMA(NULL, TimeFrame, 8, 2, MODE_SMMA, PRICE_MEDIAN, shift));   
   }else{      
      if (mode == MODE_UPPER){
         return(
            MathMax(iMA(NULL, TimeFrame, 8, 2, MODE_SMMA, PRICE_MEDIAN, shift) + iATR(NULL, TimeFrame, 2, shift)*0.2,
                    iEnvelopes(NULL, TimeFrame, 8, MODE_SMMA, 2, PRICE_MEDIAN, 0.2, mode, shift)
                    )               
                );
      }else{
         if (mode == MODE_LOWER){   
            return(MathMin(
               iMA(NULL, TimeFrame, 8, 2, MODE_SMMA, PRICE_MEDIAN, shift) - iATR(NULL, TimeFrame, 2, shift)*0.2,
               iEnvelopes(NULL, TimeFrame, 8, MODE_SMMA, 2, PRICE_MEDIAN, 0.2, mode, shift)
                          )
                   );
         }
      }                  
   }
}