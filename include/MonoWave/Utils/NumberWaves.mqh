#define const_wavenumber 200
int view_number_wave_count;
double WaveNumber[const_wavenumber][2];
/*
   WaveNumber[0][0] = цена на която се поставя номер            
   WaveNumber[0][1] = shift - на който се слага номера!
*/

void CreateNumberWaves(double array[][], int arr_index, int shift){
   if (NumberWaveView){      
      if (CheckPoint_ViewNumberWave(shift) && view_number_wave_count < const_wavenumber){
         //цена
         WaveNumber[view_number_wave_count][0] = 
            (array[arr_index-1][2] + array[arr_index-2][2])/2;
            
         //shift
         WaveNumber[view_number_wave_count][1] = 
            MathRound((array[arr_index-1][1] + array[arr_index-2][1])/2);
            
         view_number_wave_count++;
      }
   }
}   


void AddChronoNumber(){
   //View Chrono-------------------
   int list_in_chrono_position = 0;
   double step_chrono = (WindowPriceMax() - WindowPriceMin())*0.04;//iATR(NULL, 0, 20, 0)*0.5;   
   double step_chrono_offset = 0;
   //-------------------------------
   //View Wave Number, View Chrono List---------------------------------------------------
   if (view_number_wave_count > 0 && NumberWaveView){
      for (int vn = 1; vn <= view_number_wave_count; vn++){                             
         SetText(
            WaveNumber[view_number_wave_count - vn][1], 
            WaveNumber[view_number_wave_count - vn][0], 
            DoubleToStr(vn, 0), 8, DarkGray, "wave");  
          
         
         //View Chrono-----------------------------------------------   
         if (chrono_count > 0 && list_in_chrono_position <= chrono_count){
            SetText(
                  MathRound(chrono_masive[list_in_chrono_position][0])-8, 
                  chrono_masive[list_in_chrono_position][1] - step_chrono_offset, 
                  "Ch:" + DoubleToStr(vn, 0) + "-", 10, Black, "chrono"+DoubleToStr(vn, 0)+":");                                      
            step_chrono_offset = step_chrono_offset + step_chrono; 
            if (MathMod(vn, 10) == 0){
               list_in_chrono_position++; 
               step_chrono_offset = 0;              
            }
         }
         //---------------------------------------------------------
         
      }
   }
   //-----------------------------------------------------------------------------------
}