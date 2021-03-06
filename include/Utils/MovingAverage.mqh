//+------------------------------------------------------------------+
//|                                        Custom Moving Average     |
//|                                   Copyright © 2007, Ariadna Ltd. |
//+------------------------------------------------------------------+

//---- indicator parameters
extern int MA_Period=13;
extern int MA_Shift=0;
extern int MA_Method=0;
//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)
      sum+=Close[pos];
//---- main calculation loop
   while(pos>=0)
     {
      sum+=Close[pos];
      ExtMapBuffer[pos]=sum/MA_Period;
	   sum-=Close[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema(double &MABuff[], int price_count, int MA_Period = 1){
   
   double pr = 2.0 / (MA_Period + 1);
   int pos = 0;
   
   while (pos <= price_count - 1){
   
      if (pos == 0)  { MABuff[GetShift(pos)] = GetMedianPrice(pos); }
      else{
         MABuff[GetShift(pos)] = GetMedianPrice(pos)*pr + MABuff[GetShift(pos - 1)] * (1 - pr);
      }         
      
 	   pos++;
   }
}
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma(double &MABuff[], int price_count,
   int MA_Period=13, int MA_Shift=0){
   
   double sum = 0;
   int    i, k, pos = price_count;
//---- main calculation loop
   pos = price_count - MA_Period;
   if(pos > price_count) pos = price_count;
   Print("MA - INIT=", pos, " - ", MA_Period);
   while (pos >= 0){
      
      if (pos == price_count - MA_Period){
         //---- initial accumulation
      
         for(i = 0, k = pos; i < MA_Period; i++, k++){
            sum+= GetMedianPrice(k);
            //---- zero initial bars
            MABuff[k]=0;
         }
           
      }else sum=MABuff[pos+1]*(MA_Period-1)+GetMedianPrice(pos);
      
      MABuff[pos]=sum/MA_Period;
      //Print("MA = ", MABuff[pos]);
 	   pos--;
   }
}
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Close[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      ExtMapBuffer[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=Close[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Close[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer[Bars-i]=0;
  }
//+------------------------------------------------------------------+

