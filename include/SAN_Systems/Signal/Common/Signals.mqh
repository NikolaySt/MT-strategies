
bool Signal_Trace = false;

void Common_Signals_Init(int settID)
{
   Signal_TimeFrame = SAN_AUtl_TimeFrameFromStr(Signal_TimeFrameS);   
}

//-----------------------------------------------------------------------------------

bool Common_Signals_IsActive(){
   if (IsTesting()){
      //�����! ������ �� ���� ��� ������� ������ ������ �� ������ ��������, ��� � ����� ���������� ������ �� ������ ������
      int curr_year = TimeYear(Time[1]);
      if ((curr_year == Signal_Year && Signal_WorkByToday == 1 && Signal_Year != 0) // ��������� ������ ���� ���� ������ �� ����������
          || 
          ((Signal_WorkByToday == 0) && curr_year >= Signal_Year && Signal_Year != 0) //������ �� �������� ������ �� ����
          || 
          (Signal_Year == 0) // �� ������ ������ �� ����� ��� �������
         ){         
         return(true);
      }else{
         //������� ������ ������� ������ ������� ����� ������ �� �������
         return(false);   
      }       
   }else{
      // ������ �� ������ ������� � ��������� ������ ������.
      return(true);
   }   
}

