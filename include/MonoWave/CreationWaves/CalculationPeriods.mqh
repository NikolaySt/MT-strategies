int begin_sixfold;
int end_sixfold;
#define PERIOD_SIXFOLD 259200 //180 äåíà * 1440

int begin_twofold;
int end_twofold;
#define PERIOD_TWOFOLD 108000 // 75-äåíà * 1440;


int begin_minutes_288;
int end_minutes_288;
#define PERIOD_288 288 // 288 minutes

int GetSixfold(int shift){
   int month = TimeMonth(Time[shift]);
   
   if (month >= 1 && month <= 6){
      return(1);
   }else{   
      return(2);
   }
   return(0);
}

int GetSixfold_Year(int shift){
   int year = TimeYear(Time[shift]);   
   return(year);
}

int GetTwofold(int shift){
   int day = TimeDayOfYear(Time[shift]);
   int twofold = 73;
   int period_twofold;
   
   if (day <= twofold * 1){
      return(1);    
   }else{
      if (day > twofold * 1 && day <= twofold * 2){
         return(2);    
      }else{   
         if (day > twofold * 2 && day <= twofold * 3){
            return(3);    
         }else{       
            if (day > twofold * 3 && day <= twofold * 4){
               return(4);    
            }else{     
               if (day > twofold * 4 && day <= twofold * 5){
                  return(5);    
               }else{  
                  return(5);    
               }
            }                  
         }            
      }              
   }
   return(0);
}

int Get288Minutes(int shift){

   int minute = TimeHour(Time[shift]) * 60 + TimeMinute(Time[shift]);
   
   int period;
   int minutes_288 = 285;  
   
   if (minute <= minutes_288 * 1){
      return(1);    
   }else{
      if (minute > minutes_288 * 1 && minute <= minutes_288 * 2){
         return(2);    
      }else{   
         if (minute > minutes_288 * 2 && minute <= minutes_288 * 3){
            return(3);    
         }else{       
            if (minute > minutes_288 * 3 && minute <= minutes_288 * 4){
               return(4);    
            }else{     
               if (minute > minutes_288 * 4 && minute <= minutes_288 * 5){
                  return(5);    
               }else{  
                  return(5);    
               }
            }                  
         }            
      }              
   }
   return(0);
}

int Get_Position_Sixfold(int shift){

   int month = TimeMonth(Time[shift]);
   int period_sixfold;
   
   if (month >= 1 && month <= 6){
      period_sixfold = 1;
   }else{   
      period_sixfold = 2;
   }
   
   bool check_exit = false;
   int i = shift;
   begin_sixfold = 0;
   end_sixfold = 0;
   
   begin_sixfold = shift;
   while (!check_exit && i < Bars){      
      month = TimeMonth(Time[i]);  
      
      if (period_sixfold == 2){
         if (month >= 1 && month <= 6){   
            check_exit = true;
            begin_sixfold = i-1;
         }
      }else{
         if (period_sixfold == 1){
            if (month >= 7 && month <= 12){   
               check_exit = true;
               begin_sixfold = i-1;
            }  
         }       
      }
      i++;
   }
   
   check_exit = false;
   i = shift;
   end_sixfold = shift;
   while (!check_exit && i > 0){      
      month = TimeMonth(Time[i]);   
      if (period_sixfold == 2){
         if (month >= 1 && month <= 6){   
            check_exit = true;
            end_sixfold = i+1;
         }
      }else{
         if (period_sixfold == 1){
            if (month >= 7 && month <= 12){   
               check_exit = true;
               end_sixfold = i+1;
            }  
         }       
      }    
      i--;
   }   
   return(period_sixfold);
}

int Get_Position_Sixfold_Year(int shift){

   int month = TimeMonth(Time[shift]);
  
   bool check_exit = false;
   int i = shift;
   begin_sixfold = 0;
   end_sixfold = 0;
   
   begin_sixfold = shift;
   while (!check_exit && i < Bars){      
      month = TimeMonth(Time[i]);  
            
      if (month == 1){   
         check_exit = true;
         begin_sixfold = i;
      }
      i++;
   }
   
   check_exit = false;
   i = shift;
   end_sixfold = shift;
   while (!check_exit && i > 0){      
      month = TimeMonth(Time[i]);   
      if (month == 12){   
         check_exit = true;
         end_sixfold = i-1;
      }  
      i--;
   }   
   return(1);
}

int Get_Position_Òwofold(int shift){
      
   int day = TimeDayOfYear(Time[shift]);
   int twofold = 73;
   int period_twofold;
   
   if (day <= twofold * 1){
      period_twofold = 1;    
   }else{
      if (day > twofold * 1 && day <= twofold * 2){
         period_twofold = 2;    
      }else{   
         if (day > twofold * 2 && day <= twofold * 3){
            period_twofold = 3;    
         }else{       
            if (day > twofold * 3 && day <= twofold * 4){
               period_twofold = 4;    
            }else{     
               if (day > twofold * 4 && day <= twofold * 5){
                  period_twofold = 5;    
               }else{  
                  period_twofold = 5;    
               }
            }                  
         }            
      }              
   }
   
   
   bool check_exit = false;
   int i = shift;
   begin_twofold = 0;
   end_twofold = 0;
   
   begin_twofold = shift;
   while (!check_exit && i < Bars){      
      day = TimeDayOfYear(Time[i]);  
      
      if (period_twofold == 1){
         if (day > twofold * 2){   
            check_exit = true;
            //i--;
         } 
      }else{ 
         if (period_twofold == 2){
            if (day < twofold * 1){   
               check_exit = true;
            }
         }else{ 
            if (period_twofold == 3){
               if (day < twofold * 2){   
                  check_exit = true;
               }
            }else{ 
               if (period_twofold == 4){
                  if (day < twofold * 3){   
                     check_exit = true;
                  }
               }else{ 
                  if (period_twofold == 5){
                     if (day < twofold * 4){   
                        check_exit = true;
                     }
                  }               
               }              
            }          
         }      
      }

      if (check_exit){ 
         begin_twofold = i-1;         
      }else{
         i++;
      }
      
   }
   
   check_exit = false;
   i = shift;
   end_twofold = shift;
   while (!check_exit && i > 0){      
      day = TimeDayOfYear(Time[i]);

      if (period_twofold == 1){
         if (day >= twofold){   
            check_exit = true;
         }           
      }else{
         if (period_twofold == 2){
            if (day >= twofold*2){   
               check_exit = true;
            }           
         }else{
            if (period_twofold == 3){
               if (day >= twofold*3){   
                  check_exit = true;
               }           
            }else{
               if (period_twofold == 4){
                  if (day >= twofold*4){   
                     check_exit = true;
                  }           
               }else{
                  if (period_twofold == 5){
                     if (TimeYear(Time[i]) > TimeYear(Time[i+1])){
                        check_exit = true;
                        i++;
                        //i--;                          
                     }                    
                     /*
                     if (day >= twofold * 5 && day < twofold){   
                        check_exit = true;
                        if (day < twofold) i++;
                     } 
                     */          
                  }            
               }              
            }          
         }      
      }
      
      if (check_exit){ 
         end_twofold = i;         
      }else{
         i--;
      }
   }     
   return(period_twofold);
}

int Get_Position_288_minutes(int shift){


   int minute = TimeHour(Time[shift]) * 60 + TimeMinute(Time[shift]);
   int period = Get288Minutes(shift);
   int minutes_288 = 285;     
   
   bool check_exit = false;
   int i = shift;
   begin_minutes_288 = 0;
   end_minutes_288 = 0;
   
   
   while (!check_exit && i < Bars){      
      minute = TimeHour(Time[i]) * 60 + TimeMinute(Time[i]);  
      
      if (period == 1){
         if (minute > minutes_288 * 2){   
            check_exit = true;
            i--;
         } 
      }else{ 
         if (period == 2){
            if (minute < minutes_288 * 1){   
               check_exit = true;
            }
         }else{ 
            if (period == 3){
               if (minute < minutes_288 * 2){   
                  check_exit = true;
               }
            }else{ 
               if (period == 4){
                  if (minute < minutes_288 * 3){   
                     check_exit = true;
                  }
               }else{ 
                  if (period == 5){
                     if (minute < minutes_288 * 4){   
                        check_exit = true;
                     }
                  }               
               }              
            }          
         }      
      }

      if (check_exit){ 
         begin_minutes_288 = i-1;         
      }else{
         i++;
      }
      
   }
   
   check_exit = false;
   i = shift;
   end_minutes_288 = shift;
   while (!check_exit && i > 0){            
      minute = TimeHour(Time[i]) * 60 + TimeMinute(Time[i]);  

      if (period == 1){
         if (minute >= minutes_288){   
            check_exit = true;
         }           
      }else{
         if (period == 2){
            if (minute >= minutes_288*2){   
               check_exit = true;
            }           
         }else{
            if (period == 3){
               if (minute >= minutes_288*3){   
                  check_exit = true;
               }           
            }else{
               if (period == 4){
                  if (minute >= minutes_288*4){   
                     check_exit = true;
                  }           
               }else{
                  if (period == 5){
                     if (minute >= minutes_288 * 5 && minute < minutes_288){   
                        check_exit = true;
                        if (minute < minutes_288) i++;
                     }           
                  }            
               }              
            }          
         }      
      }
      
      if (check_exit){ 
         end_minutes_288 = i;         
      }else{
         i--;
      }
   }     
   return(period); 
}

int PeriodCalc(){
   if (Period() == PERIOD_MN1){
      return(PERIOD_SIXFOLD);
   }else{
      if (Period() == PERIOD_W1){
         return(PERIOD_TWOFOLD);
      }else{         
         if (Period() == PERIOD_D1){
            return(PERIOD_MN1);
         }else{
            if (Period() == PERIOD_H4){
               return(PERIOD_W1);
            }else{
               if (Period() == PERIOD_H1){
                  return(PERIOD_D1);
               }else{
                  if (Period() == PERIOD_M15){
                       return(PERIOD_288);
                  }else{         
                     if (Period() == PERIOD_M5){
                       return(PERIOD_H1);                           
                     }else{
                        return(0);               
                     }
                  }
               }                
            }               
         }                
      }
   }  
}

int PeriodCalc_Compression(){
   if (Period() == PERIOD_MN1){
      return(PERIOD_TWOFOLD);
   }else{
      if (Period() == PERIOD_W1){
         return(PERIOD_MN1);
      }else{         
         if (Period() == PERIOD_D1){
            return(PERIOD_W1);
         }else{
            if (Period() == PERIOD_H4){
               return(PERIOD_D1);
            }else{
               if (Period() == PERIOD_H1){
                  return(0);
               }else{
                  if (Period() == PERIOD_M15){
                       return(0);
                  }else{         
                     if (Period() == PERIOD_M5){
                       return(0);                           
                     }else{
                        return(0);               
                     }
                  }
               }                
            }               
         }                
      }
   }  
}

string PeriodCalc_Info(){
   if (Period() == PERIOD_MN1){
      return("Six months chart");//Sixfold
   }else{
      if (Period() == PERIOD_W1){
         return("2.5 months chart");//Twofold
      }else{         
         if (Period() == PERIOD_D1){
            return("Monthly chart");
         }else{
            if (Period() == PERIOD_H4){
               return("Weekly chart");
            }else{
               if (Period() == PERIOD_H1){
                  return("Daily chart");
               }else{
                  if (Period() == PERIOD_M15){
                     return("288 minutes chart");
                  }else{                  
                     if (Period() == PERIOD_M5){
                        return("Hourly chart");
                     }else{                  
                        return("--");               
                     }            
                  }
               }                
            }               
         }                
      }
   }  
}

string PeriodCalc_Info_Compress(){
   if (Period() == PERIOD_MN1){
      return("--");
   }else{
      if (Period() == PERIOD_W1){
         return("Monthly chart");
      }else{         
         if (Period() == PERIOD_D1){
            return("Weekly chart");
         }else{
            if (Period() == PERIOD_H4){
               return("Daily chart");
            }else{
               if (Period() == PERIOD_H1){
                  return("--");
               }else{
                  if (Period() == PERIOD_M15){
                     return("--");
                  }else{                  
                     if (Period() == PERIOD_M5){
                        return("--");
                     }else{                  
                        return("--");               
                     }            
                  }
               }                
            }               
         }                
      }
   }  
}

int PeriodCalcHighTime(){
   if (Period() == PERIOD_MN1){
      return(0);
   }else{
      if (Period() == PERIOD_W1){
         return(0);
      }else{         
         if (Period() == PERIOD_D1){
            return(PERIOD_SIXFOLD);
         }else{
            if (Period() == PERIOD_H4){
               return(PERIOD_MN1);
            }else{
               if (Period() == PERIOD_H1){
                  return(PERIOD_W1);
               }else{
                  if (Period() == PERIOD_M15){
                       return(PERIOD_D1);
                  }else{                  
                     return(0);               
                  }
               }                
            }               
         }                
      }
   }  
}

string PeriodCalcHighTime_Info(){
   if (Period() == PERIOD_MN1){
      return("");
   }else{
      if (Period() == PERIOD_W1){
         return("");
      }else{         
         if (Period() == PERIOD_D1){
            return("Six months chart");
         }else{
            if (Period() == PERIOD_H4){
               return("Monthly chart");
            }else{
               if (Period() == PERIOD_H1){
                  return("Weekly chart");
               }else{
                  if (Period() == PERIOD_M15){
                       return("Daily chart");
                  }else{                  
                     return("--");               
                  }
               }                
            }               
         }                
      }
   }  
}

int check_begin_position(int p1, int period_calc){
   switch (PeriodCalc()){
   
      case 288: {
         if (Get288Minutes(p1) == Get288Minutes(p1-1)&& p1 != 0){
            return(p1+1);   
         }        
      }
   
      case PERIOD_D1: {
         if (TimeDay(Time[p1]) != TimeDay(Time[p1-1])&& p1 != 0){
            return(p1-1);   
         }
      }

      case PERIOD_W1: {
         
         if (TimeDayOfWeek(Time[p1]) != TimeDayOfWeek(Time[p1-1])&& p1 != 0){
            
            return(p1-1);   
            
         }
      } 
      
      case PERIOD_MN1: {
         
         if (TimeMonth(Time[p1]) != TimeMonth(Time[p1-1]) && p1 != 0){
            
            return(p1-1);   
            
         }
      }      
   }
   return(p1);
}

