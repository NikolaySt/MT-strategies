//+------------------------------------------------------------------+
//|                                                   Mastering Waves|
//|                                      create by   NIKOLAY STOYCHEV|
//|                                       email: n_stoichev@yahoo.com|
//|                                                 Copyright © 2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 /not for sale/"

#property stacksize   1024

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Lavender//Gainsboro//AntiqueWhite//Lavender
#property indicator_color2 Lavender//Gainsboro//AntiqueWhite//Lavender
#property indicator_color3 LightGray
#property indicator_color4 Blue
#property indicator_color5 BurlyWood
#property indicator_color6 Red
#property indicator_color7 Blue

#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 2
#property indicator_width7 1
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style7 STYLE_SOLID


#include <MonoWave\Utils\FullVersion.mqh>


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init(){
   //-----------------Вертикална мрежа----------------------
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,VerticalLine1);   
   SetIndexLabel(0, "----");

   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,VerticalLine2);    
   SetIndexLabel(1, "----");
   //------------------------------------------------------     
   
   SetIndexStyle(2,DRAW_SECTION, STYLE_DOT);   
   SetIndexBuffer(2,MonoAlternation);
   SetIndexLabel(2, "----");    
   
   if (!PrintView) {
      SetIndexStyle(3,DRAW_SECTION, STYLE_SOLID, 1);
   }else{
      SetIndexStyle(3,DRAW_SECTION, STYLE_SOLID, 3);
   }
   SetIndexBuffer(3,Wave); 
   SetIndexLabel(3, "LEVEL");  
   
   
   SetIndexStyle(4,DRAW_SECTION, STYLE_DOT);
   SetIndexBuffer(4,up_time_wave);
   SetIndexLabel(4, "----");  
   
   if (!PrintView) {
      SetIndexStyle(5,DRAW_ARROW, STYLE_SOLID, 2);   
      SetIndexArrow(5, 158); //117
   }else{
      SetIndexStyle(5,DRAW_ARROW, STYLE_SOLID, 5);   
      SetIndexArrow(5, 117); //117      
   }    
   SetIndexBuffer(5,Point_Wave);
   SetIndexLabel(5, "POINT");     
   

   SetIndexStyle(6, DRAW_ARROW);
   SetIndexArrow(6, 159);
   SetIndexBuffer(6, GroupPoints);
   SetIndexLabel(6, "----");
   
   DeleteObjects();
   
   if (HighTimeWaveView)
      SetInfo( PeriodCalc_Info() , PeriodCalcHighTime_Info() );
   else{
      if (ChartCompression){
         SetInfo( PeriodCalc_Info_Compress());
      }else{
         SetInfo( PeriodCalc_Info());
      }
   }      

   return(0);   
}

int deinit(){
   DeleteObjects();   
}

int start(){       
   //връща часовия интервал по който се изчисляват моновълните
   int period_calc = 0;
   if (!ChartCompression){
      period_calc = PeriodCalc();
   }else{
      period_calc = PeriodCalc_Compression();
   }
   if (period_calc == 0) return(0);      
   
   int period_calc_high_time = 0;         
   if (HighTimeWaveView) period_calc_high_time = PeriodCalcHighTime();     
   
   //задаване на часовото ниво на което да работи индикатора
   if (!WorkTime(DefaultTime)) return(0);
   
   //Пресмята дали е необходимо да се преизчисли
   int limit = CalcBarsIndicatorCounted();
   
   if (limit == 1 || limit == 0){
      return(0);
   }
   //-------------------------------------------   
   
   //Инициализира глобалните променливи
   InicializationGlobalVariables(); 
      
   //Прочета обектите от графиката които се ползват за обзоначение на различни действия
   GetObjectWork();
      
   //Създава точките през равни интервали от време за всеки времеви период-
   CreatChartPointToMonoWave(period_calc, period_calc_high_time); 
   
   
   if (!ChartCompression){
      //Поставя активноста за всяка моновълна или група
      AddActivityTypeInMonoWaves(period_calc);

      //Попълва масива с началото и края на всяка вълна според активността-----------    
      AddChartPointToWave();
 
      //Поставя номерация на вълните
      AddChronoNumber();      
      
      if (RulesView) { CheckRulesWave(wave_rules_begin_count);}      
   }
   return(0);
}

void InicializationGlobalVariables(){
   Grid_Upper_Level = High[1] * 10;      
   
   ArrayInitialize(Wave, EMPTY_VALUE);  
   ArrayInitialize(Point_Wave, EMPTY_VALUE);  
   ArrayInitialize(MonoAlternation, EMPTY_VALUE);
   
   ArrayInitialize(VerticalLine1, EMPTY_VALUE);
   ArrayInitialize(VerticalLine1, EMPTY_VALUE);
   ArrayInitialize(GroupPoints, EMPTY_VALUE);   
   
   ChartPoints_count = 0; 
   ArrayInitialize(array_ChartPoints, 0);
   
   wave_count_in_rule = 0;
   ArrayInitialize(MonoWave_Rule, 0);            
   
   view_number_wave_count = 0;   
   ArrayInitialize(WaveNumber, 0);   
      
   Init_WorkWithObjects();       
}




