//+------------------------------------------------------------------+
//|                                                  Ard_Moda_Fr.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 18.11.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 18.11.2009"

 int       BarsFr=3;
 int       STEP=1;
string OBJECT_PREFIX = "LEVELS";
int ObjectId = 0;



  
void ObDeleteObjectsByPrefix(string Prefix)
  {
   int L = StringLen(Prefix);
   int i = 0; 
   while(i < ObjectsTotal())
     {
       string ObjName = ObjectName(i);
       if(StringSubstr(ObjName, 0, L) != Prefix) 
         { 
           i++; 
           continue;
         }
       ObjectDelete(ObjName);
     }     
   
  }  


int start()
  {
   int    counted_bars=IndicatorCounted();
   int shift;
   double value_up, value_down;
   datetime time_fr_up,time_fr_down;
   
   ObDeleteObjectsByPrefix(OBJECT_PREFIX);
   ObjectId = 0;
   int save_calc_shift = -1;
   for(int i = 2000; i >= 0; i--){
   
      shift = iBarShift(NULL, PERIOD_D1, Time[i]);
      if (save_calc_shift != shift){                  
         CreateMP(iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, shift)) + 1, iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, shift+1)));
         save_calc_shift = shift;
      }
   }
   return(0);
  }

string ObGetUniqueName(string Prefix)
{
   ObjectId++;
   return (Prefix+"_"+ObjectId);
}

bool CreateMP(int shift_begin, int shift_end){
   double HH = High[iHighest(NULL, NULL, MODE_HIGH, shift_end - shift_begin + 1, shift_begin)];
   double LL = Low[iLowest(NULL, NULL, MODE_LOW, shift_end - shift_begin + 1, shift_begin)];


   int NumberOfPoints = (HH - LL) / (1.0*Point*STEP) + 1;
   int Count[];
   ArrayResize(Count, NumberOfPoints);   
   ArrayInitialize(Count, 0);

   for(int i = shift_begin; i <= shift_end; i++){
      double C = CSL(i);
      while(C < CSH(i)){
        int Index = (C-LL) / (1.0*Point*STEP);
        Count[Index]++;    
        C += 1.0*Point*STEP;
      }
   }    
   
   for(i = 0; i < NumberOfPoints; i++){
   
      double StartX = Time[shift_end];
      double StartY = LL + 1.0*Point*STEP*i;
      double EndX   = Time[shift_end-Count[i]];
      double EndY   = StartY;
      string ObjName = ObGetUniqueName(OBJECT_PREFIX);
      ObjectDelete(ObjName);
      ObjectCreate(ObjName, OBJ_TREND, 0, StartX, StartY, EndX, EndY);
      ObjectSet(ObjName, OBJPROP_RAY, 0);
      ObjectSet(ObjName, OBJPROP_COLOR, Red);
      ObjectSet(ObjName, OBJPROP_WIDTH, 3);
   }     
}

double CSH(int shift)
  {
   return (MathMax(Open[shift], Close[shift]));
  }

double CSL(int shift)
  {
   return (MathMin(Open[shift],Close[shift]));
  }