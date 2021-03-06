#property copyright "Nikolay Stoychev"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 Lime
#property indicator_width2 Red

extern int ROCPeriod = 2;
extern bool PrintView = false;
double Buff_Buy[];
double Buff_Sell[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   if (PrintView){
      SetIndexStyle(0, DRAW_ARROW, NULL, 10);
      SetIndexStyle(1, DRAW_ARROW, NULL, 10);
   }else{
      SetIndexStyle(0, DRAW_ARROW, NULL, 3);   
      SetIndexStyle(1, DRAW_ARROW, NULL, 3);
   }
   SetIndexBuffer(0, Buff_Buy);
   SetIndexArrow(0, 241);
   SetIndexBuffer(1, Buff_Sell);
   SetIndexArrow(1, 242);
   

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
int start()  {

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars - counted_bars;  
   double ROC0, ROC1, ROC2, ROC3, level_revers1, level_revers0;
   for (int i = limit; i >= 0; i--) {
     
      //ROC2 =  iCustom(NULL, NULL, "ROC", ROCPeriod, 0, i+2);   
      ROC1 =  iCustom(NULL, NULL, "ROC", ROCPeriod, 0, i+1);   
      ROC0 =  iCustom(NULL, NULL, "ROC", ROCPeriod, 0, i);   
   
      level_revers1 = iClose(NULL, NULL, i+2) + ROC1;
      level_revers0 = iClose(NULL, NULL, i+1) + ROC0;
      
      if (iClose(NULL, NULL, i) >  level_revers1 && 
         iClose(NULL, NULL, i) >  level_revers0 
         //&&  ROC0 > ROC1 && ROC2 > ROC1
         ) {
         Buff_Buy[i] = iLow(NULL, NULL, i);
      }else{
         Buff_Buy[i] = 0;   
      }    
           
      if (iClose(NULL, NULL, i) <  level_revers1 && 
         iClose(NULL, NULL, i) <  level_revers0 
         //&&  ROC0 < ROC1 && ROC2 < ROC1
         ) {
         Buff_Sell[i] = iHigh(NULL, NULL, i);
      }else{
         Buff_Sell[i] = 0;   
      }         
   }      
   return(0);
}

