//+------------------------------------------------------------------+
//|                                               ARD_ViewResult.mq4 |
//|                                    Copyright © 2006, Ariadna Ltd |
//|                                              revision 12.12.2006 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Ariadna Ltd"
#property link      "revision 12.12.2006"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

string ticket, type, item, description;


datetime open_time, close_time;
double lots, open_price, SL, TP, close_price, ProfitLoss;

int start(){
   
   string value;   
   int i, hstTotal = OrdersHistoryTotal();
  /*
   SetInfo("",
      "МО = "+ DoubleToStr(Clac_PMO(true, false), 2) +  
      "\n" + "Коеф. RR =  " + RR_string_value +
      "\n" + "Познаваемост = " + Cognoscibility_string_value + "%");
  */
   int fhHistory = FileOpen("history.txt", FILE_CSV|FILE_READ, " ");
   int count = 0;
   if( fhHistory >= 1 ){
      while (!FileIsEnding(fhHistory)){
         ticket = FileReadString(fhHistory, 255);
         open_time = StrToTime(FileReadString(fhHistory, 255) + " " + FileReadString(fhHistory, 255));
         type = FileReadString(fhHistory, 255);
         lots = StrToDouble(FileReadString(fhHistory, 255));
         item = FileReadString(fhHistory, 255);
         open_price = StrToDouble(FileReadString(fhHistory, 255));
         SL = StrToDouble(FileReadString(fhHistory, 255));
         TP = StrToDouble(FileReadString(fhHistory, 255)); 
         close_time = StrToTime(FileReadString(fhHistory, 255) + " " + FileReadString(fhHistory, 255));
         close_price = StrToDouble(FileReadString(fhHistory, 255));
         FileReadString(fhHistory, 255);
         FileReadString(fhHistory, 255);
         FileReadString(fhHistory, 255);
         ProfitLoss = StrToDouble(FileReadString(fhHistory, 255));           
         if ( ticket != "" && item == Symbol() && type != "" ){          
            description = type + ", " + DoubleToStr(lots,2) + ", " + DoubleToStr(open_price, 4) + ", " + 
                  DoubleToStr(SL, 4) + ", "  + DoubleToStr(close_price, 4) + ", " + DoubleToStr(ProfitLoss,2);    
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
      Comment("File hisotry.txt not found, the last error is", GetLastError());
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

   if (type == "buy") {
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
   if (type == "buy") {
      ObjectSet(name_obj, OBJPROP_COLOR, Green);
   }else{
      ObjectSet(name_obj, OBJPROP_COLOR, Red);
   }     
}

void StopLoss_DrawLine(){   
   if (SL == 0) {            
      if (type == "buy") {
         SL = open_price - 50*Point;
      }else{
         SL = open_price + 50*Point;
      }            
   }else{
      if (type == "buy") {
         if (SL >= open_price){
            SL = open_price - 50*Point;   
         }
      }else{
         if (SL <= open_price){
            SL = open_price + 50*Point;
         }         
      }
   }
   
   string name_obj = ticket + " - SL";
   
   ObjectCreate(name_obj, OBJ_ARROW, 0, 0, 0);
   ObjectSet(name_obj, OBJPROP_ARROWCODE, 4);
   ObjectSet(name_obj, OBJPROP_TIME1, open_time);
   ObjectSet(name_obj, OBJPROP_PRICE1, SL);
   ObjectSet(name_obj, OBJPROP_COLOR, Blue);         
   
   if (ProfitLoss < 0){ 
      ObjectSet(name_obj, OBJPROP_COLOR, Red);
   }     
}
  
//+------------------------------------------------------------------+