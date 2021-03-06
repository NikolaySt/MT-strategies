double M004_MM_Init(int settID){
}

double M004_MM_Get(int settID){
   double result = 0;
   bool profitfound = false;
   bool secondprofitfound = false;
   int lastOrder = 0;

   if (M004_TotalHistoryOrders(settID) < 2) return(MM_LotStep);
   
   for(int i= OrdersHistoryTotal() - 1; i >= 0; i--){   
      if(OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY)){
         if (Magic_GetSettingsID(OrderMagicNumber()) == settID){
            if(OrderProfit() >= 0 && profitfound == true){     
               return(MM_LotStep);
            }   
                 
            if( lastOrder == 0){
               if(OrderProfit() >= 0) profitfound = true;
               if(OrderProfit() < 0)  return(OrderLots());
               lastOrder=1;            
            }
        
            if(OrderProfit() >= 0 && secondprofitfound == true){        
               return (result);
            }
        
            if(OrderProfit() >= 0){      
               secondprofitfound = true;
            }
        
            if(OrderProfit() < 0 ){      
               profitfound = false;
               secondprofitfound = false;
               result+= OrderLots();
            }      
         }
      }         
   }
   return(result);
}

int M004_TotalHistoryOrders(int settID)
{
   int total = 0;
   for(int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if (OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY))
         if (Magic_GetSettingsID(OrderMagicNumber()) == settID) total++;
   }
   return (total);
}

