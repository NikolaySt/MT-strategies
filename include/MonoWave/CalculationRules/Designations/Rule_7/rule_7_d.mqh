
int Rule_7_d(){
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//??????? ?d?: ????????? ?? m0 ? ??-?????? ?? 261.8% ?? ????????? m1
////////////////////////////////////////////////////////////////////////////////////////////////////////////  
   InfoParagraph = "7-d:1";
   Rule_7_d_paragraph_1();
   InfoParagraph = "7-d:2";
   Rule_7_d_paragraph_2();
   InfoParagraph = "7-d:3";
   Rule_7_d_paragraph_3();
   InfoParagraph = "7-d:4";
   Rule_7_d_paragraph_4();
   InfoParagraph = "7-d:5";
   Rule_7_d_paragraph_5();
   InfoParagraph = "7-d:6";
   Rule_7_d_paragraph_6();
   InfoParagraph = "7-d:7";
   Rule_7_d_paragraph_7();
   InfoParagraph = "7-d:8";
   Rule_7_d_paragraph_8();
   InfoParagraph = "7-d:All";
   Rule_7_all(); 
}

int Rule_7_d_paragraph_1(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????????????? ?? m0 (????? ???? ??????? ?????) ? ??-?????, ??? ????? ?? ????????????????? ?? m1, 
??? ????????????????? ?? m2 (????? ???? ??????? ?????) ? ??-?????, ??? ????? ?? ????????????????? ?? m1, 
? ????????????????? ?? m1 ? ?? ??-????? ?? ????????????????? ?? m0 ?/??? ?? m2, 
?? m1 ???? ?? ???? ???? ?? ?????? ??? ??????; ????????? ? ???? ?? m1 ??????????? ?:F3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   
   double time_0 = TimeDirection(0);      
   double time_2 = TimeDirection(2);      
   double time_1 = TimeDirection(1);      
   
   if ( (time_0-1) <= time_1 || (time_2-1) <= time_1 ){  

      if ( time_0  <= time_1 || time_2 <= time_1 ){  

         AddDesignation(desig_F3, ""); 
   
      }   
   
   }
   
   return(0);
}

int Rule_7_d_paragraph_2(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????????????? ?? m1 ?? ????????? ????????????????? ?? m0 ?/??? ?? m2, 
? ????????? ?? m(-2) ? ?? ??-????? ?? 161.8% ?? m(-1), ? m(-1) ? ??-?????? ?? m0, 
? ????????? ?? m1 ?? ??????? 61.8% ?? ???????????? ?? ???????? ?? m(-2) ?? ???? ?? m0, 
? ??? m3 ? ??-????? ?? m2, ????????? ???? m4 ? ??-?????? ?? m3, ? ?? ???????, 
?? ?? ??????????? ?? ???? ?? m2 ?????? ???????? ????????????, ??????????? 61.8% ?? ????????? ?? ??????? ????? m(-2) ? m2, 
? ??? ???? ? ???? ?? m1 ???? ?? ???? ?-?????  ?? ????? ?????? ??? ?????? ????????, ????????? ? ??????; 
????????? ? ???? m1 ??????????? ??:?3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   
   double time_0 = TimeDirection(0);      
   double time_2 = TimeDirection(2);      
   double time_1 = TimeDirection(1);      
   
   if ( time_1 <= time_0 || time_1 <= time_2 ){  
 
      double ratio_p = ComparePriceDirection(-2, -1);      
      if (Large_161(ratio_p)){   
         
         ratio_p = ComparePriceDirection(-1, 0);      
         if (Small_100(ratio_p)){   

            ratio_p = ComparePrice(DirectionPriceLenght(1), DirectionSumPriceLength(-2, 0));      
            if (Small_061(ratio_p)){   
         
               ratio_p = ComparePriceDirection(3, 2);      
               if (Large_100(ratio_p)){           
                  
                  ratio_p = ComparePriceDirection(4, 3);      
                  if (Small_100(ratio_p)){           
                     
                     double level1 = DirectionEndPrice(2) - DirectionSumPriceLength(-2, 2)*0.618;
                     double level2 = DirectionEndPrice(2);
                     if (CheckFirstBreakLevel(level1, level2, 4) == 1){
                        AddDesignation(desig_xc3, "");   
                     }
 
                  }                  
                  
               }
         
            }
         
         }
               
      }
   
   }

   return(0);
}

int Rule_7_d_paragraph_3(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????????????? ?? m1 ?? ????????? ????????????????? ?? m0 ??? ?? m2, 
? ????????? ?? m0 ? ? ????????? 100% - 161.8% ?? ????????? ?? m(-1), 
? ????????? ?? m2 ?? ????????? 161.8% ?? ????????? ?? m0, ? ????????? ?? m4 ? ??????? 38.2% ?? ????????? ?? m2, 
? ???? ???? m3 ? ??-????? ?? m2, ?? ?? ???????, ?? ????????? ?? m4 ? ??-????? ?? m3, ? ??? ???? ? ????, 
?? m1 ???? ?? ???? ?-?????  ?? ?????? ????????, ????????? ? ?????? ??? ????????? ? ?????? ??? ??????????; ?
???????? ? ???? ?? m1 ??????????? ??:?3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   

   double time_0 = TimeDirection(0);      
   double time_2 = TimeDirection(2);      
   double time_1 = TimeDirection(1);      
   
   if ( time_1 <= time_0 || time_1 <= time_2 ){
      
      
      double ratio_p = ComparePriceDirection(0, -1);            
      if (Large_100(ratio_p) && Small_161(ratio_p)){       
      
         ratio_p = ComparePriceDirection(2, 0);            
         if (Small_161(ratio_p)){       
         
            ratio_p = ComparePriceDirection(4, 2);            
            if (Large_038(ratio_p)){       
         
               ratio_p = ComparePriceDirection(3, 2);            
               if (Large_100(ratio_p)){       
                  
                  ratio_p = ComparePriceDirection(4, 3);            
                  if (Small_100(ratio_p)){    
                     
                     AddDesignation(desig_xc3, "");
         
                  }                    
         
               }           
         
            }           
         
         }               
      }
   }

   return(0);
}

int Rule_7_d_paragraph_4(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????????????? ?? m1 ? ??-????? ??? ????? ?? ????????????????? ?? ????? m0 ?/??? ?? m2, 
????????? ? ???? ?? m1 ??????????? ?:c3?. 

??? ????????? ?/??? ????????????????? ?? ????? m(-1) ? m1 ???????? ?? ?????  
(??? ?? ??????? ? ?????????? 61.8%) ? m(-1) ? ??-?????? ?? m0, ? ??? ????????? ????????? ?? ???????  m(-2), 
m0 ? m2 ????????? ?? m0 ?? ? ???-??????? ? ???????? ?? ???-??????? ?? ????????? 161.8% ?? ??????? ??-????????, 
?? m1 ???? ?? ???? ???? ?? ?????? ????? ?????? (? ???? ??? ??? ?-?????); ????????? ??? ???? ??????????? ?:?3?. 

??? ???? ?? ???-??????? ????? ?? ??????????? ??? ?? ? m0, ?????? ? ????????????  ?-????? ?? ?? ?????? ????? ?? ???? ?? m1, 
?? ? ??????, ?? ??? ? ????? ??????????? ? ???? ?? m1, ?-????? ???? ?? ?? ?????? ? ???? ?? m(-1) ? m(-3). 

??? ???-??????? ????? ?? ???? ??? ?? ????? m0, ?-????? ???? ?? ? ?????????? ? ??????? ?? m0; 
? ???? ?????? ????????? ? ??????? ?? m0 ????? ? ??????? ???????? ?:?3?, ? ?????? 
?:s5?; ? ???? ???????? ???????? ?????? ?? ????? ?????? ?? ??????? ? ???????? ?? m(-2) ? ?? ???????? ? ???? ?? m2. 

??? ??????? ????? m(-2) ? m2 ? ?????? ???????? ? ?????????? ?-?????, 
?? ?? ???????? ?? ?????????? ????? ????? (?? ?????? ???????? ??????? ? ???????? ????????) 
?????? ?????? ?? ?????? 61.8%-100% ?? ????????? ?? ???????? ????????, 
????? ?????????? ????? ????? ?? ?????? ???????? ??????? ? ???????? ????????. 

??? ??????? ???? ?-?????, ????? ? ?? ???????? ???????? ?? ??????? 61.8% ?? ????????? ?, 
? ???? ???? ???? ?? ???????? ???????? ?? ???????, ?? ??? ??????? ????? m(-2)-m2 
?? ???????? ?????? ?????? (????? ???? ?? ?????? ????????), ??? ???????? ???????? ? ???? ?? ?????????? ??????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   

   //?? ? ?????????!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   double time_0 = TimeDirection(0);      
   double time_2 = TimeDirection(2);      
   double time_1 = TimeDirection(1);      
   
   if ( time_1 <= time_0 || time_1 <= time_2 ){
      
      
      double ratio_p = ComparePriceDirection(-1, 1);      
      double ratio_t = CompareTimeDirection(-1, 1);  
      //??? ????????? ?/??? ????????????????? ?? ????? m(-1) ? m1 ???????? ?? ?????  
      //(??? ?? ??????? ? ?????????? 61.8%) ? m(-1) ? ??-?????? ?? m0, ? ??? ????????? ????????? ?? ???????  m(-2), 
      //m0 ? m2 ????????? ?? m0 ?? ? ???-??????? ? ???????? ?? ???-??????? ?? ????????? 161.8% ?? ??????? ??-????????, 
      //?? m1 ???? ?? ???? ???? ?? ?????? ????? ?????? (? ???? ??? ??? ?-?????); ????????? ??? ???? ??????????? ?:?3?.          
      if (
         (Equal_100(ratio_p) || Equal_061(ratio_p)) ||
         (Equal_100(ratio_t) || Equal_061(ratio_t))){
         
         ratio_p = ComparePriceDirection(-1, 0);            
         if (Small_100(ratio_p)){  
         
            if (NoSmallerDirection(0, -2, 2)){
              
               ratio_p = ComparePriceDirection(LargestDirection(-2, 0, 2), SeccondLargestDirection(-2, 0, 2));
               if (Small_161(ratio_p)){
                  
                  if (LargestDirection(-2, 0, 2) != 0){
                     //??? ???? ?? ???-??????? ????? ?? ??????????? ??? ?? ? m0, 
                     //?????? ? ???????????? ?-????? ?? ?? ?????? ????? ?? ???? ?? m1, 
                     //?? ? ??????, ?? ??? ? ????? ??????????? ? ???? ?? m1, 
                     //?-????? ???? ?? ?? ?????? ? ???? ?? m(-1) ? m(-3). 
                     if (CountArrayDesignations() > 0){
                        AddDesignation(desig_xc3_, "-1");   
                        AddDesignation(desig_xc3_, "-3");   
                     }else{
                        AddDesignation(desig_xc3, "");   
                     }
                  }else{
                     //??? ???-??????? ????? ?? ???? ??? ?? ????? m0, ?-????? ???? ?? ? ?????????? ? ??????? ?? m0; 
                     //? ???? ?????? ????????? ? ??????? ?? m0 ????? ? ??????? ???????? ?:?3?, ? ?????? 
                     //?:s5?; ? ???? ???????? ???????? ?????? ?? ????? ?????? ?? ??????? ? ???????? ?? m(-2) 
                     //? ?? ???????? ? ???? ?? m2.                   
                     AddDesignation(desig_fall, "0");    
                  }                                     
               }else{
                  AddDesignation(desig_c3, "");
               }                                
            }else{
               AddDesignation(desig_c3, "");
            }               
         }else{
            AddDesignation(desig_c3, "");
         }
      }else{
         AddDesignation(desig_c3, "");
      }       
   }
 
   return(0);
}

int Rule_7_d_paragraph_5(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? ?? m1 (???? ???? ??????? ?????) ?? ??????? ?? ????? ?? ??????????? ??????? ?? ??????? ?????????,
? ????????? ? ????????????????? ?? m(-1) ? m1 ?? ????? (??? ?? ??????? ? ?????????? 61.8%), 
? ????????? ?? m2 ? ?? ?? ????? ?? 161.8% ?? ????????? ?? m0, ? ??????? m1 ? m(-1) ?? ?? ?????????, 
? m2  ?? ?? ???????? ?? ?????, ??-????? ?? ??????? ??????????????, 
?? m1 ???? ?? ???????? ???????? ????????; ????????? ? ???? ?? m1 ??????????? ?:L5?. 
??? ????????? ?? m(-2) ?? ??????? 161.8% ?? ????????? ?? m0, ? ????????? ?? m3 ? ??-????? ?? 61.8% ?? ????????? ?? m2, 
? ? ???????????????? ?? m1 ??? ??????????? ?:L5?, ?? ? m1 ???????? ?????? ?? ???? ?????? ?????? ?? ?????.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   


   if (BreakBeginingLevel(1, /*(???? ???? ??????? ?????)*/1)){             
      
      double ratio_p = ComparePriceDirection(-1, 1);      
      double ratio_t = CompareTimeDirection(-1, 1);           
      if (
         (Equal_100(ratio_p) || Equal_061(ratio_p)) ||
         (Equal_100(ratio_t) || Equal_061(ratio_t))){      
         
         ratio_p = ComparePriceDirection(2, 0);      
         if (Large_161(ratio_p)){            
         
            if (!OverlapDirection(-1, 1)){
               double time2 = TimeDirection(2);
               double time3 = TimeDirection(3);
               if (time3 >= time2){
                  AddDesignation(desig_L5, "");   
                  
                  //??? ????????? ?? m(-2) ?? ??????? 161.8% ?? ????????? ?? m0, 
                  //? ????????? ?? m3 ? ??-????? ?? 61.8% ?? ????????? ?? m2, 
                  //? ? ???????????????? ?? m1 ??? ??????????? ?:L5?, 
                  //?? ? m1 ???????? ?????? ?? ???? ?????? ?????? ?? ?????.
                  ratio_p = ComparePriceDirection(-2, 0);      
                  if (Small_161(ratio_p)){
                     
                     ratio_p = ComparePriceDirection(3, 2);      
                     if (Small_061(ratio_p)){
                        AddDesignation(desig_many_model, "");   
                     }                      
                     
                  }  
                  
               }
            }
         }         
      }      
   }      
   return(0);
}

int Rule_7_d_paragraph_6(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ?? m3 ? ??-????? ?? 61.8% ?? ????????? ?? m2, ? ????? m2 ? ??-????? ? ??????? (??????????) ?? ????? m0, 
? ????????? ?? m(-1) ?? ????????? 161.8% ?? ????????? ?? m0, ? ???????? ???????? ?? ????? m(-1) ? m1 ?? ?????????, 
m0 ??????? ? ???? ?????? ??????????? ?:3? (?????? ?? ?????????? ??? ???????? ?? ???????? ???), ??? ?? ?????? ?????????? , 
? m1 ?? ???????? ?????? ??????????; ????????? ? ???? ?? m1 ??????????? ?(:L3)?. 
??? ????????? ?/??? ????????????????? ?? m(-1) ? m1 ?? ????? (??? ?? ??????? ? ?????????? 61.8%) 
? ??????? m(-1) ? m1 ?? ?????????, ?? m1 ???? ?? ???????? ?????? ?????????? ??? ?????? ? ????????? ?; 
????????? ? ???? ?? m1 ??????????? ?:L5?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   

   double ratio_p = ComparePriceDirection(3, 2);      
   if (Small_061(ratio_p)){  
      //m2 ? ??-????? ? ??????? (??????????) ?? ????? m0
      if (CheckTimeGoToLength(0, TimeDirection(0), 1)){
        
         ratio_p = ComparePriceDirection(-1, 0);      
         if (Small_161(ratio_p)){          
            
            if (OverlapDirection(-1, 1)){ 
               //???? ??????? ?????? -> m0 ??????? ? ???? ?????? ??????????? ?:3?                   
               AddDesignation(desig_L3, "()");   
               //??? ????????? ?/??? ????????????????? ?? m(-1) ? m1 ?? ????? (??? ?? ??????? ? ?????????? 61.8%)   
               //? ??????? m(-1) ? m1 ?? ?????????, ?? m1 ???? ?? ???????? ?????? ?????????? ??? ?????? ? ????????? ?; 
               //????????? ? ???? ?? m1 ??????????? ?:L5?.
               ratio_p = ComparePriceDirection(-1, 1);      
               double ratio_t = CompareTimeDirection(-1, 1);           
               if (
                  (Equal_100(ratio_p) || Equal_061(ratio_p)) ||
                  (Equal_100(ratio_t) || Equal_061(ratio_t))){                
                 
                  AddDesignation(desig_L5, "");  
               }                  
            }
            
         }
            
      }
   }
   

   return(0);
}

int Rule_7_d_paragraph_7(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ?? m3 ? ??-????? ?? 61.8% ?? ????????? ?? m2 
? ????????? ?? m2 ? ? ????????? ?? 61.8%?161.8% ?? ????????? ?? m0, 
? m(-1) ? ??-?????? ?? m0, ///? ????????? ?? m(-1) ? ?? ?????? ?? 161.8% ?? ????????? ?? m0,// 
?? m1 ???? ?? ???? ?-????? ?? ?????? ????????; ?????? ?? ????????? ????? 
? ????? m1 ???????? ? ??????? ?????? ??????????? ??:?3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   

   double ratio_p = ComparePriceDirection(3, 2);      
   if (Small_061(ratio_p)){  
   
      ratio_p = ComparePriceDirection(2, 0);      
      if (Large_061(ratio_p) && Small_161(ratio_p)){ 
         
         ratio_p = ComparePriceDirection(-1, 0);      
         if (Small_100(ratio_p)){// || Small_161(ratio_p)){           
            AddDesignation(desig_xc3, "");   
         }         
      }
   }         

   return(0);
}

int Rule_7_d_paragraph_8(){
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
??? ????????? ???? m2 (???? ???? ??????? ?????) ?? ??????? ?? ????? ?? ??????????? ??????? ?? ??????? ?????????, 
? ????????? ?? m4 ? ?? ?????? ?? 61.8% ?? ????????? ?? m3, ? m(-1) ? ??-?????? ?? m0, 
? ??????? m(-1) ? m1 ???????? ?? ?????????, ? ????? m0 ?? ? ??-???????? ?? m(-2) ?/??? ?? m2, 
? ????? m3 ??????? ????????? ???? ?? m(-2) (??? ?? ???????) ?? ?????, 
?? ??????????? 50% ?? ??????? ?? ??????????? ?? ??????? ????? m(-2) ? m2, ?? m2 ???? ?? ??????? ?????????? ??????; 
???????? ? ???? ?? m1 ??????????? ?:sL3?.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/   

   if (BreakBeginingLevel(2, /*(???? ???? ??????? ?????)*/1)){  
   
      double ratio_p = ComparePriceDirection(4, 3);      
      if (Small_061(ratio_p)){  
   
         ratio_p = ComparePriceDirection(-1, 0);      
         if (Small_100(ratio_p)){   
        
            if (OverlapDirection(-1, 1)){         
          
               if (NoSmallerDirection(0, -2, 2)){
               
                  if (CheckTimeGoToBeginning(-2, DirectionSumTimeLength(-2, 2)*0.6,  2)){
                     AddDesignation(desig_sL3, "");
                  }                
               
               }
              
            }
         
         }
      }    
   }        
     

   return(0);
}