

int Rule_2_b(){
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//??????? ?b?: ????????? ?? m0 ? ?? ??-????? ?? 38.2%, ?? ? ??-????? ?? 61.8% ??  ????????? ?? m1
////////////////////////////////////////////////////////////////////////////////////////////////////////////      

   InfoParagraph = "2-b:1";
   Rule_2_b_paragraph_1();

   InfoParagraph = "2-b:2";
   Rule_2_b_paragraph_2();

   InfoParagraph = "2-b:3";   
   Rule_2_b_paragraph_3();  

   InfoParagraph = "2-b:4";   
   Rule_2_b_paragraph_4();
   
   InfoParagraph = "2-b:5";
   Rule_2_b_paragraph_5();  
}


int Rule_2_b_paragraph_1(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
????????? ?:5? ? ???? ?? m1. ??? m4 ?? ????????? ???????? ???? ?? m0, 
? ???? ?? m1 ???? ?? ???????? ?????????? ?????? ??????-?????? ???????????, 
?????? m2 ? ?-?????; ????????? ??????????? ?:s5? ? ???? ?? m1 ? ??:?3?? ? ???? ?? m2. 
???????? ??????? ?? ???? ?? ?? ????????? ?? ????? ???????? ????????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
   AddDesignation(desig_5, "");
   if (CheckDirection(0) == -1){
      if (DirectionMinLevel(4) > DirectionEndPrice(0)){
         AddDesignation(desig_s5, "");
         AddDesignation(desig_xc3_, "2");
      } 
   }else{
      if (DirectionMaxLevel(4) < DirectionEndPrice(0)){
         AddDesignation(desig_s5, "");
         AddDesignation(desig_xc3_, "2");
      }        
   } 
   return(0);  
} 

int Rule_2_b_paragraph_2(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ? ??????? ?? m0 ??? ?????? ?? ??? ????????? ? m1 ??????? ????????? ???? ?? m0 
?? ????? ?? ??-?????? ?? ???????? ?? ?????????? ?? m0,  
?? ????? ??????????? ? ???? ?? m0 ???????? ????? ?????? ?????? ?? ?????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
   int time_m0_break = TimeBreakDirection(0);
   int time_m0 = TimeDirection(0);
   
   int count_wave = WavesCountInDirection(0);
   if (count_wave > 3 && time_m0_break <= time_m0 && time_m0_break > 0){
      AddDesignation(desig_note, "0");         
   }
   return(0);
} 

int Rule_2_b_paragraph_3(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ???????? ? ????????? ??????? ?? m0 ? m2 ?? ????? (??? ?? ??????? ? ?????????? 61.8%), 
? ????????? ?? ????a?a ???????????a m0 ? ?? ??-????? ?? 161.8% ?? ????????? ?? m1, 
? ????????? ?? ??????? m3 (??? ????? ?????) ???????? ??????? ??-?????? ?? ????????? ?? m(-1), 
?? ????? ?? ??????????? ???????????? ?? m(-1) , 
? ???????? ????????? ?? ???? ?? ?????????? ?? ???????? ????????; 
?????????? ???? ???? ???? ???????? ?[:?3]? ? ???? ?? m1 ?? ?????????? ???? ?:5?. 
?? ????? ?????????? ?????????? ???????? ???????? ?? ???????? ?? ????? m0 ? ???????? ? ???? ?? ????? m2. 
?????? ????????? ?? ?????????  ???????????? ???????????, ? ???????????? ? ??????????? ? ????? 4, 
?????????? ????? ???????? ???????? ????????, ?????? ?:?3? ???? ?? ???? ??? b-????? ?? ???????? ????????, 
??? ?-????? ?? ???????? ???????? - ?????? ??????. ?????????? ?? ??????? ???????????? ?? ???????????? ?????????????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
   double ratio_t = CompareTimeDirectionFull(0, 2);
   double ratio_p = ComparePriceDirectionFull(0, 2);  
   //debug------------------------------------------
   //ratio_p = 0.618;                
   //Print("OK-1 : ", ratio_p, " : " , ratio_t);  
   if ( (Equal_100(ratio_t) && Equal_100(ratio_p)) ||           
        (Equal_061(ratio_t) && Equal_100(ratio_p)) ||
        (Equal_100(ratio_t) && Equal_061(ratio_p)) ||
        (Equal_061(ratio_t) && Equal_061(ratio_p))  ) { 
      
      //debug------------------------------------------
      //Print("OK-2");
      
      ratio_p = ComparePriceDirection(-1, 1);
      if (Large_161(ratio_p)){
      
         //debug------------------------------------------
         //Print("OK-3");
         
         if ( CheckTimeGoToLength(-1, TimeDirection(-1), 2) ) {
            AddDesignation(desig_c3, "[]");
         }
      }
        
   }        
   return(0);
}

int Rule_2_b_paragraph_4(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ???????? ? ????????? ??????? ?? m0 ? m2 ?? ????????????? ????? ? m3  ? ??-????? ?? 161.8% ?? m1, 
? m4 ??????? ????????? ?????? ?? m3 (???? ???? ???????? ?????) ?? ?????, ??-????? ?? ????????????????? ?? m3, 
?? m1  ???? ?? ???? ???? ?? ?????? ????????????, ????????? ? ???? ?? ?-?????. 
??????????? ??? ???????? ???????? ?? ?????????????? ?? ?-??????? : ? ???? ?? m0,  
? ???? ?? m2 ??? ? ??????? ?? m1 (? ???? ?????? ??????? ?? ?????? ??? ??????????). 
?????? ???????? ???? ??? ???????? ????????? ??:?3?? ? ???? ?? m0, 
m2 ? ??? ???????????? ? ??????? ?? m1 (???? ????????? ??????). 
???????????? ?-??????? ?? ? ?????? ? ??????? ?? m1 ?? ???????? ?????????? 
?????? ????????? ?? m3 ? ??-????? ?? 61.8% ?? ????????? ?? m1. 
???? ?????????? ? ????? ??? ????????? ?? ??????? ? ????? 4 ? ?????????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
   double ratio_t = CompareTimeDirectionFull(0, 2);
   double ratio_p = ComparePriceDirectionFull(0, 2);                  
        
   if ( Equal_100(ratio_t) && Equal_100(ratio_p) ) { 
      
      ratio_p = ComparePriceDirection(3, 1);
      if (Small_161(ratio_p)){
         ratio_p = ComparePriceDirection(4, 3);
         double time3 = TimeDirection(3);
         double time_break_3 = TimeBreakDirection(3);
         if ( (time_break_3 <= (time3+1)) && time_break_3 > 0 && Large_100(ratio_p) ) {
            AddDesignation(desig_fall, "1");
            AddDesignation(desig_xc3_, "0");
            AddDesignation(desig_xc3_, "2");
         }
      }
        
   } 
   return(0);
}

int Rule_2_b_paragraph_5(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ???????? ???????? ?? m0 ? m2 ???????? ?? ???????????, ? ?????????????????? ?? m2  ? m0 ?? ??????? ? ?????????? 61.8%, 
? m1 ?? ? ??? ?????? ? ????????? ? m(-1) ? m3, ? ??????? ???? ????????? ?? m3 ?????? ????? ?? ????? ? ????????? ???? 
?? ????? m1, ???????? ? m1 ?? ?? ????? ???? ?? ?????????? ?????? ?????? 
? ?? ???? ?????????? ???? ???? ? ???????? ? ??????? ?:sL3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
   
   if (OverlapDirection(0, 2)){
      double ratio_t = CompareTimeDirectionFull(0, 2);
      if (Equal_061(ratio_t)){
         
         if (NoSmallerDirection(1, -1, 3)){
            
            double time = DirectionSumTimeLength(1, 3);
            
            if (CheckTimeGoToBeginning(1, time*0.6, 3)){
               AddDesignation(desig_sL3, "");   
            }
         }   
      }
   }
   return(0);
}


