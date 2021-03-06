/*-------------------------------------------------------------------------------
   МАСИВИ 
      1. МЛ точки (барове) (arr_ml_bars)
      2. Върховете и дъната на МЛ (arr_ml_peaks)
--------------------------------------------------------------------------------*/
/*------------------------------------------------------------------------------
//arr_ml_bars
[][0] high, 
[][1] low, 
[][2] time, 
[][3] направление - нагоре: 1, надолу:-1;, 
[][4] - кой пореден бар е в направлението /време/
[][5] - записва дали МЛ бара е формиран или все още се формира 1-формиран, 0 - в момента се формира

//arr_ml_peaks
[][0] връх/дъно - стойност, 
[][1] време бара в който е формиран, 
[][2] тип- връх: 1, дъно:-1;, 
[][3] брой барове в направлението - vreme;
[][4] записва дали върха е формиран и е устйчив или все още се формира 1-формиран, 0 - в момента се формира
[][5] записва датата на мл бар който е формира върха, това е текущи бар, а не бара на който е върха ползва се изтриване на връховете които в момента могат да се променят
------------------------------------------------------------------------------*/
double arr_ml_bars[20][6]; int index_ml_bars = 0;
double arr_ml_peaks[20][6]; int index_ml_peaks = 0;
void InitArraysParams(){
   index_ml_bars = 0; ArrayInitialize(arr_ml_bars, 0);
   index_ml_peaks = 0; ArrayInitialize(arr_ml_peaks, 0);         
}

void ArrayResizeInternal_2D(double&array[][], int index, int inc = 20){
   // ако масива e нарастнал повече от текущи му размер го увеличава с още 20 елемента
   int dim = ArrayRange(array, 1);
   if (index*dim >= ArraySize(array)) ArrayResize(array, index*dim + inc*dim);              
}

/*--------------------------------------------------------------------------------------

      ФУНКЦИИ за работа с масив МЛ барове /arr_ml_bars/

---------------------------------------------------------------------------------------*/


int MLSetBar(double high, double low, datetime time, int direction, double count, int forming){   
   arr_ml_bars[index_ml_bars][0] = high;
   arr_ml_bars[index_ml_bars][1] = low;
   arr_ml_bars[index_ml_bars][2] = time;
   arr_ml_bars[index_ml_bars][3] = direction;           
   arr_ml_bars[index_ml_bars][4] = count;
   arr_ml_bars[index_ml_bars][5] = forming;
   index_ml_bars++;
   /*
   if (index_ml_bars > 299){
      ArrayCopy(arr_ml_bars, arr_ml_bars, 0, 149, 299);      
      index_ml_bars = 150;
   }
   
   */
   
   ArrayResizeInternal_2D(arr_ml_bars, index_ml_bars);
   //връща индекса на добавения елемент;     
   return(index_ml_bars-1);   
}

void MLRecalcArrayIndex(datetime time){

   if (index_ml_bars == 0) return;   
   int index = index_ml_bars - 1;
   //&& MLBarForming(index_ml_bars) == 0
   while (MLBarTime(index) == time  && index >= 0){
      index--;        
   }   
   index_ml_bars = index + 1;

}

void MLGetBar(int index, double& high, double& low, datetime& time, int& direction){   
   high = arr_ml_bars[index][0];
   low = arr_ml_bars[index][1];
   time = arr_ml_bars[index][2];
   direction = arr_ml_bars[index][3]; 
}

bool MLGetLastBar(double& high, double& low, datetime& time, int& direction){     
   int index = index_ml_bars - 1;
   if (index >= 0){
      high = arr_ml_bars[index][0];
      low = arr_ml_bars[index][1];
      time = arr_ml_bars[index][2];
      direction = arr_ml_bars[index][3]; 
      return(true);
   }
   return(false);   
}

datetime MLGetTimeLastBar(){     
   int index = index_ml_bars - 1;
   if (index >= 0){
      return(arr_ml_bars[index][2]);
   }
   return(-1);   
}
int MLGetTypeLastBar(){
   int index = index_ml_bars - 1;
   if (index >= 0){
      return(arr_ml_bars[index][3]);
   }
   return(-1);   
}

int MLLastBarIndex(){ 
   if (index_ml_bars > 0){
      return(index_ml_bars - 1);
   }else{
      return(-1);
   }      
}

int MLLastFormBarIndex(){ 
   //връща последния формиран екстремум
   int index = index_ml_bars-1;     
   while (arr_ml_bars[index][5] != 1 && index >= 0){      
      index--;
   }
   return(index);    
}

bool MLBarHighLowByTime(datetime time, double& high, double& low){
   int index = MLLastBarIndex();
   high = 0; low = 0;
   if (index == -1) return(false);
   else{
      bool check_find = false;
      while (index >=0){
         if (MLBarTime(index) >= time) index--; else {check_find = true; break;}
      }
      if (check_find){
         high = MLBarHigh(index);
         low = MLBarLow(index);  
         return(true);
      }else{
         return(false);
      }  
   }          
}

double MLBarHigh(int index){return(arr_ml_bars[index][0]);}
double MLBarLow(int index){return(arr_ml_bars[index][1]);}
int MLBarType(int index){return(arr_ml_bars[index][3]);}
datetime MLBarTime(int index){return(arr_ml_bars[index][2]);}
double MLBarTimeCount(int index){return(arr_ml_bars[index][4]);}
int MLBarForming(int index){return(arr_ml_bars[index][5]);}
void MLSetBarForming(int index, int forming){ arr_ml_bars[index][5] = forming;}

double MLGetLastPoint(){
   int index = MLLastBarIndex();
   if (MLBarType(index) == 1) return(MLBarHigh(index));
   if (MLBarType(index) == -1) return(MLBarLow(index));
   return(0);
}

double MLGetCountLastBar(){
   int index = index_ml_bars - 1;
   if (index >= 0) return(arr_ml_bars[index][4]); else return(0);   
}


double MLGetLastCountTime_Type(int type){
   int index = MLLastBarIndex();
   if (index >= 0){
      if (type == arr_ml_bars[index][3]){
         return(arr_ml_bars[index][4]);
      }else{
         return(0);         
      }
   }
   return(0);  
}

int MLGetLowestHigh(int count, int begin){
//Намира Motion бара с най-ниския връх   
   double level = MLBarHigh(begin); 
   int result = begin; 
   int i = begin - 1;       
   while (i >= begin-count){
      
      if (MLBarHigh(i) < level){
         result = i;    
         level = MLBarHigh(i);
      }
      i--;     
   }      
   return(result);
}

int MLGetHighestLow(int count, int begin){   
//Намира Motion бара с най-високо дъно   
   double level = MLBarLow(begin);    
   int result = begin; 
   
   int i = begin-1;       
   while (i >= begin-count){   
      if (MLBarLow(i) > level){
         result = i;    
         level = MLBarLow(i);
      }
      i--;     
   }      
   
   return(result);
}

int MLGetLowestLow(int count, int begin){   
   //Намира Motion бара с най-ниско дъно
   double level = MLBarLow(begin); 
   int result = begin; 
   int i = begin-1;       
   while (i >= begin-count){
          
      if (MLBarLow(i) < level){
         result = i;    
         level = MLBarLow(i);
      }
      i--; 
   }      
   return(result);
}

int MLGetHighestHigh(int count, int begin){
   //Намира Motion бара с най-ниския връх          
   double level = MLBarHigh(begin); 
   int result = begin; 
   int i = begin - 1;
   while (i >= begin-count){         
      if (MLBarHigh(i) > level){
         result = i;    
         level = MLBarHigh(i);
      }
      i--;  
   }      
   return(result);
}


/*--------------------------------------------------------------------------------------

      ФУНКЦИИ за работа с масив върхове /arr_ml_peaks/

---------------------------------------------------------------------------------------*/
int MLSetPeak(double value, datetime time, int type_peak, double count, int forming, datetime time_forming = 0){   
   arr_ml_peaks[index_ml_peaks][0] = value;
   arr_ml_peaks[index_ml_peaks][1] = time;
   arr_ml_peaks[index_ml_peaks][2] = type_peak;  //"+1" - връх, "-1" - дъно
   arr_ml_peaks[index_ml_peaks][3] = count;
   arr_ml_peaks[index_ml_peaks][4] = forming; //1 формиран, 0 в процес на формиране
   arr_ml_peaks[index_ml_peaks][5] = time_forming; 
   index_ml_peaks++;  
   /*
   if (index_ml_peaks > 299){
      ArrayCopy(arr_ml_peaks, arr_ml_peaks, 0, 149, 299);      
      index_ml_peaks = 150;
   }   
   */
   ArrayResizeInternal_2D(arr_ml_peaks, index_ml_peaks);
   return(index_ml_peaks - 1);   //връща индекса на добавения елемент;
}

void PeakRecalcArrayIndex(datetime time){

   if (index_ml_peaks == 0) return;   
   int index = index_ml_peaks - 1;
//arr_ml_peaks[index][4] == 0
   while (arr_ml_peaks[index][5] == time && index >= 0){
      index--;        
   }   
   index_ml_peaks = index + 1;

}

void RecalcArrayIndexByOne(){
   if (index_ml_peaks == 0) return;   
   index_ml_peaks--;   
}


void MLGetPeak(int index, double& value, datetime& time, int& type_peak, double& count){   
   value = arr_ml_peaks[index][0];
   time = arr_ml_peaks[index][1];
   type_peak = arr_ml_peaks[index][2]; //"+1" - връх, "-1" - дъно
   count = arr_ml_peaks[index][3];
}



bool MLGetLastPeak(double& value, datetime& time, int& type_peak, double& count){   
   int index = index_ml_peaks - 1;
   if (index >= 0){
      value = arr_ml_peaks[index][0];
      time = arr_ml_peaks[index][1];
      type_peak = arr_ml_peaks[index][2];
      count = arr_ml_peaks[index][3];
      return(true);
   }
   return(false);
}

double MLGetLastPeakCount(){   
   int index = index_ml_peaks - 1;
   if (index >= 0){
      return(arr_ml_peaks[index][3]);
   }
   return(0);
}

bool MLGetLastFormPeakType(int type_peak, double& value, datetime& time, double& count){   
   //връща последния екстремум според зададения тип
   int index = index_ml_peaks-1;
   bool chfind = false;       
   
   while (!chfind && index >= 0){
      value = arr_ml_peaks[index][0];
      time = arr_ml_peaks[index][1];
      count = arr_ml_peaks[index][3];      
          
      if (type_peak == arr_ml_peaks[index][2] && arr_ml_peaks[index][4] == 1){   
            return(true);
      }else{       
         index--;
      }   
   }
   return(false);
}

int MLLastPeakIndex(){  if (index_ml_peaks > 0)  return(index_ml_peaks - 1); else return(0); }

datetime MLPeakTime(int index){     
   return(arr_ml_peaks[index][1]);
}

int MLLastFormPeakIndex(){ 
   //връща последния екстремум според зададения тип
   int index = index_ml_peaks-1;     
   while (arr_ml_peaks[index][4] != 1 && index >= 0){
      index--;
   }
   return(index);
   
}   

int MLGetFormingPeak(int index){ 
   return(arr_ml_peaks[index][4]);   
} 

double MLGetFormingDatePeak(int index){ 
   return(arr_ml_peaks[index][5]);   
} 

void MLSetFormingPeak(int index, int forming){ 
   arr_ml_peaks[index][4] = forming;   
} 

void MLSetFormingPeakLastThree(int forming){ 
   int index = index_ml_peaks-1;     
   int end = index - 3;
   if (end < 0) end = 0;
   while (index >= end){
      arr_ml_peaks[index][4] = forming;       
      index--;
   }   
     
} 