
//+1 time, +2 price, +3 bias
//-1 time, -2 price, -3 bias
/*степенуване по важност когато съвпадат на едно ниво няколко елемента
1.Time
2.Bias
3.Price
*/
int small_loc; 
int large_loc; 
double ratio_level;
datetime ratio_time;


//записва текущите нива на Small
double small_time_level;
double small_bias_level;
double small_price_level;
double GetSmall_Time_Level(){ return(small_time_level); }
double GetSmall_Bias_Level(){ return(small_bias_level); }
double GetSmall_Price_Level(){ return(small_price_level); }

double GetSmallLOC_Level(){
   switch (MathAbs(GetLOC_Large())){
      case 1: return(GetSmall_Time_Level());
      case 2: return(GetSmall_Price_Level());
      case 3: return(GetSmall_Bias_Level());   
      default: return(0);
   }
}

int GetLOC_Small(){return(small_loc);}
int GetLOC_Large(){return(large_loc);}

#define RATIO_TIME  0.35
#define RATIO_PRICE 0.68
#define RATIO_BIAS  0.50

double GetRatio(int LOC){
   switch (MathAbs(LOC)){
      case 1: return(RATIO_TIME);
      case 2: return(RATIO_PRICE);
      case 3: return(RATIO_BIAS);

      default: return(0);
   }
}
double GetLargeLOC_Level(){
   switch (MathAbs(GetLOC_Large())){
      case 1: return(GetTime_Level());
      case 2: return(GetPrice_Level());
      case 3: return(GetBias_Level());   
      default: return(0);
   }
}
datetime GetLargeLOC_Shift(){
   switch (MathAbs(GetLOC_Large())){
      case 1: return(GetTime_LevelTime());
      case 2: return(GetPrice_LevelTime());
      case 3: return(GetBias_LevelTime());   
      default: return(0);
   }
}

int GetLOC_Current(){
   if (GetTimeFrame() == Period()) return(GetLOC_Small());
   if (GetTimeFrame() > Period()) return(GetLOC_Large());
}
void SetRatio_Level(double value, datetime time){ ratio_level = value; ratio_time = time;}
double GetRatio_Level(){ return(ratio_level);}
datetime GetRatio_Time(){ return(ratio_time);}

void RT_Process_Logic(int index){
   if (GetTimeFrame() == Period()) RT_LOC_Process(index, small_loc);
   if (GetTimeFrame() > Period()) RT_LOC_Process(index, large_loc);
}

void RT_LOC_Process(int index, int& LOC){  
   double bl = GetBias_Level(); 
   double tl = GetTime_Level();
   double pl = GetPrice_Level();
   bool t_neutral = GetTime_Neutral();     
   
   int b_d = GetBias_Direction();
   int t_d = GetTime_Direction();
   int p_d = GetPrice_Direction();

   if (t_d == 1 && b_d == 1 && p_d == 1){
      if (pl < tl){
          if (pl < bl) LOC = 2; else LOC = 3;
       }else{         
          if (tl <= bl) LOC = 1; else LOC = 3;   
       }       
   }else{
       if (t_d == 1 || b_d == 1 || p_d == 1){
            if (LOC > 0){
               if (t_d != 0){
                  if (pl < tl){
                     if (pl < bl) LOC = 2; else LOC = 3;
                  }else{
                     if (tl <= bl) LOC = 1; else LOC = 3;   
                  }                       
               }else{
                  if (pl < bl) LOC = 2; else LOC = 3;
               }                  
            }else{
               if (t_d != 0){
                  if (pl > tl){
                     if (pl > bl) LOC = -2; else LOC = -3;
                  }else{
                     if (tl >= bl) LOC = -1; else LOC = -3;   
                  }     
               }else{
                  if (b_d == 1 && p_d == 1){
                     if (pl < bl) LOC = 2; else LOC = 3;   
                  }else{
                     if (pl > bl) LOC = -2; else LOC = -3;
                  }                  
               }
            }
       }else{
         if (t_d != 0){
            if (pl > tl){
               if (pl > bl) LOC = -2; else LOC = -3;
            }else{
               if (tl >= bl) LOC = -1; else LOC = -3;   
            }               
         }else{
            if (LOC > 0){
               if (pl > bl) LOC = -2; else LOC = -3;
            }else{
               if (pl < bl) LOC = 2; else LOC = 3;  
            }
         }
      }   
   }      
   
   if (Period() != GetTimeFrame()) {
      double extremum = 0;
      switch (LOC){
         case 1: extremum = SearchMaxLevel(GetTime_LevelTime(), GetTimeFrame()); break;
         case 2: extremum = SearchMaxLevel(GetPrice_LevelTime(), GetTimeFrame());break;
         case 3: extremum = SearchMaxLevel(GetBias_LevelTime(), GetTimeFrame()); break;  
         case -1: extremum = SearchMinLevel(GetTime_LevelTime(), GetTimeFrame());break;
         case -2: extremum = SearchMinLevel(GetPrice_LevelTime(), GetTimeFrame());break;
         case -3: extremum = SearchMinLevel(GetBias_LevelTime(), GetTimeFrame()); break;
      }   
      switch (LOC){
         case 1: SetRatio_Level( tl + (extremum -tl)*GetRatio(LOC), GetTime_LevelTime()); break;
         case 2: SetRatio_Level( pl + (extremum -pl)*GetRatio(LOC), GetPrice_LevelTime() );break;
         case 3: SetRatio_Level( bl + (extremum -bl)*GetRatio(LOC), GetBias_LevelTime() );break;
         case -1: SetRatio_Level( tl - (tl - extremum)*GetRatio(LOC), GetTime_LevelTime() );break;
         case -2: SetRatio_Level( pl - (pl - extremum)*GetRatio(LOC), GetPrice_LevelTime() );break;
         case -3: SetRatio_Level( bl - (bl - extremum)*GetRatio(LOC), GetBias_LevelTime() );break;
      }   
   }
}   


double SearchMaxLevel(datetime time, int timeframe){   
   int index = iHighest(NULL, timeframe, MODE_HIGH, iBarShift(NULL, timeframe, time), 0);
   return(iHigh(NULL, timeframe, index));
}

double SearchMinLevel(datetime time, int timeframe){   
   int index = iLowest(NULL, timeframe, MODE_LOW, iBarShift(NULL, timeframe, time), 0);  
   return(iLow(NULL, timeframe, index));
}

void RTSmall_SaveLevels(){
   small_time_level = GetTime_Level();
   small_bias_level = GetBias_Level();
   small_price_level = GetPrice_Level();
}

void CreateSmallSignal(){
   bool exit = false;
   bool entry = false;
   if (MathAbs(GetLOC_Small()) > 1){
      //когато пазара се контролира от - "price", или "bias"
      if (GetLOC_Small() > 0 && GetChannelMark() < 0) exit = true; //exit
      if (GetLOC_Small() < 0 && GetChannelMark() > 0) exit = true; //exit    

      if (GetLOC_Small() > 0 && GetChannelMark() > 0) entry = true; //ENTRY
      if (GetLOC_Small() < 0 && GetChannelMark() < 0) entry = true; //ENTRY         
   }else{
      //Когато пазара се контролира от времето
      if (GetLOC_Small() > 0 && GetChannelMark() > 0) exit = true; //exit
      if (GetLOC_Small() < 0 && GetChannelMark() < 0) exit = true; //exit
      
      if (GetLOC_Small() > 0 && GetChannelMark() < 0) entry = true; //ENTRY
      if (GetLOC_Small() < 0 && GetChannelMark() > 0) entry = true; //ENTRY      
   }
   string name = "text_signal_small";
   if (exit || entry){
      string text;
      if (exit) text = "EXIT.MODE";
      if (entry) text = "ENTRY.MODE";
      switch(MathAbs(GetLOC_Small())){
         //time
         case 1: text = text + " / " + "VOLATILE"; break;
         //price
         case 2: text = text + " / " + "Organized TREND"; break;
         //bias
         case 3: if (GetLOC_Small() > 0) text = text + " / " + "ACCUMULATION"; else text = text + " / " + "DISTRIBUTION"; break;
      }                      
      
      ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name, OBJPROP_XDISTANCE, 5);
      ObjectSet(name, OBJPROP_YDISTANCE, 30);
      ObjectSetText(name, text, 10, "Arial", White);      
   }else{
      ObjectSetText(name, "", 10, "Arial", White);           
   }   

}


