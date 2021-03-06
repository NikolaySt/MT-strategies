//+------------------------------------------------------------------+
//|   Пресмята цената
//+------------------------------------------------------------------+
//Параметри записващи текущото състояние на цената
double price_level;
datetime price_level_shift;
int price_level_direction = 1; // -1 тренд надолу, +1 тренд нагоре

void InitPriceParams(){
   price_level_direction = 1;
   price_level = 0;
}

int GetPrice_Direction(){return(price_level_direction);}     
void SetPrice_Direction(int value){price_level_direction = value;}

double GetPrice_Level(){ return(price_level);}
datetime GetPrice_LevelTime(){ return(price_level_shift);}
void SetPrice_Level(double value, datetime time){ price_level = value; price_level_shift = time;}

void Price_LevelPeak(){         
   double value, high, low; datetime time; double count;
   if (GetPrice_Direction() == -1){         
      if (MLGetLastFormPeakType(1, value, time, count)){  /*търси последен връх от устойчиво формираните*/                       
          SetPrice_Level(value, time);                                     
      }                                     
   }
   if (GetPrice_Direction() == 1){   
      if (MLGetLastFormPeakType(-1 , value, time, count)){ /*търси последно дъно от устойчиво формираните*/
            SetPrice_Level(value, time);                  
      }              
   }          
}

void Price_CheckBreak(){
   double high, low, value;
   datetime time; int direction;
   
   if (MLGetLastBar(high, low, time, direction)){
      if (direction == 1) value = high;
      if (direction == -1) value = low;
   
      int shift = GetShift(time, GetTimeFrame());
      //test
      value = GetClose(shift, GetTimeFrame());
      //------------------

      //Когато цената е ПОЛОЖИТЕЛНА прави проверка дали имаме пробито Ценово ниво      
      if (GetPrice_Direction() == 1){       
         if (value < GetPrice_Level()){ //пробив
            SetPriceToBuff(shift, GetPrice_Level()); //записва нивото на пробива
            
            SetPrice_Direction(-1); 
            Price_LevelPeak();
            //смяна на направлението            
         }
      }  
   
      //Когато цената е ОТРИЦАТЕЛНА прави проверка дали имаме пробито Ценово ниво
      if (GetPrice_Direction() == -1){      
         if (value > GetPrice_Level()){//пробив    
            SetPriceToBuff(shift, GetPrice_Level()); //записва нивото на пробива
            
            SetPrice_Direction(1); 
            Price_LevelPeak();  
            //смяна на направлението            
         }
      }  
   }          
}


 



