
#define TYPE_DOWN_ML_BREAK_HIGHPEAK 1001
#define TYPE_UP_ML_BREAK_LOWPEAK 2001
#define TYPE_LOW_PEAK_FORM 3001
#define TYPE_HIGH_PEAK_FORM 4001


void RT_Main_Process(int bars = 150){  
   int timeframe = GetTimeFrame();   
   
   int shift = bars;    
   int index;
   
   bool check_exit_high, check_exit_low;
   double high, low;
   
   //��������� �� MLGetLastPeak
   double value; datetime time; int type_peak; double count;   
   
   while (Condition(shift)){
      
      //������� ������������ �� ����
      index = iBarShift(NULL, timeframe, Time[shift]);
      high = GetHigh(index, timeframe);
      low = GetLow(index, timeframe);      

      check_exit_high = false;        
      check_exit_low = false;            
      
      while (!check_exit_high && !check_exit_low && Condition(shift)){  
         //����� ��� �������� ���������/������������ �� ���� ����� ����� � ������                                                    
         shift--;                  
         index = iBarShift(NULL, timeframe, Time[shift]);            
         
         if (GetHigh(index, timeframe) > high) check_exit_high = true;
         if (GetLow(index, timeframe) < low) check_exit_low = true;                     
         
         
         if (Period() == GetTimeFrame()){            
            SetBiasLineToBuff(index, GetBias_Level());
            SetBiasDirectionToBuff(index, GetBias_Direction());
             if (IsTesting()) TrendPoint("bias_"+Time[index], Time[index], GetBias_Level(), 0);  
         }
      }  
      
      if (check_exit_high && check_exit_low && MLGetLastPeak(value, time, type_peak, count)) {           
         //������� ��� � ������ � ����� ��������� �� ��������� ���         
         if (GetLow(index, timeframe) < value && type_peak == -1) {
            //������ �� ���� � ������� (LOW ��������� �� MotionLine - ���-�������)                        
            RT_MLDirection(index, -1, timeframe, TYPE_UP_ML_BREAK_LOWPEAK);                          
         }else{                                          
            if (GetHigh(index, timeframe) > value && type_peak == 1) {            
               //����� �� ���� � ������ (HIGH ��������� �� MotionLine - ���-�������)
               RT_MLDirection(index, 1, timeframe, TYPE_DOWN_ML_BREAK_HIGHPEAK);               
            }else{                 
               
               if (check_exit_high && MLGetTypeLastBar() == 1){
                  //������ �� ������ �� �������� �� ���������� ����������� �� MotionLine                  
                  RT_MLDirection(index, 1, timeframe);                                                      
               }               
               if (check_exit_low && MLGetTypeLastBar() == -1){  
                  //������ �� ���� �� �������� �� ���������� ����������� �� MotionLine           
                  RT_MLDirection(index, -1, timeframe);                                                        
               }                            
            }
         }                     
      }else{
         //������� ��� � ������ ���� �� ����� ��������� �� ��������� ���
         
         //������ ������         
         if (check_exit_high) {
            MLGetLastFormPeakType(1, value, time, count);
            if (GetHigh(index, timeframe) > value){ // ����������� �� ������ �� �������� ����
               RT_MLDirection(index, 1, timeframe, TYPE_LOW_PEAK_FORM);          
            }else{            
               RT_MLDirection(index, 1, timeframe);          
            }               
            
         }        
             
         //������ ������
         if (check_exit_low) {
            MLGetLastFormPeakType(-1, value, time, count);
            if (GetLow(index, timeframe) < value){// ����������� �� ������ �� �������� ����
               RT_MLDirection(index, -1, timeframe, TYPE_HIGH_PEAK_FORM);          
            }else{            
               RT_MLDirection(index, -1, timeframe);          
            }                                             
         }
      }    
      
      
   } 
   //��������� ����/���� � ��������� ML ��� 
   RT_CheckEndPeak(0, MLBarType(MLLastBarIndex()), 0);                      
}


void RT_MLDirection(int index, int DownUp, int timeframe, int type = -1){               
   int ML_bar_forming = 1; // �� ������������ ���� � ��������
   if (index == 0) ML_bar_forming = 0; // �������� ��� � ������� �� �������
   
   switch(type){
      case TYPE_DOWN_ML_BREAK_HIGHPEAK:
            // �� ������� ���������� � ���� ������, ������ ��� ����� ������ �� ����� ���������� � �� ��������� ���� �� ��
            if (GetClose(index, timeframe) > GetOpen(index, timeframe)){                              
               //���� �� �������� ������
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), -1, MLGetLastCountTime_Type(-1)+0.5, 1);
               Bias_Process();
               RT_CheckEndPeak(index, -1, 1);   
                                                         
               
               //������ �� �������� ������
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(1)+0.5, ML_bar_forming);
               Bias_Process();          
            }else{               
               //��������� ��������� ��������
               RT_CheckEndPeak(index, -1, 1);   
               //������� � ����� ��� �������� ������ � ��������a               
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(1)+0.5, 0);
               Bias_Process(); 
               //��������� ���� ������������ ����� �� ������ �� ���� � �������� ���� �� ����� � ��� �� �� ������� ������� ���� ������������
               //�.� ������ ��� � � ��� ���������� ����� ���� �� ������� ������������ ��� ������������ ����-�
               MLSetBarForming(MLLastBarIndex(), 1);
               
               
               RT_CheckEndPeak(index, 1, 1);  
                                                           
               //� ����� ��� ������� �������� ������
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), -1, MLGetLastCountTime_Type(-1)+0.5, ML_bar_forming);
               Bias_Process();    
            }
         break;
      case TYPE_UP_ML_BREAK_LOWPEAK:  
            // �� ������� ���������� � ���� ������, ������ ��� ����� ������ �� ����� ���������� � �� ���������� ���� �� ��
            if (GetClose(index, timeframe) < GetOpen(index, timeframe)){      
               //�������� ��������� ��������
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), 1, MLGetLastCountTime_Type(1)+0.5, 1);
               Bias_Process(); 
               RT_CheckEndPeak(index, 1, 1);  
                
                                      
               //������� ��������� ��������               
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(-1)+0.5, ML_bar_forming); 
               Bias_Process();
            }else{               
               //��������� ��������� ��������
               
               RT_CheckEndPeak(index, 1, 1);   
                                                                           
               //������� ��������� �������� � ���������               
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(DownUp)+0.5, 0); 
               Bias_Process(); 
               //��������� ���� ������������ ����� �� ������ �� ���� � �������� ���� �� ����� � ��� �� �� ������� ������� ���� ������������
               //�.� ������ ��� � � ��� ���������� ����� ���� �� ������� ������������ ��� ������������ ����-�
               MLSetBarForming(MLLastBarIndex(), 1);                                       
               RT_CheckEndPeak(index, -1, 1);                 
                              
                                           
               //� ���� ��� ������� ��������� ��������  
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), 1, MLGetLastCountTime_Type(1)+0.5, ML_bar_forming); 
               Bias_Process();                                      
            }   
            
         break;
      default: {        
         if (type == TYPE_LOW_PEAK_FORM || type == TYPE_HIGH_PEAK_FORM){
            //��� ������� �������� ���� ��� ���� �� �� ������������ ���������� ����/���� � ��������                         
            RT_CheckEndPeak(index, DownUp*(-1), 1); // �������� �� ����������� �� ������� �������� ) 
         }else{  
            RT_CheckEndPeak(index, DownUp*(-1), ML_bar_forming);  // �������� �� ����������� �� ������� �������� ) 
         }            
         
         if (MLGetTypeLastBar() == DownUp){         
            MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(DownUp)+1, ML_bar_forming);             
         }else{
            MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, 1, ML_bar_forming); 
         }  
                    
         Bias_Process();                             
         break;
      }
   }    
   //��������� �� ������ �� �������� ����         
   
}

void RT_CheckEndPeak(int index, int type_peak, int peak_forming){
   if (MLBarType(MLLastBarIndex()) == type_peak){
      //������� ��������� �������� ���� ��� ���� �� �� � �����               
      MLSetPeak(MLGetLastPoint(), MLGetTimeLastBar(), MLBarType(MLLastBarIndex()), MLBarTimeCount(MLLastBarIndex()), peak_forming);          
       
   }
}   

int CALC_TIMEFRAME;
void SetTimeFrame(int timeframe){ CALC_TIMEFRAME = timeframe;}
int GetTimeFrame(){ return(CALC_TIMEFRAME);}

int CalcUpTimeFrame( int TimeFrame )
{
   switch(TimeFrame){
      case PERIOD_M1: return(PERIOD_M5);
      case PERIOD_M5: return(PERIOD_M15);
      case PERIOD_M15: return(PERIOD_H1);
      case PERIOD_H1: return(PERIOD_H4);
      case PERIOD_H4: return(PERIOD_D1);
      case PERIOD_D1: return(PERIOD_W1);
      case PERIOD_W1: return(PERIOD_MN1);
      case PERIOD_MN1: return(PERIOD_MN1);
      default: return(0);
   }  
}

bool Condition(int index){ return(index > 0);}
datetime GetTime(int index, int timeframe){return(iTime(NULL, timeframe, index));}
double GetHigh(int index, int timeframe){return(iHigh(NULL, timeframe, index));}
double GetLow(int index, int timeframe){return(iLow(NULL, timeframe, index));}
double GetOpen(int index, int timeframe){return(iOpen(NULL, timeframe, index));}
double GetClose(int index, int timeframe){return(iClose(NULL, timeframe, index));}
int GetShift(datetime time, int timeframe){return(iBarShift(NULL, timeframe, time));}

/*
double GetLow(int index, int timeframe){  
   if (shift == 0 && timeframe != Period()){
      int begin = iBarShift(NULL, Period(), iTime(NULL, timeframe, iBarShift(NULL, timeframe, Time[0])));
      //Print(begin);
      return(Low[iLowest(NULL, Period(), MODE_LOW, begin + 1, 0)]);
   }else{
      return(iLow(NULL, timeframe, index));
   }   
}
*/

