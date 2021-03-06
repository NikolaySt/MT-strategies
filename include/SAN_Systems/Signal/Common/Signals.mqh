
bool Signal_Trace = false;

void Common_Signals_Init(int settID)
{
   Signal_TimeFrame = SAN_AUtl_TimeFrameFromStr(Signal_TimeFrameS);   
}

//-----------------------------------------------------------------------------------

bool Common_Signals_IsActive(){
   if (IsTesting()){
      //ВАЖНО! ползва се само при тестове задава година по година сделките, ако е извън зададената година не отваря сделки
      int curr_year = TimeYear(Time[1]);
      if ((curr_year == Signal_Year && Signal_WorkByToday == 1 && Signal_Year != 0) // условието задава само една година на пресмятане
          || 
          ((Signal_WorkByToday == 0) && curr_year >= Signal_Year && Signal_Year != 0) //задава от дадената година до днес
          || 
          (Signal_Year == 0) // за всички години за които има история
         ){         
         return(true);
      }else{
         //затваря всички поръчки когато излезне извън зоната на периода
         return(false);   
      }       
   }else{
      // когато не правим тестове а системата работи реално.
      return(true);
   }   
}

