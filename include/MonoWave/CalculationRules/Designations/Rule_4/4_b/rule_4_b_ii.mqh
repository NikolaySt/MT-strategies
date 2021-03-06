

int Rule_4_b_ii(){
////////////////////////////////////////////////////////////////////////////////////////////////////////////
//��������� �ii�: ��������� �� m3 �� ������ � ��������� 161.8% - 261.8% (�����������) �� ��������� �� m2
////////////////////////////////////////////////////////////////////////////////////////////////////////////      
   InfoParagraph = "4-b-ii:1";
   Rule_4_b_ii_paragraph_1();
   InfoParagraph = "4-b-ii:2";
   Rule_4_b_ii_paragraph_2();
   InfoParagraph = "4-b-ii:3";
   Rule_4_b_ii_paragraph_3();
   InfoParagraph = "4-b-ii:4";
   Rule_4_b_ii_paragraph_4();   
}


int Rule_4_b_ii_paragraph_1(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� m(-1) ��������� 261.8% ��������� �� m1, 
������������ m1 �� � ���� �� ������� ������ ������ �� ����� � ����� ����� �� ����, 
������ ��������� � ���� �� m1 ���� ���� ��� ����������� �:F3/:c3�. 
��� � ������� �� ��������� �� m2 �� ������� �������� ���� �� m1 ��������� � ���� �:�3�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/             
   double ratio_p = ComparePriceDirection(-1, 1);
   if ( Large_261(ratio_p) ){   
      AddDesignation(desig_F3, "");             
      if (BreakEndToFormationDirection(1, 2)){
         AddDesignation(desig_xc3, ""); 
      }else{
         AddDesignation(desig_c3, "");    
      }
   }
   return(0);  
} 

int Rule_4_b_ii_paragraph_2(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� m1 � ��-����� �� ����� m(-1) � m(-3), 
� m2 (���� ���� ������� �����) ������� ������������ ��������� ���� �������� �� ������� m(-2) � m0, 
�� ����� ��-����� �� ������� �� ��������� m1, �� m1 ���� �� ���� ���� ����� �� ������ � �������� ����, 
������ �������� ��� ������� �� m1 ����������� �[:L5]�.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/ 
      
   double ratio_p = ComparePriceDirection(1, -1);
   double ratio_p_1 = ComparePriceDirection(1, -3);
   if ( Large_100(ratio_p) && Large_100(ratio_p_1) ){
      
      if (BreakTL(-2, 0, TimeDirection(1)+1, 1)){
         AddDesignation(desig_L5, "[]");
      }          
   }           
   return(0);  
} 

int Rule_4_b_ii_paragraph_3(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ��������� �� m4 � ��-����� �� 61.8% �� ��������� �� m3, 
������������ m1 �� � ������ �� ������� ������ ������ �� ����� � ������ �����; 
� ���� ������ ��������� � ���� �� m1 ���� ���� ��� ����������� �:�3/(:sL3)/(:s5)�. 

��� � ������� �� ��������� �� m2 �� ������� ���� �� m1, ��������� � ���� ����������� �:�3�. 

��� ������������ �� �������� �� m3 �� ���� �� m5 � ��-����� �� 161.8% �� ��������� �� m1 �/��� 
��� ��������� ���� �� m2 (���� ���� ������� �����) �� ������� �� ����� ��-������ 
�� ������� �� ������� ���������, �������� �� ������� �:sL3�. 

��� ����������������� �� m0 (���� ���� ������� �����) ������������ � ��-����� 
�� ������������������ �� ����� m(-1) � m1, �������� �:s5�. 

���������: ��� ���������� ����������� �:sL3�, ���������� �� ������� � ����� m2 � �� ���� �����������.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/    
   double ratio_p = ComparePriceDirection(4, 3);
   if ( Small_061(ratio_p) ){
      
      if (BreakEndToFormationDirection(1, 2)){
         AddDesignation(desig_xc3, ""); 
      }else{
         AddDesignation(desig_c3, "");    
      }
      
      //---------------------------------------------------------------------------------
      ratio_p = ComparePrice(DirectionSumPriceLength(3, 5), DirectionPriceLenght(1));
      double time_2_break = TimeBreakDirection(2);
      double time_2 = TimeDirection(2);   
            
      if ( !(Small_161(ratio_p) || (time_2_break > (time_2+1) && time_2_break > 0)) ){
         AddDesignation(desig_sL3, "()");
      }         
      //---------------------------------------------------------------------------------      
            
      
      double time1 = CompareTimeDirection(0, -1, 1 /*���� ���� ������� ����� �� �0*/);
      double time2 = CompareTimeDirection(0, 1, 1 /*���� ���� ������� ����� �� �0*/);
      
      if (Large_100(time1) || Large_100(time2)){            
         AddDesignation(desig_s5, "()"); 
      }             
   } 
   return(0);  
} 

int Rule_4_b_ii_paragraph_4(){   
/* 
////////////////////////////////////////////////////////////////////////////////////////////////////////////
��� ���� ���� �� ������� ������� �� ������������� ����������, 
��������� � ���� �� m1 ����������� �:F3/:c3/:sL3/:s5�. 

� ��� � ������� �� ��������� �� m2 �� ������� ���� �� m1, �������� ����������� ��:�3� ��� �������. 

� ��� m1 � ��-����� �� m(-1) � �� m(-3) � m2 ������� ������������ ��������� ���� �������� �� m(-2) � m0, 
�� ����� �� ����� �� ������� �� ��������� �� m1, �� m1 ���� �� ���� ���� ����� �� ������ � �������� ����; 
�������� ����������� �[:L5]�  ��� �������. 

� ��� m1 � ��-����� �� m(-1) � �� m3, 
� ��������� ���� �� m3 (���� ���� ������� �����) �� ������� �� ����� ��-����� �� ������� �� ������� ���������, 
�������� �� ������� �:�3�. 

� ��� ��������� �� m1 � ��-����� �� 61.8% �� ��������� �� m(-1) �/��� 
����������������� �� m0 ������������ � ��-����� �� ������������������ �� m(-1) � m1, �������� ����������� �:s5�. 

� ��� ��������� �� m4 � ��-����� �� 61.8% �� ��������� �� m3 �������� �� ������� �:F3�. 

� ��� ��������� ���� �� m2 (���� ���� ������� �����) �� ������� �� ����� ��-������ �� ������� �� ������� ���������, 
�������� �:sL3� � ������� �� m1.

////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/    
//��� ���� ���� �� ������� ������� �� ������������� ����������, 
//��������� � ���� �� m1 ����������� �:F3/:c3/:sL3/:s5�.
   if (CountArrayDesignations() == 0){

      //-----------------------------------------------------------------
      //� ��� ��������� �� m4 � ��-����� �� 61.8% �� ��������� �� m3 �������� �� ������� �:F3�.       
      double ratio_p = ComparePriceDirection(4, 3);
      if (! Small_061(ratio_p)){
         AddDesignation(desig_F3, ""); 
      }
      //-----------------------------------------------------------------
      //� ��� m1 � ��-����� �� m(-1) � �� m(-3) � m2 ������� ������������ ��������� ���� �������� �� m(-2) � m0, 
      //�� ����� �� ����� �� ������� �� ��������� �� m1, �� m1 ���� �� ���� ���� ����� �� ������ � �������� ����; 
      //�������� ����������� �[:L5]�  ��� �������.       
      ratio_p = ComparePriceDirection(1, -1);
      double ratio_p_1 = ComparePriceDirection(1, -3);
      if ( Large_100(ratio_p) && Large_100(ratio_p_1) ){
      
         if (BreakTL(-2, 0, TimeDirection(1), 1)){
            AddDesignation(desig_L5, "[]");
         }          
      }                             
      //-----------------------------------------------------------------        
           
      //� ��� m1 � ��-����� �� m(-1) � �� m3, 
      //� ��������� ���� �� m3 (���� ���� ������� �����) �� ������� �� ����� ��-����� �� ������� �� ������� ���������, 
      //�������� �� ������� �:�3�.                  
      ratio_p = ComparePriceDirection(1, -1);
      ratio_p_1 = ComparePriceDirection(1, 3);                  

      double time_3_break = TimeBreakDirection(3);
      double time_3 = TimeDirection(3); 
      
      if ( !(Small_100(ratio_p) && Small_100(ratio_p_1) && ( time_3_break < (time_3+1) && time_3_break > 0)) ){
         AddDesignation(desig_c3, "");  
      }                   

      //� ��� � ������� �� ��������� �� m2 �� ������� ���� �� m1, �������� ����������� ��:�3� ��� �������.       
      if (BreakEndToFormationDirection(1, 2)){
         AddDesignation(desig_xc3, ""); 
      }                  
      //-----------------------------------------------------------------      
      //� ��� ��������� �� m1 � ��-����� �� 61.8% �� ��������� �� m(-1) �/��� 
      //����������������� �� m0 ������������ � ��-����� �� ������������������ �� m(-1) � m1, �������� ����������� �:s5�. 
      ratio_p = ComparePriceDirection(1, -1);
      double time1 = CompareTimeDirection(0, -1, 1 /*���� ���� ������� ����� �� �0*/);
      double time2 = CompareTimeDirection(0, 1, 1 /*���� ���� ������� ����� �� �0*/);
          
      if ( Large_061(ratio_p) || (Large_100(time1) || Large_100(time2))){
         AddDesignation(desig_s5, "");   
      }   
      //-----------------------------------------------------------------          
      //� ��� ��������� ���� �� m2 (���� ���� ������� �����) �� ������� �� ����� ��-������ �� ������� 
      //�� ������� ���������, �������� �:sL3� � ������� �� m1.      
      double time_2_break = TimeBreakDirection(2);
      double time_2 = TimeDirection(2);   
            
      if ( !(time_2_break > (time_2+1) && time_2_break > 0) ){
         AddDesignation(desig_sL3, "");
      }  
      //-----------------------------------------------------------------        
   }

   return(0);  
} 