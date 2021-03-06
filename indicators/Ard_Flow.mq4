//+------------------------------------------------------------------+
//|                                                 Ard_Ichimoku.mq4 |
//|                                    Copyright © 2008 Ariadna Ltd. |
//|                                              revision 24.02.2008 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008 Ariadna Ltd."
#property link      "revision 24.02.2008"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 LightSteelBlue
#property indicator_color2 Pink
#property indicator_color3 LightSteelBlue
#property indicator_color4 Pink
#property indicator_color5 LightSteelBlue
#property indicator_color6 Pink

#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2

extern string  About = "Copyright(c) 2008 Ariadna Ltd";
extern string  Revision = "27.02.2008";
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];


double Array_RedLine[10];
double Array_GreenLine[10];
double Array_ich_a[10];
double Array_ich_b[10];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);

   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);   
  
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);

   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   
   
   ArrayInitialize(Array_RedLine, EMPTY_VALUE);
   ArrayInitialize(Array_GreenLine, EMPTY_VALUE);
   ArrayInitialize(Array_ich_a, EMPTY_VALUE);
   ArrayInitialize(Array_ich_b, EMPTY_VALUE);
   
   SetIndexStyle(4,DRAW_SECTION);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexShift(4, 3);
   SetIndexEmptyValue(ExtMapBuffer5, EMPTY_VALUE);
   
   SetIndexStyle(5,DRAW_SECTION);
   SetIndexBuffer(5,ExtMapBuffer6);   
   SetIndexShift(5, 3);
   SetIndexEmptyValue(ExtMapBuffer6, EMPTY_VALUE);       
   

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
   
   int limit = MathMin(6000, MathMax(Bars - IndicatorCounted(), 100));
   
   int n, Small_shift_begin, Small_shift_end, Small_Period;
   double senko_a, senko_b, base_line, Small_close;
   double Red_Line, Green_Line;
   double value_senkosa, value_senkosb, value_senkosa_1, value_senkosb_1;
   double prev_value_senkosa, prev_value_senkosb;
   
   switch (Period()){
      case PERIOD_MN1: Small_Period = PERIOD_W1;  break;
      case PERIOD_W1:  Small_Period = PERIOD_D1;  break; 
      case PERIOD_D1:  Small_Period = PERIOD_H4;  break; 
      case PERIOD_H4:  Small_Period = PERIOD_H1;  break; 
      case PERIOD_H1:  Small_Period = PERIOD_M15; break;
      case PERIOD_M15: Small_Period = PERIOD_M5;  break;
   }
   int offcet = MathRound( 26/( Period()/Small_Period ) );// + 1 ;
   double median;
   double value_atr;
   for (int i = limit - 1; i >= 0; i--){           
      
      Small_shift_begin = iBarShift(NULL, Small_Period, Time[i]); 
      Small_shift_end = iBarShift(NULL, Small_Period, Time[i-1]); 
      if (i == 0) Small_shift_end = 0;
      
      Red_Line = iMA(NULL, 0, 8, 5, MODE_SMMA, PRICE_MEDIAN, i);       
      Green_Line = iMA(NULL, 0, 5, 3, MODE_SMMA, PRICE_MEDIAN, i);  
      

      value_senkosa = 0;
      value_senkosb = 0;
      value_senkosa_1 = 0;
      value_senkosb_1 = 0;
      for (n = Small_shift_begin; n >= Small_shift_end+1; n--){
         value_senkosa = value_senkosa + iIchimoku(NULL, Small_Period, 9, 26, 52, MODE_SENKOUSPANA, n);
         value_senkosb = value_senkosb + iIchimoku(NULL, Small_Period, 9, 26, 52, MODE_SENKOUSPANB, n);     
             
         value_senkosa_1 = value_senkosa_1 + iIchimoku(NULL, Small_Period, 9, 26, 52, MODE_SENKOUSPANA, n-26);
         value_senkosb_1 = value_senkosb_1 + iIchimoku(NULL, Small_Period, 9, 26, 52, MODE_SENKOUSPANB, n-26);           
      }   
      if (MathAbs(Small_shift_begin - Small_shift_end) !=0){
         value_senkosa = value_senkosa/MathAbs(Small_shift_begin - Small_shift_end);
         value_senkosb = value_senkosb/MathAbs(Small_shift_begin - Small_shift_end);
         
         Array_ich_a[i] = value_senkosa_1/MathAbs(Small_shift_begin - Small_shift_end);
         Array_ich_b[i] = value_senkosb_1/MathAbs(Small_shift_begin - Small_shift_end);       
      }else{  
         value_senkosa = prev_value_senkosa;
         value_senkosb = prev_value_senkosb;      
         Array_ich_a[i] = Array_ich_a[i+1]; 
         Array_ich_b[i] = Array_ich_b[i+1];   
      }
            
      ExtMapBuffer1[i] = MathMax(MathMax(Red_Line, Green_Line), MathMax(value_senkosa, value_senkosb));
      ExtMapBuffer2[i] = MathMin(MathMin(Red_Line, Green_Line), MathMin(value_senkosa, value_senkosb));
      
      //value_atr = iATR(NULL, 0, 21, i)*0.4;
      //median = ExtMapBuffer2[i] + (ExtMapBuffer1[i] - ExtMapBuffer2[i])/2;
      
      ExtMapBuffer3[i] = ExtMapBuffer1[i];//MathMax(median + value_atr, ExtMapBuffer1[i]);
      ExtMapBuffer4[i] = ExtMapBuffer2[i];//MathMin(median - value_atr, ExtMapBuffer2[i]);
      prev_value_senkosa = value_senkosa;
      prev_value_senkosb = value_senkosb;
      
      
      Array_RedLine[i] = iMA(NULL, 0, 8, 0, MODE_SMMA, PRICE_MEDIAN, i);       
      Array_GreenLine[i] = iMA(NULL, 0, 5, 0, MODE_SMMA, PRICE_MEDIAN, i);        
   }  

   for (i = 5; i >= 0; i--){
      ExtMapBuffer5[i] = 
         MathMax(
            MathMax(Array_RedLine[i+2], Array_GreenLine[i]), 
            MathMax(Array_ich_a[i+offcet-3], Array_ich_b[i+offcet-3])
         );
      ExtMapBuffer6[i] = 
         MathMin(
            MathMin(Array_RedLine[i+2], Array_GreenLine[i]), 
            MathMin(Array_ich_a[i+offcet-3], Array_ich_b[i+offcet-3])
         );  
   }   
   ExtMapBuffer5[5] = ExtMapBuffer3[2];
   ExtMapBuffer6[5] = ExtMapBuffer4[2];   

   
   ExtMapBuffer5[4] = ExtMapBuffer3[1];
   ExtMapBuffer6[4] = ExtMapBuffer4[1];   
   
   ExtMapBuffer5[3] = ExtMapBuffer3[0];
   ExtMapBuffer6[3] = ExtMapBuffer4[0];   
   return(0);
   
  }
//+------------------------------------------------------------------+


