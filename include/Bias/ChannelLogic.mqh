
#define ChannelRatioIn   0.25
#define ChannelRatioOut  0.125

int channel_mark = 0;
//записва знака на канала дали е положителене 
//или отрицателен зависимост кой е пърбия връх
void SetChannelMark(int value ){channel_mark = value;}
int GetChannelMark(){ return(channel_mark);}

int channel_direction = 0;
//записва дали канала е насочен нагоре или надолу
//ползва се да определим дали сме в ривър или лаке
//когато LOC e "+" и канала е насочен надолу (-1) сме в Lake
//когато LOC e "+" и канала е насочен nagore (1) сме в Rivar
int GetChannel_Direction(){ return(channel_direction);}
void SetChannel_Direction(int value){ channel_direction = value;}

double channel_level;
double channel_range;
double projection_Level;

void SetChannel_Level(double value){ channel_level = value;}
double GetChannel_Level(){ return(channel_level);}

void SetProjection_Level(double value){ projection_Level = value;}
double GetProjection_Level(){ return(projection_Level);}

void SetChannel_Range(double value){ channel_range = value;}
double GetChannel_Range(){ return(channel_range);}


void Channel_Process(bool DrawLines = true){   
   SetChannel_Level(0); //инициализира променливите
   SetProjection_Level(0); //инициализира променливите
   SetChannelMark(0);
   SetChannel_Range(0);
            
   int index, type_peak;
   double value, count; 
   datetime time;
      
   int i = MLLastFormPeakIndex();
   bool ch_find = false;
   
   int first_peak = 0;
   datetime t1 = 0, t2 = 0;   
   double v1, v2;      
   
   while (i >= 0 && !ch_find){
      MLGetPeak(i, value, time, type_peak, count);
      if (t1 == 0 ){
         //записва първия намерен връх/дъно
         first_peak = type_peak;
         t1 = time;
         v1 = value;                      
      }else{     
         if (t2 == 0){            
            if (first_peak == type_peak){
               //записва втрои намерен връх/дъно (същия тип като пръвия)
               t2 = time;
               v2 = value;                  
            }   
         }
      }
      if (t1 != 0 && t2 != 0){
         ch_find = true;
      }                  
      i--;
   }   
   
   if (ch_find){ 
      int x1, x2, x3;
      if (first_peak == -1){
         x2 = GetLLShiftFrame(t2, GetTimeFrame());
         x1 = GetLLShiftFrame(t1, GetTimeFrame());
         if (Low[x1] > Low[x2])
            SetChannel_Direction(1);
         else
            SetChannel_Direction(-1);         
      }
      if (first_peak == 1){
         x2 = GetHHShiftFrame(t2, GetTimeFrame());
         x1 = GetHHShiftFrame(t1, GetTimeFrame());
         if (High[x1] > High[x2])
            SetChannel_Direction(1);
         else
            SetChannel_Direction(-1);
      }      
      if (x1 == x2) {
         //ако са равни значи нямаме ТЛ
         return;
      }
      double trend_line =  InternalLineFunction(x1, x2, v1, v2, 0);
      SetChannel_Level(trend_line);
            
      double high; double low; int type_ml; 
      double range = 0, curr_range = 0;
      //-----------------------------------------------------------------------------
      
      //между двата намерини върха търси точка от графиката която е най-външнна (най далечна от линията)      
      i = 0;      
      while (Time[i] >= Time[x2]){         
         if (Time[i] <= Time[x1]){   
            if (first_peak == 1) value = Low[i];
            if (first_peak == -1) value = High[i];
            curr_range = MathAbs(value - InternalLineFunction(x1, x2, v1, v2, i));           
            range = MathMax(range, curr_range); 
         }          
         i++;            
      }    
      if (range <= 0) {
         //не е намерене точка за прокецията
         return;
      }       
      SetChannel_Range(range); //- записва ра големината на калана без знак;
      //-----------------------------------------------------------------------------
      //first_peak == 1 тренд линията е отгоре, проекцията е отдолу
      //first_peak == -1 тренд линията е отдолу, , проекцията е отгоре
      SetChannelMark(first_peak*(-1));
      

      //в зависимост от това дали първо сме намерили връх или дъно определяме какъв ще е диапазона като знак    
      range = range*first_peak*(-1);                       
      
      //на какво разстояние е цената от линията на канала      
      bool ch_out_price = false;
      double price_div;

      SetProjection_Level(trend_line + range);      
      
      if (!DrawLines) return;
      
      if (first_peak == 1) price_div = Close[0] - trend_line + range*ChannelRatioOut;
      if (first_peak == -1) price_div = trend_line - range*ChannelRatioOut - Close[0];      
      if (price_div > 0){
         DrawLine("line" +"_ch_pro_double_" + GetTimeFrame(), "",  x2, x1, v2 + range*(-1), v1 + range*(-1), Red, 1, STYLE_DASH, true);                                
         ch_out_price = true;
      }
            
      //на какво разстояние е цената от линията на проекцията      
      if (first_peak == 1) price_div = (trend_line + range*(1+ChannelRatioOut)) - Close[0];
      if (first_peak == -1) price_div = Close[0] - (trend_line + range*(1+ChannelRatioOut));
      if (price_div > 0){
         DrawLine("line" +"_ch_pro_double_" + GetTimeFrame(), "",  x2, x1, v2 + range*2, v1 + range*2, Red, 1, STYLE_DASH, true);                                
         ch_out_price = true;
      }      
      
      
      //изчертава линиите//      
      //тренд линия---------------------------------------------------
      DrawLine("line" +"_ch_" + GetTimeFrame(), "", x2, x1, v2, v1, White, 2, STYLE_SOLID, true);      
         //диапазони
      if (!ch_out_price){
         DrawLine("line" +"_ch_out_" + GetTimeFrame(), "", x2, x1, v2 - range*ChannelRatioOut, v1 - range*ChannelRatioOut, Silver, 1, STYLE_DOT, true); 
         DrawLine("line" +"_ch_int_" + GetTimeFrame(), "", x2, x1, v2 + range*ChannelRatioIn, v1 + range*ChannelRatioIn, Silver, 1, STYLE_DOT, true); 
      }
      //--------------------------------------------------------------
      
             
      //линия на проекция-----------------------------------------------
      DrawLine("line" +"_ch_pro_" + GetTimeFrame(), "",  x2, x1, v2 + range, v1 + range, White, 1, STYLE_DASH, true);                    
         //диапазони
      if (!ch_out_price){         
         DrawLine("line" +"_ch_pro_out_" + GetTimeFrame(), "", x2, x1, v2 + range*(1+ChannelRatioOut), v1 + range*(1+ChannelRatioOut), Silver, 1, STYLE_DOT, true);                                        
         DrawLine("line" +"_ch_pro_in_" + GetTimeFrame(), "", x2, x1, v2 + range*(1-ChannelRatioIn), v1 + range*(1-ChannelRatioIn), Silver, 1, STYLE_DOT, true);                                  
      }         
      //-----------------------------------------------------                  
   }
}

double InternalLineFunction(int x1, int x2, double y1, double y2, int x3){
   //по две точки (х1, у1) и (х2, у2) намира трета точка у3() по зададена х3
   double a = (y2 - y1)/(x2 - x1);
   double b = y1 - a*x1;   
   return(a*x3 + b);   
}