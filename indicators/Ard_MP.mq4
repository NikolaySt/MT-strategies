//+------------------------------------------------------------------+
//|                                                 Level Sensor.mq4 |
//|                                          Copyright © 2005, Sfen. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Sfen"
#property indicator_chart_window
// input parameters
extern int MAX_HISTORY = 500;
extern int STEP = 1;
//----
string OBJECT_PREFIX = "LEVELS";
int ObjectId = 0;

int init(){

   return(0);
}

int deinit(){
   ObDeleteObjectsByPrefix(OBJECT_PREFIX);
   return(0);
}

int start(){
   ObDeleteObjectsByPrefix(OBJECT_PREFIX);
   MP(1, Period(), 91, 0);
   return(0);
}
//+------------------------------------------------------------------+

void MP(int step, int timeframe, int count, int begin){
   string S;
   
   double HH, LL;   
   
   int i, j, k;

   HH = iHigh(NULL, timeframe, iHighest(NULL, timeframe, MODE_HIGH, count, begin));
   LL = iLow(NULL, timeframe, iLowest(NULL, timeframe, MODE_LOW, count, begin));
   
   int NumberOfPoints = (HH - LL) / (1.0*Point*step) + 1;
   int Count[];
   ArrayResize(Count, NumberOfPoints);
   ArrayInitialize(Count, 0);
   int moda = 0 , index_moda = 0; 
   double low, high; int index;
   for(i = begin; i <= begin + count; i++){
      low = iLow(NULL, timeframe, i);
      high = iHigh(NULL, timeframe, i);
      
      while(low < high){         
         index = (low - LL) / (1.0*Point*step);
         Count[index]++;    
         low = low + 1.0*Point*step;
         if (Count[index] > moda){
            index_moda = index;
            moda = Count[index]; 
         }         
      }
   }
   
   double StartX, StartY, EndX, EndY;   
   StartX = Time[5];
   string ObjName;
   for(i = 0; i < NumberOfPoints; i++){           
      StartY = LL + 1.0*Point*step*i;
      EndX   = Time[5+Count[i]];
      EndY   = StartY;

      ObjName = ObGetUniqueName(OBJECT_PREFIX);
      ObjectDelete(ObjName);
      ObjectCreate(ObjName, OBJ_TREND, 0, StartX, StartY, EndX, EndY);
      ObjectSet(ObjName, OBJPROP_RAY, 0);
      ObjectSet(ObjName, OBJPROP_COLOR, White);
   }      
   
   ObjName = ObGetUniqueName(OBJECT_PREFIX);
   ObjectDelete(ObjName);
   ObjectCreate(ObjName, OBJ_TREND, 0, Time[5], LL + 1.0*Point*step*index_moda, Time[5+Count[index_moda]], LL + 1.0*Point*step*index_moda);
   ObjectSet(ObjName, OBJPROP_RAY, 0);
   ObjectSet(ObjName, OBJPROP_COLOR, Red);
   ObjectSet(ObjName, OBJPROP_WIDTH, 4);
   
   
}


string IntToStr(int value){
   return (DoubleToStr(value, 0));
}

string ObGetUniqueName(string Prefix){
   ObjectId++;
   return (Prefix+" "+IntToStr(ObjectId));
}

void ObDeleteObjectsByPrefix(string Prefix){ 
   int L = StringLen(Prefix);
   int i = 0; 
   string ObjName;
   while(i < ObjectsTotal()){   
      ObjName = ObjectName(i);
      if(StringSubstr(ObjName, 0, L) != Prefix){ 
         i++; 
         continue;
      }
      ObjectDelete(ObjName);
   }   
}

double MP_MODA(int step, int timeframe, int count, int begin){
   
   double HH, LL;      
   int moda = 0 , index_moda = 0; 
   double low, high; int index;

   HH = iHigh(NULL, timeframe, iHighest(NULL, timeframe, MODE_HIGH, count, begin));
   LL = iLow(NULL, timeframe, iLowest(NULL, timeframe, MODE_LOW, count, begin));
   
   int NumberOfPoints = (HH - LL) / (1.0*Point*step) + 1;
   int mp_array[];
   ArrayResize(mp_array, NumberOfPoints);
   ArrayInitialize(mp_array, 0);      

   for(int i = begin; i <= begin + count; i++){
      low = iLow(NULL, timeframe, i);
      high = iHigh(NULL, timeframe, i);
      
      while(low < high){         
         index = (low - LL) / (1.0*Point*step);
         mp_array[index]++;    
         low = low + 1.0*Point*step;
         if (mp_array[index] > moda){
            index_moda = index;
            moda = mp_array[index]; 
         }         
      }
   }     
   return(LL + 1.0*Point*step*index_moda);
}