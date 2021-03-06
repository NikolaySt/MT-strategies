//+------------------------------------------------------------------+
//|   Пресмята и изчертава смяната на цената
//+------------------------------------------------------------------+

string BASE_NAME_LEVEL = "pricelevel";  //Име на хоризонаталната линия която 
                                        //маркира нивото на цената където настъпва смяна

//Параметри записващи текущото състояние на цената
double price_level;
int price_level_shift_begin;
int price_level_direction = 1; // -1 тренд надолу, +1 тренд нагоре


double current_price_level;
int current_price_level_shift_begin;

int save_shift = 0;
double save_motion_line = 0;
bool change_direction = false;

int Save_Shift_begin = 0;

void InitPriceParametars(){
   price_level_direction = 1;
   save_shift = 0;
   save_motion_line = 0;
   change_direction = false;   
}

int GetPriceDirection(){
   return(price_level_direction);
}   
   


void SaveExtremumPrice(int shift, double motion_line, int direction){
   
   if (direction == 1){
      if (price_level_direction == -1){   
         price_level = motion_line;
         price_level_shift_begin = shift;               
      }
   }
   if (direction == -1){
      if (price_level_direction == 1){   
         price_level = motion_line;
         price_level_shift_begin = shift;               
      }
   } 
    
   current_price_level = motion_line;
   current_price_level_shift_begin = shift;                 
}

void CheckPriceLevel(int shift, double motion_line){

   CheckUpBreak(shift, motion_line);    
   CheckDownBreak(shift, motion_line);    
  
   save_motion_line = motion_line;
   save_shift = shift;    
   
   //BuffPriceLine[shift] = price_level_direction*3;
   
  
   
   if (shift == 0)
      CheckPriceLevel_EndBar();        
}

//Когато цената е ПОЛОЖИТЕЛНА прави проверка дали имаме пробито Ценово ниво
void CheckUpBreak(int shift, double motion_line){   
   
   if (price_level_direction == 1 ){
      if (price_level > motion_line){
         price_level_direction = -1;                     
                 
         DrawLine( BASE_NAME_LEVEL + "_" + price_level_shift_begin, "",  price_level_shift_begin, shift, price_level, price_level, MediumOrchid, 1, STYLE_DOT);          
   
         BuffUpPrice[shift] = EMPTY_VALUE;                      
         BuffDownPrice[shift] = motion_line;
                
         BuffDownPrice[save_shift] = save_motion_line;         
         ExtrapolationLine(BuffDownPrice, save_motion_line, save_shift, motion_line, shift);        
         
         change_direction = true;
                  
         price_level = current_price_level;
         price_level_shift_begin = current_price_level_shift_begin;   
         
         //ползва се само в изчертаването на правоъгълниците
         Save_Shift_begin = shift;
      }else{
      
         BuffUpPrice[shift] = motion_line;  
         if (change_direction) {
            change_direction = false;            
           // ExtrapolationLine(BuffDownPrice, save_motion_line, save_shift, motion_line, shift);
         }else{
            BuffDownPrice[shift] = EMPTY_VALUE;
         }               
         
         
         ExtrapolationLine(BuffUpPrice, save_motion_line, save_shift, motion_line, shift);      
      }
   }
}   

//Когато цената е ОТРИЦАТЕЛНА прави проверка дали имаме пробито Ценово ниво
void CheckDownBreak(int shift, double motion_line){ 
   if (price_level_direction == -1){
      if (price_level < motion_line){
         price_level_direction = 1;                     
         
         DrawLine( BASE_NAME_LEVEL + "_" + price_level_shift_begin, "",  price_level_shift_begin, shift, price_level, price_level, MediumOrchid, 1, STYLE_DOT);          
         
         BuffUpPrice[shift] = motion_line;       
         BuffDownPrice[shift] = EMPTY_VALUE;
         
         BuffUpPrice[save_shift] = save_motion_line;       
         ExtrapolationLine(BuffUpPrice, save_motion_line, save_shift, motion_line, shift);               
         
         change_direction = true;                 
         
         price_level = current_price_level;
         price_level_shift_begin = current_price_level_shift_begin; 
         
         Save_Shift_begin = shift;
      }else{ 
         if (change_direction) {
            change_direction = false; 
         }else{
            BuffUpPrice[shift] = EMPTY_VALUE;
         }                     
         BuffDownPrice[shift] = motion_line;                
         
         ExtrapolationLine(BuffDownPrice, save_motion_line, save_shift, motion_line, shift);
    
      }    
   }
}   

void CheckPriceLevel_EndBar(){
   DrawLine(BASE_NAME_LEVEL + "_" + price_level_shift_begin, "",  price_level_shift_begin, 0, price_level, price_level, MediumOrchid, 1);             
}

//Построява линия между две точки които са на разтояни повече от 1-ца отместване
void ExtrapolationLine(
   double &Buff[], 
   double prev_price, int prev_shift, 
   double curr_price , int curr_shift){
   
   double delta_step;
   int i, n = 0;
   if (prev_shift != 0){
      if (MathAbs(prev_shift - curr_shift) > 1){
         
         delta_step = MathAbs(curr_price - prev_price)/MathAbs(prev_shift - curr_shift);
         
         n = 0;
         for(i = curr_shift+1; i < prev_shift; i++){
            n++;
            if (prev_price < curr_price){
               Buff[i] = curr_price - delta_step * n;                
            }else{
               Buff[i] = curr_price + delta_step * n;
            }                     
         }         
      }
   }
}   



