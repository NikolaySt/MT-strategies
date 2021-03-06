//+------------------------------------------------------------------+
//|                                                    MySystem.mq4  |
//|                               Copyright © 2007, Nikolay Stoychev |
//|                                                       22.10.2007 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Nikolay Stoychev"
#property link      "26.07.2006"

#property indicator_chart_window
#property indicator_buffers 7
//---- input parameters
extern string ColorDiagram = "white";
extern string About = "Copyright © 2009, Nikolay Stoychev";
extern bool Bollinger = true;
extern bool MA = true;
extern bool Fractals = true;
extern bool Fractals_Line = true;
//---- buffers
double Buffer_Upper[];
double Buffer_Lower[];
double Buffer_MA1[];
double Buffer_MA2[];
double Buffer_Fraktals_up[];
double Buffer_Fraktals_down[];
double FractalsLine[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
     
   SetIndexBuffer(0,Buffer_Upper);
   SetIndexDrawBegin(0,21);

   
   SetIndexBuffer(1,Buffer_Lower);
   SetIndexDrawBegin(1,21);
   
   
   SetIndexBuffer(2,Buffer_MA1);
   SetIndexShift(2, 3);
   SetIndexDrawBegin(2,21);
   
   
   SetIndexBuffer(3,Buffer_MA2);
   SetIndexShift(3, 5);
   SetIndexDrawBegin(3,21);   
   
   SetIndexBuffer(4, Buffer_Fraktals_up); 
   SetIndexDrawBegin(4, 5);    
   
   SetIndexBuffer(5, Buffer_Fraktals_down); 
   SetIndexDrawBegin(5, 5);   
   
   SetIndexBuffer(6, FractalsLine);     
  
   
   if (ColorDiagram == "black"){   
      SetIndexStyle(0,DRAW_LINE, STYLE_SOLID, 1, LightGray);
      SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, 1, LightGray);
      SetIndexStyle(2,DRAW_LINE, STYLE_DOT, 1, Lime);
      SetIndexStyle(3,DRAW_LINE, STYLE_SOLID, 2, Red);
      
      SetIndexStyle(4,DRAW_ARROW, STYLE_SOLID, 0, DeepSkyBlue);      
      SetIndexArrow(4, 217);             
      SetIndexStyle(5,DRAW_ARROW, STYLE_SOLID, 0, DeepSkyBlue);      
      SetIndexArrow(5, 218);  
      
      SetIndexStyle(6, DRAW_SECTION, STYLE_SOLID, 1, Silver);          
   }else{
      SetIndexStyle(0,DRAW_LINE, STYLE_SOLID, 1, MediumBlue);
      SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, 1, MediumBlue);
      SetIndexStyle(2,DRAW_LINE, STYLE_DOT, 1, MediumSeaGreen);
      SetIndexStyle(3,DRAW_LINE, STYLE_SOLID, 2, Red);
      
            
      SetIndexStyle(4,DRAW_ARROW, STYLE_SOLID, 0, Black);      
      SetIndexArrow(4, 217);            
      SetIndexStyle(5,DRAW_ARROW, STYLE_SOLID, 0, Black);      
      SetIndexArrow(5, 218);     
      
      SetIndexStyle(6, DRAW_SECTION, STYLE_SOLID, 1, LightSlateGray);       
   }     

   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int   limit = Bars - IndicatorCounted();
   double offset, value;
   
   double up_fractal, down_fractal;   

   for(int i=limit-1; i>=0; i--){
      if (Bollinger) {
         Buffer_Upper[i] = iBands(NULL, 0, 21, 2, 0, PRICE_MEDIAN, MODE_UPPER, i);
         Buffer_Lower[i] = iBands(NULL, 0, 21, 2, 0, PRICE_MEDIAN, MODE_LOWER, i);
      }
      if (MA) {
         Buffer_MA1[i] = iMA(NULL, 0, 9, 0, MODE_EMA, PRICE_MEDIAN, i);             
         Buffer_MA2[i] = iMA(NULL, 0, 15, 0, MODE_EMA, PRICE_MEDIAN, i);
      }         
      if (i > 0){
         if (Fractals) {
            offset = iATR(NULL, 0, 21, i);
            //Buffer_Fraktals_up[i] = iFractals(NULL, 0, MODE_UPPER, i) + offset * 0.10;
            //Buffer_Fraktals_down[i] = iFractals(NULL, 0, MODE_LOWER, i) - offset * 0.15;
         
            //Фрактали по 3 бара
            Buffer_Fraktals_up[i] = UpFractal(i) + offset * 0.10;
            Buffer_Fraktals_down[i] = DownFractal(i) - offset * 0.15;         
         
            if (Fractals_Line) {
               //value = iFractals(NULL, 0, MODE_UPPER, i);
               //Фрактали по 3 бара
               value = UpFractal(i);
               if (value > 0){
                  FractalsLine[i] = value;   
               }
                 
               //value = iFractals(NULL, 0, MODE_LOWER, i);
               //Фрактали по 3 бара
               value = DownFractal(i);
               if (value > 0){
                  FractalsLine[i] = value;   
               }  
            }                    
         }
      } 

      
              
   }
   /*
   string Small_Period = "";
   switch (Period()){
      case PERIOD_MN1: Small_Period = "Модели по потока на Година"; break;
      case PERIOD_W1: Small_Period = "Модели по потока на МЕСЕЦ"; break; 
      case PERIOD_D1: Small_Period = "Модели по потока на СЕДМИЦА"; break; 
      case PERIOD_H4: Small_Period = "Модели по потока на ДЕН"; break; 
      case PERIOD_H1: Small_Period = "Модели по потока на 4-часа"; break;
      case PERIOD_M15: Small_Period = "Модели по потока на 1-час"; break;
      case PERIOD_M5: Small_Period = "Модели по потока на 15-минути"; break;      
   }
   Comment(Small_Period);
   */
   return(0);
  }

double UpFractal(int i){   
   if (High[i] >= High[i+1] && High[i] >= High[i-1]){
      return(High[i]);
   }else{
      return(0);
   }
}

double DownFractal(int i){   
   if (Low[i] <= Low[i+1] && Low[i] <= Low[i-1]){
      return(Low[i]);
   }else{
      return(0);
   }
}

//+------------------------------------------------------------------+