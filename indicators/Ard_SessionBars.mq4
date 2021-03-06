//+------------------------------------------------------------------+
//|                                              Ard_SessionBars.mq4 |
//|                               Copyright © 2010, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Nikolay Stoychev"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 DodgerBlue
#property indicator_color3 Red
#property indicator_color4 DodgerBlue
#property indicator_width3 5
#property indicator_width4 5
//--- input parameters
extern int       BeginHourSess1 = 7;
extern int       EndHourSess1 = 12;
extern int       BeginHourSess2 = 15;
extern int       EndHourSess2 = 20;
//--- buffers
double HLBuff1[];
double HLBuff2[];
double OCBuff1[];
double OCBuff2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(0,HLBuff1);
   
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(1,HLBuff2);
   
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID, 5);
   SetIndexBuffer(2,OCBuff1);
   
   SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID, 5);
   SetIndexBuffer(3,OCBuff2);
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
   
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);   
   if(counted_bars > 0) counted_bars--;   

   int limit = Bars - counted_bars;  
   
   double o1, h1, c1, l1;
   int index1 = -1;
   
   double o2, h2, c2, l2;
   int index2 = -1;
      
   int hour;
   for (int i = limit; i >= 0; i--) {
      
//*---------------------------------------------------------------------------------------------      
      hour = TimeHour(iTime(NULL, PERIOD_H1, i));
      if (hour >= BeginHourSess1 && hour <= EndHourSess1){
         if (hour == BeginHourSess1){
            index1 = i;
            o1 = iOpen(NULL, PERIOD_H1, index1);                 
         } 
         if (index1 != -1){
            h1 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, index1 - i + 1, i));
            l1 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, index1 - i + 1, i));
            c1 = iClose(NULL, PERIOD_H1, i);  
                       
            if (o1 > c1){
               HLBuff1[index1] = h1;
               HLBuff2[index1] = l1;                     
            }else{
               HLBuff1[index1] = l1;
               HLBuff2[index1] = h1;                    
            }            
            OCBuff1[index1] = o1;
            OCBuff2[index1] = c1;                  
         }
      }
//------------------------------------------------------------------------------------------*/      
      
      
      
//*---------------------------------------------------------------------------------------------            
      if (hour >= BeginHourSess2 && hour <= EndHourSess2){
         if (hour == BeginHourSess2) {
            index2 = i;  
            o2 = iOpen(NULL, PERIOD_H1, index2);
         }  
         if (index2 != -1){                   
            h2 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, index2 - i + 1, i));
            l2 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, index2 - i + 1, i));
            c2 = iClose(NULL, PERIOD_H1, i);          
         
            if (o2 > c2){
               HLBuff1[index2] = h2;
               HLBuff2[index2] = l2;            
            }else{
               HLBuff1[index2] = l2;
               HLBuff2[index2] = h2;                                 
            } 
            OCBuff1[index2] = o2;
            OCBuff2[index2] = c2;       
         }
      }
//------------------------------------------------------------------------------------------*/        
      
   } 
   return(0);
  }
//+------------------------------------------------------------------+


/*---------------------------------------------------------------------------------------------      
      hour = TimeHour(iTime(NULL, PERIOD_H1, i));
      if (hour == BeginHourSess2){
         o2 = iOpen(NULL, PERIOD_H1, i);   
         h2 = iHigh(NULL, PERIOD_H1, i);
         l2 = iLow(NULL, PERIOD_H1, i);
         c2 = iClose(NULL, PERIOD_H1, i);   
         index2 = i;  
         if (o2 > c2){
            HLBuff1[index2] = h2;
            HLBuff2[index2] = l2;                     
         }else{
            HLBuff1[index2] = l2;
            HLBuff2[index2] = h2;                    
         }            
         OCBuff1[index2] = o2;
         OCBuff2[index2] = c2;                  
      }
      if (hour > BeginHourSess2 && hour <= EndHourSess2){
         h2 = iHigh(NULL, PERIOD_H1, iHighest(NULL, PERIOD_H1, MODE_HIGH, index2 - i + 1, i));
         l2 = iLow(NULL, PERIOD_H1, iLowest(NULL, PERIOD_H1, MODE_LOW, index2 - i + 1, i));
         c2 = iClose(NULL, PERIOD_H1, i);          
         
         if (o2 > c2){
            HLBuff1[index2] = h2;
            HLBuff2[index2] = l2;            
         }else{
            HLBuff1[index2] = l2;
            HLBuff2[index2] = h2;                                 
         } 
         OCBuff1[index2] = o2;
         OCBuff2[index2] = c2;       
      }
//------------------------------------------------------------------------------------------ */ 