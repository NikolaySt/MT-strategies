
int Rule_5_a(){
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//??????? ???: ????????? ?? m0 e ??-????? ?? 100% ?? ????????? ?? m1
////////////////////////////////////////////////////////////////////////////////////////////////////////////  
   if (WavesCountInDirection(2) > 3){
   //**(??? m2 ?? ?????? ?? ?????? ?? ??? ????????? [??? ????? ?????????] )
      InfoParagraph = "5-a-i:1";
      Rule_5_a_i_paragraph_1();
      InfoParagraph = "5-a-i:2";
      Rule_5_a_i_paragraph_2();
   }else{
   //**(??? m2 ?? ?????? ?? ?? ?????? ?? ??? ????????? [??? ????? ?????????] )
      InfoParagraph = "5-a-ii:1";
      Rule_5_a_ii_paragraph_1();
      InfoParagraph = "5-a-ii:2";
      Rule_5_a_ii_paragraph_2();
      InfoParagraph = "5-a-ii:3";
      Rule_5_a_ii_paragraph_3();
      InfoParagraph = "5-a-ii:4";
      Rule_5_a_ii_paragraph_4();
      InfoParagraph = "5-a-ii:5";
      Rule_5_a_ii_paragraph_5();
      InfoParagraph = "5-a-ii:6";
      Rule_5_a_ii_paragraph_6();
      InfoParagraph = "5-a-ii:7";
      Rule_5_a_ii_paragraph_7();
      InfoParagraph = "5-a-ii:8";
      Rule_5_a_ii_paragraph_8();
      InfoParagraph = "5-a-ii:9";
      Rule_5_a_ii_paragraph_9();
      InfoParagraph = "5-a-ii:10";
      Rule_5_a_ii_paragraph_10();
      InfoParagraph = "5-a-ii:11";
      Rule_5_a_ii_paragraph_11();
      InfoParagraph = "5-a-ii:12";
      Rule_5_a_ii_paragraph_12();
      InfoParagraph = "5-a-ii:13";
      Rule_5_a_ii_paragraph_13();
   }      
}

//----------------------------------------------------------------------------------------------------------
//**(??? m2 ?? ?????? ?? ?????? ?? ??? ????????? [??? ????? ?????????] )
//----------------------------------------------------------------------------------------------------------

int Rule_5_a_i_paragraph_1(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ?? ??????? ??? ????????? ?? m2 ? ?? ?????? ?? 61.8% ?? ????????? ?? m1, 
?? ???? ?? ???????? ?????? ???????? ?? ??????? ??? ??????? ?? ???? ????????? (???? m1), 
??????????? ?????????????? ?? m1 ? ?????????????? ?-?????, 
??? m1 ??????? ? ??????? ?????????? ?-?????  ??? ?????????? b-????? , 
??? m1 ???????????? ????? ????? ?? ???????? ?????? ?????? (???????? ??? ?????????? ??????) ? ????????? ????; 
? ???? ?? m1 ????????? ??????????? ?:5/:s5?. 
??? ????????? ?? ??????? ??? ????????? ???? m1 ? ??????? 25% ?? ????????? ?? m1, 
???????? ??? ??????? ???????? ??????????? ?:F3?. 
?????????: ???????????? ???????? ?? ?????????? ?-?????, 
????????? ?????? ? ??????? ?? m1 ? ?? ???? ? ????? ?:5??, ? ??????? ???????? ??:?3??. 
?????????? ???????? ? ?????????? b-?????, 
????????? ?????? ? ??????? ?? m1 ? ?? ???? ? ???? ???????? ?5?? ? ??????? ?b:F3??. 
? ?????????? ?????? ????? ?? ????????? ?????? ???????? ?? ???? ?????????? ??????? ????? ??????? ???????? ?? ?????? 
(? ??????????? ?????????????? ?? m1), ? ????????? ?????? ?? 61.8% ?? m1.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
   
   double ratio_p = CompareLengthWithCountWaves(1, 2, /*countwave*/3);
   if (Small_061(ratio_p)){
      AddDesignation(desig_5, "");
      AddDesignation(desig_s5, "");
      if (Large_025(ratio_p)){
         AddDesignation(desig_F3, "");   
      }
      AddDesignation(desig_fall, "1");
   }
      
   return(0);
}

int Rule_5_a_i_paragraph_2(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ?? ??????? ??? ????????? ?? m2 ????????? 61.8% ????????? ?? m1, 
?? ???? ?? ???????? ??? ?-????? ?? ?????? ???????? ??? ?????? b-?????, 
??? ????? ????? ?? ???????? ?????? ?????? ? ????????? 5-??.; 
? ???? ?? m1 ????????? ??????????? ?:F3/:5? ???????? ???? ??? ???????????? ????????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////   
*/ 
   double ratio_p = CompareLengthWithCountWaves(1, 2, /*countwave*/3);
   if (Large_061(ratio_p)){
      AddDesignation(desig_F3, "");
      AddDesignation(desig_5, "");
   }
   
   return(0);
}


//----------------------------------------------------------------------------------------------------------
//**(??? m2 ?? ?????? ?? ?? ?????? ?? ??? ????????? [??? ????? ?????????] )
//----------------------------------------------------------------------------------------------------------

int Rule_5_a_ii_paragraph_1(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ?????, 
?? ??????????? ????????????????? ?? ??????? ?????????, 
? ???????? ???????? ?? m(-2) ? m0 ?? ?? ????????? ???? ? ????????, ? m2 ? ??-????? ?? m(-2), 
? ????????? ?/??? ????????????????? ?? m(-2) ? m0 ?????????? ?? ????????? ???? ?? ?????, 
? m(-1) ? ??-????? ?? m1 ? / ??? ?? m(-3), ?? m1 ???? ?? ???????? ?????? ?????? ???????? ??????; 
????????? ? ???? ?? m1 ??????????? ?:L5?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/            
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
      
      if (!OverlapDirection(-2, 0)){
      
         double ratio_p = ComparePriceDirection(2, -2);      
         if (Large_100(ratio_p)){         
         
            ratio_p = ComparePriceDirectionFull(-2, 0);
            double ratio_t = CompareTimeDirectionFull(-2, 0);
            if (!Equal_100(ratio_p) || !Equal_100(ratio_t)){
               
               ratio_p = ComparePriceDirection(-1, 1);   
               double ratio_p_1 = ComparePriceDirection(-1, -3);   
               if (Large_100(ratio_p) || Large_100(ratio_p_1)){
                  
                  AddDesignation(desig_L5, "");    
               }              
            }
         }
      }
   }    

   return(0);   
} 

int Rule_5_a_ii_paragraph_2(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ?????, 
?? ??????????? ????????????????? ?? ??????? ?????????,? m2 ? ??-????? ?? m(-2), ? m(-4) ? ??-????? ?? m(-3), 
?? m1 ???? ?? ? ???? ?? ?????? ??? ?????? ????????; ????????? ? ???? ?? m1 ?????????? ?:L5?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/            
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1); 
   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
      
      double ratio_p = ComparePriceDirection(2, -2);       
      if (Large_100(ratio_p)){
         
         ratio_p = ComparePriceDirection(-4, -3); 
         if (Large_100(ratio_p)){
            AddDesignation(desig_L5, ""); 
         }
         
      } 
   }
   return(0);   
} 

int Rule_5_a_ii_paragraph_3(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ?????, 
?? ??????????? ????????????????? ?? ??????? ?????????, m2 ? ??-????? ?? m(-2), ? m(-3) ? ??-????? ?? m(-2) ? ?? m(-4), 
?? ? m1  ???? ?? ??????? ?????????? ?????? ?????? ?? ?????,??????? ?? ???? ?? ?????? ????????, ?????? m(-2) ?? ???? ?-?????; 
????????? ? ???? ?? m1 ??????????? ?:L5?,? ? ???? ?? m(-2) ??????????? ??:?3??. 
??? ? ???? ???????? ?????????? ?? ????????? ?? m(-1) ? ??????? 161.8% ?? ????????? ?? m0 ?? ?? ???????? ????????? ????????, 
?? ????? ?????????? ?? ???? ??????. ??? ????????? ?? m(-1) ? ?? ??-????? ?? 100%, ?? ??-????? ?? 161.8% ?? ????????? ?? m0, 
??????????? ???????? ?? ? ??????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
      
      double ratio_p = ComparePriceDirection(2, -2);       
      if (Large_100(ratio_p)){
      
         ratio_p = ComparePriceDirection(-3, -2);       
         if (Large_100(ratio_p)){

            ratio_p = ComparePriceDirection(-3, -4);       
            if (Large_100(ratio_p)){
            
               AddDesignation(desig_L5, "");
               AddDesignation(desig_xc3_, "-2");                                        
            }                   
         }          
      }      
   }
   return(0);    
} 
 

int Rule_5_a_ii_paragraph_4(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ?????, 
?? ??????????? ????????????????? ?? ??????? ?????????, ? m2 ? ??-?????? ?? m(-2), 
?? m1 ???? ?? ???? ???? ?? ?????? ??????? ??? ??????; ????????? ? ???? ?? m1 ??????????? ?:L5?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
      
      double ratio_p = ComparePriceDirection(2, -2);       
      if (Small_100(ratio_p)){

         AddDesignation(desig_L5, "");          
      } 
   }
   return(0);    
} 
 
int Rule_5_a_ii_paragraph_5(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ????? ????????????? ??????? ?? ??????? ?????????, 
? m(-2) ? ??-?????? ?? m(-1), ? m(-1) ?? ? ???-?????? ?? m(-3) ? m1,? ????????? ?? m3 ?? ????????? 61.8% ????????? ?? m2, 
? ????????? ???? ?? m(-3) ?? ??????? (??? ???????) ?? ????? ?? ?????? ?? 50% ?? ?????? ?? ???????? ?? m(-3) ?? ???? ?? m1, 
? ???????? ???? ?? m1 ?? ?? ??????? ?? ?????? ??????? ?????,  ?? ??????? ?????????, 
? ???????? ???????? ?? ????? ????? m2-m4 ? ??????? ??????? ????????? ??????????? ????????? m1, 
? ?:?3? ?? ????? ????? ?? ?????????? ??????????? ??????????? ?? ????? m(-1), 
?? m1 ???? ?? ???????? ?????????? ??????; ???????? ??? ??????? ?? m1 ??????????? ?:L3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
      
      double ratio_p = ComparePriceDirection(-2, -1);       
      if (Small_100(ratio_p)){
      
         if (NoSmallerDirection(-1, -3, 1)){
         
            ratio_p = ComparePriceDirection(3, 2);       
            if (Small_061(ratio_p)){ 
               
               if (CheckTimeGoToBeginning(-3, DirectionSumTimeLength(-3, 1)*0.6,  1)){
                  
                  
                  if (!CheckBreakLevelInTime(1, time_1*4, 1)){
                     
                     ratio_p = ComparePrice(DirectionSumPriceLength(2, 4), DirectionPriceLenght(1)); 
                     
                     if (Large_161(ratio_p)){
                        AddDesignation(desig_L3, "");    
                     }
                  }                                      
               }
            }
         }
      } 
   }
   return(0);    
}  

int Rule_5_a_ii_paragraph_6(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ????? ?? ??????????? ??????? ?? ??????? ?????????, 
? ????????? ?? m3 ?? ?????? ? ????????? 61.8% - 100% ?? ????????? ?? m1, 
?? m1 ???? ?? ???? ???? ?? ?????? ?????????? ?????????, ??? ???? ???????? ? ???? ??????????? ?:F3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
   
      double ratio_p = ComparePriceDirection(3, 1);       
      if (Large_061(ratio_p) && Small_100(ratio_p)){      
      
         AddDesignation(desig_F3, "");    
      }
   }
   return(0);    
}  

int Rule_5_a_ii_paragraph_7(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ????? ?? ??????????? ??????? ?? ??????? ?????????, 
? m3 ? ??-????? ?? m2, ? ????????? ?? m0 ? ??????? 161.8% ?? ????????? ?? m2, 
? ????????? ???? ?? m3 ?? ??????? ?? ?????, ?? ??????????? ????????????????? ?? m3, 
?? m1 ???? ?? ???? ???? ??  ?????????? ??????; ????????? ? ???? ?? m1 ??????????? ?:F3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break <= (time_1+1) && time_1_break > 0){  
   
      double ratio_p = ComparePriceDirection(3, 2);       
      if (Large_100(ratio_p)){      
         
         ratio_p = ComparePriceDirection(0, 2);       
         
         if (Large_161(ratio_p)){ 
            
            double time_3_break = TimeBreakDirection(3);
            double time_3 = TimeDirection(3);   
            if (time_3_break <= time_3 && time_3_break > 0){             
            
               AddDesignation(desig_F3, ""); 
                  
            }
            
         }
            
      }
   }
   return(0);    
}

int Rule_5_a_ii_paragraph_8(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 ?? ??????? ?? ?????, ??-?????? ?? ????????????????? ?? m1, 
? ????????? ?? m2 ?? ????????? 61.8% ?? ???????? ?????????? ????????? ?? ???????? ?? m(-1) ?? ???? ?? m1, 
? m3 ? ??-?????? ?? m2, ?? ? ???????? ?? ???????? ?????? ???????? ? ????? m1 ?? ???? ???-????????/??????? 
????? ?????????? ?? ?????? ?? ?????? ??? ????? 2-???? ????????????? ????? ?? m0-m2, 
????????? ? ???? ?? m1 ??????????? ?:F3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break > time_1 && time_1_break > 0){  
      
      double ratio_p = ComparePrice(DirectionPriceLenght(2), DirectionSumPriceLength(-1, 1));        
      if (Small_061(ratio_p)){      
                     
         ratio_p = ComparePriceDirection(3, 2);       
         if (Small_100(ratio_p)){
            AddDesignation(desig_F3, "");
         } 
            
      }
   }
   return(0);    
}

int Rule_5_a_ii_paragraph_9(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 ?? ?????? ?? ????? ??-?????? ?? ????????????????? ?? m1, m3 ? ??-????? ?? m2, 
? ?????????  ?? m2 ?? ????????? 61.8% ?? ???????? ?????????? ?????????? ?? ???????? ?? m(-1) ?? ???? ?? m1, 
?? ?????? ???? ?? ???????? ?????? ???????? (???? ?? ???? ?? ???????????? ???? ???? ?? ?? ??? m1, 
? m2 ?? ???? ?-?????) ??? ?????????? ??????????; ????????? ? ???? ?? m1 ????????????? ?:F3/:c3/:L5?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break > time_1 && time_1_break > 0){  
      
      double ratio_p = ComparePrice(DirectionPriceLenght(2), DirectionSumPriceLength(-1, 1));        
      if (Small_061(ratio_p)){      
                     
         ratio_p = ComparePriceDirection(3, 2);       
         if (Large_100(ratio_p)){
            AddDesignation(desig_F3, "");
            AddDesignation(desig_c3, "");
            AddDesignation(desig_L5, "");
         } 
            
      }
   }
   return(0);    
}

int Rule_5_a_ii_paragraph_10(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 ?? ??????? ?? ?????, ??-?????? ?? ????????????????? ?? m1, ? m2 ? ??-?????? ?? m(-2), 
?? m1 ???? ?? ????????? ??????, ?????? ? ??????? ?? ?????? ??????????; ????????? ? ???? ?? m1 ??????????? ?:L5?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break > time_1 && time_1_break > 0){          
                     
         double ratio_p = ComparePriceDirection(2, -2);       
         if (Small_100(ratio_p)){
            AddDesignation(desig_L5, "");
         } 
            

   }
   return(0);    
}

int Rule_5_a_ii_paragraph_11(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 ?? ??????? ?? ?????, ??-?????? ?? ????????????????? ?? m1, 
? ????????? ?? m(-1) ? ??????? 61.8% ?? ????????? ?? m1, ? m3 ? ??-?????? ?? m2, 
? ????????? ???? ?? m3 (???? ???? ??????? ?????) ?? ??????? ?? ????? ?? ??????????? ????????????????? ?? m3, 
?? m1 ???? ?? ???? ???? ?? ?????? ????????, ????????? ?? ?????? ?????? ??????, 
?????? ????????? ? ???? ?? m1 ??????????? ?:F3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
   double time_1_break = TimeBreakDirection(1);
   double time_1 = TimeDirection(1);   
   if (time_1_break > time_1 && time_1_break > 0){          
                     
         double ratio_p = ComparePriceDirection(-1, 1);       
         if (Large_061(ratio_p)){
         
            ratio_p = ComparePriceDirection(3, 2);       
            if (Small_100(ratio_p)){

               double time_3_break = TimeBreakDirection(3);
               double time_3 = TimeDirection(3);   
               if (time_3_break <= (time_3+1) && time_3_break > 0){             
            
                  AddDesignation(desig_F3, ""); 
                  
               }            
            
            }
         } 
            

   }
   return(0);    
}


int Rule_5_a_ii_paragraph_12(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? m3 ? ??-????? ?? m2, ? m4 ? ??-????? ?? m3, ? ????????? ?? m0 ? ??-????? ?? 61.8% ?? ????????? ?? m1, 
?? ????? m1 ???? ?? ? ?????? ?? ???????? ??????????; ????????? ? ???? ?? m1 ??????????? ?(:F3)?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
        
                     
   double ratio_p = ComparePriceDirection(3, 2);       
   if (Large_100(ratio_p)){
   
      ratio_p = ComparePriceDirection(4, 3);       
      if (Large_100(ratio_p)){
      
         ratio_p = ComparePriceDirection(0, 1);       
         if (Small_061(ratio_p)){                 
      
            AddDesignation(desig_F3, "()"); 
            
         }                  
      }
   } 

   return(0);    
}


int Rule_5_a_ii_paragraph_13(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? m3 ? ??-????? ?? m2, ? m4 ? ??-????? ?? m3,  ? ???????? ?? m0 ? ? ????????? 61.8% - 100% ?? ????????? ?? m1, 
?? ? ???????? ?? ?? ??????? ???????? ??????????; ????????? ? ???? ?? m1 ??????????? ?(:?3)?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/      
        
                     
   double ratio_p = ComparePriceDirection(3, 2);       
   if (Large_100(ratio_p)){
   
      ratio_p = ComparePriceDirection(4, 3);       
      if (Large_100(ratio_p)){
      
         ratio_p = ComparePriceDirection(0, 1);       
         if (Large_061(ratio_p) && Small_100(ratio_p)){                 
      
            AddDesignation(desig_c3, "()"); 
            
         }                  
      }
   } 

   return(0);    
}