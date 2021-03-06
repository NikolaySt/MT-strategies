//+------------------------------------------------------------------+
//|                                                       SAN_AO.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Red
#property indicator_color3 Lime

//--- input parameters
extern int       MAFast=5;
extern int       MASlow=34;
extern int       MASignal=5;
//--- buffers
double ACBuff1[];
double ACBuff2[];
double AOBuff[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
    SetIndexStyle(0,DRAW_LINE);  
   SetIndexBuffer(0, AOBuff);     
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1, ACBuff1);
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2, ACBuff2); 
   

     
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
int start(){
   int limit = Bars-IndicatorCounted();   
           
   for (int i = 0; i < limit; i++) {
      AOBuff[i] = iMA(NULL, NULL, MAFast, 0, MODE_SMA, PRICE_MEDIAN, i)
               -
            iMA(NULL, NULL, MASlow, 0, MODE_SMA, PRICE_MEDIAN, i);                                                
   }
   
   double value, value_old = 0;
   
   for ( i = 0; i < limit; i++) {
      value = AOBuff[i] - iMAOnArray(AOBuff, Bars, MASignal, 0, MODE_SMA, i);                                                
      value_old = AOBuff[i+1] - iMAOnArray(AOBuff, Bars, MASignal, 0, MODE_SMA, i+1);                                                
            
      if (value > value_old){
         ACBuff2[i]  = value;
         ACBuff1[i]  = 0;
      }else{      
         ACBuff1[i]  = value;
         ACBuff2[i]  = 0;      
      }   
            
   }      
   
   return(0);
}
//+------------------------------------------------------------------+