//+------------------------------------------------------------------+
//|   �������� � ��������� ������������ BIAS
//+------------------------------------------------------------------+
#include <RiverTechnology\BiasLine\BiasParametars.mqh>
#include <RiverTechnology\BiasLine\BiasUtils.mqh>


void CalcBias(int shift, double high, double low, int zone){
   //zone : +1 ��������� �������� �� motionline
   //zone : -1 ��������� �������� �� motionline     
   
   AddMotionBarToArray(shift, high, low);  
   
   if (bias_direction == 0){
      bias_direction = 1;
      bias_level = low; 
   }
 
   if (bias_direction == 1){
      if (low < bias_level){         
         BreakDownBias(shift);                      
      }else{         
         CalcContinueDownBias(shift);      
      }       
   }else{  
      if (bias_direction == -1){
         if (high > bias_level){          
            BreakUpBias(shift);            
         }else{
            CalcContinueUpBias(shift);
         } 
      }
   }   
   BiasProcess(shift, high, low);   
}

void BreakDownBias(int curr_bar_shift){ 
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);   

   //������� �������� �� ��������� ������� ���� ����� � ������
   //�������� �� ����     
   // ������ �� ��� �������� �� ������� ����, 4-�� ���� ����� ��� �������� ��� ���� 4-��
   save_fisrt_bias_shift = bias_shift; 
          
   GetBiasHighLevel(bias_shift, MotionBarFirst(), bias_shift, bias_level);
   
   //������� Motion ���� ����� � ����� �����
   //������ �� ��� �������� �� ��� ������/������� ���
   break_bias_shift = MotionBarFirst();
   
   //������� ���� �� ��������� ����� ����� ������� �� Biasa
   //������ �� ���� ��� ����������� �� �������
   bias_begin_shift = curr_bar_shift;  
          

   DrawLine(BiasLineName(bias_begin_shift), "",  curr_bar_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);
         
   bias_direction = -1;  
}

void BreakUpBias(int curr_bar_shift){
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);   
   
   save_fisrt_bias_shift = bias_shift;
   
   GetBiasLowLevel(bias_shift, MotionBarFirst(), bias_shift, bias_level);   
   
   break_bias_shift = MotionBarFirst();
   
   bias_begin_shift = curr_bar_shift;     
   
   DrawLine(BiasLineName(bias_begin_shift), "",  curr_bar_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);

   bias_direction = 1;      
}

//-------------------------------------------------------------------
// �������� ����������� �� ������������(BIAS) ������ ��� �� ������
// ������ �.�. � �����������
//-------------------------------------------------------------------
void CalcContinueDownBias(int curr_bar_shift){
   
   int shift_motion_highest_low;
   
   //��������� Bias-������� �� ���� ����� � � ������� �� ������� ��������� �������� �� ���������� ����������   
   if (bias_begin_shift !=0){
      DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);   
   }
   
   
   
   //�������� ��� ��� �� Motion ������� � � ���-����� ����
   //� ��������� �� �������� �� ������� �� Bias-� �� ����������� � �����������.
   shift_motion_highest_low = GetShiftMotionHighestLow(break_bias_shift,  MotionBarFirst());           
      
      
   //������ ������� ���� �� Bias-� ������ �������� 
   //(4-�� Motion ���� ����� � �� ������ ������� ��� ��� ��������� ��� ����� Motion ���, ��� �� �� ����� �� 4-��)
   //�� �������� ������ �� ��� ��� �� �� ������ �� ������� ����.
   GetBiasLowLevel(save_fisrt_bias_shift, shift_motion_highest_low, bias_shift, bias_level);                                       

   //������� ����������� �� ���� �� �������� ������� ������ �� ������ ���-������ ����
   bias_begin_shift = MotionBarShift(shift_motion_highest_low); 
   
   //��������� Bias-������� �� ������������� ������ ���� �� ���� ������ � ���������� ������������ �� ����-� �� ������� ��� � ������� �� �������� �������.      
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);          
    
}

//-------------------------------------------------------------------
// �������� ����������� �� ������������(BIAS) ������ ��� �� ������
// ������ �.�. � �����������
//-------------------------------------------------------------------
void CalcContinueUpBias(int curr_bar_shift){
   int shift_motion_lowest_high;

   if (bias_begin_shift !=0){
      DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);         
   }      

   shift_motion_lowest_high = GetShiftMotionLowestHigh(break_bias_shift,  MotionBarFirst());           
   
   
   GetBiasHighLevel(save_fisrt_bias_shift, shift_motion_lowest_high, bias_shift, bias_level);                                                                                
   
   bias_begin_shift = MotionBarShift(shift_motion_lowest_high);
                                   
   DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, curr_bar_shift, bias_level, bias_level, Blue, 2);             
}


void BiasDrawEnd(){
   if (bias_begin_shift == 0 && bias_level != 0) {
     DrawLine(BiasLineName(bias_begin_shift), "",  1, 0, bias_level, bias_level, Blue, 2);
   }else{
     DrawLine(BiasLineName(bias_begin_shift), "",  bias_begin_shift, 0, bias_level, bias_level, Blue, 2);
  }      
}

void BiasProcess(int shift, double high, double low){

   if (bias_direction == 1){
     BuffHigh[shift] = low;
     BuffLow[shift] = high;      
   }else{
      if (bias_direction == -1){
         BuffHigh[shift] = high;
         BuffLow[shift] = low;   
      }
   }
   
   if (bias_level != 0) {
      //BuffBiasLine[shift] = -1*(((bias_level - ((high + low)/2))/bias_level)*100);
      
         //BuffHigh[shift] = high;
         //BuffLow[shift] = low;  
   }      
   
   //Print(bias_level);
}

//-------------------------------------------------------------------------
//-------------------------------------------------------------------------
int GetBiasDirection(){
   return(bias_direction);
}



/*
//DEBUG-------------------------------------------------------------------------------
   if (TimeToStr(Time[curr_bar_shift])=="2007.06.06 00:00"){
      
      Print("���-������ ���� = ", TimeToStr(Time[bias_begin_shift]), 
      ": ������ �� 4-�� = ", TimeToStr(Time[MotionBarShift(save_fisrt_bias_shift)]),
      ": ���� 4-�� = ", TimeToStr(Time[MotionBarShift(shift_motion_highest_low)]),
      ": ���� : ", bias_level,
      ": ��� = ", BiasLineName(bias_begin_shift)
      
      );
   }   
//------------------------------------------------------------------------------------   
   
//DEBUG-------------------------------------------------------------------------------
   if (TimeToStr(Time[curr_bar_shift])=="2007.06.05 00:00" ){
      
      Print("BREAK - ������ = ", TimeToStr(Time[MotionBarShift(save_fisrt_bias_shift)]), 
      ": ���� : ", bias_level
      );
   }   
   
   if (TimeToStr(Time[curr_bar_shift])=="2007.06.05 00:00"){
      
      Print("���-������ ���� = ", TimeToStr(Time[bias_begin_shift]), 
      ": ������ �� 4-�� = ", TimeToStr(Time[MotionBarShift(save_fisrt_bias_shift)]),
      ": ���� 4-�� = ", TimeToStr(Time[bias_begin_shift]),
      ": ���� : ", bias_level,
      ": ��� = ", BiasLineName(bias_begin_shift)
      
      );
   }      
//------------------------------------------------------------------------------------  

*/



