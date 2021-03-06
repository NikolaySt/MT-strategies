

int DeleteObjects(){ 
   string name1, name2, name3, name4, name5, name6, name7 = "";  
   //имената трявва да са със една дължина
   name1 = "text";
   name2 = "line";
   //ObjectsDeleteAll(NULL, OBJ_LABEL);
   //ObjectsDeleteAll(NULL, OBJ_TEXT);
   //ObjectsDeleteAll(NULL, OBJ_TREND);
   InternalDeleteObjects(name1, name2);   
   
}

string TimeFrameТоString( int TimeFrame )
{
   switch(TimeFrame){
      case PERIOD_M1: return("1 Minute");
      case PERIOD_M5: return("5 Minutes");
      case PERIOD_M15: return("15 Minutes");
      case PERIOD_M30: return("30 Minutes");
      case PERIOD_H1: return("1 Hour");
      case PERIOD_H4: return("4 Hours");
      case PERIOD_D1: return("Daily");
      case PERIOD_W1: return("Weekly");
      case PERIOD_MN1: return("Monthly");
      default: return("");
   }  
}

int TimeFrameFromString( string value )
{
   //"M5 M15 H1 H4 D1 W1 MN
  int result =-1;
  if( value == "M1" ) 
  {
      result = PERIOD_M1;
  }    
  if( value == "M5" ) 
  {
      result = PERIOD_M5;
  }     
  if( value == "M15" ) 
  {
      result = PERIOD_M15;
  }     
  if( value == "M30" ) 
  {
      result = PERIOD_M30;
  }    
  if( value == "H1" ) 
  {
      result = PERIOD_H1;
  } 
  else if( value == "H4" )
  {
      result = PERIOD_H4;    
  } 
  else if( value == "D1" )
  {
      result = PERIOD_D1;    
  } 
  else if( value == "W1" )
  {
      result = PERIOD_W1;    
  }   
  else if( value == "MN" )
  {
      result = PERIOD_MN1;    
  }   
  else if( value == "" )
  {
      result = 0;    
  }
  
  return (result);
}


void ArrayResizeInternal_1D(string &array[], int index, int inc = 20){
   if (index >= ArraySize(array)) ArrayResize(array, index + inc);              
}
int AddElementToArrayText(string& arr[], string text, int& index){
   arr[index] = text; index++;
   ArrayResizeInternal_1D(arr, index);
   return(index);
}         
int InternalDeleteObjects(string name1 = "", string name2 = ""){            

   string arr_obj[20];      
   string name_obj, prefix;
   int i, index_arr = 0;
   int count_obj = ObjectsTotal();
   
   for (i = 0; i < count_obj; i++){
      name_obj = ObjectName(i);      
      prefix = StringSubstr(name_obj, 0, StringLen(name1));                   
      if (prefix == name1) index_arr = AddElementToArrayText(arr_obj, name_obj, index_arr);        
      if (prefix == name2) index_arr = AddElementToArrayText(arr_obj, name_obj, index_arr);                                
   }
   
   for (i = 0; i < index_arr; i++){ ObjectDelete(arr_obj[i]); }      

   return(0);
}

bool DrawLine(string name, string text, int shift1, int shift2, 
   double price1, double price2, color linecolor, int width, int style = STYLE_SOLID, bool ray = false){
   
   if(ObjectFind(name)<0) ObjectCreate(name, OBJ_TREND, 0, 0, 0);   
   
   ObjectSet(name, OBJPROP_TIME1, Time[shift1]); 
   ObjectSet(name, OBJPROP_TIME2, Time[shift2]);
   ObjectSet(name, OBJPROP_PRICE1, price1); 
   ObjectSet(name, OBJPROP_PRICE2, price2);         
   ObjectSet(name, OBJPROP_RAY, ray);
   ObjectSet(name, OBJPROP_COLOR, linecolor);
   ObjectSet(name, OBJPROP_WIDTH, width); 
   ObjectSet(name, OBJPROP_STYLE, style);

   ObjectSetText(name, text, 12, "Arial", Blue);       
      
   return(0);   
}


void SetTextEx(string name, string text, int shift, double price, int time_color){    
   if (price == 0 || shift >= Bars){return(0);}                
   if ( ObjectFind(name) < 0 ) ObjectCreate(name, OBJ_TEXT, 0, 0, 0);    
   ObjectMove(name, 0, Time[shift], price);            
   ObjectSetText(name, text, 10, "Arial Narrow", time_color);
   return(0);
}

/*
if (check_trace){      
      Print("count = ", count);
      Print("start = ", start);
      Print("begin_shift = ", curr_shift);
      Print("end_shift = ", iBarShift(NULL, Period(), next_time));
      
      check_trace = false;
   }        
*/

int GetLLShiftFrame(int time, int timeframe){
   if (timeframe == Period()){
      return(iBarShift(NULL, Period(), time)); 
   }else{
      int count, start;       
      int time_shift = iBarShift(NULL, timeframe, time);
      int curr_shift = iBarShift(NULL, Period(), time);
      
      if (time_shift == 0){
         count =  curr_shift;
         start = 0; 
      }else{     
         datetime next_time = iTime(NULL, timeframe, time_shift - 1);            
         count =  curr_shift - (iBarShift(NULL, Period(), next_time));                  
         start = curr_shift - count;// + 1;                        
      }  
      return(iLowest(NULL, Period(), MODE_LOW, count, start));
   }
}

int GetHHShiftFrame(int time, int timeframe){
   if (timeframe == Period()) {
      return(iBarShift(NULL, Period(), time)); 
   }else{         
      int count, start;       
      int time_shift = iBarShift(NULL, timeframe, time);
      int curr_shift = iBarShift(NULL, Period(), time);
      
      if (time_shift == 0){
         count =  curr_shift;
         start = 0; 
      }else{                 
         datetime next_time = iTime(NULL, timeframe, time_shift - 1);            
         count =  curr_shift - (iBarShift(NULL, Period(), next_time));                  
         start = curr_shift - count;// + 1 
         //трябва да е +1 за всички часови нива с изключение на 
         //Ден-Седмица защото там има грешка която е от МТ, за да хване първия бар         
      }            
      
      return(iHighest(NULL, Period(), MODE_HIGH, count, start));               
   }
}



