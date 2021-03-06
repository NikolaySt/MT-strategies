//+------------------------------------------------------------------+
//|                                               ARD_ViewResult.mq4 |
//|                                    Copyright © 2006, Ariadna Ltd |
//|                                              revision 12.12.2006 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Ariadna Ltd"
#property link      "revision 12.12.2006"
#include "..\include\stdlib.mqh"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

string ticket, type, item, description;


datetime open_time, close_time;
double lots, open_price, SL, TP, close_price, ProfitLoss;

#include <MonoWave\Utils\Information.mqh>
#include <OperationHistory.mqh>
int start(){
   
   string value;   
   int i, hstTotal = OrdersHistoryTotal();
  
   SetInfo("",
      "МО = "+ DoubleToStr(Clac_PMO(true, false), 2) +  
      "\n" + "Коеф. RR =  " + RR_string_value +
      "\n" + "Познаваемост = " + Cognoscibility_string_value + "%");
  
   for(i = 0; i < hstTotal; i++){  
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == true){
         ticket = DoubleToStr(OrderTicket(), 0);
         open_time = OrderOpenTime();
         if (OrderType() == OP_BUY) {
            type = "buy";
         }else{
            if (OrderType() == OP_SELL) {
               type = "sell";
            }else{
               type = "";   
            }
         }
         
         lots = OrderLots();
         item = OrderSymbol();        
         open_price = OrderOpenPrice();
         SL = OrderStopLoss();
         TP = OrderTakeProfit();
         close_time = OrderCloseTime();
         close_price = OrderClosePrice();
         ProfitLoss = OrderProfit();  
      }
      if ( ticket != "" && type != "" && item == Symbol()){          
         description = type + ", " + DoubleToStr(lots,2) + ", " + DoubleToStr(open_price, 4) + ", " + 
               DoubleToStr(SL, 4) + ", "  + DoubleToStr(close_price, 4) + ", " + DoubleToStr(ProfitLoss,2);    
         
         if (ProfitLoss >= 0) DrawPosition();
      }      
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