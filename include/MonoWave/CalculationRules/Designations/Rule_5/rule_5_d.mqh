
int Rule_5_d(){
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//������� �d�: ��������� �� m0 � ������ �� 261.8% �� ��������� m1
////////////////////////////////////////////////////////////////////////////////////////////////////////////  
   InfoParagraph = "5-d:1";
   Rule_5_d_paragraph_1();
   InfoParagraph = "5-d:2";
   Rule_5_d_paragraph_2();
   InfoParagraph = "5-d:3";
   Rule_5_d_paragraph_3();
   InfoParagraph = "5-d:4";
   Rule_5_d_paragraph_4();
   InfoParagraph = "5-d:5";
   Rule_5_d_paragraph_5();
   InfoParagraph = "5-d:6";
   Rule_5_d_paragraph_6();
   InfoParagraph = "5-d:7";
   Rule_5_d_paragraph_7();
   InfoParagraph = "5-d:8";
   Rule_5_d_paragraph_8();
   InfoParagraph = "5-d:9";
   Rule_5_d_paragraph_9();
   InfoParagraph = "5-d:10";
   Rule_5_d_paragraph_10();
   
}

int Rule_5_d_paragraph_1(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ����� m2 �� ������ �� ������ �� ��� ���������, ��������� � ���� �� m1 ����������� �:F3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               

   if (WavesCountInDirection(2) > 3){
      AddDesignation(desig_F3, "");   
   }
   return(0);
} 


int Rule_5_d_paragraph_2(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� ���� �� m2 (���� ���� ������� �����) �� ������� �� ����� �� ����������� ������� �� ������� ���������, 
� m(-2) � ��-������ �� m0, 

//Dobaveno ot men!!!!!!!!!!!!
//� m(-2) � ��-������ �� m(-1), 

� ���� ������������ �� m2, ��������� ���� �� m(-2) �� ������� (��� �������) �� ����� �� ��-������ �� 50% �� ������� 
�� ��������� �� ������� ����� m(-2) � m2, �������� � ���� �� m1 ����������� �(:sL3)� 
(���������, �� ��� ����� m2 ���� �� �������� ���������� ������ � �������� 3-��)
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               

   if (BreakBeginingLevel(2, /*(���� ���� ������� �����)*/1)){

      double ratio_p = ComparePriceDirection(-2, 0);      
      if (Small_100(ratio_p)){   
      
         //ratio_p = ComparePriceDirection(-2, -1);      
         //if (Large_100(ratio_p)){       
      
            if (CheckTimeGoToBeginning(-2, DirectionSumTimeLength(-2, 2)*0.6, 2)){
               AddDesignation(desig_sL3, "()");    
            }           
         //}   
      }
   }
   
   return(0);
} 

int Rule_5_d_paragraph_3(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m3 � ��-����� �� 61.8% �� ��������� �� m2, � ��������� �� ����� m1 � m3 �� ���������, 
� ����� m4 � ��-������ �� ����� m2, � ��������� ���� �� m4 �� ������� �� �����, 
��-����� �� ������� �� ������� ���������, 
��� ���� ��������� ���� �� m0 �� ������� �� ����� �� ��-������ �� 50% �� ������� �� ��������� �� m0 � m4, 
�� � m4 ���� �� �������� ���������� ������ ������; ��������� � ���� �� m1 ����������� �:�3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 2);      
   if (Small_061(ratio_p)){   
      
      if (OverlapDirection(1, 3)){
      
         ratio_p = ComparePriceDirection(4, 2);      
         if (Small_100(ratio_p)){           
      
            if (BreakBeginingLevel(4, /*(���� ���� ������� �����)*/1)){
            
               if (CheckTimeGoToBeginning(0, DirectionSumTimeLength(0, 4)*0.6, 4)){
                  AddDesignation(desig_c3, "");    
               }           
               
            }
         }
      }
   }

   
   return(0);
} 
 
int Rule_5_d_paragraph_4(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m3 � ��-����� �� 61.8% �� ��������� �� m2, 
� ��������� �� ������� ����� m2-m4 � ��-������, 
� ����������������� � ��-����� (���������� � ����� �����������) ������ ������� m0, 
� ��� ��������� �� m(-1) � �� ��-����� �� 61.8% �� ��������� �� m0, 
�� ���������� ��-������ ���������� � ����� m1 �� �������� ������ ����������, 
������ ��������� � ���� �� m1 ����������� �(:L3)�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 2);      
   if (Small_061(ratio_p)){   
      
      if (CheckTimeGoToLength(0, TimeDirection(0), 1)){         
         
         ratio_p = ComparePriceDirection(-1, 0);      
         if (Large_061(ratio_p)){          
            AddDesignation(desig_L3, "()");   
         }         
      }
   }
   
   return(0);
}  

int Rule_5_d_paragraph_5(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m3 � ��-����� �� 61.8% �� ��������� �� m2, 
� ��������� �� ������� ����� m2-m4 � ��-������, 
� ����������������� � ��-����� (���������� � ����� �����������), 
������ ����� m0, � ��������� �� m(-1) � ����� �� ��������� �� m0, 
� �����������������  �� m1 � ��-������ ��� ����� �� ����������������� �� m(-1) 
� ����������������� �� m0 � ��-������ �� ����������������� �� m(-1) � m1, 
�� ���������� �� ������ ���������� � m1 �� �������� �������� ������ � ��������� �є; 
�������� ��� ������� �� m1 ���������� �[:L5]�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 2);      
   if (Small_061(ratio_p)){   
      
      if (CheckTimeGoToLength(0, TimeDirection(0), 1)){         
         
         ratio_p = ComparePriceDirection(-1, 0);      
         if (Equal_100(ratio_p)){
            
            double ratio_t = CompareTimeDirection(1, -1);
            if (Large_100(ratio_t)){   
               
            
               ratio_t = CompareTimeDirection(0, -1);
               double ratio_t1 = CompareTimeDirection(0, 1);
               if (Large_100(ratio_t) && Large_100(ratio_t1)){   
               
                  AddDesignation(desig_L5, "[]"); 
                  
               }                              
            }                          
         }         
      }
   }
   
   return(0);
}

int Rule_5_d_paragraph_6(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m3 � � ��������� �� 61.8% �� 100% �� ��������� �� m2, 
� ��������� �� m4 � ��-����� �� 61.8% �� ��������� �� m0, � ����������������� �� m1 � ��-����� �� ����������������� �� m0,
�� m1 ���� �� ���� �-����� � ������� �� ������ ��������; ���������� ���� � ��������� � ���� �� m1 ����������� ��:�3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 2);      
   if (Large_061(ratio_p) && Small_100(ratio_p)){             
         
      ratio_p = ComparePriceDirection(4, 0);      
      if (Small_061(ratio_p)){
            
         double ratio_t = CompareTimeDirection(1, 0);
         if (Small_100(ratio_t)){   
            
            AddDesignation(desig_xc3, "");             
                                     
         }         
      }
   }
   
   return(0);
}

int Rule_5_d_paragraph_7(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m3 � � ��������� �� 61.8% �� 100% �� ��������� �� m2, 
� ��������� �� m4 � �� ��-����� �� 61.8% �� ��������� �� m0, ��������� � ���� �� m1 ����������� �:F3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 2);      
   if (Large_061(ratio_p) && Small_100(ratio_p)){             
         
      ratio_p = ComparePriceDirection(4, 0);      
      if (Large_061(ratio_p)){
              
         AddDesignation(desig_F3, "");          
                                     
      }
   }
   
   return(0);
}

int Rule_5_d_paragraph_8(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m3 � ��-����� �� 61.8% �� ��������� �� m2, ��������� � ���� �� m1 ����������� �:F3 / :c3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 2);      
   if (Small_061(ratio_p)){             
      AddDesignation(desig_F3, "");                                          
      AddDesignation(desig_c3, "");
   }
   
   return(0);
}

int Rule_5_d_paragraph_9(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� ����� m3 � �� ��-����� �� 61.8% �� ��������� �� ����� m1, �� � �� ����� �� ����� m2, 
� ����� m4 �� � ��-������ �� m2, � ��������� �� m4 (��� ����� ����� m4- m6) �� �������� �������� ���� �� m3 
� ��������� �� � �� ��-����� �� 61.8% �� ��������� �� m0, 
�� ��� ������ ���������� m1 �� � ����� ������� �� ������ ���������� ���������; 
�������� � ���� �� m1 ����������� �:F3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   double ratio_p = ComparePriceDirection(3, 1);         
   if (Large_061(ratio_p)){             
   
      ratio_p = ComparePriceDirection(3, 2);  
      if (Small_100(ratio_p)){
      
         ratio_p = ComparePriceDirection(4, 2);  
         if (Large_100(ratio_p)){
            
            //opredelia dali m6 probiva krainoto nivo na m3
            if (CheckDirect_2_Break_Direct_1(3, 6)){           
               
               ratio_p = ComparePrice(Length_Group_4_6(), DirectionPriceLenght(0));
               double ratio_p1 = ComparePrice(4, 0);
               if (Large_061(ratio_p) || Large_061(ratio_p1) ){ 
                  AddDesignation(desig_F3, "");
               }
            
            }                     
         }      
         
      }
      
   }
   
   return(0);
}

int Rule_5_d_paragraph_10(){     
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� �� ���� ������ � ������� �� m1 ������ ������� �����������, ��������� ����������� �:F3�
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/               
   if (CountArrayDesignations() == 0){
      AddDesignation(desig_F3, ""); 

   } 
   
   return(0);
}
 
 