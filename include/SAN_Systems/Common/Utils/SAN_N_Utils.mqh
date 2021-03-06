/*
Помощни функции

bool CloseOverHighest(int TimeFrame, int count, int bar_begin = 2);
bool CloseUnderLowest(int TimeFrame, int count, int bar_begin = 2);

bool CloseHiLo(int direction, int timeFrame, int count, int begin = 2);
bool CloseOverHighestEx(int TimeFrame, int count, int bar_begin = 2);
bool CloseUnderLowestEx(int TimeFrame, int count, int bar_begin = 2);

double SearchFractalInPeriod(int mode, int TimeFrame, int fr_bars, int count, datetime& timefr);
double PivotLevel(int trend, int TimeFrame, double ratio);

double UpFractalFloat(int bars_count, int TimeFrame,  int i);
double DownFractalFloat(int bars_count, int TimeFrame,  int i);

double SAN_NUtl_CalcLevelFrSL(int TradeType, int timeFrame,  int shift_begin, int shift_end);

//намира модата по метода на МаркетПрофил
double MP_MODA(int step, int timeframe, int count, int begin, bool view = false);
//void SetPoint(double level, datetime time, int point_color = Red, int point_width = 1);
//void SetLine(double y1, double y2, datetime x1, datetime x2, int line_color = Red, int line_width = 1);
//void SetText(double y, datetime x, string text, int text_color = Red);

double (int type, int TimeFrame, int distance_points, int shift, int FrBars, bool view_up, bool view_down  );
double TL_LevelTwoPoint(int type, int TimeFrame, int distance_points, int shift, int FrBars, bool view_up, bool view_down, int& Direction[] );   
*/

#define TD_UP  1
#define TD_DOWN  -1
#define TD_NONE  0

/*
Помощни функции
*/

double TrendLineLevelTwoPoint(int type, int TimeFrame, int distance_points, int shift, int FrBars, bool view_up, bool view_down){               
   int Direction[1];
   Direction[0] = 0;
   int dir = 0;
   return(TL_LevelTwoPoint(type, TimeFrame, distance_points, shift, FrBars, view_up, view_down, Direction));
}

double TL_LevelTwoPoint(int type, int TimeFrame, int distance_points, int shift, int FrBars, bool view_up, bool view_down, int& Direction[] ){               
   
   double level = 0;   
   int shift_up1= 0, 
       shift_up2= 0, 
       
       shift_down1 = 0,        
       shift_down2= 0, 
       
       shift_ch_up= 0, //не се ползват
       shift_ch_down =0; //не се ползват
   InternalFindTriplePoint(TimeFrame, distance_points, shift_up1, shift_up2, shift_ch_up, shift_down1, shift_down2, shift_ch_down, FrBars);
   
   if (shift_up1 > 0 && shift_up2 > 0 && type == 1/*UPPER*/){
      level = InternalLineFunction(shift_up1, shift_up2, 
               iHigh(NULL, TimeFrame, shift_up1),
               iHigh(NULL, TimeFrame, shift_up2),
               shift);    
      
      if (iHigh(NULL, TimeFrame, shift_up1) >= iHigh(NULL, TimeFrame, shift_up2)){
         Direction[0] = -1;
      }else{
         Direction[0] = 1;
      }    
      if (view_up){            
         InternalDrawLine(TimeFrame, 
               shift_up1, shift, 
               iHigh(NULL, TimeFrame, shift_up1), level, 
               "Line_tr_up_" + iTime(NULL, TimeFrame, shift_up2), 
               DoubleToStr(level, 4) + ", ("+Direction[0]+")", Lime, 1);                                        
      }               
               
   }
   if (shift_down1 > 0 && shift_down2 > 0 && type == -1/*LOWER*/){
      level = InternalLineFunction(shift_down1, shift_down2, 
               iLow(NULL, TimeFrame, shift_down1),
               iLow(NULL, TimeFrame, shift_down2),
               shift);                                                     
      if (iLow(NULL, TimeFrame, shift_up1) >= iLow(NULL, TimeFrame, shift_up2)){
         Direction[0] = -1;
      }else{
         Direction[0] = 1;
      }      
      if (view_down){
         InternalDrawLine(TimeFrame,                
               shift_down1, shift, 
               iLow(NULL, TimeFrame, shift_down1), level, 
               "Line_tr_down_" + iTime(NULL, TimeFrame, shift_down2), 
               DoubleToStr(level, 4) + ", ("+Direction[0]+")", Red, 1);                       
      }               
   
      
   }       
   return(level);
   
}

double InternalLineFunction(int x1, int x2, double y1, double y2, int x3){
   //по две точки (х1, у1) и (х2, у2) намира трета точка у3() по зададена х3
   double a = (y2 - y1)/(x2 - x1);
   double b = y1 - a*x1;   
   return(a*x3 + b);   
}

void InternalFindTriplePoint(int TimeFrame, int distance_bar, int& shift_up1, int& shift_up2, int& shift_ch_up, int& shift_down1, int& shift_down2, int& shift_ch_down, int FrBars = 3){
   shift_up1 = -1;
   shift_up2 = -1;
   shift_ch_up = -1; 
   shift_down1 = -1;
   shift_down2 = -1;   
   shift_ch_down = -1;
   double fr;
   bool find_down = false;
   bool find_up = false;
   for (int i = 2; i < 50; i++ ){
      
      fr = 0;
      if (FrBars == 3){
         if (iHigh(NULL, TimeFrame, i) > iHigh(NULL, TimeFrame, i-1) && iHigh(NULL, TimeFrame, i) >= iHigh(NULL, TimeFrame, i+1))
         {
            fr = iHigh(NULL, TimeFrame, i);
         }
      }else{
         fr = iFractals(NULL, TimeFrame, MODE_UPPER, i);
      }         

      if (fr > 0 && shift_up2 == -1){
         //записва горната втора която
         shift_up2 = i;
      }else{
         if (fr > 0 && shift_up1 == -1 && shift_up2 != -1 && i - shift_up2 >= distance_bar) {
            //записва горната първа точка точка
            shift_up1 = i;
            find_up = true;
         }else{
            //търси срещуположна точка
            //---------------------------------------------------------------------------------------
            if (!find_up && shift_up2 != -1){
               fr = 0;
               if (FrBars == 3){
                  if (iLow(NULL, TimeFrame, i) < iLow(NULL, TimeFrame, i-1) && 
                       iLow(NULL, TimeFrame, i) <= iLow(NULL, TimeFrame, i+1))
                  {
                     fr = iLow(NULL, TimeFrame, i);
                  }
               }else{
                  fr = iFractals(NULL, TimeFrame, MODE_LOWER, i);
               }                  
               
               if (fr > 0){
                  if (shift_ch_up == -1 ){
                     shift_ch_up = i;   
                  }else{
                     if (iLow(NULL, TimeFrame, i)  < iLow(NULL, TimeFrame, shift_ch_up))  shift_ch_up = i;  
                  }
               }   
            }
            //---------------------------------------------------------------------------------------                 
         }
      }            
      
      fr = 0;
      if (FrBars == 3){
         if (iLow(NULL, TimeFrame, i) < iLow(NULL, TimeFrame, i-1) && 
              iLow(NULL, TimeFrame, i) <= iLow(NULL, TimeFrame, i+1))
         {
            fr = iLow(NULL, TimeFrame, i);
         }
      }else{
         fr = iFractals(NULL, TimeFrame, MODE_LOWER, i);
      }  
            
      if (fr > 0 && shift_down2 == -1){
         shift_down2 = i;
      }else{
         if (fr > 0 && shift_down1 == -1  && shift_down2 != -1 && i - shift_down2 >= distance_bar ) {
            shift_down1 = i;
            find_down = true;
         }else{
            if (!find_down && shift_down2 != -1){
               fr = 0;
               if (FrBars == 3){
                  if (iHigh(NULL, TimeFrame, i) > iHigh(NULL, TimeFrame, i-1) && iHigh(NULL, TimeFrame, i) >= iHigh(NULL, TimeFrame, i+1))
                  {
                     fr = iHigh(NULL, TimeFrame, i);
                  }
               }else{
                  fr = iFractals(NULL, TimeFrame, MODE_UPPER, i);
               }                 
               if (fr > 0){
                  if (shift_ch_down == -1 ){
                     shift_ch_down = i;   
                  }else{
                     if (iHigh(NULL, TimeFrame, i)  > iHigh(NULL, TimeFrame, shift_ch_down))  shift_ch_down = i;  
                  }
               }  
            }        
         }          
      }      
      if (find_up && find_down) break;
   }  
}



void InternalDrawLine(int TimeFrame, int x1, int x2, double y1, double y2, string name, string text, color linecolor, int width = 5){
   
   if(ObjectFind(name) < 0) ObjectCreate(name, OBJ_TREND, 0, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, iTime(NULL, TimeFrame, x1));
   ObjectSet(name, OBJPROP_TIME2, iTime(NULL, TimeFrame, x2));
   ObjectSet(name, OBJPROP_PRICE1, y1);
   ObjectSet(name, OBJPROP_PRICE2, y2);   
      
   ObjectSet(name, OBJPROP_RAY, false);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, width); 
   //ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);


   ObjectSetText(name, "       " + text, 12, "Arial", Blue);             
}

bool DrawLine(string name, string text, int shift1, int shift2, 
   double price1, double price2, color linecolor, int width, int style = STYLE_SOLID, bool ray = false){
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_TREND, 0, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, Time[shift1]); 
   ObjectSet(name, OBJPROP_TIME2, Time[shift2]);
   ObjectSet(name, OBJPROP_PRICE1, price1); 
   ObjectSet(name, OBJPROP_PRICE2, price2);         
   ObjectSet(name, OBJPROP_RAY, ray);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, width); 
   ObjectSet(name, OBJPROP_STYLE, style);

   ObjectSetText(name, text, 12, "Arial", Blue);       
      
   return(0);   
}


bool CloseOverHighest(int period, int count, int bar_begin = 2){
   double offset = 0;
   
   int shift = iBarShift(NULL, period, Time[0])+1;         
   //sravniava ot 3-ti bar нататък ako bar_begin = 2
   int index = iHighest(NULL, period, MODE_HIGH, count, shift+bar_begin);
   double HH = iHigh(NULL, period, index);
   
   double c = iClose(NULL, period, shift);
   double o = iOpen(NULL, period, shift);
   double h = iHigh(NULL, period, shift);
   double l = iLow(NULL, period, shift);   
          
   return(
         c > HH && // цената на затваряне да е над N-брой бара
         (c > o && c > (h - l)*(2/3) + l)     // затворелия бар да е над 2/3 от дъното си.
      );
}

bool CloseUnderLowest(int period, int count, int bar_begin = 2){
   double offset = 0;
   
   int shift = iBarShift(NULL, period, Time[0])+1;   
   //sravniava ot 3-ti bar нататък ako bar_begin = 2
   int index = iLowest(NULL, period, MODE_LOW, count, shift+bar_begin);
   double LL = iLow(NULL, period, index);
   
   double c = iClose(NULL, period, shift);
   double o = iOpen(NULL, period, shift);
   double h = iHigh(NULL, period, shift);
   double l = iLow(NULL, period, shift);   
      
   return(
         c < LL && // цената на затваряне да е под N-брой бара
         (c < o && c < h - (h - l)*(2/3))     // затворелия бар да е под 2/3 от върха си.
      );
}

bool CloseHiLo(int direction, int timeFrame, int count, int begin = 2, int shift = 1){  
   double c = iClose(NULL, timeFrame, shift);
   double o = iOpen(NULL, timeFrame, shift);
   double h = iHigh(NULL, timeFrame, shift);
   double l = iLow(NULL, timeFrame, shift);  
     
   double extr = 0;
   int index = 0;
   
   if (direction == 1){
      //sravniava ot 3-ti bar нататък ako bar_begin = 2
      index = iHighest(NULL, timeFrame, MODE_HIGH, count, shift + begin);
      extr = iHigh(NULL, timeFrame, index);       
      return(
            c >= extr && // цената на затваряне да е над N-брой бара
            (c > o && c > (h - l)*(2/3) + l)     // затворелия бар да е над 2/3 от дъното си.
         );
   }
   if (direction == -1){   
      //sravniava ot 3-ti bar нататък ako bar_begin = 2
      index = iLowest(NULL, timeFrame, MODE_LOW, count, shift + begin);
      extr = iLow(NULL, timeFrame, index);
      return(
            c <= extr && // цената на затваряне да е под N-брой бара
            (c < o && c < h - (h - l)*(2/3))     // затворелия бар да е под 2/3 от върха си.
         );   
   }  
}

bool CloseOverHighestEx(int period, int count, int bar_begin = 2){
     
   int shift = iBarShift(NULL, period, Time[0])+1;         
   //sravniava ot 3-ti bar нататък ako bar_begin = 2
   int index = iHighest(NULL, period, MODE_HIGH, count, shift+bar_begin);
   double HH = iHigh(NULL, period, index);
   
   double c = iClose(NULL, period, shift);
   double o = iOpen(NULL, period, shift);
   double h = iHigh(NULL, period, shift);
   double l = iLow(NULL, period, shift);   
          
   return(
         c >= HH && // цената на затваряне да е над N-брой бара
         (c > o && c > (h - l)*(2/3) + l)     // затворелия бар да е над 2/3 от дъното си.
      );
}


bool CloseUnderLowestEx(int period, int count, int bar_begin = 2){
   
   
   int shift = iBarShift(NULL, period, Time[0])+1;   
   //sravniava ot 3-ti bar нататък ako bar_begin = 2
   int index = iLowest(NULL, period, MODE_LOW, count, shift+bar_begin);
   double LL = iLow(NULL, period, index);
   
   double c = iClose(NULL, period, shift);
   double o = iOpen(NULL, period, shift);
   double h = iHigh(NULL, period, shift);
   double l = iLow(NULL, period, shift);   
      
   return(
         c <= LL && // цената на затваряне да е под N-брой бара
         (c < o && c < h - (h - l)*(2/3))     // затворелия бар да е под 2/3 от върха си.
      );
}

double SearchFractalInPeriod(int mode, int period, int fr_bars, int count, datetime& timefr){
   int shift = MathRound(fr_bars / 2) + 1;
   double fr = 0;   
   int i;   
   timefr = 0;
   for(i = shift; i <= shift + count; i++)
   {
      if (mode == TD_UP) fr = UpFractalFloat(fr_bars, period, i);                    
      if (mode == TD_DOWN) fr = DownFractalFloat(fr_bars, period, i);  
      if (mode == MODE_UPPER) fr = UpFractalFloat(fr_bars, period, i);                    
      if (mode == MODE_LOWER) fr = DownFractalFloat(fr_bars, period, i);                             
      if (fr != 0) {
         timefr = iTime(NULL, period, i);
         return(fr);                     
      }             
   }  
   
   return(0);
}

double PivotLevel(int mode, int period, double ratio){
   int shift = iBarShift(NULL, period, Time[0])+1;  
   double C = iClose(NULL, period, shift);
   double O = iOpen(NULL, period, shift);
   double H = iHigh(NULL, period, shift);
   double L = iLow(NULL, period, shift);   
   
   double C2 = iLow(NULL, period, shift+1); 
      
   if (mode == TD_UP) return((H - L)*ratio + L);
   if (mode == TD_DOWN) return(H - (H - L)*ratio);
   if (mode == MODE_UPPER) return((H - L)*ratio + L);
   if (mode == MODE_LOWER) return(H - (H - L)*ratio);
}

double UpFractalFloat(int bars_count, int period,  int i){ 
   int day = TimeDayOfWeek(iTime(NULL, period, i));
   if (!(day >= 1 && day <= 5)) return(0);

   int left_offset = 0;
   int right_offset = 0;
   
   for(int n = 1; n <= MathRound(bars_count / 2); n++){
      day = TimeDayOfWeek(iTime(NULL, period, i+n));
      if (!(day >= 1 && day <= 5)) left_offset = 1;      
      day = TimeDayOfWeek(iTime(NULL, period, i-n));
      if (!(day >= 1 && day <= 5)) right_offset = 1; 

      if (!(NormalizeDouble(iHigh(NULL, period, i),4) >= NormalizeDouble(iHigh(NULL, period, i+n+left_offset), 4) )){
         return(0);         
      }
      if (!(NormalizeDouble(iHigh(NULL, period, i),4) >= NormalizeDouble(iHigh(NULL, period, i-n-right_offset), 4) )){
         return(0);       
      }            
   }
   return(NormalizeDouble(iHigh(NULL, period, i), 4)); 
}


double DownFractalFloat(int bars_count, int period,  int i){   
   int day = TimeDayOfWeek(iTime(NULL, period, i));
   if (!(day >= 1 && day <= 5)) return(0);

   int left_offset = 0;
   int right_offset = 0;

   for(int n = 1; n <= MathRound(bars_count / 2); n++){         
      if (!(NormalizeDouble(iLow(NULL, period, i), 4) <= NormalizeDouble(iLow(NULL, period, i+n+left_offset), 4) )){
         return(0);              
      }
      if (!(NormalizeDouble(iLow(NULL, period, i), 4) <= NormalizeDouble(iLow(NULL, period, i-n-right_offset), 4) )){
         return(0);              
      }      
   }   
   return(NormalizeDouble(iLow(NULL, period, i), 4)); 
}



void SetPoint(double level, datetime time, int point_color = Red, int point_width = 1){
      string name = "fr_" + level + "_" + time;
      ObjectCreate(name, OBJ_ARROW, NULL,  time, level);
      ObjectSet(name, OBJPROP_ARROWCODE, 159);
      ObjectSet(name, OBJPROP_COLOR, point_color);
      ObjectSet(name, OBJPROP_WIDTH, point_width);  
 
}

void SetLine(double y1, double y2, datetime x1, datetime x2, int line_color = Red, int line_width = 1){
      string name = "corr_" + y1 + "_" + x1 + "_" + x2;
      ObjectCreate(name, OBJ_TREND, NULL, x1, y1, x2, y2);
      ObjectSet(name, OBJPROP_COLOR, line_color);
      ObjectSet(name, OBJPROP_WIDTH, line_width);  
      ObjectSet(name, OBJPROP_RAY, false);  
 
}

void SetText(double y, datetime x, string text, int text_color = Red){
      string name = "text_" + y + "_" + x;
      
      ObjectCreate(name, OBJ_TEXT, NULL, 0, 0);
      ObjectSet(name, OBJPROP_TIME1, x);
      ObjectSet(name, OBJPROP_PRICE1, y);
      ObjectSetText(name, text, 10, "Times New Roman", text_color);  
}

double SAN_NUtl_CalcLevelFrSL(int TradeType, int timeFrame,  int shift_begin, int shift_end){     
   int trend = TradeType;
   int shift_begin_wave = -1;
   int n = 0;
   double fr = 0;
   double save_fr_up = 0;
   double save_fr_down = 99999999;

   double master_wave_down = 99999999;
   int master_wave_down_shift = 0;
   double master_wave_up = 0;
   int master_wave_up_shift = 0;
   
   bool check_new = false;
   bool find_correction = false;
   
   for(int i = shift_begin; i >= shift_end; i--){
      
      
      //Обръщане на тренда при пробив на дъно или връх 
      if (trend == -1){ 
         if (save_fr_up != 0 && iClose(NULL, timeFrame, i) > save_fr_up){
            trend = 1;     
            check_new = true;  
            save_fr_down = master_wave_down;   
            
            master_wave_down = 99999999;
            master_wave_down_shift = 0;    
                          
         }
      }else{
         if (trend == 1){
            if (save_fr_down != 99999999 && iClose(NULL, timeFrame, i) < save_fr_down){
               trend = -1;  
               check_new = true;      
               save_fr_up = master_wave_up;   
               
               master_wave_up = 0;
               master_wave_up_shift = 0;                           
            }
         }      
      }
      
      //Пордължение по тренда с формиране на ново ниво от корекцията
      if (trend == -1){
         if (iClose(NULL, timeFrame, i) < master_wave_down){
            find_correction = true;
         }
         fr = iFractals(NULL, timeFrame, MODE_LOWER, i+1);
         if (fr != 0){
            if (fr < master_wave_down){
               master_wave_down = fr;
               master_wave_down_shift = i;
               //save_fr_up = 0;
               check_new = true;
            }            
         }
      }
      
      if (trend == 1){
         if (iClose(NULL, timeFrame, i) > master_wave_up){
            find_correction = true;
         }      
         fr = iFractals(NULL, timeFrame, MODE_UPPER, i+1);
         if (fr != 0){
            if (fr > master_wave_up){
               master_wave_up = fr;
               master_wave_up_shift = i;
               //save_fr_down = 9999999999;  
               check_new = true;
            }            
         }
      }   

      //-------------------------Открива дъното на корективната вълна-------------------------
      if (find_correction){
         fr = 0;
         if (trend == 1) shift_begin_wave = master_wave_up_shift;
         if (trend == -1) shift_begin_wave = master_wave_down_shift;
      
         if (shift_begin_wave != 0){
            for (n = i; n <= shift_begin_wave; n++) {
            
               if (trend== -1){
               
                  fr = iFractals(NULL, timeFrame, MODE_UPPER, n+1);
               
                  if (fr != 0){    
                     if (check_new) {
                        save_fr_up = fr;
                        check_new = false;
                     }
                     if (fr > save_fr_up){                     
                        save_fr_up = fr;
                     }
                  }
               }
         
               if (trend== 1){
                  fr = iFractals(NULL, timeFrame, MODE_LOWER, n+1);
                  if (fr != 0){
                     if (check_new) {
                        save_fr_down = fr;
                        check_new = false;
                     }               
                     if (fr < save_fr_down){
                        save_fr_down = fr;
                     }
                  }
               }         
            }
         }   
         find_correction = false;
      }         
      //---------------------------------------------------------------
      
      if (trend == -1){
         if (save_fr_up != 99999999 && save_fr_up != 0){         
            return(save_fr_up);
         }                      
      }         
      if (trend == 1){
         if (save_fr_down != 99999999 && save_fr_down != 0){         
            return(save_fr_down);
         }
         
      }               
          
   }

   return(0);
}
//------------------------------------------------------------------+

double MP_MODA(int step, int timeframe, int count, int begin, bool view = false){
   
   if (count <= 0 ) return(0);
   
   double HH, LL;      
   int moda = 0 , index_moda = 0; 
   double low, high; int index;

   HH = iHigh(NULL, timeframe, iHighest(NULL, timeframe, MODE_HIGH, count, begin));
   LL = iLow(NULL, timeframe, iLowest(NULL, timeframe, MODE_LOW, count, begin));
   
   int NumberOfPoints = (HH - LL) / (1.0*Point*step) + 1;
   int mp_array[];
   ArrayResize(mp_array, NumberOfPoints);
   ArrayInitialize(mp_array, 0);      

   for(int i = begin; i <= begin + count; i++){
      low = iLow(NULL, timeframe, i);
      high = iHigh(NULL, timeframe, i);
      
      while(low < high){         
         index = (low - LL) / (1.0*Point*step);
         mp_array[index]++;    
         low = low + 1.0*Point*step;
         if (mp_array[index] > moda){
            index_moda = index;
            moda = mp_array[index]; 
         }         
      }
   }   
   
   if (view){   
      string OBJECT_PREFIX = "MP_LEVELS";
      ObjDeleteObjectsByPrefix(OBJECT_PREFIX);
      double StartX, StartY, EndX, EndY;   
      StartX = Time[5];
      string ObjName;
      for(i = 0; i < NumberOfPoints; i++){           
         StartY = LL + 1.0*Point*step*i;
         EndX   = Time[5+mp_array[i]];
         EndY   = StartY;

         ObjName = ObjGetUniqueName(OBJECT_PREFIX);
         ObjectDelete(ObjName);
         ObjectCreate(ObjName, OBJ_TREND, 0, StartX, StartY, EndX, EndY);
         ObjectSet(ObjName, OBJPROP_RAY, 0);
         ObjectSet(ObjName, OBJPROP_COLOR, White);
      }      
   
      ObjName = ObjGetUniqueName(OBJECT_PREFIX);
      ObjectDelete(ObjName);
      ObjectCreate(ObjName, OBJ_TREND, 0, Time[5], LL + 1.0*Point*step*index_moda, Time[5+mp_array[index_moda]], LL + 1.0*Point*step*index_moda);
      ObjectSet(ObjName, OBJPROP_RAY, 0);
      ObjectSet(ObjName, OBJPROP_COLOR, Red);
      ObjectSet(ObjName, OBJPROP_WIDTH, 4);  
   } 
   
   return(LL + 1.0*Point*step*index_moda);
}
int ObjectId = 0;
string ObjGetUniqueName(string Prefix){
   ObjectId++;
   return (Prefix + " "+ ObjectId);
}
void ObjDeleteObjectsByPrefix(string Prefix){ 
   int L = StringLen(Prefix);
   int i = 0; 
   string ObjName;
   while(i < ObjectsTotal()){   
      ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix){ 
         i++; 
         continue;
      }
      ObjectDelete(ObjName);
   }   
}

