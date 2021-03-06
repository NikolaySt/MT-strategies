//+------------------------------------------------------------------+
//|                                               Ard_MedianLine.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 18.11.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 18.11.2009"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   CreateML(iBarShift(NULL, Period(), StrToTime("2006.05.03 00:00")), iBarShift(NULL, Period(), StrToTime("2006.05.01 16:00")));
   return(0);
  }
//+------------------------------------------------------------------+

string OBJECT_PREFIX = "LEVELS";
int ObjectId = 0;

string ObGetUniqueName(string Prefix)
{
   ObjectId++;
   return (Prefix+"_"+ObjectId);
}

double CreateML(int shift_begin, int shift_end){
   double HH = High[iHighest(NULL, NULL, MODE_HIGH, shift_end - shift_begin + 1, shift_begin)];
   double LL = Low[iLowest(NULL, NULL, MODE_LOW, shift_end - shift_begin + 1, shift_begin)];
   
   double range = 0;
   for(int i = shift_begin; i <= shift_end; i++){
      range = range + (HH - High[i]);
   }    
   
   double point = range/(shift_end - shift_begin+ 1);
   
   
   double StartX = Time[shift_end];
   double StartY = HH - point;
   double EndX   = Time[shift_begin];
   double EndY   =  HH - point;
   string ObjName = ObGetUniqueName(OBJECT_PREFIX);
   ObjectDelete(ObjName);
   ObjectCreate(ObjName, OBJ_TREND, 0, StartX, StartY, EndX, EndY);
   ObjectSet(ObjName, OBJPROP_RAY, 0);
   ObjectSet(ObjName, OBJPROP_COLOR, Red);
   

}