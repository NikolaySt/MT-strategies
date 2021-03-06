//+------------------------------------------------------------------+
//|                                                 SAN_AOACZone.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 White
#property indicator_color4 White

extern int MAFast = 5;
extern int MASlow = 34;
extern int MASignal = 5;

//--- buffers
double Buff_Direc[];
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double Buff_AO[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Buff_Direc);  
    
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Buff_AO);     
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
   int zone_0, zone_1;
   for (int i = limit; i >= 0; i--) {
      
      
      zone_0 = IndAC(i) + IndAO(i);      
      zone_1 = IndAC(i+1) + IndAO(i+1);      
      
      Buff_Direc[i] = 0;
      
      if (zone_0 == 2 && zone_1 == 2){ //zelena zona
         ExtMapBuffer1[i] = Low[i];   
         ExtMapBuffer2[i] = High[i];
         ExtMapBuffer1[i+1] = Low[i+1];   
         ExtMapBuffer2[i+1] = High[i+1];  
         Buff_Direc[i] = 1;       
      }
      if (zone_0 == -2 && zone_1 == -2){ //4ervena zona
         ExtMapBuffer1[i] = High[i];
         ExtMapBuffer2[i] = Low[i];     
         ExtMapBuffer1[i+1] = High[i+1];
         ExtMapBuffer2[i+1] = Low[i+1];                     
         Buff_Direc[i] = -1;
      }  
   }
   return(0);
  }
//+------------------------------------------------------------------+


int IndAC(int shift){
   int dir = 0;
   double AC_0 = AC(shift);//iAC(NULL, NULL, shift);
   double AC_1 = AC(shift+1);//iAC(NULL, NULL, shift+1);
   if (AC_0 > AC_1) {dir = 1;}                // zelen бар
   if (AC_0 < AC_1) {dir = -1;}               // 4erven бар
   return(dir);
}


int IndAO(int shift){
   int dir = 0;
   double AO_0 = AO(shift);//iAO(NULL, NULL, shift);
   double AO_1 = AO(shift+1);//iAO(NULL, NULL, shift+1);
   if (AO_0 > AO_1) {dir = 1;}                // zelen бар
   if (AO_0 < AO_1) {dir = -1;}               // 4erven бар
   return(dir);
}


double AO(int shift){
   return(iCustom(NULL, NULL, "SAN_AO", MAFast, MASlow, MASignal, 0, shift));
   
}


double AC(int shift){   
   return(iCustom(NULL, NULL, "SAN_AO", MAFast, MASlow, MASignal, 1, shift));
}