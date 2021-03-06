//+------------------------------------------------------------------+
//|                                              Ard_CountTrends.mq4 |
//|                                    Copyright © 2009 Ariadna Ltd. |
//|                                              revision 26.10.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009 Ariadna Ltd."
#property link      "revision 26.10.2009"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
      Comment("MODE_TICKVALUE = " + MarketInfo(Symbol(), MODE_TICKVALUE) + 
      "\n MODE_TICKSIZE = " + MarketInfo(Symbol(), MODE_TICKSIZE) + 
      "\n LOT_SIZE = " + MarketInfo(Symbol(),MODE_LOTSIZE) +
      "\n value_point = " + MarketInfo(Symbol(), MODE_TICKVALUE) * 0.1  
      );
      

  
   string desc, name, str;
   datetime time;
   int total = ObjectsTotal();   
   
   int handle = FileOpen("trend.txt", FILE_CSV|FILE_WRITE, ",");
   if(handle < 1){
      Print("File trend.dat not found, the last error is ", GetLastError());
      return(false);
   }


   for (int i = 0; i < total; i++){
      name = ObjectName(i);
      if (ObjectType(name) == OBJ_VLINE){
         time = ObjectGet(name, OBJPROP_TIME1);
         desc = ObjectDescription(name);       
         
         str = TimeDay(time) + "." +  TimeMonth(time) + "." + TimeYear(time) + "," + desc; 
         FileWrite(handle, str);
      }         
   }   
   FileClose(handle);
   
   //InitArrTrend();
   return(0);
  }
//+------------------------------------------------------------------+

string Array_Trend[100][2];
bool InitArrTrend(){
   int handle = FileOpen("trend_daily_EUR.txt", FILE_CSV|FILE_READ, ",");
   if(handle < 1){
      Print("File trend_daily_EUR.txt not found, the last error is ", GetLastError());
      return(false);
   }
   string buff;
   while(FileTell(handle) < FileSize(handle)){      
      Print(FileReadString(handle, 12) +","+ FileReadString(handle, 4));
   }
   FileClose(handle);   
}   