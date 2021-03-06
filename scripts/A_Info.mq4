//+------------------------------------------------------------------+
//|                                    Copyright © 2010 Ariadna Ltd. |
//|                                              revision 26.10.2010 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010 Ariadna Ltd."
#property link      "revision 26.10.2010"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

double PointCost(string base = "GBP") {
   double result;
   double point = MarketInfo(Symbol(), MODE_LOTSIZE) * MarketInfo(Symbol(), MODE_POINT);
   string second = StringSubstr(Symbol(), 3, 3);
   string symbol1 = base + second;
   string symbol2 = second + base;
   if (second == base){
      result = MarketInfo(Symbol(), MODE_TICKVALUE);
   }else {
      if (MarketInfo(symbol1, MODE_BID) != 0.0) 
         result = point * (1 / MarketInfo(symbol1, MODE_BID));
      else 
         result = point * MarketInfo(symbol2, MODE_ASK);
   }
   return (result);
}

int start()
  {/*
      Comment("MODE_TICKVALUE = " + MarketInfo(Symbol(), MODE_TICKVALUE) + 
      "\n MODE_TICKSIZE = " + MarketInfo(Symbol(), MODE_TICKSIZE) + 
      "\n LOT_SIZE = " + MarketInfo(Symbol(),MODE_LOTSIZE) +
      "\n value_point = " + MarketInfo(Symbol(), MODE_TICKVALUE) * 0.1  +
                                                                          //GBP/JPY                     //* MarketInfo("GBPUSD", MODE_BID)          //котировка GBP/USD
      "\n 1 point = " + (MarketInfo(Symbol(),MODE_LOTSIZE) *  MarketInfo(Symbol(), MODE_TICKSIZE) ) / MarketInfo(Symbol(), MODE_BID) + 
      "\n 1 point gbp = "  + PointCost() 
      
      
      );                        
          
          */
   Print("//1999.01.01 00:00:00 Time = ", StrToTime("1999.01.01 00:00:00"));
   Print("//2004.04.04 04:22:34 Time = ", StrToTime("2004.04.04 04:22:34"));
   Print("//2009.12.12 21:22:34 Time = ", StrToTime("2009.12.12 21:22:34"));      
   Print("//2010.01.01 00:00:00 Time = ", StrToTime("2010.01.01 00:00:00"));
   Print("//2011.01.01 00:00:00 Time = ", StrToTime("2011.01.01 00:00:00"));  
   Alert("//2011.01.01 00:00:00 Time = ", StrToTime("2011.01.01 00:00:00")) ;
   Alert("spred", MarketInfo("EURUSD",MODE_SPREAD));
   return(0);
  }
//+------------------------------------------------------------------+
 