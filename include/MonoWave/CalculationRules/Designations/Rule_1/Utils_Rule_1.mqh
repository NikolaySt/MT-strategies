
bool Equal_price_time_100_61_m0_m2(){
   double ratio_t = CompareTimeDirectionFull(0, 2);
   double ratio_p = ComparePriceDirectionFull(0, 2);                  
     
   if ( (Equal_100(ratio_t) && Equal_100(ratio_p)) ||           
        (Equal_061(ratio_t) && Equal_100(ratio_p)) ||
        (Equal_100(ratio_t) && Equal_061(ratio_p)) ||
        (Equal_061(ratio_t) && Equal_061(ratio_p))  ) { 
        
      return(true);
   }else{
      return(false);      
   }      
}        