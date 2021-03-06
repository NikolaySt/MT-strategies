string BIAS_LINE_NAME = "line_a1";
string PRICE_LINE_NAME = "line_a2";
string TIME_LINE_NAME = "line_a3";                                        
string RATIO_LINE_NAME = "line_a4";

void DrawObj_Process(){   

   double level_price = GetPrice_Level();
   double level_bias  = GetBias_Level();
   double level_time  = GetTime_Level();
         
   string t, p, b;
   string offset;
   if (GetTimeFrame() > Period()){      
      offset =  "                                           ";         
      t = "T"; b = "B"; p = "P";       
   }else{
      offset = "               ";           
      t = "t"; b = "b"; p = "p";
   }           
         
   if (level_price == level_bias) {      
      if (level_price == level_time){
         SetTextEx("text_a1_" + GetTimeFrame(), offset+t+" "+b+" "+p+" " + DoubleToStr(level_price, Digits), 0, level_price, MediumOrchid);          
      }else{
         SetTextEx("text_a1_" + GetTimeFrame(), offset+b+" "+p+" " +DoubleToStr(level_price, Digits), 0, level_price, MediumOrchid);       
         SetTextEx("text_a2_" + GetTimeFrame(), offset+t+" " + DoubleToStr(level_time, Digits), 0, level_time, Brown);          
      }
   }else{            
      if (level_bias == level_time) {
         SetTextEx("text_a1_" + GetTimeFrame(), offset+t+" "+b+" " + DoubleToStr(level_bias, Digits), 0, level_bias, DodgerBlue);                
         SetTextEx("text_a2_" + GetTimeFrame(), offset+p+" " + DoubleToStr(level_price, Digits), 0, level_price, MediumOrchid);                
      }else{
         if (level_price == level_time){
            SetTextEx("text_a1_" + GetTimeFrame(), offset+t+" "+p+" " + DoubleToStr(level_bias, Digits), 0, level_time, Brown);                
            SetTextEx("text_a2_" + GetTimeFrame(), offset+b+" " + DoubleToStr(level_bias, Digits), 0, level_bias, DodgerBlue);                
         }else{         
            SetTextEx("text_a1_" + GetTimeFrame(), offset+b+" " + DoubleToStr(level_bias, Digits), 0, level_bias, DodgerBlue);                
            SetTextEx("text_a2_" + GetTimeFrame(), offset+p+" " + DoubleToStr(level_price, Digits), 0, level_price, MediumOrchid);                
            SetTextEx("text_a3_" + GetTimeFrame(), offset+t+" " + DoubleToStr(level_time, Digits), 0, level_time, Brown);                      
         }
      }
   }      
   
   if (ViewPrice) Draw_PriceLine(); 
   if (ViewBias)  Draw_BiasLine();
   if (ViewTime)  Draw_TimeLine();  
   Draw_RatioLevel();
   Draw_SmallLOC();
   Draw_LargeLOC();
   
   if (Period() != GetTimeFrame()) Draw_RatioLevel();
}

int GetLevelLineStyle(){ if (GetTimeFrame() > Period()) return(STYLE_DASH); else return(STYLE_DOT);}

int GetShift_ByDirection(datetime time, int direction){
   if (direction == -1) return(GetHHShiftFrame(time, GetTimeFrame()));
   if (direction == 1) return(GetLLShiftFrame(time, GetTimeFrame()));     
}


void Draw_TimeLine(){   
   datetime time;
   double value;
   GetTime_LevelParams(time, value);
   int shift = GetShift_ByDirection(time, GetTime_Direction());
   if (shift == 0) shift = 1;
   int line_width = 1;
   if (GetLOC_Current() == -1 || GetLOC_Current() == 1) { line_width = 3; if (GetTimeFrame() > Period()) line_width = 6;}
   DrawLine(TIME_LINE_NAME + "_" + GetTimeFrame(), "",  shift, 0, value, value, Brown, line_width, GetLevelLineStyle(), true);                
}

void Draw_PriceLine(){
   double value = GetPrice_Level();   
   int shift = GetShift_ByDirection(GetPrice_LevelTime(), GetPrice_Direction());    
   if (shift == 0) shift = 1;
   int line_width = 1;
   if (GetLOC_Current() == -2 || GetLOC_Current() == 2) { line_width = 3; if (GetTimeFrame() > Period()) line_width = 6;}
   DrawLine(PRICE_LINE_NAME + "_" + GetTimeFrame(), "",  shift, 0, value, value, MediumOrchid, line_width, GetLevelLineStyle() , true);                
}


void Draw_BiasLine(){
   double value = GetBias_Level();
   double high, low;  datetime time;  int direction;
   MLGetBar(GetBias_Index(), high, low, time, direction);   
   int shift = GetShift_ByDirection(time, GetBias_Direction()); 
   if (shift == 0) shift = 1;
   int line_width = 1;
   if (GetLOC_Current() == -3 || GetLOC_Current() == 3) { line_width = 3; if (GetTimeFrame() > Period()) line_width = 6;}
   DrawLine(BIAS_LINE_NAME + "_" + GetTimeFrame(), "",  shift, 0, value, value, DodgerBlue, line_width, GetLevelLineStyle(), true);             
}

void Draw_RatioLevel(){
   double value = GetRatio_Level();
   int shift =  iBarShift(NULL, Period(), GetRatio_Time());
   DrawLine(RATIO_LINE_NAME, "",  shift, 0, value, value, Yellow, 1, STYLE_DASH, true);                
}


void Draw_MotionLine(){
   double low, high;
   double low1, high1;
   double price, price1;
   datetime time, time1;
   int direction, direction1;
   
   
   double count;   
   string text;   
   double offset; 
   int shift;
   
   for (int i = 1; i <= MLLastBarIndex(); i++){    
   
      MLGetBar(i, high1, low1, time1, direction1);
      MLGetBar(i-1, high, low, time, direction);

      if ( direction == 1) price = high;   
      if ( direction == -1) price = low;   
      if ( direction1 == 1) price1 = high1;   
      if ( direction1 == -1) price1 = low1;         
      
      DrawLine("line_ml_"+time1+"_"+direction1, "", 
               GetShift(time, Period()), GetShift(time1,  Period()),
               price, price1, Gray, 2, STYLE_SOLID);       
               
      //SetTextEx("text_ml_"+time1+"_" +direction1, MLBarForming(i), GetShift(time1, Period()), price1+(direction1*15*Point), Lime);               
   } 
}

void Draw_Peaks(){
   double value, value1;
   double price;
   datetime time, time1;
   int direction, direction1;
   double count;
   
   int shift;
   string text;
   
   for (int i = 1; i <= MLLastPeakIndex(); i++){          
      
      MLGetPeak(i-1, value, time, direction, count);
      MLGetPeak(i, value1, time1, direction1, count);

      DrawLine("line_peak_"+time1+"_" +direction1, "", 
               GetShift(time, Period()), GetShift(time1, Period()),
               value, value1, White, 1, STYLE_SOLID);
               
      //SetTextEx("text_peak_"+time1+"_" +direction1, MLGetFormingPeak(i), GetShift(time1, Period()), value1+(direction1*15*Point), Lime);
   } 
}

void Draw_SmallLOC(){
   string text;
   int lbl_color;
   if (GetLOC_Small() > 0){
      lbl_color = Lime;
   }else{
      lbl_color = Red;   
   }
   
      if (GetLOC_Small() == 1 || GetLOC_Small() == -1) text = "time";
      if (GetLOC_Small() == 2 || GetLOC_Small() == -2) text = "price";
      if (GetLOC_Small() == 3 || GetLOC_Small() == -3) text = "bias";
          
      
         
   string name = "text_loc_small";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, 5);
   ObjectSet(name, OBJPROP_YDISTANCE, 15);
   ObjectSetText(name, "small LOC = " + text, 10, "Arial", lbl_color);
}

void Draw_LargeLOC(){
   string text;
   int lbl_color;
   if (GetLOC_Large() > 0){
      lbl_color = Lime;
   }else{
      lbl_color = Red;   
   }
   
   if (GetLOC_Large() == 1 || GetLOC_Large() == -1) text = "TIME";
   if (GetLOC_Large() == 2 || GetLOC_Large() == -2) text = "PRICE";
   if (GetLOC_Large() == 3 || GetLOC_Large() == -3) text = "BIAS";                
         
   string name = "text_loc_large";
   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, 5);
   ObjectSet(name, OBJPROP_YDISTANCE, 55);
   ObjectSetText(name, "LARGE LOC = " + text, 10, "Arial", lbl_color);
}