bool BreakBeginingLevel(int direct1, int add_unit_time = 0){
//за колко време(плиюс add_unit_time) е пробито началното ниво на direct1
   double time_break = TimeBreakDirection(direct1);
   double time = TimeDirection(direct1);   
   if (time_break <= (time + add_unit_time) && time_break > 0){ 
      return(true);
   }else{
      return(false);
   }
}


double DirectionSumPriceLength(int direc_begin, int direc_end){
   double b = DirectionBeginPrice(direc_begin);
   double e = DirectionEndPrice(direc_end);
   return (MathAbs(b - e));
}

int DirectionSumTimeLength(int direc_begin, int direc_end){
   int time = 0;
   for (int i = direc_begin; i <= direc_end; i++){
      time = time + TimeDirection(i);
   }
   return (time);   
}


double ComparePriceDirectionFull(int direct_1, int direct_2){
//сравнява като винаги дели по-малкото на по-голямото
   double d1 = DirectionPriceLenght(direct_1);
   double d2 = DirectionPriceLenght(direct_2);
   if (d2 != 0 && d2 != 0){
      if (d1 > d2){
         return(d2/d1);
      }else{
         return(d1/d2);
      }
   }else{      
      return(-1);
   }
}

double CompareTimeDirectionFull(int direct_1, int direct_2){
//сравнява като винаги дели по-малкото на по-голямото
   double d1 = TimeDirection(direct_1);
   double d2 = TimeDirection(direct_2);     
   if (d2 != 0 && d2 != 0){
      if (d1 > d2){
         return(d2/d1);
      }else{
         return(d1/d2);
      }
   }else{      
      return(-1);
   }
}

double ComparePriceDirection(int direct_1, int direct_2){
//сравнява като винаги дели ПЪРВОТО на ВТОРОТО
   
   double d1 = DirectionPriceLenght(direct_1);
   double d2 = DirectionPriceLenght(direct_2);
   if (d2 != 0){
      return(d1/d2);
   }else{
      return(-1);
   }      
}

//-------------------------------------------------------
double ComparePrice(double direct_1, double direct_2){
//сравнява като винаги дели ПЪРВОТО на ВТОРОТО
   if (direct_2 != 0){
      return(direct_1/direct_2);
   }else{
      return(-1);
   }  

}
//Двете функции са еднакви разликата е в името за да може втората да се ползва за сравняване 
//на всякакви стойности

double CompareTime(double direct_1, double direct_2){
//сравнява като винаги дели ПЪРВОТО на ВТОРОТО
   if (direct_2 != 0){
      return(direct_1/direct_2);
   }else{
      return(-1);
   }  

}
//-------------------------------------------------------

double CompareTimeDirection(int direct_1, int direct_2, int Direct_1_Plus_Time = 0){
//сравнява като винаги дели ПЪРВОТО на ВТОРОТО
//към времето на direct_1 може да се прибави "Plus_Time" за случаите когато е плюс една единица време
   double d1 = TimeDirection(direct_1) + Direct_1_Plus_Time;
   double d2 = TimeDirection(direct_2);
   if (d2 != 0){
      return(d1/d2);
   }else{
      return(-1);
   }      
}

bool OverlapDirection(int direct_1, int direct_2){
   double d1 = Direction(direct_1);
   double d2 = Direction(direct_2);
   
   double  min, max;   
   
   if (d1 == -1 && d2 == -1){
      max = DirectionMaxLevel(direct_1);
      min = DirectionMinLevel(direct_2);
      
      if (max >= min) {return(true);}else {return(false);}
   }else{
      if (d1 == 1 && d2 == 1){   
         min = DirectionMinLevel(direct_1);
         max = DirectionMaxLevel(direct_2);             
         if (max >= min) {return(true);}else {return(false);}                
      }else{
         return(false);
      }
   }
}

bool NoSmallerDirection(int NotSmaller, int direct_1, int direct_2){
   double Not = DirectionPriceLenght(NotSmaller);
   double d1 = DirectionPriceLenght(direct_1);
   double d2 = DirectionPriceLenght(direct_2);   
   if ((Not > d1) || (Not > d2)){
      return(true);
   }else{
      return(false);
   }
}

int LargestDirection(int direct_1, int direct_2, int direct_3){
   double d1 = DirectionPriceLenght(direct_1);
   double d2 = DirectionPriceLenght(direct_2);
   double d3 = DirectionPriceLenght(direct_3); 

   double max = MathMax(MathMax(d1, d2), d3);
   if (max == d1) return(direct_1);
   if (max == d2) return(direct_2);
   if (max == d3) return(direct_3);
}
int SeccondLargestDirection(int direct_1, int direct_2, int direct_3){
   double d1 = DirectionPriceLenght(direct_1);
   double d2 = DirectionPriceLenght(direct_2);
   double d3 = DirectionPriceLenght(direct_3); 
   
   if (d1 > d2 && d1 < d3) return(direct_1);
   if (d2 > d1 && d2 < d3) return(direct_2);
   if (d3 > d1 && d3 < d2) return(direct_3);
}


bool CheckBreakLevelInTime(int direct_Level, double time, int direct_begin){
/*
отчита дали края на direct_Level е пробит за дадено време
*/
   double price_level = DirectionEndPrice(direct_Level);
   double direct = CheckDirection(direct_Level);

   double level; 
   
   int time_break = 1;
   bool check_break = false;
   bool large = false;
   
   int index = DirectionWaveInPointArray(direct_begin)-1;
   
   while (!check_break && !large && index > 0){
   
      level = GetPriceArrayChartPoints(index);
      
      
      if (direct == 1){
         if (level > price_level){
            check_break = true;   
         }
      }else{
         if (level < price_level){
            check_break = true;   
         }         
      }
      time_break++;
      if (time_break > time){
         large = true;   
      }
      
      index--;
   }
   
   if (check_break){
      return(true);
   }else{
      return(false);      
   }
}


bool CheckTimeGoToBeginning(int direct_Level, double time, int direct_begin){
/*
намира времето за което се пробива началното ниво на direct_Level
като времето трябва да е по малко от time.
Началото от където се отчита пробива е direct_begin
*/
   double price_level = DirectionBeginPrice(direct_Level);
   double direct = CheckDirection(direct_Level);

   double level; 
   
   int time_break = 0;
   bool check_find = false;
   bool large = false;
   
   int index = DirectionWaveInPointArray(direct_begin)-1;
   
   while (!check_find && !large && index > 0){
   
      level = GetPriceArrayChartPoints(index);
      
      time_break++;
      if (direct == 1){
         if (level < price_level){
            check_find = true;   
         }
      }else{
         if (level > price_level){
            check_find = true;   
         }         
      }
      if (time_break > time){
         large = true;   
      }
      index--;
   }
   
   if (check_find && !large){
      return(true);
   }else{
      return(false);      
   }
}

bool CheckGroupGoToLevel(int direct_Level, int direct_begin, int direct_end){
/*
намира групата вълни коиято пробива началното ниво на direct_Level
груата от на4алото на direct_begin до края на direct_end

*/
   double price_level = DirectionBeginPrice(direct_Level);
   double direct = Direction(direct_Level);
   
   double level; 
   
   bool check_find = false;
   
   int index_b = DirectionWaveInPointArray(direct_begin);
   int index_e = DirectionWaveInPointArray(direct_end);
   
   while (!check_find && index_b >= index_e){
   
      level = GetPriceArrayChartPoints(index_b);
      
      if (direct == 1){
         if (level < price_level){
            check_find = true;   
         }
      }else{
         if (level > price_level){
            check_find = true;   
         }         
      }

      index_b--;
   }
   
   if (check_find){
      return(true);
   }else{
      return(false);      
   }
}

bool CheckTimeGoToLength(int direct_length, double time, int direct_begin, double ratio = 1){
/*
намира времето за което дедена вълна (или група) достига дължина равна на direct_length*ratio
за зададеното време.
Началото от където се отчита измерването е direct_begin
*/
   double length = DirectionPriceLenght(direct_length)*ratio;       
   
   int time_break = 0;
   bool check_length = false;
   bool large = false;
   
   int index = DirectionWaveInPointArray(direct_begin);   
   double level_begin = GetPriceArrayChartPoints(index);
   double level_next, level = 0;
   index--;
   //Print("length=", length, " :: time=", time, " :: BeginLevel=",  level_begin);
   
   while (!check_length && !large && index > 0){
      
      level_next = GetPriceArrayChartPoints(index);
      level = MathAbs(level_begin - level_next);
      time_break++;
      
      //Print("level=", level, " :: level_next=", level_next);

      if (level >= length){
         check_length = true;   
      }

      if (time_break > time){
         large = true;   
      }
      
      index--;
      
   }
   
   //Print("time=", time_break);
   
   if (check_length && !large){
      return(true);
   }else{
      return(false);      
   }
}

bool BreakTL(int direct1, int direct2, double time, int direct_begin){
//Фунцията намира дали дадена ТЛ зададена по краищата на две вълни 
//direct1, direct2, се пробива за време по-малко от зададеното като пробива се отчита от 
//началото на края на вълна direct_begin
//!!!!!!!!!!!!!!!!
//Не е довършено 
//ne vinagi TL se 4ertae po krai6tata, poniakoga se polzvat Extremumite, особенно за втората точка direct2.

   int up_down_line = 0;
   if (CheckDirection(direct1) == -1 && CheckDirection(direct2) == -1){
      up_down_line = 1;
   }else{
      if (CheckDirection(direct1) == 1 && CheckDirection(direct2) == 1){ 
         up_down_line = -1;
      }else{
         return(false);
      }
   }
   

   double y1 = DirectionEndPrice(direct1);   
   double x1 = DirectionWaveInPointArray(direct1);           
  
   double y2 = DirectionEndPrice(direct2) - y1;         
   double x2 = x1 - DirectionWaveInPointArray(direct2);
   double a = y2/x2;   
   double x_p = x1 - DirectionWaveInPointArray(direct_begin);      
   
   int time_break = 1;
   int index = DirectionWaveInPointArray(direct_begin)-1;
   bool large = false;
   bool check_break = false;
   
   double y_p;
   double line_point;
   
   while (!check_break && !large && index > 0){
      

      y_p = GetPriceArrayChartPoints(index) - y1;       
      x_p = x_p +1;
      line_point = a*x_p;
      
      //Print("TL-point=", line_point + y1, " Y_point=",GetPriceArrayChartPoints(index)); 
                             
      if (up_down_line == 1){
         if (y_p < line_point){
         /*
            Print("TL Up");
            Print("y_p=", y_p);
            Print("line_point=", line_point);   
            Print("Level ", GetPriceArrayChartPoints(index));
            Print("time ", time_break);
            */
            check_break = true;   
         }
      }else{
         if (y_p > line_point){
            check_break = true;   
         }               
      }         
      
      if (time_break > time){
         large = true;   
      }      

      time_break++; 
      index--;
   }     
   if (check_break && !large){
      return(true);
   }else{
      return(false);      
   }
         
}

int CheckFirstBreakEndWaves(int direct1, int direct2, int direct_begin){
// Коя от двата края се пробива първи.
   double end_level_1 = DirectionEndPrice(direct1);
   double end_level_2 = DirectionEndPrice(direct2);

   
   int index = DirectionWaveInPointArray(direct_begin)-1;
   double level = 0;
   while (index > 0){
      level = GetPriceArrayChartPoints(index);
      if (end_level_1 < end_level_2){
         if (level > end_level_2) return(2);
         if (level < end_level_1) return(1);
      }else{
         if (level < end_level_2) return(2);
         if (level > end_level_1) return(1);         
      }
      index--;
   }
   return(0);
}

int CheckFirstBreakLevel(double level1, double level2, int direct_begin){
// Коя от двте нива се пробива първо
   double end_level_1 = level1;
   double end_level_2 = level2;
   
   int index = DirectionWaveInPointArray(direct_begin)-1;
   double level = 0;
   while (index > 0){
      level = GetPriceArrayChartPoints(index);
      if (end_level_1 < end_level_2){
         if (level > end_level_2) return(2);
         if (level < end_level_1) return(1);
      }else{
         if (level < end_level_2) return(2);
         if (level > end_level_1) return(1);         
      }      
      index--;
   }
   return(0);
}

bool BreakEndToFormationDirection(int direct1, int direct2){
//отчита дали е пробит края на дадена вълна при формирането на следващата
//края на direct1 дали е пробит от част от direct2
   if (CheckDirection(direct1) == 1){
//      Print(DirectionEndPrice(direct1), " : ", DirectionMaxLevel(direct2));
      
      if (DirectionEndPrice(direct1) <  DirectionMaxLevel(direct2)){
         return(true);
      }else{
         return(false);
      }
   }else{
      if (DirectionEndPrice(direct1) >  DirectionMinLevel(direct2)){
         return(true);
      }else{
         return(false);
      }   
   }
}

double Length_Group_4_6(){
   double b = DirectionBeginPrice(4);
   int index = DirectionIndexInMonoWaveRule(5);
   double e = ArrayWaveRule_Get_Price(index-1);
   return (MathAbs(b - e));   
}

double EndLevel_Direct_6(){
   int index = DirectionIndexInMonoWaveRule(5);
   double e = ArrayWaveRule_Get_Price(index-1);
   return (e);   
}

bool CheckDirect_2_Break_Direct_1(int direct1, int direct2){
//определя кое ниво е по ниско или по високо в зависимост от направлението на direct1
   double level1 = DirectionEndPrice(direct1);
   double level2;
   if (direct2 == 6){
      level2 = EndLevel_Direct_6();
   }else{
      level2 = DirectionEndPrice(direct1);
   }
   if (CheckDirection(direct1) == 1){
      if (level1 > level2) {
         return(true);
      }else{
         return(false);
      }
   }else{
      if (level1 < level2) {
         return(true);
      }else{
         return(false);
      }      
   }
}

bool Check_Direct2_Break_EndDirect_1(int direct1, int direct2){
//oпределя дали края на вълна direct1 се пробива от Direct2(Max/Min)
   double level1 = DirectionEndPrice(direct1);
   double level2 = 0;
   if (Direction(direct1) == -1){
      level2 = DirectionMinLevel(direct2);
      if (level2 > level1){
         return(false); // direct1 нивото не е пробито
      }else{
         return(true);
      }
   
   }else{
      level2 = DirectionMaxLevel(direct2);
      if (level2 < level1){
         return(false); // direct1 нивото не е пробито
      }else{
         return(true);
      }      
   }
   
}

bool CheckBreakBeginLevel(int direct1){
//Проверява дали по време на формирането на direct1 не се пробива нейното начално ниво
// true - пробив
// false - няма пробив
    double level1 = DirectionBeginPrice(direct1);
    
    if (Direction(direct1) == 1){ 
      double min = DirectionMinLevel(direct1);
      if (level1 > min){
         return(true); // пробив на началното ниво
      }else{
         return(false);
      }
    }else{
      double max = DirectionMaxLevel(direct1);
      if (level1 < max){
         return(true); //пробив на началното ниво
      }else{
         return(false);
      }      
    }
}

double CompareLengthWithCountWaves(int direct_length, int direct_check, int countwave){
//Изчилсява дължината на двете вълни и я сравянва 
//като втората вълна се измерва до броя зададени подвълни в направлението
   double length = DirectionPriceLenght(direct_length);
   
      
   int index = DirectionIndexInMonoWaveRule(direct_length)-countwave;
   
   double begin_price = DirectionBeginPrice(direct_check);   
   double length_check = MathAbs(begin_price - ArrayWaveRule_Get_Price(index));
   
   return(length_check/length);  
}

int MonoWaveShiftInDirection(int direct, int wave){
    int index_end = DirectionIndexInMonoWaveRule(direct);
    int index_begin = DirectionIndexInMonoWaveRule(direct-1);
    int i = index_begin-1;
    int wave_count = 1;
    bool exit = false;
    int shift;
    
    while (!exit && i >= index_end){
      if (wave_count == wave){
         exit = true;   
         shift = ArrayWaveRule_Get_Shift(i);
      }
      wave_count++;
      i--;  
   }
   
   if (exit){
      return(shift);
   }else{
      return(-1);
   }
}

//-----------------------------------------------------------------------------------------------

bool Equal_361(double ratio){
   return(ratio > (3.618-0.1) && ratio < (3.618+0.1));
}

bool Equal_261(double ratio){
   return(ratio > (2.618-0.1) && ratio < (2.618+0.1));
}

bool Equal_224(double ratio){
   return(ratio > (2.24-0.1) && ratio < (2.24+0.1));
}

bool Equal_161(double ratio){
   return(ratio > (1.618-0.1) && ratio < (1.618+0.1));
}

bool Equal_127(double ratio){
   return(ratio > (1.27-0.1) && ratio < (1.27+0.1));
}

bool Equal_100(double ratio){
   return(ratio > 0.9 && ratio < 1.1);
}

bool Equal_088(double ratio){
   return(ratio > (0.886-0.1) && ratio < (0.886+0.1));
}

bool Equal_078(double ratio){
   return(ratio > (0.786-0.1) && ratio < (0.786+0.1));
}

bool Equal_061(double ratio){
   return(ratio > (0.618-0.1) && ratio < (0.618+0.1));
}

bool Equal_050(double ratio){
   return(ratio > (0.50-0.1) && ratio < (0.50+0.1));
}

bool Equal_038(double ratio){
   return(ratio > (0.382-0.1) && ratio < (0.382+0.1));
}


//-----------------------------------------------------------------------------------------------
bool Large_261(double ratio){
   return(ratio > (2.618-0.1));
}

bool Large_161(double ratio){
   return(ratio > (1.618-0.1));
}

bool Large_130(double ratio){
   return(ratio > (1.30-0.1));
}

bool Large_100(double ratio, bool limit = false){
   if (limit){
      return(ratio > 1.0);
   }else{
      return(ratio > 0.9);
   }
}

bool Large_061(double ratio){
   return(ratio > (0.618-0.1));
}

bool Large_038(double ratio){
   return(ratio > (0.382-0.1));
}

bool Large_025(double ratio){
   return(ratio > (0.25-0.1));
}

//-----------------------------------------------------------------------------------------------
bool Small_261(double ratio){
   return(ratio < (2.618+0.1));
}

bool Small_161(double ratio){
   return(ratio < (1.618+0.1));
}

bool Small_138(double ratio){
   return(ratio < (1.382+0.1));
}

bool Small_130(double ratio){
   return(ratio < (1.300+0.1));
}

bool Small_100(double ratio, bool limit = false){
   if (limit){
      return(ratio < 1.0);
   }else{
      return(ratio < 1.1);
   }
}

bool Small_070(double ratio){
   return(ratio < (0.70+0.1));
}

bool Small_061(double ratio){
   return(ratio < (0.618+0.1));
}
bool Small_050(double ratio){
   return(ratio < (0.50+0.1));
}
//-----------------------------------------------------------------------------------------------
bool Almost_161(double ratio){
   return(ratio > (1.618-0.15));   
}
//-----------------------------------------------------------------------------------------------