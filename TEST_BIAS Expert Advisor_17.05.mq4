
extern double Lots = 0.1;// bazow lot pri wlizane s fiksiran lot,ili pri MM - towa e minimalniq lot s koito shte wliza eksperta
extern bool UseMaxLot=false;// pri MM koito uweli4awa kapitala e dobre da ima nqkakwo ograni4enie do kyde da wdiga riska
extern double MaxLots=3.00;// parametar koito ukazwa maksimalniq lot pri wkliu4eno UseMaxLot
extern bool UseMM=true; // dali da se izpolzwa MM
extern int MMOption=0; //0 - mnojitel, 1-binaren MM, 2
extern double Multiplier=1.2;// mnojitel
extern int SLOption=0;//0 da izliza pri presi4ane na liniqta, 1 - da izliza pri stoploss zadaden w pari
extern double StopLoss=50; // zadawa se w pari
extern int TPOption=1;//
extern double TakeProfit=5; //zadawa se w pari
extern int TrailingStop=50;// Plavasht stop - shte si pre4at s BreakEven - trqbwa da se izpolzwa edno ot dwete.
extern int BreakEven=0; // zadawa se w pipsowe, ako e 0 - nqma, ako e > ima. Stoinostta trqbwa da se syobrazi s minimalnoto razstoqnie za postawqne na stop.
extern int Slippage=3;// towa e maksimalno otklonenie pri instant execution.
extern int MagicNumber=12345678;// towa e unikalen nomer na sistemata po koqto tq shte si razpoznawa poziciite
extern int BiasBarsCount=4; // parametar za indikatora
extern int BiasTotalBars=250;// parametar za indikatora
extern bool OpenAtTickCross =true;

double BiasCurrent=0;
double BiasPrevious=0;
double lasttick=0;
double previoustick=0;
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
  // tuk se prowerqwa dali brokera e s 5 simwola ili 4 , respektiwno za jpy 3 ili 2  
  
  
  previoustick=lasttick;
  lasttick=Bid;
  if(lasttick<Point || previoustick<Point) return(0);
                      
  if (Volume[0]<2 || BiasCurrent==0 || BiasPrevious==0 )
  {
    BiasCurrent=iCustom(Symbol(),0,"Ard_BiasLogicExp",BiasBarsCount,BiasTotalBars,0,0);
    BiasPrevious=iCustom(Symbol(),0,"Ard_BiasLogicExp",BiasBarsCount,BiasTotalBars,0,1);
  }
  double MyPoint=Point;
  if(Digits==3 || Digits==5) MyPoint=Point*10;
  
  double lts=Lots;
  if(UseMM==true)
  {
  if(MMOption==0) lts= CalculateMultiplier();
  if(MMOption==1) lts= calculateBMM();
  }
  
  if(UseMaxLot)
  {
  lts=MathMin(lts,MaxLots);
  }
  Comment("The System will trade with "+lts+" Lots");
  //prowerka za otwarqne na poziciq - trqbwa da nqmame poziciq w tozi bar, da nqmame otworeni pozicii ot tazi sistema
  // prowerkata Minute()<2 sluji za po byrz baktest i tyi kato trqbwa da otworim na samiq open na bara.
  if(OpenAtTickCross==false)
  {
  if(CanTradeThisBar() && TotalBiasOrders()==0 ) 
  {
     // prowerka za otwarqne na dylga poziciq
     //if(iCustom(Symbol(),0,"Ard_BiasLogic",BiasBarsCount,BiasTotalBars,0,0)<Open[0] && iCustom(Symbol(),0,"Ard_BiasLogic",BiasBarsCount,BiasTotalBars,0,1)>Open[1]  )
     if(BiasCurrent<Open[0] && BiasPrevious>Open[1]  )
     {
        OrderSend(Symbol(),OP_BUY,lts,Ask,3,0,0,"buy",MagicNumber,0,Blue);
        return(0);
        }
     // prowerka za otwarqne na kysa poziciq   
    // if(iCustom(Symbol(),0,"Ard_BiasLogic",BiasBarsCount,BiasTotalBars,0,0)>Open[0] && iCustom(Symbol(),0,"Ard_BiasLogic",BiasBarsCount,BiasTotalBars,0,1)<Open[1]  )
     if(BiasCurrent>Open[0] && BiasPrevious<Open[1]  )
     {
        OrderSend(Symbol(),OP_SELL,lts,Bid,3,0,0,"sell",MagicNumber,0,Red);
        return(0);
        }
   
  }
  }
  else
  {
  if(/*CanTradeThisBar() &&*/ TotalBiasOrders()==0 ) 
  {
     // prowerka za otwarqne na dylga poziciq
     //if(LastOrderType()<=0)
   if((BiasCurrent<Bid  && BiasCurrent>Open[0] ) || (BiasCurrent<=Open[0]  && BiasPrevious>Close[1] && High[1]< BiasPrevious ) )
   if (CanBuyThisBar() )
    //if (previoustick<BiasCurrent && Bid>=BiasCurrent && CanBuyThisBar() )
      {
        OrderSend(Symbol(),OP_BUY,lts,Ask,3,0,0,"buy",MagicNumber,0,Blue);
       
        return(0);
        }

   
     // prowerka za otwarqne na kysa poziciq   
     //if(LastOrderType()>=0)
    if((BiasCurrent>Bid && BiasCurrent<Open[0] ) || (BiasCurrent>=Open[0]  && BiasPrevious<Close[1] && Low[1]>BiasPrevious )  )
    if(CanSellThisBar())
   // if(previoustick>BiasCurrent && Bid<=BiasCurrent && CanSellThisBar())
     {
     
        OrderSend(Symbol(),OP_SELL,lts,Bid,3,0,0,"sell",MagicNumber,0,Red);
       
        return(0);
        }
        
       
  
  }
  }
  
 
  
  
  // obhojdane na otworenite pozicii i tyrsene na uslowiq za zatwarqne ili modificirane na treilingstop
  for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // dali e poziciq
         OrderSymbol()==Symbol() && // dali e na tozi simwol
         OrderMagicNumber()==MagicNumber // dali e ot nashata sistema
         )  // 
        {
         if(OrderType()==OP_BUY)   // prowerka na dylga poziciq
           {
              if(TPOption==0) // TPOption==0 ozna4awa 4e izlizame po TP w pari
              {
                if(Bid-OrderOpenPrice() >=TakeProfit*MyPoint)
                {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                }
              }
              
              if(SLOption==0 || TPOption==1 ) // towa ozna4awa 4e izlizame po nasreshten signal
              {
                 if(OrderOpenTime()<Time[0] && BiasCurrent>Bid)
                 OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
              
              }
              
              if(SLOption==1)  // izlizame po stop w pari
              {
                if(OrderOpenPrice()-Bid>=StopLoss*MyPoint)
                {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                }
              }
          
            // prowerqwame za BreakEven
            if(BreakEven>0)  
            {
             if(Bid-OrderOpenPrice()>MyPoint*BreakEven && MathAbs(OrderOpenPrice()-OrderStopLoss())>MyPoint )
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);
            }
           
            // prowerka za treilingstop
            if(TrailingStop>0)  
              {                 
               if(Bid-OrderOpenPrice()>MyPoint*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-MyPoint*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*MyPoint,OrderTakeProfit(),0,Green);
                     return(0);
                    }
                 }
              }
           }
         else // prowerka na kysite pozicii
           {
            
            if(TPOption==0) // izlizame pri TakeProfit w pari
              {
                if(OrderOpenPrice()-Ask>=TakeProfit*MyPoint)
                {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                }
              }
              
              if(SLOption==0 || TPOption==1 ) // izlizame po nasreshten signal
              {
                 if(OrderOpenTime()<Time[0] && BiasCurrent<Bid)
                 OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
              
              }
              
              if(SLOption==1) // izlizame po stoploss w pari
              {
                if(Ask-OrderOpenPrice()>=StopLoss*MyPoint)
                {
                   OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Slippage,Red);
                }
              }
              
               // prowerqwame za BreakEven
            if(BreakEven>0)  
            {
               if((OrderOpenPrice()-Ask)>(MyPoint*BreakEven) && MathAbs(OrderOpenPrice()-OrderStopLoss())>MyPoint)
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Red);
            }
            // prowerka na treilignstopa
            if(TrailingStop>0)  
              {                 
               if((OrderOpenPrice()-Ask)>(MyPoint*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+MyPoint*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+MyPoint*TrailingStop,OrderTakeProfit(),0,Red);
                     return(0);
                    }
                 }
              }
           }
        }
     }
  
  
  
  
  
//----
   return(0);
  }
//+------------------------------------------------------------------+


// funkciq koqto prowerqwa dali nesme tyrguwali we4e w tekushtiq bar
bool CanTradeThisBar()
{ 
for(int i=OrdersHistoryTotal()-1;i>=0;i--)
{
   OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
   if (OrderMagicNumber()==MagicNumber)
   {
      if (OrderOpenTime()>Time[0]) return(false);
      else return(true);
      //if (OrderCloseTime()>Time[0]) return(false);
   }
}

return (true);
}


bool CanBuyThisBar()
{ 
for(int i=OrdersHistoryTotal()-1;i>=0;i--)
{
   OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
   if (OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY)
   {
      if (OrderCloseTime()>Time[1]) return(false);
      else return(true);
      //if (OrderCloseTime()>Time[0]) return(false);
   }
}

return (true);
}

bool CanSellThisBar()
{ 
for(int i=OrdersHistoryTotal()-1;i>=0;i--)
{
   OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
   if (OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL)
   {
      if (OrderCloseTime()>Time[1]) return(false);
      else return(true);
      //if (OrderCloseTime()>Time[0]) return(false);
   }
}

return (true);
}



int LastOrderType()
{ 

for(int i=OrdersHistoryTotal()-1;i>=0;i--)
{

   OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
   if (OrderMagicNumber()==MagicNumber)
   {
      if (OrderType()==OP_BUY) return(1);
      if (OrderType()==OP_SELL) return(-1);
   }
}
return (0);
}

// funkciq koqto razpoznawa orderite pusnati ot sistemata i wryshta broq otworeni orderi ot neq w tekushtiq moment
int TotalBiasOrders()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber) result++;

   }
  return (result);
}


int TotalBuyBiasOrders()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY) result++;

   }
  return (result);
}

int TotalSellBiasOrders()
{
  int result=0;
  for(int i=0;i<OrdersTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_TRADES);
     if (OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL) result++;

   }
  return (result);
}


// tuk se prowerqwa kolko ordera imame ot poziciqta
int TotalHistoryOrders()
{
  int result=0;
  for(int i=0;i<OrdersHistoryTotal();i++)
  {
     OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY);
     if (OrderMagicNumber()==MagicNumber) result++;

   }
  return (result);
}



// tuk se izwyrshwa cqlata kalkulaciq po binarniq MM - malko e po slojno zashtoto trqbwa da moje da 
// razpoznawa orderite na sistemata po MAgicNumber
double CalculateMultiplier()
{

for(int i=OrdersHistoryTotal()-1;i>=0;i--)
  {
     if(OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY))
     if (OrderMagicNumber()==MagicNumber) 
     {
        
      
       
        if(OrderProfit()>=0)
        {
        return(Lots);
        }
        else
        {
        //if (MarketInfo(Symbol(),MODE_MINLOT)==0.01)
        return (NormalizeDouble(OrderLots()*Multiplier,2));
       // if (MarketInfo(Symbol(),MODE_MINLOT)==0.1)
       // return (NormalizeDouble(OrderLots()*Multiplier,1));
        
        }
      } 
   }
        


return(Lots);

}

double calculateBMM()
{
double result = 0;
bool profitfound=false;
bool secondprofitfound=false;
int lastOrder=0;

 if(TotalHistoryOrders()<2) return(Lots);
 for(int i=OrdersHistoryTotal()-1;i>=0;i--)
  {
     if(OrderSelect(i,SELECT_BY_POS ,MODE_HISTORY))
     if (OrderMagicNumber()==MagicNumber) 
     {
        if(OrderProfit()>=0 && profitfound==true)
        {
     
        return(Lots);
        }
        
        if( lastOrder==0)
        {
           if(OrderProfit()>=0) profitfound=true;
           if(OrderProfit()<0)  return(OrderLots());
           lastOrder=1;
            
        }
        
        if(OrderProfit()>=0 && secondprofitfound==true)
        {
        
         return (result);
        }
        
        if(OrderProfit()>=0)
        {
      
         secondprofitfound=true;
        }
        
        if(OrderProfit()<0 ) 
        {
      
        profitfound=false;
        secondprofitfound=false;
        result+=OrderLots();
        }

      
     }
  }


return(result);
}