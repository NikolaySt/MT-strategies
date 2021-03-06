//+------------------------------------------------------------------+
//|                                                   vhSendSell.mq4 |
//|                               Copyright © 2011, Nikolay Stoychev |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Stoychev"
#property link      ""

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
      
  ObjectSet("vHT_Buy_OP", OBJPROP_PRICE1, 1);
  ObjectSet("vHT_Buy_OP", OBJPROP_PRICE2, 1);
  ObjectSetText("vHT_Buy", "       ", 12, "Arial", Blue);  
  RefreshRates();     
   return(0);
  }
//+------------------------------------------------------------------+