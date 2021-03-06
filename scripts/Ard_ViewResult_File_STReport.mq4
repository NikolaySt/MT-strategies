//+------------------------------------------------------------------+
//|                                               ARD_ViewResult.mq4 |
//|                                    Copyright © 2010, Ariadna Ltd |
//|                                              revision 15.05.2010 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ariadna Ltd"
#property link      "revision 15.05.2010"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

string ticket, type_open, type_close, item, description;


datetime open_time, close_time;
double lots, open_price, open_SL, close_SL, TP, close_price, ProfitLoss;

int start(){
   
   string value;   
   int i, hstTotal = OrdersHistoryTotal();
  /*
   SetInfo("",
      "МО = "+ DoubleToStr(Clac_PMO(true, false), 2) +  
      "\n" + "Коеф. RR =  " + RR_string_value +
      "\n" + "Познаваемост = " + Cognoscibility_string_value + "%");
  */


   int fhHistory = FileOpen("StrategyTesterReport.csv", FILE_CSV|FILE_READ, " ");
   int count = 0;
   if( fhHistory >= 1 ){
         
      while (!FileIsEnding(fhHistory)){
         
         ticket = FileReadString(fhHistory, 255);
         type_open = FileReadString(fhHistory, 255);
         open_time = StrToTime(FileReadString(fhHistory, 255) + " " + FileReadString(fhHistory, 255));         
         lots = StrToDouble(FileReadString(fhHistory, 255));
         open_price = StrToDouble(FileReadString(fhHistory, 255));
         open_SL = StrToDouble(FileReadString(fhHistory, 255));
         TP = StrToDouble(FileReadString(fhHistory, 255)); 
         
         ticket = FileReadString(fhHistory, 255);
         type_close = FileReadString(fhHistory, 255);
         close_time = StrToTime(FileReadString(fhHistory, 255) + " " + FileReadString(fhHistory, 255));         
         lots = StrToDouble(FileReadString(fhHistory, 255));
         close_price = StrToDouble(FileReadString(fhHistory, 255));
         close_SL = StrToDouble(FileReadString(fhHistory, 255));
         TP = StrToDouble(FileReadString(fhHistory, 255));          
         
         if ( ticket != "" && type_close != "" ){          
            description = type_open + ", " + DoubleToStr(lots,2) + ", " + DoubleToStr(open_price, 4) + ", " + 
                  DoubleToStr(open_SL, 4) + ", "  + DoubleToStr(close_price, 4);// + ", " + DoubleToStr(ProfitLoss,2);    
            DrawPosition();
         } 
         while( !FileIsLineEnding(fhHistory)){
            FileReadString(fhHistory, 255);   
         }
         count++;
      }          
      Comment("Count Transaction = ", count);
      FileClose(fhHistory);
   }else{
      Comment("File StrategyTesterReport.csv not found, the last error is ", GetLastError());
   }
 
      
   return(0);
}

void DrawPosition(){
   Open_DrawLine();   
   Close_DrawLine();    
   StopLoss_DrawLine();
}
void Open_DrawLine(){
   string name_obj = ticket + " - " + description;
   
   ObjectCreate(name_obj, OBJ_ARROW, 0, 0, 0);
   ObjectSet(name_obj, OBJPROP_ARROWCODE, 1);
   ObjectSet(name_obj, OBJPROP_TIME1, open_time);
   ObjectSet(name_obj, OBJPROP_PRICE1, open_price);

   if (type_open == "buy") {
      ObjectSet(name_obj, OBJPROP_COLOR, Green);
   }else{
      ObjectSet(name_obj, OBJPROP_COLOR, Red);
   }      
}

void Close_DrawLine(){
   string name_obj = ticket + " - close";   
   ObjectCreate(name_obj, OBJ_TREND, 0, 0, 0);
   ObjectSet(name_obj, OBJPROP_TIME1, open_time);
   ObjectSet(name_obj, OBJPROP_PRICE1, open_price);
   ObjectSet(name_obj, OBJPROP_TIME2, close_time);
   ObjectSet(name_obj, OBJPROP_PRICE2, close_price);  
   ObjectSet(name_obj, OBJPROP_COLOR, Red);
   ObjectSet(name_obj, OBJPROP_WIDTH, 1);
   ObjectSet(name_obj, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(name_obj, OBJPROP_RAY, false); 
   
   name_obj = ticket + " - close_line";
   ObjectCreate(name_obj, OBJ_ARROW, 0, 0, 0);
   ObjectSet(name_obj, OBJPROP_ARROWCODE, 3);
   ObjectSet(name_obj, OBJPROP_TIME1, close_time);
   ObjectSet(name_obj, OBJPROP_PRICE1, close_price);         
   if (type_open == "buy") {
      ObjectSet(name_obj, OBJPROP_COLOR, Green);
   }else{
      ObjectSet(name_obj, OBJPROP_COLOR, Red);
   }     
}

void StopLoss_DrawLine(){      
   string name_obj = ticket + " - SL";
   
   ObjectCreate(name_obj, OBJ_ARROW, 0, 0, 0);
   ObjectSet(name_obj, OBJPROP_ARROWCODE, 4);
   ObjectSet(name_obj, OBJPROP_TIME1, open_time);
   ObjectSet(name_obj, OBJPROP_PRICE1, open_SL);
   ObjectSet(name_obj, OBJPROP_COLOR, Blue);         
   
   if (ProfitLoss < 0){ 
      ObjectSet(name_obj, OBJPROP_COLOR, Red);
   }     
}
  
//+------------------------------------------------------------------+