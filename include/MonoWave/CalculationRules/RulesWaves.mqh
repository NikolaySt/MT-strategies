
//const Fibo Level----------
double fibo_38 = 0.382;
double fibo_61 = 0.618;
double fibo_100 = 1;
double fibo_161 = 1.618;
double fibo_261 = 2.618;
//--------------------------

double range = 0.04; //4% допустимо отклонение.
/*
string StructorListIntRule (int rule_type,  string condition_4 = ""){
   switch (rule_type){
      case 1: return("{:5/(:c3)/(x:c3)/[:sL3]/[:s5]}");
      case 2: return("{:5/(:sL3)/[:c3]/[:s5]}");
      case 3: return("{:F3/:c3/:s5/:5/(:sL3/[:L5]}");
      case 4: {
         
         if (condition_4 == "a") return("{:F3/:c3/:s5/[:sL3]}");
         if (condition_4 == "b") return("{:F3/:c3/:s5/(:sL3)/(x:c3)/[:L5]}");
         if (condition_4 == "c") return("{:c3/(:F3)/(x:c3)}"); 
         if (condition_4 == "d") return("{:F3/(:c3)/(x:c3)}");
         if (condition_4 == "e") return("{:F3/(x:c3)/[:c3]}");
      }  
      case 5: return("{:F3/:c3/:5/:L5/(:L3)}");
      case 6: return("{вс.}");
      case 7: return("{вс.}");
   }
}
*/

int Rules_Base(double m1, double m2){
   double attitude  = m2/m1;
   if (attitude > 0  && attitude < fibo_38){
      return(1);   
   }else{
      if (attitude >= fibo_38  && attitude < fibo_61){
         return(2);         
      }else{
         if (attitude == fibo_61){
            return(3);         
         }else{
            if (attitude > fibo_61  && attitude < fibo_100){
               return(4);         
            }else{
               if (attitude >= fibo_100 && attitude < fibo_161){
                  return(5);         
               }else{
                  if (attitude >= fibo_161  && attitude <= fibo_261){
                     return(6);         
                  }else{
                     if (attitude > fibo_261){
                        return(7);         
                     }           
                  }           
               }           
            }         
         }
      }
   }
}

bool RuleFind_4(double m1, double m2){
   double attitude  = m2/m1;
   if (attitude > fibo_61 - range  && attitude < fibo_100 + range){
      return(true);
   }else{
      return(false);
   }
}


string Condition_1(double m0, double m1){
   double attitude  = m0/m1;
   if (attitude > 0  && attitude < fibo_61){
      return("a");   
   }else{
      if (attitude >= fibo_61  && attitude < fibo_100){
         return("b");         
      }else{
         if (attitude >= fibo_100 && attitude <= fibo_161){
            return("c");         
         }else{
            if (attitude > fibo_161){
               return("d");         
            }         
         }
      }
   }
}     

string Condition_2(double m0, double m1){
   double attitude  = m0/m1;
   if (attitude > 0  && attitude < fibo_38){
      return("a");   
   }else{
      if (attitude >= fibo_38  && attitude < fibo_61){
         return("b");         
      }else{
         if (attitude >= fibo_61 && attitude < fibo_100){
            return("c");         
         }else{
            if (attitude >= fibo_100  && attitude <= fibo_161){
               return("d");         
            }else{
               if (attitude > fibo_161){
                  return("e");         
               }           
            }         
         }
      }
   }
}  

string Condition_3(double m0, double m1){
   double attitude  = m0/m1;
   if (attitude > 0  && attitude < fibo_38){
      return("a");   
   }else{
      if (attitude >= fibo_38  && attitude < fibo_61){
         return("b");         
      }else{
         if (attitude >= fibo_61 && attitude < fibo_100){
            return("c");         
         }else{
            if (attitude >= fibo_100  && attitude < fibo_161){
               return("d");         
            }else{
               if (attitude >= fibo_161  && attitude <= fibo_261){
                  return("e");         
               }else{
                  if (attitude > fibo_261){
                     return("f");                  
                  }
               }           
            }         
         }
      }
   }
} 

string Condition_4(double m0, double m1, double m2, double m3, string& categoria){
   double attitude  = m0/m1;
   double attitude_3_2  = m3/m2;
   
   if (attitude > 0 && attitude < fibo_38){
      //-----------------categoria-----------------------------
      if (attitude_3_2 >= fibo_100 && attitude_3_2 < fibo_161){ 
         categoria = "i";
      }else{
         if (attitude_3_2 >= fibo_161 && attitude_3_2 <= fibo_261){ 
            categoria = "ii";         
         }else{
            categoria = "iii";  
         }
      }
      //-------------------------------------------------------
      if (attitude_3_2 == 0) { categoria = ""; }
      return("a");   
      
   }else{
      if (attitude >= fibo_38  && attitude < fibo_100){

         //-----------------categoria-----------------------------
         if (attitude_3_2 >= fibo_100 && attitude_3_2 < fibo_161){ 
            categoria = "i";
         }else{
            if (attitude_3_2 >= fibo_161 && attitude_3_2 <= fibo_261){ 
               categoria = "ii";         
            }else{
               categoria = "iii";  
            }
         }
         //-------------------------------------------------------
         if (attitude_3_2 == 0) { categoria = ""; }
         return("b");         
      }else{
         if (attitude >= fibo_100 && attitude < fibo_161){
            //-----------------categoria-----------------------------
            if (attitude_3_2 >= fibo_100 && attitude_3_2 < fibo_161){ 
               categoria = "i";
            }else{
               if (attitude_3_2 >= fibo_161 && attitude_3_2 <= fibo_261){ 
                  categoria = "ii";         
               }else{
                  categoria = "iii";  
               }
            }
            //-------------------------------------------------------
            if (attitude_3_2 == 0) { categoria = ""; }
            return("c");            
         }else{
            if (attitude >= fibo_161  && attitude <= fibo_261){
            
               //-----------------categoria-----------------------------
               if (attitude_3_2 >= fibo_100 && attitude_3_2 <= fibo_261){ 
                  categoria = "i,ii";
               }else{                  
                  categoria = "iii";  
               }
               //-------------------------------------------------------
               if (attitude_3_2 == 0) { categoria = ""; }
               return("d");         
            }else{
               if (attitude > fibo_261){
                  //-----------------categoria-----------------------------
                  if (attitude_3_2 >= fibo_100 && attitude_3_2 <= fibo_261){ 
                     categoria = "i,ii";
                  }else{                  
                     categoria = "iii";  
                  }
                  //-------------------------------------------------------
                  if (attitude_3_2 == 0) { categoria = ""; }
                  return("e");         
               }           
            }         
         }
      }
   }
} 

string Condition_567(double m0, double m1){
   double attitude  = m0/m1;
   if (attitude > 0  && attitude < fibo_100){
      return("a");   
   }else{
      if (attitude >= fibo_100  && attitude < fibo_161){
         return("b");         
      }else{
         if (attitude >= fibo_161 && attitude <= fibo_261){
            return("c");         
         }else{
            if (attitude > fibo_261){
               return("d");         
            }         
         }
      }
   }
} 

string Rules_Alt(int skip_rule, double m1, double m2){
   double attitude  = m2/m1;
   string rules_tmp = "";
   if (attitude > 0  && attitude < (fibo_38 + range) && !(skip_rule == 1)){
      rules_tmp = "1";   
   }
   
   if (attitude > (fibo_38 - range) && attitude < (fibo_61 + range) && !(skip_rule == 2)){
      rules_tmp = rules_tmp + "2";         
   }
   
   if (attitude >= (fibo_61 - range) && attitude <= (fibo_61 + range) && !(skip_rule == 3)){
      rules_tmp = rules_tmp + "3";         
   }
   
   if (attitude > (fibo_61 - range) && attitude < (fibo_100 + range) && !(skip_rule == 4)){
      rules_tmp = rules_tmp + "4";         
   }
   
   if (attitude >= (fibo_100 - range) && attitude < (fibo_161 + range) && !(skip_rule == 5)){
      rules_tmp = rules_tmp + "5";         
   }
   
   if (attitude >= (fibo_161 - range) && attitude <= (fibo_261 + range) && !(skip_rule == 6)){
      rules_tmp = rules_tmp + "6";         
   }
   
   if (attitude > (fibo_261 - range) && !(skip_rule == 7)){
      rules_tmp = rules_tmp + "7";         
   }     
   return(rules_tmp);
}

string Condition_1_Alt(double m0, double m1){
   double attitude  = m0/m1;
   string cond = "";
   if (attitude > 0  && attitude < fibo_61 + range){
      cond = "a";   
   }
   if (attitude >= fibo_61 - range && attitude < fibo_100 + range){
      cond = cond + "b";         
   }
   if (attitude >= fibo_100 - range && attitude <= fibo_161 + range){
      cond = cond + "c";         
   }
   if (attitude > fibo_161 - range){
      cond = cond + "d";         
   }  
   return(cond);       
}     

string Condition_2_Alt(double m0, double m1){
   double attitude  = m0/m1;
   string cond = "";   
   if (attitude > 0  && attitude < fibo_38 + range){
      cond = cond + "a";
   }
   if (attitude >= fibo_38 - range && attitude < fibo_61 + range){
      cond = cond + "b";
   }
   if (attitude >= fibo_61 - range && attitude < fibo_100 + range){
      cond = cond + "c";         
   }
   if (attitude >= fibo_100 - range && attitude <= fibo_161 + range){
      cond = cond + "d";         
   }
   if (attitude > fibo_161 - range){
      cond = cond + "e";         
   }        
   return(cond);      
}  

string Condition_3_Alt(double m0, double m1){   
   double attitude  = m0/m1;
   string cond = "";
   if (attitude > 0  && attitude < fibo_38 + range){
      cond = cond + "a";   
   }
   if (attitude >= fibo_38 - range && attitude < fibo_61 + range){
      cond = cond + "b";         
   }
   if (attitude >= fibo_61 - range && attitude < fibo_100 + range){
      cond = cond + "c";         
   }
   if (attitude >= fibo_100 - range && attitude < fibo_161 + range){
      cond = cond + "d";         
   }
   if (attitude >= fibo_161 - range && attitude <= fibo_261 + range){
      cond = cond + "e";         
   }
   if (attitude > fibo_261 - range){
      cond = cond + "f";                  
   }
   return(cond);
} 


string Condition_4_Alt(double m0, double m1, double m2, double m3){
   double attitude  = m0/m1;
   double attitude_3_2  = m3/m2;
   string categoria = "";
   string cond = "";
   if (attitude > 0 && attitude < fibo_38 + range){
      categoria = "";
      //-----------------categoria-----------------------------
      if (attitude_3_2 >= fibo_100 - range && attitude_3_2 < fibo_161 + range){ 
         categoria = "i";
      }
      if (attitude_3_2 >= fibo_161 - range && attitude_3_2 <= fibo_261 + range){ 
         if (categoria != "") categoria = categoria + "-";
         categoria = categoria + "ii";   
      }      
      if (attitude_3_2 > fibo_261 - range){      
         if (categoria != "") categoria = categoria + "-";
         categoria = categoria + "iii";  
      }
      //-------------------------------------------------------
      if (attitude_3_2 == 0) { categoria = ""; }
      if (cond != "") cond = cond + "*";
      cond = "a-" + categoria;         
   }
   
   if (attitude >= fibo_38 - range && attitude < fibo_100 + range){
      categoria = "";
      //-----------------categoria-----------------------------
      if (attitude_3_2 >= fibo_100 - range && attitude_3_2 < fibo_161 + range){ 
         categoria = "i";
      }
      if (attitude_3_2 >= fibo_161 - range && attitude_3_2 <= fibo_261 + range){ 
         if (categoria != "") categoria = categoria + "-";
         categoria = categoria + "ii";         
      }     
      if (attitude_3_2 > fibo_261 - range){      
         if (categoria != "") categoria = categoria + "-";
         categoria = categoria + "iii";  
      }
      //-------------------------------------------------------           
      if (attitude_3_2 == 0) { categoria = ""; }
      if (cond != "") cond = cond + "*";
      cond = cond + "b-" + categoria;               
   }
   
   if (attitude >= fibo_100 - range && attitude < fibo_161 + range){         
      categoria = "";
      //-----------------categoria-----------------------------
      if (attitude_3_2 >= fibo_100 - range && attitude_3_2 < fibo_161 + range){ 
         categoria = "i";
      }
      if (attitude_3_2 >= fibo_161 - range && attitude_3_2 <= fibo_261 + range){ 
         if (categoria != "") categoria = categoria + "-";
            categoria = categoria + "ii";         
      }     
      if (attitude_3_2 > fibo_261 - range){  
           if (categoria != "") categoria = categoria + "-";  
            categoria = categoria + "iii";  
      }
      //-------------------------------------------------------
      if (attitude_3_2 == 0) { categoria = ""; }
      if (cond != "") cond = cond + "*";
      cond = cond + "c-" + categoria;          
   }            
   if (attitude >= fibo_161 - range && attitude <= fibo_261 + range){               
      categoria = "";
      //-----------------categoria-----------------------------
      if (attitude_3_2 >= fibo_100 - range && attitude_3_2 <= fibo_261 + range){ 
         categoria = "i,ii";
      }         
      if (attitude_3_2 > fibo_261 - range){
            if (categoria != "") categoria = categoria + "-";      
            categoria = categoria + "iii";  
      }
      //-------------------------------------------------------
      
      if (attitude_3_2 == 0) { categoria = ""; }
      if (cond != "") cond = cond + "*";
      cond = cond + "d-" + categoria;         
   }               
   if (attitude > fibo_261 - range){  
      categoria = "";          
      //-----------------categoria-----------------------------
      if (attitude_3_2 >= fibo_100 - range && attitude_3_2 <= fibo_261 + range){ 
         categoria = "i,ii";
      }         
      if (attitude_3_2 > fibo_261 - range){  
            if (categoria != "") categoria = categoria + "-";
            categoria = categoria + "iii";  
      }
      //-------------------------------------------------------
      if (attitude_3_2 == 0) { categoria = ""; }
      if (cond != "") cond = cond + "*";
      cond = cond + "e-" + categoria;        
   }   
   return( cond );
} 

string Condition_567_Alt(double m0, double m1){
   double attitude  = m0/m1;
   string cond = "";      
   if (attitude > 0 && attitude < fibo_100 + range){
      cond = cond + "a";   
   }
   if (attitude >= fibo_100 - range && attitude < fibo_161 + range){
      cond = cond + "b";         
   }
   if (attitude >= fibo_161 - range && attitude <= fibo_261 + range){
      cond = cond + "c";         
   }
   if (attitude > fibo_261 - range){
      cond = cond + "d";         
   }
   return(cond);         

} 

