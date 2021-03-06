//+------------------------------------------------------------------+
//|   �������� �������
//+------------------------------------------------------------------+

datetime time_level_shift = 0;
double time_level = 0;
int time_direction = 0; //"1"-������, "-1"-������
bool time_neutral = false; // true - ��������� ��������

void InitTimeParams(){
   time_direction = 0;
   time_neutral = false;   
}

void SetTime_Neutral(bool value){time_neutral = value;}
bool GetTime_Neutral(){return(time_neutral);}

void SetTime_LevelParams(datetime time, double value){ time_level_shift = time;  time_level = value; }
void GetTime_LevelParams(datetime& time, double& value){ time = time_level_shift; value = time_level;}

int SetTime_Direction(int value){time_direction = value;}
double GetTime_Level(){ return(time_level);}
datetime GetTime_LevelTime(){ return(time_level_shift);}
int GetTime_Direction(){if (GetTime_Neutral()) return(0); else return(time_direction);}


void Time_Process(){
   TimeChange_NeutralLevel();
   TimeChange_InitLevel(); 
   
}

void TimeChange_NeutralLevel(int index = -1){   
   double ml_value, high, low; datetime time; int ml_type;
   MLGetBar(MLLastBarIndex(), high, low, time, ml_type);  
   if (ml_type == -1){ ml_value = low;}
   if (ml_type == 1){ ml_value = high;}
   double count = MLGetCountLastBar();  

   
   //�� �� ����� ������ - ������������� �� ������� � ������
   if (ml_type == 1 && GetTime_Direction() == -1){  
      if (ml_value > GetTime_Level()){
         //����� ������ �� ������ �� ������� 
         if (!GetTime_Neutral()) SetTimeBreakToBuff(iBarShift(NULL, GetTimeFrame(), time),  GetTime_Level());   
         if ( count <= MLGetLastPeakCount()){        
            //�������� ����� ���������
            SetTime_Neutral(true);
            
         }
      }   
      
      if (count == MLGetLastPeakCount() || (MLGetLastPeakCount() - count == 0.5)){ 
         //����� ��������� ����� �������� ������ � ���������� ����                                  
         //��� ��������� � 0.5
         
         //��� ������� �� ������� �� ��� � ��������      
         if (MLBarForming(MLLastBarIndex()) != 0) SetTime_LevelParams(time, ml_value);       
      }              
           
   }              
   //�� �� ����� ������ - ������������� �� ������� � ������
   if (ml_type == -1 && GetTime_Direction() == 1){           
      if (ml_value < GetTime_Level() ){
         //����� ������ �� ������ �� �������
         if (!GetTime_Neutral()) SetTimeBreakToBuff(iBarShift(NULL, GetTimeFrame(), time),  GetTime_Level());   
         if ( count <= MLGetLastPeakCount() ) {
            //�������� ����� ���������     
            SetTime_Neutral(true);                 
            
         }         
      }   
      
      
      if (count == MLGetLastPeakCount() || (MLGetLastPeakCount() - count == 0.5)){ 
         //����� ��������� ����� �������� ������ � ���������� ����
         //��� ��������� � 0.5   
         
         //��� ������� �� ������� �� ��� � ��������      
         if (MLBarForming(MLLastBarIndex()) != 0)  SetTime_LevelParams(time, ml_value);                  
      }               
      
   }   
   
   
   //*********************************************************************************************
   //�� �� ����� ������ - ������������� �� ������� e ������
   //�� �� ����� ������ - ������������� �� ������� e ������
   if ((ml_type == -1 && GetTime_Direction() == -1) || (ml_type == 1 && GetTime_Direction() == 1)){           
      if (GetTime_Neutral()){              
         if (count == MLGetLastPeakCount() || (MLGetLastPeakCount() - count == 0.5)){     
            if (MLBarForming(MLLastBarIndex()) != 0) SetTime_LevelParams(time, ml_value);                  
         }          
      }else{                        
         if (count == 0.5){     
            SetTime_LevelParams(time, low);                              
         }               
      } 
                 
   }    
   /*
   if ((ml_type == -1 && GetTime_Direction() == -1) || (ml_type == 1 && GetTime_Direction() == 1)){           

                 
   }   
   */ 
   //*********************************************************************************************   
}

void TimeChange_InitLevel(){   
   //������������ ��������� ���� �� ������� 
   //1. ��� ����� �� ����������� �� ����������� � ����������� � �������;
   //2. ��� �������� �� ��������� ���������
   double value, count, high, low; datetime time; int peak_type, ml_type;
   
   MLGetLastBar(high, low, time, ml_type);
          
   if (MLGetCountLastBar() > MLGetLastPeakCount()){         
      //�������� ������ ����� �� ������ �� ��������� ����
      
      if ((GetTime_Direction() != -1 && ml_type == -1) || (GetTime_Neutral() && GetTime_Direction() == -1 && ml_type == -1)){
         SetTime_Direction(-1);         
         MLGetLastPeak(value, time, peak_type, count);                       
         SetTime_LevelParams(time, value);                                    
         SetTime_Neutral(false);
      }

      if ((GetTime_Direction() != 1 && ml_type == 1)|| (GetTime_Neutral() && GetTime_Direction() == 1 && ml_type == 1)){   
         SetTime_Direction(1);
         MLGetLastPeak(value, time, peak_type, count);                       
         SetTime_LevelParams(time, value);                               
         SetTime_Neutral(false);
      }         
      
   }          
}
//----------------------------------------------------------------

void Time_SetPeak(){      
   string text; int time_color;   
   double value, count; datetime time_peak; int peak_type;
   MLGetLastPeak(value, time_peak, peak_type, count); 
   if (MathRound(count) == count) text = DoubleToStr(count, 0); else text = DoubleToStr(count, 1);      
       
   double offset_price = iATR(NULL, 0, 50, GetShift(time_peak, GetTimeFrame())) * 0.3;     
   
   if (peak_type == -1){ /* �� ����*/
      value = value - offset_price;
      if (GetTime_Direction() == -1){            
         time_color = Red;                     
      }else{
         time_color = Silver;
      }
   }
   
       
   if (peak_type == 1){/* �� ���� */
      value = value + offset_price;
      if (GetTime_Direction() == 1){            
         time_color = Lime;
      }else{         
         time_color = Silver;
      }
   }   
   
   if (GetTime_Neutral()) time_color = Yellow;    
   Time_SetText(text, time_peak, value, time_color, peak_type);                
}          

void Time_SetText(string text, datetime time, double price, int time_color, int type){      
   string name = "text_" + DoubleToStr(time, 0) + "_" + type;
   if ( ObjectFind(name) < 0 ) ObjectCreate(name, OBJ_TEXT, 0, 0, 0);    
   ObjectMove(name, 0, time, price);            
   ObjectSetText(name, text, 10, "Arial Narrow", time_color);
   return(0);
}