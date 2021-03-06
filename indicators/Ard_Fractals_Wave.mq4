//+------------------------------------------------------------------+
//|                                            Ard_Fractals_Wave.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 10.01.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 10.01.2009"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color4 Red;
#property indicator_width4 3;
//---- buffers
double wave[];
double Buffer_Fraktals_up[];
double Buffer_Fraktals_down[];
double FractalsLine[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicators

   
   SetIndexBuffer(0, Buffer_Fraktals_up); 
   SetIndexDrawBegin(0, 5);   
   ArrayInitialize(Buffer_Fraktals_up, 0);
   ArrayInitialize(Buffer_Fraktals_down, 0);
   
   SetIndexBuffer(1, Buffer_Fraktals_down); 
   SetIndexDrawBegin(1, 5);   
   
   SetIndexBuffer(2, FractalsLine);    
   
   SetIndexStyle(0,DRAW_ARROW, STYLE_SOLID, 0, Black);      
   SetIndexArrow(0, 217);            
   SetIndexStyle(1,DRAW_ARROW, STYLE_SOLID, 0, Black);      
   SetIndexArrow(1, 218);     
      
   SetIndexStyle(2, DRAW_SECTION, STYLE_SOLID, 1, LightSlateGray);        
   
   
   SetIndexStyle(3,DRAW_SECTION, STYLE_SOLID);
   SetIndexBuffer(3,wave);
   SetIndexEmptyValue(3,0.0);   
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
double up_fractal, down_fractal;   
bool ch_first = true;
int check_wave_up_down = 0;
double save_begin, save_end, high_extremum, low_extremum;
bool check_final_wave = false;
int save_end_shift, save_begin_shift;
int ch_find_across_fractal = false;

double save_correction;
int save_correction_shift;
   
int start()
  {
   int limit = 1000;
   double value;
  
   int i = limit; 
   while (i >= 0){ //; ){
      i--;   
      CalculationFractals(i);
            
      if (ch_first){
         if (!(Buffer_Fraktals_up[i] > 0 && Buffer_Fraktals_down[i] > 0)){
            //започва от тaм където на един бар има само един фрактал
            if (Buffer_Fraktals_up[i] > 0) FirstInitParamWave(i, 2);                    
            if (Buffer_Fraktals_down[i] > 0) FirstInitParamWave(i, 1);                                     
         }            
      }else{
      
         //-----------------------------------------------------
         if (check_wave_up_down == 2 && !check_final_wave){
            //търсим края на вълната за надолу
            FindEndWave(i, 2); 
            if (i==157) trace("FindEndWave", i, "i", i, "down", check_wave_up_down, "final", check_final_wave);                                           
         }

         if (check_wave_up_down == 1 && !check_final_wave){
            //търсим края на вълната за нагоре
            FindEndWave(i, 1);
            //trace("FindEndWave", i, "up", check_wave_up_down);
         }
         //-----------------------------------------------------
               
         if (check_final_wave && check_wave_up_down == 2){
            //търсим пробив на екстремумит на спадащата вълна за да е отчетем
            //като е завърила или да започнем с нова вълна               
            if (Close[i] > high_extremum){
               //започва нова вълна за нагоре защото е пробито началот на вълната
               //констроираме завършилата вълна                                   
               BreakWave_BeginNewWave(i, 2);
               FindEndWave(i, 1); 
            }else{
               if (Low[i] < low_extremum ){
                   //започва нова вълна за надолу защото е пробита края вълната
                  //констроираме завършилата вълна ВАЖНО! тук имаме гънка на пазара     
                  BeginNewWave(i, 2); 
                  FindEndWave(i, 2);                                   
               }else{
                  //Записваме връщането на вълната //коригираща фаза
                  Check_Up_Fraktal_Corection(i);                      
               } 
            }               
         }

         if (check_final_wave && check_wave_up_down == 1){            
            if (Close[i] < low_extremum){
               BreakWave_BeginNewWave(i, 1);  
               FindEndWave(i, 2);
               //i++;
            }else{           
               if (High[i] > high_extremum ){
                  BeginNewWave(i, 1);
                  FindEndWave(i, 1);                                 
               }else{
                  Check_Down_Fraktal_Corection(i);                                     
               } 
            }               
         }                                 
      }                                             
   }
   return(0);
}
void FirstInitParamWave(int &i, int up_down){
   double fr;
   int shift = i;
      
   if (up_down == 1){
      ////започва вълна за нагоре
      
      //тръсим най ниския фрактал в спадащата вълна преди фрактал за нагоре
         fr = Buffer_Fraktals_down[i];               
         while (Buffer_Fraktals_up[i] == 0 && i > 0){ 
         
            if (Buffer_Fraktals_down[i] > 0){               
               if (Buffer_Fraktals_down[i] < fr){
                  fr = Buffer_Fraktals_down[i];    
                  shift = i;
               }
            }
            i--; CalculationFractals(i);
         } 
      i = shift;     
      save_begin = Buffer_Fraktals_down[i];
      low_extremum = Buffer_Fraktals_down[i];
   }else{
      ////започва вълна за надолу в началото
      
      fr = Buffer_Fraktals_up[i];
      //тръсим най високия фрактал преди обратния
      while (Buffer_Fraktals_down[i] == 0 && i > 0){                                             
         if (Buffer_Fraktals_up[i] > 0){
            
            if (Buffer_Fraktals_up[i] > fr){
               fr = Buffer_Fraktals_up[i];    
               shift = i;               
            }
         }
         i--; 
         CalculationFractals(i);                        
      }  
      i = shift; 
      save_begin = Buffer_Fraktals_up[i];   
      high_extremum = Buffer_Fraktals_up[i];      
          
   }                  
   //общи параметри
   check_wave_up_down = up_down;
   save_begin_shift = i;
   ch_first = false;   
}   

void FindEndWave(int &i, int up_down){
   double fr;
   int shift = i;
   //int save_shift_accros_fractal;   
   
   //if (ch_find_across_fractal){
      //i++;
      //save_shift_accros_fractal = i;
   //}
   
   //започната е вълна за НАГОРЕ търсим края
   if (Buffer_Fraktals_up[i] > 0 && up_down == 1){

       fr = Buffer_Fraktals_up[i];
       //i--;
      //тръсим най високия фрактал в покачващата вълна преди фрактал за надолу
      while (Buffer_Fraktals_down[i] == 0 && i > 0){                                             
         if (Buffer_Fraktals_up[i] > 0){
            
            if (Buffer_Fraktals_up[i] > fr){
               fr = Buffer_Fraktals_up[i];    
               shift = i;               
            }
         }
         i--; 
         CalculationFractals(i);                        
      }
      //if (save_shift_accros_fractal == shift){
      //   shift--;          
      //}  
      i = shift;    
      InitEndWave(shift, up_down); 
      //Правим проверка дали на един и същи бар няма срещуположни фракали 
      //if (Buffer_Fraktals_down[shift] > 0){         
       //  ch_find_across_fractal = true;         
      //}else{
         //ch_find_across_fractal = false;
      //}      
   } 
    
   
   
   //започната е вълна за надолу търсим края
   if (Buffer_Fraktals_down[i] > 0 && up_down == 2){
   //тръсим най ниския фрактал в спадащата вълна преди фрактал за нагоре
      fr = Buffer_Fraktals_down[i];     
      //i--;          
      while (Buffer_Fraktals_up[i] == 0 && i > 0){ 
         
         if (Buffer_Fraktals_down[i] > 0){            
            if (Buffer_Fraktals_down[i] < fr){
               fr = Buffer_Fraktals_down[i];    
               shift = i;
            }
         }
         i--; CalculationFractals(i);
      }            
      i = shift;
      InitEndWave(shift, up_down); 
      //Правим проверка дали на един и същи бар няма срещуположни фракали 
      //if (Buffer_Fraktals_up[shift] > 0){         
      //   ch_find_across_fractal = true;       
      //}else{
        // ch_find_across_fractal = false;
      //}
      
   }        
   
}

void InitEndWave(int i, int up_down){

   if (up_down == 1){
      //намерена е крайна точка на покачващата вълна
      save_end = Buffer_Fraktals_up[i];                                  
      high_extremum = Buffer_Fraktals_up[i];   
      save_correction = 9999999;
   }else{
      //намерена е крайна точка на спадащата вълна
      save_end = Buffer_Fraktals_down[i];   
      low_extremum = Buffer_Fraktals_down[i];   
      save_correction = 0;
   }      
   //общи параметри
   save_end_shift = i;         
   check_final_wave = true;              
   save_correction_shift = 0;
}

void BreakWave_BeginNewWave(int i, int break_up_down){        
   if (break_up_down == 1){
      //започва нова вълна за надолу защото е пробито началот на вълната
      //констроираме завършилата вълна                
   
      //записваме началните параметри на новата за НАДОЛУ вълна

      high_extremum = save_end;   
      check_wave_up_down = 2;
      save_correction = 0;

   }else{
      //започва нова вълна за нагоре защото е пробито началот на вълната
      //констроираме завършилата вълна                       
      //записваме началните параметри на новата за НАГОРЕ вълна
      low_extremum = save_end;      
      check_wave_up_down = 1;
      save_correction = 99999999;                            
   }
   

   
   wave[save_begin_shift] = save_begin;
   if (ch_find_across_fractal){
      //save_end_shift = save_end_shift  1;  
      ch_find_across_fractal = false;
   }
   
   wave[save_end_shift] = save_end;       
   save_begin = save_end;
   save_begin_shift = save_end_shift;
   check_final_wave = false;
   save_correction_shift = 0;    
   
   //Правим проверка дали на един и същи бар няма срещуположни фракали 
   if (Buffer_Fraktals_up[i] > 0 && Buffer_Fraktals_down[i] > 0){         
      ch_find_across_fractal = true;
   }else{
      ch_find_across_fractal = false;   
   }    
      
}

void BeginNewWave(int i, int up_down){   
   
   if (up_down == 1){      
      //започва нова вълна за NAGORE защото е пробита края вълната
      //констроираме завършилата вълна ВАЖНО! тук имаме гънка на пазара          
      
      //Записваме връщането на вълната //коригираща фаза                                        
      if (Check_Down_Fraktal_Corection(i)){
         if (Buffer_Fraktals_up[i] > 0){
            // ако на един бар съвпадат два фрактала
            save_correction_shift = save_correction_shift + 1; 
         }
      }         
      low_extremum = save_correction;      
      check_wave_up_down = 1;
   }else{      
      //започва нова вълна за надолу защото е пробита края вълната
      //констроираме завършилата вълна ВАЖНО! тук имаме гънка на пазара     
   
      //Записваме връщането на вълната //коригираща фаза         
      if (Check_Up_Fraktal_Corection(i)) {
         if (Buffer_Fraktals_down[i] > 0){
         // ако на един бар съвпадат два фрактала
            save_correction_shift = save_correction_shift + 1; 
         }            
      }         
      high_extremum = save_correction;   
      check_wave_up_down = 2;             
   }
   
   wave[save_begin_shift] = save_begin;
   wave[save_end_shift] = save_end; 
   //записваме и гънката на пазара // КОРЕКЦИЯТА
   wave[save_correction_shift] = save_correction; 

   save_begin = save_correction;
   save_begin_shift = save_correction_shift;     
   
   save_correction_shift = 0;   
   check_final_wave = false;  
   
    if (up_down == 1){
      save_correction = 999999; 
      //ПРАВИМ ПРОВЕРКА дали текущия бар не е образувал фрактал   
      //if (Buffer_Fraktals_up[i] > 0) InitEndWave(i, 1); 
    }else{
      save_correction = 0;       
      //if (Buffer_Fraktals_down[i] > 0) InitEndWave(i, 2);
    }            
}
       

bool Check_Down_Fraktal_Corection(int i){
   //Записваме връщането на вълната //коригираща фаза
   if (Buffer_Fraktals_down[i] > 0){
      if (Buffer_Fraktals_down[i] < save_correction){                            
         save_correction = Buffer_Fraktals_down[i];
         save_correction_shift = i;
         return(true);
      }
   }
   return(false);
}

bool Check_Up_Fraktal_Corection(int i){
   //Записваме връщането на вълната //коригираща фаза
   if (Buffer_Fraktals_up[i] > 0){
      if (Buffer_Fraktals_up[i] > save_correction){                                     
         save_correction = Buffer_Fraktals_up[i];
         save_correction_shift = i;
         return(true);
      }
   }
   return(false);
}

void CalculationFractals(int i){
   //Фрактали по 3 бара
   Buffer_Fraktals_up[i] = UpFractal(i);
   Buffer_Fraktals_down[i] = DownFractal(i);

   if (Buffer_Fraktals_up[i] > 0){FractalsLine[i] = Buffer_Fraktals_up[i];}
   if (Buffer_Fraktals_down[i] > 0){FractalsLine[i] = Buffer_Fraktals_down[i]; }  
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

void trace(
   string name, 
   int index,
   string nparam1 = "", double vparam1 = 0,
   string nparam2 = "", double vparam2 = 0,
   string nparam3 = "", double vparam3 = 0,
   string nparam4 = "", double vparam4 = 0,
   string nparam5 = "", double vparam5 = 0,
   string nparam6 = "", double vparam6 = 0 ){

   Print(name," - ", TimeToStr(Time[index]),", ",
      nparam1, " = ", vparam1, ", ",
      nparam2, " = ", vparam2, ", ",
      nparam3, " = ", vparam3, ", ",
      nparam4, " = ", vparam4, ", ",
      nparam5, " = ", vparam5, ", ",
      nparam6, " = ", vparam6);
}


//+------------------------------------------------------------------+