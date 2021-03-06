double high_const = 100000;
double low_const = -100000;
int m1_index_count = 0;

double m0_length, m_1_length, m_2_length, m_3_length, m_4_length;
double m1_length; 
double m2_length, m3_length, m4_length, m5_length, m_6_length;

int Initialize_Wave_m(){
   m0_length = 0; 
   m_1_length = 0; 
   m_2_length = 0;
   m_3_length = 0;
   m_4_length = 0;   
   
   m1_length = 0;
   m2_length = 0;
   m3_length = 0;
   m4_length = 0;
   m5_length = 0;
   
   m_6_length = 0;
      
   return(0);
}

double Calc_Wave_Left_m1(
   double& array_waves[][], int size_array_waves, int index,
   double& array_waves_direction[][],
   double _max_point_wave, double _min_point_wave, bool save_m0 = false){
   
   bool check_exit;
   int n;
   int offset_wave_cross; 
   
   double max_offset_wave, min_offset_wave;
   double begin_array_waves;
      
   double max_point_wave = _max_point_wave;
   double min_point_wave = _min_point_wave;
   
   int save_wave_max, save_wave_min;
   
   int count_m1;
   int k = 1;
   int m1_index;
   
   if (save_m0) {
      count_m1 = 5;
      
   }else{
      count_m1 = 1;
   }
   
   m1_index = index;
   double min, max, max_curr_direct, min_curr_direct, max_fail_direct, min_fail_direct;

   while (k <= count_m1){
      check_exit = false; 
      n = 1;
      //намира с коя вълна пробива екстремумите на текущата моновълна
      max_offset_wave = low_const; 
      min_offset_wave = high_const;
      

      max_fail_direct = array_waves[m1_index+n][3];
      min_fail_direct = array_waves[m1_index+n][4]; 
      max_curr_direct = max_fail_direct;               
      min_curr_direct = min_fail_direct;      
      
      while(!check_exit){
         max = array_waves[m1_index+n][3];
         min = array_waves[m1_index+n][4];                         
         
         begin_array_waves = array_waves[m1_index+n+1][2];
         
         
         if (begin_array_waves > max_offset_wave) { 
            max_offset_wave = begin_array_waves;//max;            
            save_wave_max = m1_index+n;
         }
         if (begin_array_waves < min_offset_wave) { 
            min_offset_wave = begin_array_waves;//min;            
            save_wave_min = m1_index+n;
         }   
         
         //записва екстремумите за случаите когато m2 е ПО-ГОЛЯМА от m1
         if (max_curr_direct < max){
            max_curr_direct = max;   
         }
         if (min_curr_direct > min){
            min_curr_direct = min;   
         }                
         //-----------------------------------------------------------
                                                         
         
         if (begin_array_waves > max_point_wave || begin_array_waves < min_point_wave){   
            
            check_exit = true;                                                   
            offset_wave_cross = n;
         }else{            
            if (n + m1_index > size_array_waves) {
               check_exit = true;
            }else{  
               //записва екстремумите за случаите когато m2 е ПО-МАЛКА от m1
               if (max_fail_direct < max){
                  max_fail_direct = max;   
               }
               if (min_fail_direct > min){
                  min_fail_direct = min;   
               }               
               //-----------------------------------------------------------
                                     
               n++;
            }
         }         
      }
      
      
      
      begin_array_waves = array_waves[m1_index+offset_wave_cross+1][2];               
      if (array_waves[m1_index+1][2] < array_waves[m1_index][2]){          
         //нарастваща вълна                 
         if (begin_array_waves > max_point_wave){         
            array_waves_direction[m1_index_count][0] = array_waves[m1_index+n+1][2];          
            array_waves_direction[m1_index_count][1] = array_waves[m1_index+1][2];//вярно         
            array_waves_direction[m1_index_count][2] = array_waves[m1_index+n+1][1];          
            array_waves_direction[m1_index_count][3] = array_waves[m1_index+1][1];   //вярно                        
            array_waves_direction[m1_index_count][4] = array_waves[m1_index+1][0];
            //-------------------------------------------------------------------------
            //Индекс на вълната пробила Макс. екстремума.
            array_waves_direction[m1_index_count][5] = 0; 
               //Right_IndexBreakMaxExtremum(array_waves[m1_index+n+1][0], array_waves[m1_index+1][0], max_point_wave);
            //-------------------------------------------------------------------------
            //Брой вълни в едно направление
            array_waves_direction[m1_index_count][6] = n;
            
            //Направление на вълната
            CalcDirection(array_waves_direction, m1_index_count);
            //array_waves_direction[m1_index_count][7] = -1;

            //Екстремуми на вълната
            //макс
            array_waves_direction[m1_index_count][8] = max_curr_direct;//array_waves[m1_index+n+1][3];
            //мин
            array_waves_direction[m1_index_count][9] = min_curr_direct;//array_waves[m1_index+1][4];                 
            
            //Записва индекса на MonoWave_Rule
            array_waves_direction[m1_index_count][10] = m1_index+1;
                           
            m1_index_count++;                 
            m1_index = m1_index+n;
              
         }else{
            array_waves_direction[m1_index_count][0] = array_waves[save_wave_max+1][2];          
            array_waves_direction[m1_index_count][1] = array_waves[m1_index+1][2];//вярно         
            array_waves_direction[m1_index_count][2] = array_waves[save_wave_max+1][1];          
            array_waves_direction[m1_index_count][3] = array_waves[m1_index+1][1];   //вярно                        
            array_waves_direction[m1_index_count][4] = array_waves[m1_index+1][0];
            
            //-------------------------------------------------------------------------
            //Индекс на вълната пробила екстремума. /няма пробив/
            array_waves_direction[m1_index_count][5] = 0;          
            //-------------------------------------------------------------------------
            //Брой вълни в едно направление
            array_waves_direction[m1_index_count][6] = save_wave_max - m1_index;

            //Направление на вълната
            CalcDirection(array_waves_direction, m1_index_count);
            //array_waves_direction[m1_index_count][7] = -1;            

            //Екстремуми на вълната
            //макс
            array_waves_direction[m1_index_count][8] = max_fail_direct;//array_waves[save_wave_max+1][3];
            //мин
            array_waves_direction[m1_index_count][9] = min_fail_direct;//array_waves[m1_index+1][4];              
            
            //Записва индекса на MonoWave_Rule
            array_waves_direction[m1_index_count][10] = m1_index+1;            
            
            m1_index_count++;                                
            m1_index = save_wave_max;                  
         }              
         
      }else{
         //намалаваща вълна  
         if (begin_array_waves < min_point_wave){
            array_waves_direction[m1_index_count][0] = array_waves[m1_index+n+1][2];          
            array_waves_direction[m1_index_count][1] = array_waves[m1_index+1][2];//вярно         
            array_waves_direction[m1_index_count][2] = array_waves[m1_index+n+1][1];          
            array_waves_direction[m1_index_count][3] = array_waves[m1_index+1][1];   //вярно    
            array_waves_direction[m1_index_count][4] = array_waves[m1_index+1][0];  
            
            //-------------------------------------------------------------------------
            //Индекс на вълната пробила Min. екстремума.
            array_waves_direction[m1_index_count][5] = 0;
               //Right_IndexBreakMinExtremum(array_waves[m1_index+n+1][0], array_waves[m1_index+1][0], min_point_wave);            
            //-------------------------------------------------------------------------                                           
            //Брой вълни в едно направление
            array_waves_direction[m1_index_count][6] = n;   
            
            //Направление на вълната
            CalcDirection(array_waves_direction, m1_index_count);
            //array_waves_direction[m1_index_count][7] = 1;                       
                        
            //Екстремуми на вълната
            //макс
            array_waves_direction[m1_index_count][8] = max_curr_direct;//array_waves[m1_index+1][3];
            //мин
            array_waves_direction[m1_index_count][9] = min_curr_direct;//array_waves[m1_index+n+1][4];  
            
            //Записва индекса на MonoWave_Rule
            array_waves_direction[m1_index_count][10] = m1_index+1;                      
            
            m1_index_count++;                 
            m1_index = m1_index + n;                              
         }else{
            array_waves_direction[m1_index_count][0] = array_waves[save_wave_min+1][2];          
            array_waves_direction[m1_index_count][1] = array_waves[m1_index+1][2];//вярно         
            array_waves_direction[m1_index_count][2] = array_waves[save_wave_min+1][1];          
            array_waves_direction[m1_index_count][3] = array_waves[m1_index+1][1]; //вярно
            array_waves_direction[m1_index_count][4] = array_waves[m1_index+1][0];                        
            
            //-------------------------------------------------------------------------
            //Индекс на вълната пробила екстремума - Няма пробив
            array_waves_direction[m1_index_count][5] = 0;            
            //-------------------------------------------------------------------------  
            //Брой вълни в едно направление
            array_waves_direction[m1_index_count][6] = save_wave_min - m1_index;                         
            
            //Направление на вълната
            CalcDirection(array_waves_direction, m1_index_count);
            //array_waves_direction[m1_index_count][7] = 1;  
            
            //Екстремуми на вълната
            //макс
            array_waves_direction[m1_index_count][8] = max_fail_direct;//array_waves[m1_index+1][3];
            //мин
            array_waves_direction[m1_index_count][9] = min_fail_direct;//array_waves[save_wave_min+1][4];   
           
            //Записва индекса на MonoWave_Rule
            array_waves_direction[m1_index_count][10] = m1_index+1;           
            
            m1_index_count++;   
            m1_index = save_wave_min;       
         }          
      }

      //--------------използваме екстремумите за отчитане на м0, м-1, м-2...
      //max_point_wave = max;
      //min_point_wave = min;
      
      //--------------използваме началото и края за отчитане на м0, м-1, м-2----      
      if (array_waves_direction[m1_index_count-1][0] < array_waves_direction[m1_index_count-1][1]){ 
         //нарастваща вълна        
         max_point_wave = array_waves_direction[m1_index_count-1][1]; //по-високата точка         
         min_point_wave = array_waves_direction[m1_index_count-1][0]; //по-ниската точка        
      }else{
         //намалаваща вълна  
         max_point_wave = array_waves_direction[m1_index_count-1][0];         
         min_point_wave = array_waves_direction[m1_index_count-1][1];         
      }          
      //------------------------------------------------------------------
      switch (k) {
         case 1: m0_length  = max_point_wave - min_point_wave;  
         case 2: m_1_length = max_point_wave - min_point_wave;
         case 3: m_2_length = max_point_wave - min_point_wave;
         case 4: m_3_length = max_point_wave - min_point_wave;
         case 5: m_4_length = max_point_wave - min_point_wave;
      }                         
        
      k++;
   }
   return(0);
}

double Calc_Wave_Right_m1(
   double& array_waves[][], int size_array_waves, int index,
   double& array_waves_direction[][],
   double _max_point_wave, double _min_point_wave,  bool save_m2 = false){
   
   double max_offset_wave, min_offset_wave;
   bool check_exit;
   int offset_wave_cross; 
   double end_MonoWave_Rule;         
   int n;
   double m2_tmp;

   double max_point_wave = _max_point_wave;
   double min_point_wave = _min_point_wave;   
   
   int save_wave_max, save_wave_min;

   int count_m1;
   int k = 1;
   int m1_index;
   
   if (save_m2) {
      count_m1 = 4;
      
   }else{
      count_m1 = 1;
   }
   m1_index = index;

   bool extremum_break = false;
   double min, max, max_curr_direct, min_curr_direct, max_fail_direct, min_fail_direct;

   max_offset_wave = low_const; 
   min_offset_wave = high_const;            
   double length, end_level;
   
   while (k <= count_m1){
   
      check_exit = false; 
      n = 1;
      //намира с коя вълна пробива екстремумите на текущата моновълна
      max_offset_wave = low_const; 
      min_offset_wave = high_const;            
      
      extremum_break = false;
      
      max_fail_direct = array_waves[m1_index-n][3];
      min_fail_direct = array_waves[m1_index-n][4]; 
      max_curr_direct = max_fail_direct;               
      min_curr_direct = min_fail_direct;
      
      while(!check_exit){
         max = array_waves[m1_index-n][3];
         min = array_waves[m1_index-n][4];                         
         
         end_MonoWave_Rule = array_waves[m1_index-n][2];
                           
         if (end_MonoWave_Rule > max_offset_wave) { 
            max_offset_wave = max;            
            save_wave_max = m1_index-n;
         }
         if (end_MonoWave_Rule < min_offset_wave) { 
            min_offset_wave = min;            
            save_wave_min = m1_index-n;          
         }    
         
         //записва екстремумите за случаите когато m2 е ПО-ГОЛЯМА от m1
         if (max_curr_direct < max){
            max_curr_direct = max;   
         }
         if (min_curr_direct > min){
            min_curr_direct = min;   
         }                
         //-----------------------------------------------------------
                         
         if (end_MonoWave_Rule > max_point_wave || end_MonoWave_Rule < min_point_wave){
            //Debug Print(n," - ", max_offset_wave, " | ", min_offset_wave);
            check_exit = true;                                       
            offset_wave_cross = n;
            extremum_break = true;            
         }else{            
            if (m1_index-n <= 0) {
               check_exit = true;
               return(0); //!!!!!!!!!!!!!
            }else{ 
               //записва екстремумите за случаите когато m2 е ПО-МАЛКА от m1 
               if (max_fail_direct < max){
                  max_fail_direct = max;   
               }
               if (min_fail_direct > min){
                  min_fail_direct = min;   
               }               
               //-----------------------------------------------------------
               n++;
            }
         }                          
      }          
      
      end_MonoWave_Rule = array_waves[m1_index-offset_wave_cross][2];
      if (array_waves[m1_index+1][2] < array_waves[m1_index][2]){ 
         //нарастваща вълна     
         if (end_MonoWave_Rule < min_point_wave){
               length = MathAbs(array_waves[m1_index][2] - array_waves[m1_index-n][2]);                                                
               array_waves_direction[m1_index_count][0] = array_waves[m1_index][2];   
               array_waves_direction[m1_index_count][1] = array_waves[m1_index-n][2];         
               array_waves_direction[m1_index_count][2] = array_waves[m1_index][1]; //начало на направлението      
               array_waves_direction[m1_index_count][3] = array_waves[m1_index-n][1]; //край на направлението 
               array_waves_direction[m1_index_count][4] = array_waves[m1_index-n][0]; 
               
               //Индекс на вълната пробила Min. екстремума.
               array_waves_direction[m1_index_count][5] = 
                  Left_IndexBreakMinExtremum(array_waves[m1_index][0], array_waves[m1_index-n][0], min_point_wave);
               //-------------------------------------------------------------------------               
               //Записва броя на вълните в даденото направление
               array_waves_direction[m1_index_count][6] = n;
               
               //Направление на вълната
               CalcDirection(array_waves_direction, m1_index_count); 
                            
                              
               //Екстремуми на вълната
               //макс
               array_waves_direction[m1_index_count][8] = max_curr_direct;//array_waves[m1_index][3];
               //мин
               array_waves_direction[m1_index_count][9] = min_curr_direct;//array_waves[m1_index-n][4];                 
               
               //Записва индекса на MonoWave_Rule
               array_waves_direction[m1_index_count][10] = m1_index-n;               
               
               m1_index_count++;                 
               m1_index = m1_index-n;       
         }   
         if (end_MonoWave_Rule > max_point_wave){ 
            length = MathAbs(array_waves[m1_index][2] - array_waves[save_wave_min][2]);                                       
               array_waves_direction[m1_index_count][0] = array_waves[m1_index][2];   
               array_waves_direction[m1_index_count][1] = array_waves[save_wave_min][2];         
               array_waves_direction[m1_index_count][2] = array_waves[m1_index][1];      //начало на направлението  
               array_waves_direction[m1_index_count][3] = array_waves[save_wave_min][1]; //край на направлението
               array_waves_direction[m1_index_count][4] = array_waves[save_wave_min][0];                                
               
               //Индекс на вълната пробила екстремума - няма екстремум
               array_waves_direction[m1_index_count][5] = 0;
               //-------------------------------------------------------------------------                  
               //Записва броя на вълните в даденото направление
               array_waves_direction[m1_index_count][6] = m1_index - save_wave_min;
               
               //Направление на вълната
               CalcDirection(array_waves_direction, m1_index_count);               
               
               //Екстремуми на вълната
               //макс               
               
               array_waves_direction[m1_index_count][8] = max_fail_direct;//array_waves[m1_index][3];
               //мин
               array_waves_direction[m1_index_count][9] = min_fail_direct;//array_waves[save_wave_min][4];                           
               
               //Записва индекса на MonoWave_Rule
               array_waves_direction[m1_index_count][10] = save_wave_min;                              
               
               m1_index_count++;     
               m1_index = save_wave_min; 
         }                       
      }else{
         //намалаваща вълна  
         if (end_MonoWave_Rule > max_point_wave){
               length = MathAbs(array_waves[m1_index][2] - array_waves[m1_index-n][2]);
               array_waves_direction[m1_index_count][0] = array_waves[m1_index][2];   
               array_waves_direction[m1_index_count][1] = array_waves[m1_index-n][2];         
               array_waves_direction[m1_index_count][2] = array_waves[m1_index][1];   //начало на направлението     
               array_waves_direction[m1_index_count][3] = array_waves[m1_index-n][1]; //край на направлението 
               array_waves_direction[m1_index_count][4] = array_waves[m1_index-n][0];                                                        
               
               //Индекс на вълната пробила Макс. екстремума.
               array_waves_direction[m1_index_count][5] = 
                  Left_IndexBreakMaxExtremum(array_waves[m1_index][0], array_waves[m1_index-n][0], max_point_wave);
               //-------------------------------------------------------------------------                
               //Записва броя на вълните в даденото направление
               array_waves_direction[m1_index_count][6] = n;  
               
               //Направление на вълната
               CalcDirection(array_waves_direction, m1_index_count);                            
               
               //Екстремуми на вълната
               //макс
               array_waves_direction[m1_index_count][8] = max_curr_direct;//array_waves[m1_index-n][3];
               //мин
               array_waves_direction[m1_index_count][9] = min_curr_direct;//array_waves[m1_index][4];                 
               
               //Записва индекса на MonoWave_Rule
               array_waves_direction[m1_index_count][10] = m1_index-n;               
                              
               m1_index_count++; 
               m1_index = m1_index-n;                       
         }   
         if (end_MonoWave_Rule < min_point_wave){   
               length = MathAbs(array_waves[m1_index][2] - array_waves[save_wave_max][2]);
               array_waves_direction[m1_index_count][0] = array_waves[m1_index][2];   
               array_waves_direction[m1_index_count][1] = array_waves[save_wave_max][2];         
               array_waves_direction[m1_index_count][2] = array_waves[m1_index][1];     //начало на направлението  
               array_waves_direction[m1_index_count][3] = array_waves[save_wave_max][1];//край на направлението 
               array_waves_direction[m1_index_count][4] = array_waves[save_wave_max][0]; 
               
               //Индекс на вълната пробила Макс. екстремума.
               array_waves_direction[m1_index_count][5] = 0;               
               //Записва броя на вълните в даденото направление
               array_waves_direction[m1_index_count][6] = m1_index-save_wave_max;                 
               
               //Направление на вълната
               CalcDirection(array_waves_direction, m1_index_count);                
               
               //Екстремуми на вълната
               //макс
               array_waves_direction[m1_index_count][8] = max_fail_direct;//array_waves[save_wave_max][3];
               //мин
               array_waves_direction[m1_index_count][9] = min_fail_direct;//array_waves[m1_index][4];              
               
               //Записва индекса на MonoWave_Rule
               array_waves_direction[m1_index_count][10] = save_wave_max;                              
                                           
               m1_index_count++;       
               m1_index = save_wave_max;
                  
         }          
      } 
      //--------------използваме екстремумите за отчитане на м2, м3...
      //max_point_wave = max;
      //min_point_wave = min;
      
      //--------------използваме началото и края за отчитане на м2, м3----
      if (array_waves_direction[m1_index_count-1][0] < array_waves_direction[m1_index_count-1][1]){ 
         //нарастваща вълна        
         max_point_wave = array_waves_direction[m1_index_count-1][1]; //по-високата точка         
         min_point_wave = array_waves_direction[m1_index_count-1][0]; //по-ниската точка        
      }else{
         //намалаваща вълна  
         max_point_wave = array_waves_direction[m1_index_count-1][0];         
         min_point_wave = array_waves_direction[m1_index_count-1][1];         
      }       
      //------------------------------------------------------------------
      switch (k) {
         case 1: {
            m2_length = length;//max_point_wave - min_point_wave;
            if (count_m1 == 1 && RuleFind_4(m1_length, m2_length)){
               count_m1 = 2;      
            }            
         }
         case 2: m3_length = length;//max_point_wave - min_point_wave;
         case 3: m4_length = length;//max_point_wave - min_point_wave;
         case 4: m5_length = length;//max_point_wave - min_point_wave;
      }        
      k++;
   }
   if (!extremum_break) m2_length = 0;
   return(0);
}  

double Calc_break_m1_m0(double& array[][]){
   double ratio = ComparePriceDirection(1, 0);        
   
   if (!Large_100(ratio, true)) return(0);     
   
   if (Direction(1) == 1) {             
      array[0][5] = Left_IndexBreakMaxExtremum(      
         DirectionWaveInPointArray(0), 
         DirectionWaveInPointArray(1), 
         DirectionBeginPrice(0)
      );
   }else{           
      array[0][5] = Left_IndexBreakMinExtremum(      
         DirectionWaveInPointArray(0), 
         DirectionWaveInPointArray(1), 
         DirectionBeginPrice(0)
      );
   }   
}

 


int Left_IndexBreakMaxExtremum(int begin_index, int end_index,  double Level){    
   int k = begin_index;   
   while (array_ChartPoints[k][0] < Level && k >= end_index){
      k--;   
   }   
   if (k > 0){
      return(k);
   }else{
      return(0); 
   }
}

int Left_IndexBreakMinExtremum(int begin_index, int end_index, double Level){    
   int k = begin_index;
   while (array_ChartPoints[k][0] > Level && k >= end_index){
      k--;   
   }   
   if (k > 0){
      return(k);
   }else{
      return(0); 
   }
}

bool CalcDirection(double& array[][], int index){
   //Wave_Direction[0][0] = цена от която започва вълната           
   //Wave_Direction[0][1] = цена на която завършва вълната 
   if (array[index][0] < array[index][1]){
      array[index][7] = 1;
   }else{
      array[index][7] = -1;
   }

}