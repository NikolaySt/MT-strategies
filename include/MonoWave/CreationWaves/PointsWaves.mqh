int wave_count_in_rule;
double MonoWave_Rule[const_wavecount][5];
/*
   MonoWave_Rule[0][0] = Index - /�������������� �� �������� ����� � array_ChartPoints/     
   MonoWave_Rule[0][1] = shift - �� ��������� ! 
   MonoWave_Rule[0][2] = �e���� ���� �� ���� �� �������  
   MonoWave_Rule[0][3] = MAX - ���������� ���� �� �������
   MonoWave_Rule[0][4] = MIN - ��������� ���� �� �������   
 
*/

double ArrayWaveRule_Get_Shift(int index){
   return(MonoWave_Rule[index][1]);
}
double ArrayWaveRule_Get_Price(int index){
   return(MonoWave_Rule[index][2]);
}

void AddChartPointToWave(){
   int k, n = 0;
   bool check_horz = false;
   k = 1;
   Add_PointToWave(0); 
   while (k < const_wavecount){  
      //DEBUG------------
      /*
      SetWaveRule(
         array_ChartPoints[k][1], 
         DoubleToStr(k, 0) + " : "+ DoubleToStr(array_ChartPoints[k][2],0), 
         array_ChartPoints[k][0], 
         8, 
         Black, 
         "NIndex", 
         "", 
         1
      );      
      */
      //------------
      //�������� ��������� ������ - ������ 1 - 2
      if (array_ChartPoints[k][2] == 1 && array_ChartPoints[k-1][2] == 2){
         Add_PointToWave(k);             
      }
      
      //�������� ��������� ������ - ������
      if (array_ChartPoints[k][2] == 2 && array_ChartPoints[k-1][2] == 1){
         Add_PointToWave(k);      
      }  
      
      //----------------------------------------------------------------------------------
      //�����. ������ - �����.������ - �����. ������       
      if (array_ChartPoints[k][2] == -1 && array_ChartPoints[k+1][2] == 1 && array_ChartPoints[k-1][2] == 1){                     
         Add_PointToWave(k);  
         Add_PointToWave(k+1);  

      }

      //�����. ������ - �����.������ - �����. ������       
      if (array_ChartPoints[k][2] == -2 && array_ChartPoints[k+1][2] == 2 && array_ChartPoints[k-1][2] == 2){     
         Add_PointToWave(k);      
         Add_PointToWave(k+1);  

      }      
      //----------------------------------------------------------------------------------

      //----------------------------------------------------------------------------------
      //�����. ������ - �����.������ - �����. ������       
      if (array_ChartPoints[k][2] == -2 && array_ChartPoints[k+1][2] == 1 && array_ChartPoints[k-1][2] == 1){         
         Add_PointToWave(k);     
         Add_PointToWave(k+1);  
      }    

      
      //�����. ������ - �����.������ - �����. ������       
      if (array_ChartPoints[k][2] == -1 && array_ChartPoints[k+1][2] == 2 && array_ChartPoints[k-1][2] == 2){
         Add_PointToWave(k);      
         Add_PointToWave(k+1);                                 
      }    
      
      //----------------------------------------------------------------------------------
      
      
      
      //�����. ������ - n*�����.��������� - �����. ������  
      if ((array_ChartPoints[k][2] == -2 || array_ChartPoints[k][2] == -1 || array_ChartPoints[k][2] == -3) && array_ChartPoints[k-1][2] == 1){      
         n = 1;
         check_horz = false;
        
         while (array_ChartPoints[k+n][2] == -2 || 
                array_ChartPoints[k+n][2] == -1 || 
                array_ChartPoints[k+n][2] == -3){                                     
            n++;
            check_horz = true;
         }
         if (array_ChartPoints[k+n][2] == 1 && check_horz){
            Add_PointToWave(k);  
            Add_PointToWave(k+n);                        
         }
      }     
      
      //�����. ������ - n*�����.��������� - �����. ������ 
      if ((array_ChartPoints[k][2] == -2 || array_ChartPoints[k][2] == -1 || array_ChartPoints[k][2] == -3) && array_ChartPoints[k-1][2] == 2){      
         n = 1;
         check_horz = false;
                  
         while (array_ChartPoints[k+n][2] == -2 || 
                array_ChartPoints[k+n][2] == -1 || 
                array_ChartPoints[k+n][2] == -3){
            n++;           
            check_horz = true;
         }
         if (array_ChartPoints[k+n][2] == 2 && check_horz){
            Add_PointToWave(k);  
            Add_PointToWave(k+n);
      
         }
      }                
      

      //----------------------------------------------------------------------------------          
      //�����. ������ - n*�����.��������� - �����. ������ 
      
      if ((array_ChartPoints[k][2] == -2 || array_ChartPoints[k][2] == -1 || array_ChartPoints[k][2] == -3) && array_ChartPoints[k-1][2] == 2){      
         n = 1;      
                   
         while (array_ChartPoints[k+n][2] == -2 || 
                array_ChartPoints[k+n][2] == -1 || 
                array_ChartPoints[k+n][2] == -3){
            n++;
         }

         if (array_ChartPoints[k+n][2] == 1){    
            if (Rule_Neutralnost_61_Higher(array_ChartPoints, k+n, k-1)){
               Add_PointToWave(k+n);  
            }else{
               Add_PointToWave(k);                
            }   
         }                  
      }
      
      //�����. ������ - n*�����.��������� - �����. ������ 
      
      if ((array_ChartPoints[k][2] == -2 || array_ChartPoints[k][2] == -1 || array_ChartPoints[k][2] == -3) && array_ChartPoints[k-1][2] == 1){      
         n = 1; 
                                
         while (array_ChartPoints[k+n][2] == -2 || 
                array_ChartPoints[k+n][2] == -1 || 
                array_ChartPoints[k+n][2] == -3){
            n++;                      
         }         
         
         if (array_ChartPoints[k+n][2] == 2){
            if (Rule_Neutralnost_61_Lower(array_ChartPoints, k+n, k-1)){
               Add_PointToWave(k+n);      
            }else{
               Add_PointToWave(k);                
            }      
         }          
         
      }     
      //----------------------------------------------------------------------------------                 
      k++;     
   }
}   

bool Rule_Neutralnost_61_Higher(double array[][], int index, int index_start_calc){
   double begin_wave = array[index+1][0]; 
   double end_wave = array[index][0];
   //double end_wave = array[index_start_calc][0]; // � ���� �� ��������������� ���������//  
   
   double percent_61 = end_wave - (end_wave - begin_wave)*0.618;
   double percent_100 = end_wave;
   double percent_0 =  begin_wave;
   
   double wave_extremum = 0;
   
   int k = 0;
   bool check_61 = false;
   bool check_0 = false;
   bool check_100 = false;
   int wave_type = 0;
   
   while (!check_0 && !check_100  && index_start_calc - k >= 0){
      end_wave = array[index_start_calc - k][0];
      wave_type = array[index_start_calc - k][2];
      
      wave_extremum = end_wave; 
   
      
      if (percent_61 > wave_extremum && wave_extremum != 0){
         check_61 = true;
      }
      if (percent_100 < wave_extremum && wave_extremum != 0){
         check_100 = true;
      }
      if (percent_0 > wave_extremum && wave_extremum != 0){
         check_0 = true;
      }      
      k++;      
   }
                
   if (check_0) { return(false); }
   if (check_100) {    
      if (check_61){
         return(false);      
      }else{
         return(true);   
      }
   }      
}

bool Rule_Neutralnost_61_Lower(double array[][], int index, int index_start_calc){
   double begin_wave = array[index+1][0];
   double end_wave = array[index][0];
   //double end_wave = array[index_start_calc][0]; // � ���� �� ��������������� ���������//   
   
   double percent_61 = end_wave + (begin_wave - end_wave)*0.618;
   double percent_100 = end_wave;
   double percent_0 =  begin_wave;
   
   double wave_extremum = 0;
   
   int k = 0;
   bool check_61 = false;
   bool check_0 = false;
   bool check_100 = false;
   int wave_type = 0;
   
   while (!check_0 && !check_100  && index_start_calc - k >= 0){
      end_wave = array[index_start_calc - k][0];
      wave_type = array[index_start_calc - k][2];
      wave_extremum = end_wave;
               
      if (percent_61 < wave_extremum && wave_extremum != 0){
         check_61 = true;
      }
      if (percent_100 > wave_extremum && wave_extremum != 0){
         check_100 = true;
      }
      if (percent_0 < wave_extremum && wave_extremum != 0){
         check_0 = true;
      }      
      k++;      
   }
  
   if (check_0) { return(false); }
   if (check_100) {    
      if (check_61){
         return(false);      
      }else{
         return(true);   
      }
   }      
}
     
int Add_PointToWave(int k){      
   int shift = array_ChartPoints[k][1];
   double level = array_ChartPoints[k][0];
   if (PointWaveView){
      if (k != 0){
         Point_Wave[shift] = level; 
      }
   }
   
   
   CreatWaveInRule(shift, level, k);      
   
   return(0);
}  

int CreatWaveInRule(int shift, double level, int indexChartPoint = 0){
   double min; 
   double max;
    
   ExtremelyLevels(array_ChartPoints, min, max, MonoWave_Rule[wave_count_in_rule-1][0], indexChartPoint); 

   MonoWave_Rule[wave_count_in_rule][0] = indexChartPoint;    
   MonoWave_Rule[wave_count_in_rule][1] = shift;      
   MonoWave_Rule[wave_count_in_rule][2] = level;    
   MonoWave_Rule[wave_count_in_rule-1][3] = max;
   MonoWave_Rule[wave_count_in_rule-1][4] = min;                                       
   wave_count_in_rule++;           
   
   //������� ������ �� ������� ����� � ����� ���� ������������ ����� �� ������������ �� ���������
   if (Check_Waves_Rules_Calc(shift)){
      //������� ���� ����� �� ����� �� �� �������� ���������
      wave_rules_begin_count = wave_count_in_rule;
   }
   
   CreateNumberWaves(MonoWave_Rule, wave_count_in_rule, shift);
}

void ExtremelyLevels(double array[][], double& min, double& max, int index1, int index2){
   max = -100000;
   min = 100000;
   for(int i = index1; i <= index2; i++){
      if (max < array[i][0]){
         max = array[i][0];
      }
      if (min > array[i][0]){
         min = array[i][0];
      }      
   }
} 