//+------------------------------------------------------------------+
//|   Пресмята отклонението BIAS
//+------------------------------------------------------------------+
int bias_index = 0;
int bias_direction = 0; // -1 тренд надолу, +1 тренд нагоре
int save_fisrt_bias_shift = 0;


void SetBias_BeginIndex(int index){save_fisrt_bias_shift = index;}
int GetBias_BeginIndex(){return(save_fisrt_bias_shift);}

void SetBias_Index(int value){ bias_index = value;}
int GetBias_Index(){ return(bias_index);}

int GetBias_Direction(){ return(bias_direction);}
void SetBias_Direction(int value){ bias_direction = value;}

double GetBias_Level(){
   double high, low; datetime time; int ml_type;
   MLGetBar(GetBias_Index(), high, low, time, ml_type);   
   if (GetBias_Direction() == 1)  return(low);
   if (GetBias_Direction() == -1)  return(high);
}   
datetime GetBias_LevelTime(){
   double high, low; datetime time; int ml_type;
   MLGetBar(GetBias_Index(), high, low, time, ml_type);   
   return(time);   
} 

void InitBiasParams(){
   bias_index = 0;
   bias_direction = 0; // -1 тренд надолу, +1 тренд нагоре
   save_fisrt_bias_shift = 0;
}

void Bias_Process(){
   double high, low; datetime time; int ml_type;   
   MLGetLastBar(high, low, time, ml_type);   // за отчитане пробива ползва последнини бар от ML без значение дали е формиран или не /т.е. дали е текущ/
   int shift = GetShift(time, GetTimeFrame());   
   double close = GetClose(shift, GetTimeFrame());
      
   if (GetBias_Direction() == 0){
      //при начално започване. все още липсва посока
      SetBias_Direction(1); //- поставя някаква
      SetBias_Index(0); 
      SetBias_BeginIndex(0);
   }         
      
   if (GetBias_Direction() == 1){
      if (close < GetBias_Level()){ 
      //if (low < GetBias_Level()){                           
         Bias_BreakProcess(); 
      }else{         
         Bias_Continue();                   
      }         
   }else{
      if (GetBias_Direction() == -1){ 
         if (close > GetBias_Level()){       
         //if (high > GetBias_Level()) {                                                     
            Bias_BreakProcess(); 
         }else{
            Bias_Continue();
         }            
      }
   }
}


void Bias_BreakProcess(){  
   int index;
   int last_mlbar = MLLastFormBarIndex();   
   if (GetBias_Direction() == 1) {     
      SetBias_Direction(-1);                                          
      
      //Намираме Индекса на ML бара с най-висок връх което ни служи за край на връщането назад
      //и го записваме. Ще ни служи за репер докато новия биас е //отрицателен//
      SetBias_BeginIndex(MLGetHighestHigh(last_mlbar - GetBias_Index(), last_mlbar));              
      
     
      //намираме индекса на МЛ бара който е с най-нисък връх в интервала от последния формиран бар
      //до началото на GetBias_BeginIndex      
      index = MLGetLowestHigh(last_mlbar - GetBias_BeginIndex(), last_mlbar);                     

      //намираме индекса на бара който служи за нiиво на биас;
      SetBias_Index(Bias_CalcHighIndex(index - GetBias_BeginIndex()+1, index));                     
   }else{      
      if (GetBias_Direction() == -1) {
         SetBias_Direction(1);                  
         //Намираме Индекса на ML бара с най-ниското дъно което ни служи за край на връщането назад
         //и го записваме ще ни служи за репер докато новия биас е //положителен//
         SetBias_BeginIndex(MLGetLowestLow(last_mlbar - GetBias_Index(), last_mlbar));        
                
                  
         //намираме индекса на МЛ бара който е с най-високo дъно в интервала от последния формиран бар
         //до началото на GetBias_BeginIndex
         index = MLGetHighestLow(last_mlbar - GetBias_BeginIndex(), last_mlbar);
         
         
         //намираме индекса на бара който служи за ниво на биас;
         SetBias_Index(Bias_CalcLowIndex(index - GetBias_BeginIndex()+1, index));  
      }      
   }      
                           
}


void Bias_Continue(){   
   int index;           
   int last_mlbar = MLLastFormBarIndex();
   if (GetBias_Direction() == 1){                     
      //намираме индекса на МЛ бара който е с най-висок дъно в интервала от последния формиран бар
      //до началото на GetBias_BeginIndex
      index = MLGetHighestLow(last_mlbar - GetBias_BeginIndex(), last_mlbar);
      
      //намираме индекса на бара който служи за ново на биас;
      SetBias_Index(Bias_CalcLowIndex(index - GetBias_BeginIndex(), index));      
   }   
   
   if (GetBias_Direction() == -1){
      //намираме индекса на МЛ бара който е с най-нисък връх в интервала от последния формиран бар
      //до началото на GetBias_BeginIndex      
      index = MLGetLowestHigh(last_mlbar - GetBias_BeginIndex(), last_mlbar);
      
      //намираме индекса на бара който служи за ново на биас;
      SetBias_Index(Bias_CalcHighIndex(index - GetBias_BeginIndex(), index));  
   }
}


//-------------------------------------------------------------------------
//Намира "отрицателното" Отклонението (Bias) в даден интервал от Motion барове.
//-------------------------------------------------------------------------
int Bias_CalcHighIndex(int count, int begin){   
   bool find = false; 
   
   double level = MLBarHigh(begin); 
   int result = begin; 
   
   int bias_bar_count = 1;
   
   int i = begin - 1;
   while (i >= begin-count && !find){
           
      if (MLBarHigh(i) > level){
         level = MLBarHigh(i);  
         result = i;        
         bias_bar_count++;
         
         if (bias_bar_count == BiasBars) find = true;                       
      } 
      i--;      
            
   }      
   return(result);       
}

//-------------------------------------------------------------------------
//Намира "положителното" Отклонението (Bias) в даден интервал от Motion барове.
//-------------------------------------------------------------------------
int Bias_CalcLowIndex(int count, int begin){
   bool find = false; 
   
   double level = MLBarLow(begin);
   int result = begin;
    
   int bias_bar_count = 1;   
   
   int i = begin - 1;  
   
   while (i >= begin-count && !find){
   
      if (MLBarLow(i) < level){
         level = MLBarLow(i);  
         result = i;        
         bias_bar_count++;
         
         if (bias_bar_count == BiasBars) find = true;                       
      }      
      i--;               
   }      
   return(result); 
}


