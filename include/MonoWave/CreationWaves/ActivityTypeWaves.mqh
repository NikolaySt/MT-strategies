
double Ratio_288 = 0.5;
double Ratio_daily = 0.2;
double Ratio_weekly = 0.2;
double Ratio_monthly = 0.2;
double Ratio_twofold = 0.5;
double Ratio_sixfold = 0.5;

void AddActivityTypeInMonoWaves(int period_calc){
//----------------Поставя активноста за всяка моновълна или група---------------------------------------------------
   double ATR = 0;
   double range = 0;
   int poly_type = 0;
   int calc;
   int save_poly_type = 0;
   bool check_begin_GroupPoint = false;
   for (int i = 0; i < ChartPoints_count; i++){
      
      Point_Wave[i] = EMPTY_VALUE;
      
      if (period_calc == PERIOD_SIXFOLD){
         ATR = iATR(NULL, PERIOD_MN1, 10, i)*Ratio_sixfold;   
      }else{
         if (period_calc == PERIOD_TWOFOLD){      
            ATR = iATR(NULL, PERIOD_MN1, 10, i)*Ratio_twofold;   
         }else{
            if (period_calc == PERIOD_MN1){      
               ATR = iATR(NULL, period_calc, 10, i)*Ratio_monthly;   
            }else{
               if (period_calc == PERIOD_W1){      
                  ATR = iATR(NULL, period_calc, 10, i)*Ratio_weekly;   
               }else{
                  if (period_calc == PERIOD_D1){      
                     ATR = iATR(NULL, period_calc, 10, i)*Ratio_daily;   
                  }else{
                     if (period_calc == PERIOD_288){      
                        ATR = iATR(NULL, PERIOD_H1, 10, i)*Ratio_288;   
                     }else{
                        ATR = 0;                        
                     }              
                  }                
               }                        
            }            
         }
      }         
      
                
   
      range = array_ChartPoints[i][0] - array_ChartPoints[i+1][0];         
      if ((array_ChartPoints[i+1][1] - array_ChartPoints[i][1]) != 0){
         calc = Calc_Activity_Box(array_ChartPoints[i][1], range/ (array_ChartPoints[i+1][1] - array_ChartPoints[i][1]) , Tolerance);
      }
      

       poly_type = Check_Poly(array_ChartPoints[i][1]);       


      if (poly_type > 0){
         SetMonoType(i, poly_type); 
            
         if (save_poly_type != poly_type){
            //price , shift
            SetGroupPoint(array_ChartPoints[i-1][0], array_ChartPoints[i-1][1]);    
            save_poly_type = poly_type;
            check_begin_GroupPoint = true;
         }
      }else{ 
         if (check_begin_GroupPoint){
            SetGroupPoint(array_ChartPoints[i][0], array_ChartPoints[i][1]);       
            save_poly_type = 0;
            check_begin_GroupPoint = false;            
         }      
         if (calc != 0) {
            if (calc == 1){
               if (range > 0) {
                  SetMonoType(i, 1); 
               }else{   
                  SetMonoType(i, 2);    
               }            
            }else{
               if (range > 0){ //нагоре                  
                  SetMonoType(i, -1);               
               }else{      
                  if (range < 0){ //надолу
                     SetMonoType(i, -2);         
                  }else{ // хоризонатална
                     SetMonoType(i, -3);
                  }
               }                         
            }
         }else{       
          SetMonoType(i, Calc_Activity_neighbour(i, ATR));       
         }
      }
      /*         
      }else{
         if (check_begin_GroupPoint){
            SetGroupPoint(array_ChartPoints[i][0], array_ChartPoints[i][1]);       
            save_poly_type = 0;
            check_begin_GroupPoint = false;            
         }
         if (calc != 0) {
            if (calc == 1){
               if (range > 0) {
                  SetMonoType(i, 1); 
               }else{   
                  SetMonoType(i, 2);    
               }            
            }else{
               if (range > 0){ //нагоре                  
                  SetMonoType(i, -1);               
               }else{      
                  if (range < 0){ //надолу
                     SetMonoType(i, -2);         
                  }else{ // хоризонатална
                     SetMonoType(i, -3);
                  }
               }                         
            }
         }else{
            //насочено движение нагоре
            if (range > ATR) {         
               SetMonoType(i, 1); 
            }else{
               //насочено движение надолу
               if (range < -ATR) {
                  SetMonoType(i, 2); 
               } else {
      
                  //хоризонтална ценова активност    
                  if (range < ATR && range > -ATR){         
                     if (range > 0){ //нагоре
                        SetMonoType(i, -1); 
                     }else{      
                        if (range < 0){ //надолу
                           SetMonoType(i, -2);      
                        }else{ // хоризонатална
                           SetMonoType(i, -3); 
                        }
                     }         
                  }                           
               }            
            }                       
         } 
      }  
      */
     
   }
}   

int SetMonoType(int index, int TypeWave){
   array_ChartPoints[index][2] = TypeWave;    
} 

int SetGroupPoint(double level, int shift){
   GroupPoints[shift] = level;   
}

int Calc_Activity_neighbour(int index, double ATR){
   double range;
   double up_value = array_ChartPoints[index][0] - array_ChartPoints[index+1][0];
   bool up = false;   
   
   if (index > 1){
      range = MathAbs(array_ChartPoints[index][0] - array_ChartPoints[index+1][0]); 
      double right_neighbour = MathAbs(array_ChartPoints[index][0] - array_ChartPoints[index-1][0]);
      double left_neighbour = MathAbs(array_ChartPoints[index+1][0] - array_ChartPoints[index+2][0]);      
      
      if (right_neighbour != 0 && left_neighbour != 0){
         double ratio1 = range/right_neighbour;
         double ratio2 = range/left_neighbour;
      

         if (up_value > 0){
            up = true;
         }else{
            up = false;
         }
         if (ratio1 < 0.382 && ratio2 < 0.382){
            if (range == 0) {
               return(-3);
            }else{               
               if (up) {return(-1);}else{return(-2);}
            }
         }else{
            if (range < ATR && range > -ATR){         
               if (range > 0){ //нагоре
                  return(-1); 
               }else{      
                  if (range < 0){ //надолу
                     return(-2);      
                  }else{ // хоризонатална
                     return(-3); 
                  }
               }         
            }else{         
               if (up) {return(1);}else{return(2);}         
            }
         }
      }else{
         if (range < ATR && range > -ATR){         
            if (range > 0){ //нагоре
               return(-1); 
            }else{      
               if (range < 0){ //надолу
                  return(-2);      
               }else{ // хоризонатална
                  return(-3); 
               }
            }         
         }else{       
            if (up_value > 0){
               return(1);
            }else{
               return(2);
            } 
         }                     
      } 
                    
   }else{
      if (up_value > 0){
         return(1);
      }else{
         return(2);
      }   
      
   }
   
}