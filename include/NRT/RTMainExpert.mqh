
#define TYPE_DOWN_ML_BREAK_HIGHPEAK 1001
#define TYPE_UP_ML_BREAK_LOWPEAK 2001
#define TYPE_LOW_PEAK_FORM 3001
#define TYPE_HIGH_PEAK_FORM 4001


void RT_Main_Process(int bars = 150){  
   int timeframe = GetTimeFrame();   
   //if (Bars < 150) return;
   int shift = bars;    
   int index;
   
   bool check_exit_high, check_exit_low;
   double high, low;
   
   //параметри за MLGetLastPeak
   double value; datetime time; int type_peak; double count;   
     
   while (Condition(shift)){
      
      //записва екстремумите на бара
      index = shift; //iBarShift(NULL, timeframe, Time[shift]);
         
      if (bars == 2){
         // за eксперти взима екстремумите на последния бар с по-малка дата от зададената
         // ако няма такъв взима бара от графиката
         if (!MLBarHighLowByTime(GetTime(0, timeframe), high, low)){      
            high = GetHigh(index, timeframe);
            low = GetLow(index, timeframe);                             
         }
      }else{
         high = GetHigh(index, timeframe);
         low = GetLow(index, timeframe);               
      }
       
      check_exit_high = false;        
      check_exit_low = false;            
      
      while (!check_exit_high && !check_exit_low && Condition(shift)){  
         //търси бар пробиващ екстремум/екстремумите на бара преди входа в цикъла                                                    
         shift--;                  
         index = shift; //iBarShift(NULL, timeframe, Time[shift]);            
         RT_Process_Logic(index);
         if (GetHigh(index, timeframe) > high) check_exit_high = true;
         if (GetLow(index, timeframe) < low) check_exit_low = true;                     
         if  (!check_exit_high && !check_exit_low) TimeChange_NeutralLevel();                                       
       
      }   
             
      if (bars == 2 && (check_exit_high || check_exit_low)){ // само за експерт          
         if (GetTime(index, timeframe) == MLBarTime(MLLastBarIndex()))  {      
            //ако последниата добавена МЛ точка (бар) е същата дата като текущуя бар
            //следователно трябва да редактираме вместо да добавяме нова точка      
            //затова връщаме индекса назад за може да презапишем точките върху старите           
            PeakRecalcArrayIndex(GetTime(index, timeframe));//изчиства неформираните върхове           
            MLRecalcArrayIndex(GetTime(index, timeframe));               
         } 
      }                        
    
      if (check_exit_high && check_exit_low && MLGetLastPeak(value, time, type_peak, count)) {           
         //текущия бар е пробил и двата ексремума на предишния бар         
         if (GetLow(index, timeframe) < value && type_peak == -1) {
            //дъното на бара е пробило (LOW екстремум на MotionLine - най-близкия)                        
            RT_MLDirection(index, -1, timeframe, TYPE_UP_ML_BREAK_LOWPEAK);                          
         }else{                                          
            if (GetHigh(index, timeframe) > value && type_peak == 1) {   

               //върха на бара е пробил (HIGH екстремум на MotionLine - най-близкия)
               RT_MLDirection(index, 1, timeframe, TYPE_DOWN_ML_BREAK_HIGHPEAK);               
            }else{                 
               
               if (check_exit_high && MLGetTypeLastBar() == 1){
                  //пробив на нагоре по посоката на предишното направление на MotionLine                  
                  RT_MLDirection(index, 1, timeframe);                                                      
               }               
               if (check_exit_low && MLGetTypeLastBar() == -1){  
                  //пробив на долу по посоката на предишното направление на MotionLine           
                  RT_MLDirection(index, -1, timeframe);                                                        
               }                            
            }
         }                     
      }else{
         //текущия бар е пробил един от двата ексремума на предишния бар
         
         //пробив нагоре         
         if (check_exit_high) {
            MLGetLastFormPeakType(1, value, time, count); 
            if (GetHigh(index, timeframe) > value){ // проверяваме за пробив на предишен връх
               RT_MLDirection(index, 1, timeframe, TYPE_LOW_PEAK_FORM);          
            }else{            
               RT_MLDirection(index, 1, timeframe);          
            }               
            
         }        
             
         //пробив надолу
         if (check_exit_low) {
            MLGetLastFormPeakType(-1, value, time, count);           
            if (GetLow(index, timeframe) < value){// проверяваме за пробив на предишно дъно
               RT_MLDirection(index, -1, timeframe, TYPE_HIGH_PEAK_FORM);          
            }else{            
               RT_MLDirection(index, -1, timeframe);          
            }                                             
         }
      }    
      
      RT_Process_Logic(index);
                  
   } 
   TimeChange_NeutralLevel(); // праверка за неутралност   
   //приключва върх/дъно в последния ML бар 
   //RT_CheckEndPeak(0, MLBarType(MLLastBarIndex()), 0);   
   RT_Process_Logic(1);
}


void RT_MLDirection(int index, int DownUp, int timeframe, int type = -1){               
   int ML_bar_forming = 1; // по подразбиране бара е формиран
   //if (index == 0) ML_bar_forming = 0; // последен бар в момента се формира
   
   switch(type){
      case TYPE_DOWN_ML_BREAK_HIGHPEAK:
            // до момента движението е било надолу, текущи бар прави пробив на двата екстремума и на предишния връх от МЛ
            if (GetClose(index, timeframe) > GetOpen(index, timeframe)){                              
               //край на движение надолу
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), -1, MLGetLastCountTime_Type(-1)+0.5, 1);
               Bias_Process();
               Time_Process();
               RT_CheckEndPeak(index, -1, 1);   
                                                         
               
               //начало на движение нагоре
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(1)+0.5, ML_bar_forming);
               Bias_Process();
               Time_Process(); 
                         
            }else{               
               //приключва низходящо движение
               Time_Process();
               RT_CheckEndPeak(index, -1, 1);   
               //започва в същия бар движение нагоре и приключвa               
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(1)+0.5, 0);
               Bias_Process(); 
               //изчислява биас отклонението преди да зададе че бара е формиран това се прави с цел да се изчилис корекно Биас отклонението
               //т.к текущи бар е с два екстремума които може да пробият едновременно два срещуположни биас-а
               MLSetBarForming(MLLastBarIndex(), 1);
               
               
               Time_Process();
               RT_CheckEndPeak(index, 1, 1);  
                                                           
               //в същия бар започва движение надолу
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), -1, MLGetLastCountTime_Type(-1)+0.5, ML_bar_forming);
               Time_Process();
               Bias_Process();    
               
            }
         break;
      case TYPE_UP_ML_BREAK_LOWPEAK:  
            // до момента движението е било нагоре, текущи бар прави пробив на двата екстремума и на предишнито дъно от МЛ
            if (GetClose(index, timeframe) < GetOpen(index, timeframe)){      
               //приклчва възходящо движение
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), 1, MLGetLastCountTime_Type(1)+0.5, 1);
               Bias_Process(); 
               Time_Process();
               RT_CheckEndPeak(index, 1, 1);  
                
                                      
               //започва низходящо движение               
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(-1)+0.5, ML_bar_forming); 
               Time_Process();
               Bias_Process();
               
            }else{               
               //приключва възнодящо движение
               Time_Process();            
               RT_CheckEndPeak(index, 1, 1);   
                                                                           
               //започва низходящо движение и приключва               
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(DownUp)+0.5, 0); 
               Bias_Process(); 
               //изчислява биас отклонението преди да зададе че бара е формиран това се прави с цел да се изчисли корекно Биас отклонението
               //т.к текущи бар е с два екстремума които може да пробият едновременно два срещуположни биас-а
               MLSetBarForming(MLLastBarIndex(), 1);               
               Time_Process();                          
               RT_CheckEndPeak(index, -1, 1);                 
                              
                                           
               //в същи бар започва възходящо движение  
               MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), 1, MLGetLastCountTime_Type(1)+0.5, ML_bar_forming); 
               Bias_Process();
               Time_Process();                                      
               
            }   
            
         break;
      default: {        
         //if  (MLBarTimeCount(MLLastBarIndex()) > 1) MLSetFormingPeakLastThree(1);
         if (type == TYPE_LOW_PEAK_FORM || type == TYPE_HIGH_PEAK_FORM){
            //има пробито предишно дъно или врух от МЛ следователно последнния връх/дъно е формиран             
            RT_CheckEndPeak(index, DownUp*(-1), 1); // проверка за приключване на обратно движение ) 
         }else{  
            RT_CheckEndPeak(index, DownUp*(-1), ML_bar_forming);  // проверка за приключване на обратно движение ) 
         }            
         
         if (MLGetTypeLastBar() == DownUp){         
            MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, MLGetLastCountTime_Type(DownUp)+1, 0);             
         }else{
            MLSetBar(GetHigh(index, timeframe), GetLow(index, timeframe), GetTime(index, timeframe), DownUp, 1, 0); 
         }  
         Bias_Process(); 
         MLSetBarForming(MLLastBarIndex(), ML_bar_forming);  
         
         Time_Process();  
                                     
         break;
      }
   }    
   //проверека за пробив на ценовото ниво         
   Price_CheckBreak();       
}

void RT_CheckEndPeak(int index, int type_peak, int peak_forming){
   if (MLBarType(MLLastBarIndex()) == type_peak){
      //записва последния формиран връх или дъно от МЛ в масив                     
      MLSetPeak(MLGetLastPoint(), MLGetTimeLastBar(), MLBarType(MLLastBarIndex()), MLBarTimeCount(MLLastBarIndex()), peak_forming, GetTime(index, GetTimeFrame()));          
       
      //прави промяна на нивото на цената според новия връх  
      Price_LevelPeak();        
         
      //показва цифра на времето на върха/дъното оцветена в червено, жулно, зелено, бяло
      if (ActiveSetToChart) Time_SetPeak();
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

bool Condition(int index){ return(index > 1);}
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
/*
    
*/      