
// Group wave------------------------------------------------
string Poly_name = "poly";
string Multy_name = "multy";
string Macro_name = "macro";
string Mono_name = "....";
// брои колко квадрата има на графиката
int Poly_Count = 0; 

double poly_wave[100][4];
/*
   poly_wave[0][0] = shift - начало!          
   poly_wave[0][1] = shift - край! 
   poly_wave[0][2] = цена  - Начало!
   poly_wave[0][3] = цена - Край!
*/
// ----------------------------------------------------------

// BOX-----------------------------------------------------
string Box_name = "box";
// брои колко квадрата има на графиката
int Box_Count = 0; 

double Boxes[100][4];
/*
   Boxes[0][0] = shift - начало!          
   Boxes[0][1] = shift - край! 
   Boxes[0][2] = horizonatalen diapazon 
   Boxes[0][3] = vertikalen diapazon         
*/
// ----------------------------------------------------------

// M1-----------------------------------------------------
string m1_name = "m1";
int m1_Count = 0; 
int m1_mark;
/*
   m1_mark = позиция на вертикалната лния!          
*/
// ----------------------------------------------------------

// Wave Number ----------------------------------------------
string wave_number_name_begin = "b";
string wave_number_name_end = "e";
int wave_number_begin;
int wave_number_end;
/*
   wave_number_begin, ...end = позиция на вертикалната лния!          
*/
// ----------------------------------------------------------

// ChronoView ----------------------------------------------
string chrono_name = "ch";
double chrono_masive[20][2];
int chrono_count;
   
/*
   //chrono_masive[0][0] = shift
   //chrono_masive[0][1] = price
   
*/
// ----------------------------------------------------------

// Custom Point Wave ----------------------------------------------
string custom_point_name = "pw";
double custom_point_masive[50][2];
int custom_point_count;
/*
   //custom_point_masive[0][0] = shift
   //custom_point_masive[0][1] = price   
*/
// ----------------------------------------------------------

// Begin Calculation Rules -----------------------------------
string wave_rules_begin = "r";
int wave_rules_begin_shift;
int wave_rules_begin_count;
/*
   wave_number_begin, ...end = позиция на вертикалната лния!          
*/
// ----------------------------------------------------------

int GetObjectWork(){
   int total_obj = ObjectsTotal();
   string name_obj, desct_obj, desct_save;
   
   datetime t1, t2;
   int t1_shift, t2_shift, save;
   double p1, p2;

   double x_box, y_box;

   
   Box_Count = 0;   
   Poly_Count = 0;
   m1_Count = 0;
   m1_mark = -1;
   chrono_count = 0;
   custom_point_count = 0;
   
   ArrayInitialize(chrono_masive, 0);
   
   wave_number_begin = -1;
   wave_number_end = -1;
   
   wave_rules_begin_shift = -1;
   wave_rules_begin_count = 0;
   
   for(int i = 0; i <= total_obj; i++){
      name_obj = ObjectName(i);      
      
          
      if (name_obj != "" && CheckObjectTimeFrame(name_obj)){         
         if  (ObjectType(name_obj) == OBJ_TREND){
            
            // Group Wave--------------------------------------------------------         
            desct_save = ObjectDescription(name_obj);      
            desct_obj = StringSubstr(desct_save, 0, 4);
            
            if (Poly_name != desct_obj){
               desct_obj = StringSubstr(desct_save, 0, 5);                  
            }
            
            if (Poly_name == desct_obj || Multy_name == desct_obj || Macro_name == desct_obj || Mono_name == desct_obj){            
               p1 = ObjectGet(name_obj, OBJPROP_PRICE1); 
               p2 = ObjectGet(name_obj, OBJPROP_PRICE2); 
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               t2 = ObjectGet(name_obj, OBJPROP_TIME2);                
               t1_shift = iBarShift(NULL, NULL, t1);
               t2_shift = iBarShift(NULL, NULL, t2);
            
               if (t1_shift < t2_shift){
                  save = t1_shift;
                  t1_shift = t2_shift;
                  t2_shift = save;
               
                  save = p1;
                  p1 = p2;
                  p2 = save;
                
               }                    
               poly_wave[Poly_Count][0] = t1_shift;
               poly_wave[Poly_Count][1] = t2_shift;
               poly_wave[Poly_Count][2] = p1;
               poly_wave[Poly_Count][3] = p2;                      
               Poly_Count++;  
               
            }
            // ----------------------------------------------------------------- 
         }   
            // BOX---------------------------------------------------------------
         
         if  (ObjectType(name_obj) == OBJ_RECTANGLE){  
                      
            desct_save = ObjectDescription(name_obj);  
            desct_obj = StringSubstr(desct_save, 0, 3); 
            
            if (Box_name == desct_obj){   
                  
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               t2 = ObjectGet(name_obj, OBJPROP_TIME2); 
               p1 = ObjectGet(name_obj, OBJPROP_PRICE1); 
               p2 = ObjectGet(name_obj, OBJPROP_PRICE2); 
               t1_shift = iBarShift(NULL, NULL, t1);
               t2_shift = iBarShift(NULL, NULL, t2);
            
               if (t1_shift < t2_shift){
                  save = t1_shift;
                  t1_shift = t2_shift;
                  t2_shift = save; 
               }
               x_box = MathAbs(t2_shift - t1_shift);
               y_box = MathAbs(p2 - p1);
         
               Boxes[Box_Count][0] = t1_shift;
               Boxes[Box_Count][1] = t2_shift;
               Boxes[Box_Count][2] = x_box;
               Boxes[Box_Count][3] = y_box;                      
               Box_Count++;  
            }            
            // -----------------------------------------------------------------     
         }   
         // M1, Wave Number-----------------------------------------------------
         if  (ObjectType(name_obj) == OBJ_VLINE){
            desct_save = ObjectDescription(name_obj);      
            desct_obj = StringSubstr(desct_save, 0, 2);
            
            if (m1_name == desct_obj){    
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               m1_Count++;
               m1_mark = iBarShift(NULL, NULL, t1);             
               
            } 
            //Wave Number  
            desct_save = ObjectDescription(name_obj);      
            desct_obj = StringSubstr(desct_save, 0, 1); 
                       
            if (wave_number_name_begin == desct_obj){    
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               wave_number_begin = iBarShift(NULL, NULL, t1);                            
            }      
            if (wave_number_name_end == desct_obj){    
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               wave_number_end = iBarShift(NULL, NULL, t1);                            
            }         
            
            //Begin Calculation Rules
            desct_save = ObjectDescription(name_obj);      
            desct_obj = StringSubstr(desct_save, 0, 1); 
                       
            if (wave_rules_begin == desct_obj){    
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               wave_rules_begin_shift = iBarShift(NULL, NULL, t1);                            
            }                                    
         }   
         // -----------------------------------------------------------------                                    
         
         // Chrono Wave, Custom Wave Point------------------------------------------
         if  (ObjectType(name_obj) == OBJ_ARROW){
            desct_save = ObjectDescription(name_obj);                  
            desct_obj = StringSubstr(desct_save, 0, 2);
            //Chrono Wave-------------------
            if (chrono_name == desct_obj){    
               
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               p1 = ObjectGet(name_obj, OBJPROP_PRICE1); 
               
               chrono_masive[chrono_count][0] = iBarShift(NULL, NULL, t1);
               chrono_masive[chrono_count][1] = p1;
               chrono_count++;               
            } 
            //Custom Wave Point-------------------                                                     
            if (custom_point_name == desct_obj){    
               
               t1 = ObjectGet(name_obj, OBJPROP_TIME1); 
               p1 = ObjectGet(name_obj, OBJPROP_PRICE1); 
               
               custom_point_masive[custom_point_count][0] = iBarShift(NULL, NULL, t1);
               custom_point_masive[custom_point_count][1] = p1;
               custom_point_count++;  
               
            }  
         } 
         // -----------------------------------------------------------------                   
      }
   }
   return(0);
}


int Check_Poly(int shift_wave){
   
   if (Poly_Count > 0){
      
      int i = 0, poly, up_down;
      bool find_poly = false;
      int t1_shift, t2_shift;
      double p1, p2;      
      while (i < Poly_Count && !find_poly){
         t1_shift = poly_wave[i][0];
         t2_shift = poly_wave[i][1];                             
         p1 = poly_wave[i][2];
         p2 = poly_wave[i][3];
         
         
         if (shift_wave < t1_shift && shift_wave >= t2_shift){
            if (p1 <= p2) { 
               up_down = 1;
            }else{
               up_down = 2;               
            }
            
            find_poly = true;  
            poly = i; 
         }
         i++;
      }
      if (find_poly){
         return(up_down);           
      }else{
         return(0);   
      }
   }
   return(0);   
}

int Calc_Activity_Box(int shift_wave, double wave_y, double tolerance){
   
   if (Box_Count > 0){
      
      int i = 0, box;
      bool find_box = false;
      int t1_shift, t2_shift;      
      double x_box, y_box;
      double ratio_box;
      while (i < Box_Count && !find_box){
         t1_shift = Boxes[i][0];
         t2_shift = Boxes[i][1];
                              
         
         if (shift_wave < t1_shift && shift_wave >= t2_shift){
            
            find_box = true;  
            box = i; 
         }
         i++;
      }
      if (find_box){
         
         x_box = Boxes[box][2];
         y_box = Boxes[box][3];  
         
         ratio_box = y_box / x_box;          
         
         if (wave_y <= ratio_box - (ratio_box * tolerance) && wave_y >= -ratio_box + (ratio_box * tolerance)){
            return(-1);
            
         }else{
            return(1);               
         }
      }else{
         return(0);   
      }
   }
   return(0);   
}

bool CheckPoint_ViewNumberWave(int shift){
   if (wave_number_begin > -1){      
      if (shift < wave_number_begin && shift >= wave_number_end){
         return(true);
      }
   }
   return(false);
}

bool Check_Waves_Rules_Calc(int shift){
   if (wave_rules_begin_shift > -1){      
      if (shift < wave_rules_begin_shift){
         return(true);
      }
   }
   return(false);
}

double Check_Custom_Wave_Point_Level(int position_point){
   bool check_find_point = false;
   int i = 0;
   while (!check_find_point && i < custom_point_count){
      if (position_point == custom_point_masive[i][0]){
         check_find_point = true;   
      }else{
         i++;   
      }
   }
   if (check_find_point){
      return(custom_point_masive[i][1]);
   }else{
      return(0);
   }
}

bool CheckObjectTimeFrame(string name){
   
   int time_frame = ObjectGet(name, OBJPROP_TIMEFRAMES);
   switch (time_frame){
      case NULL: return(true);
      case OBJ_ALL_PERIODS: return(true);
      case EMPTY: return(false);
      case OBJ_PERIOD_MN1: return(Period() == PERIOD_MN1);
      case OBJ_PERIOD_W1: return(Period() == PERIOD_W1);
      case OBJ_PERIOD_D1: return(Period() == PERIOD_D1);
      case OBJ_PERIOD_H4: return(Period() == PERIOD_H4);
      case OBJ_PERIOD_H1: return(Period() == PERIOD_H1);
      case OBJ_PERIOD_M30: return(Period() == PERIOD_M30);
      case OBJ_PERIOD_M15: return(Period() == PERIOD_M15);
      case OBJ_PERIOD_M5: return(Period() == PERIOD_M5);
      case OBJ_PERIOD_M1: return(Period() == PERIOD_M1);
   }
   
}

