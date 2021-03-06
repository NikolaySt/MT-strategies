//+------------------------------------------------------------------+
//|                                               WF_AsiaSession.mq4 |
//|                                     Copyright © 2010, NutCracker |
//|                                              forex-way@yandex.ru |
//|                                              http://wellforex.ru |
//-------------------------------------------------------------------+

#property copyright "Copyright © 2010, http://wellforex.ru"
#property link      "forex-way@yandex.ru"
extern int      Magic=10001;
extern int      ATRPeriod = 12;
extern int      AsiaStartTime = 2;            //Время начала азиатской сессии
extern int      AsiaEndTime = 11;             //Время окончания азиатской сессии
extern int      CloseTime = 15;               //Время закрытия открытых ордеров
extern int      MinATRPercent=35;             //Мин % 
extern int      MaxATRPercent=55;             //Макс %  
extern int      Take=180;                     //TakeProfit
extern int      Stop=70;                      //StopLoss
extern bool     Tral=false;                   //Трал обычный да/нет                  
extern int      TS=30;                        //Уровень трала                          
extern int      TralStep=15;                  //Шаг трала 
extern bool     UseSound       = True;        //Использовать звуковой сигнал да/нет
extern bool     MM=false;                     //Включение ММ да/нет
extern double   MMRisk=1;                     //Risk Factor
extern double   Lots = 0.1;                   //Лот
extern bool     Visual=true;
int  MaxTries=5,Dec;
int  i, cnt=0, ticket, mode=0, digit=0, total, OrderToday=0;
double  StopLoss, TakeProfit, Lotsi=0, spread, MinStop, DayATR, max, min, p1, p2;
int LastVol;
string  name="Asia";
string SoundSuccess   = "alert.wav";   // Звук успеха
string SoundError     = "timeout.wav"; // Звук ошибки
datetime t1, t2;
color ColorToShow;  
    
int init()
  {
Lotsi = Lots;

return(0);
  }


int start()
{
   MinStop=MarketInfo(Symbol(), MODE_STOPLEVEL);
   digit  = MarketInfo(Symbol(),MODE_DIGITS); 
   spread  = MarketInfo(Symbol(),MODE_SPREAD); 
   if (digit==5 || digit==3) Dec=10;
   if (digit==4 || digit==2) Dec=1; 
   Lotsi = Lots;
    

t1=StrToTime(TimeToStr(CurTime(), TIME_DATE)+" "+DoubleToStr(AsiaStartTime,0));
t2=StrToTime(TimeToStr(CurTime(), TIME_DATE)+" "+DoubleToStr(AsiaEndTime-1,0));
if(Volume[0]==1 || Volume[0]<LastVol)
{ 
TakeProfit=Take*Dec*Point;
StopLoss=Stop*Dec*Point;
if (MM) Lotsi = MoneyManagement (MM,MMRisk);
if (ScanTradesOpen(Magic)>0 && Tral) TrailStops(Magic); 
if (ScanTradesBuyOpen(Magic)>0 && Hour()==CloseTime) AllBuyOrdDel(Magic); 
if (ScanTradesSellOpen(Magic)>0 && Hour()==CloseTime) AllSellOrdDel(Magic); 

if (ScanTradesOpen(Magic)==0 && Hour()==AsiaEndTime)
{
DayATR=iATR(NULL,PERIOD_D1,ATRPeriod,1);
max=0;
for(int kkk=1;kkk<=AsiaEndTime-AsiaStartTime;kkk++){if (iHigh(NULL,PERIOD_H1,kkk)>max) max=iHigh(NULL,PERIOD_H1,kkk);}
p1=max;
min=100000; 
for(int lll=1;lll<=AsiaEndTime-AsiaStartTime;lll++){if (iLow(NULL,PERIOD_H1,lll)<min) min=iLow(NULL,PERIOD_H1,lll);}
p2=min;     
ColorToShow = CornflowerBlue;
if ((p1-p2)>MaxATRPercent*DayATR/100 || (p1-p2)<MinATRPercent*DayATR/100) ColorToShow = Salmon; 
if (!IsOptimization() && Visual) ShowVisual();
if ((p1-p2)>MaxATRPercent*DayATR/100 || (p1-p2)<MinATRPercent*DayATR/100) return(0);

if (iClose(0,60,1)<iClose(0,60,24) && iClose(0,60,1)<iOpen(0,60,AsiaEndTime-AsiaStartTime)) BuyMarketOrdOpen(Blue,Magic);
if (iClose(0,60,1)>iClose(0,60,24) && iClose(0,60,1)>iOpen(0,60,AsiaEndTime-AsiaStartTime)) SellMarketOrdOpen(Red,Magic);

}
}
LastVol=Volume[0];  
}


//Money Management
double MoneyManagement ( bool flag, double risk)
{
   double Lotsi=Lots;
	    
   if ( flag ) Lotsi=NormalizeDouble(AccountFreeMargin()*risk/10000,2);   
   if (Lotsi<MarketInfo(Symbol(), MODE_MINLOT)) Lotsi=MarketInfo(Symbol(), MODE_MINLOT);  
   return(Lotsi);
}  

void BuyMarketOrdOpen(int ColorOfBuy,int Magic)
  {
  int try, res;
      
  for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();		  

         res=OrderSend(Symbol(),OP_BUY,Lotsi,NormalizeDouble(Ask ,digit),2*Dec,NormalizeDouble(Bid ,digit)-StopLoss,NormalizeDouble(Ask ,digit)+TakeProfit,name,Magic,0,ColorOfBuy);
      Sleep(2000);
      if(res>0)
           {
            if (UseSound) PlaySound(SoundSuccess);
            OrderToday=OrderToday+1;
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) break;
            }
         else 
         {
          if (UseSound) PlaySound(SoundError);
         Print("Error opening BUY order : ",GetLastError(), " Try ", try); 
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
         Sleep(5000);
         }     
       }
      return;
      }

void SellMarketOrdOpen(int ColorOfSell,int Magic)      
      { 
        int try, res;  

 for (try=1;try<=MaxTries;try++)
       {
       while (!IsTradeAllowed()) Sleep(5000);
       RefreshRates();	
       
      res=OrderSend(Symbol(),OP_SELL,Lotsi,NormalizeDouble(Bid ,digit),2*Dec,NormalizeDouble(Ask ,digit)+StopLoss,NormalizeDouble(Bid ,digit)-TakeProfit,name,Magic,0,ColorOfSell);
      Sleep(2000);
      if(res>0)
           {
            if (UseSound) PlaySound(SoundSuccess);
            OrderToday=OrderToday+1;
            if(OrderSelect(res,SELECT_BY_TICKET,MODE_TRADES)) break;
            }
         else 
         {
          if (UseSound) PlaySound(SoundError);
         Print("Error opening SELL order : ",GetLastError(), " Try ", try); 
         if (try==MaxTries) {Print("Warning!!!Last try failed!");} 
         Sleep(5000);
        }
      }
      return;
      }
        

// ---- Scan Trades opened
int ScanTradesOpen(int Magic)
{   
   total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL)  && OrderMagicNumber() == Magic) 
   {
   numords++;
   }
   }
   return(numords);
}
 



void TrailStops(int Magic)
{        
    int total=OrdersTotal();
    for (cnt=0;cnt<total;cnt++)
    { 
     OrderSelect(cnt, SELECT_BY_POS);   
     mode=OrderType();    
        if ( OrderSymbol()==Symbol() && OrderMagicNumber()==Magic ) 
        {
          
            if ( mode==OP_BUY )
            {
           if(OrderStopLoss()<OrderOpenPrice() && NormalizeDouble(Ask,digit)-OrderOpenPrice()>Point*TS*Dec)
               {
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask,digit)-TralStep*Dec*Point,OrderTakeProfit(),0,Green);
         return(0);
        } 
           if(OrderStopLoss()>OrderOpenPrice() && NormalizeDouble(Ask,digit)-OrderStopLoss()>Point*TralStep*Dec)
               {
         OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask,digit)-TralStep*Dec*Point,OrderTakeProfit(),0,Green);
         return(0);
        }        
            }
             
           if ( mode==OP_SELL)
            {
            if((OrderStopLoss()>OrderOpenPrice() || OrderStopLoss()==0) && OrderOpenPrice()-NormalizeDouble(Bid,digit)>Point*TS*Dec)
            {
           OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid,digit)+TralStep*Dec*Point,OrderTakeProfit(),0,Green);
           return(0);
            }
            if(OrderStopLoss()<OrderOpenPrice()  && OrderStopLoss()-NormalizeDouble(Bid,digit)>Point*TralStep*Dec)
            {
           OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid,digit)+TralStep*Dec*Point,OrderTakeProfit(),0,Green);
           return(0);
            }
        }    
        }
    }   
}

void AllBuyOrdDel(int Magic)
{
    int total=OrdersTotal();
    for (int cnt=total-1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);   
      
        if (OrderMagicNumber()==Magic && OrderType()==OP_BUY)     
        {
        bool result = false;
 
 for (int try=1;try<=MaxTries;try++)
       {		 
          RefreshRates();
          result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid ,digit),5*Dec,Yellow);
          if(result) break;            
          if(!result) Print("OrderSend CloseBuy failed with error #",GetLastError(), " Try ", try);                                      
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
          Sleep(5000);
        }
       }
      } 
     
  return;
  }  

void AllSellOrdDel(int Magic)
{
    int total=OrdersTotal();
    for (int cnt=total-1;cnt>=0;cnt--)
    { 
      OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES);   
      
        if (OrderMagicNumber()==Magic && OrderType()==OP_SELL)     
        {
        bool result = false;
 
 for (int try=1;try<=MaxTries;try++)
       {		 
          RefreshRates();
          result = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask ,digit),5*Dec,Yellow);
          if(result) break;            
          if(!result) Print("OrderSend CloseSell failed with error #",GetLastError(), " Try ", try);                                      
          if (try==MaxTries) {Print("Warning!!!Last try failed!");}
          Sleep(5000);
        }
       }
      } 
     
  return;
  } 

int ScanTradesBuyOpen(int Magic)
{   
   int total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_BUY)  && OrderMagicNumber() == Magic) 
   numords++;
   }
   return(numords);
}

int ScanTradesSellOpen(int Magic)
{   
   int total = OrdersTotal();
   int numords = 0;
      
   for(cnt=0; cnt<total; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
   if(OrderSymbol() == Symbol() && (OrderType()==OP_SELL)  && OrderMagicNumber() == Magic) 
   numords++;
   }
   return(numords);
}

// ---- Show chanal
int ShowVisual()
{
      if (TimeCurrent()>=t2 && ObjectFind("Chanal"+t2)==-1)
      {
         ObjectCreate("Chanal"+t2, OBJ_RECTANGLE,0,0,0,0,0);
         ObjectSet   ("Chanal"+t2, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet   ("Chanal"+t2, OBJPROP_COLOR, ColorToShow);
         ObjectSet   ("Chanal"+t2, OBJPROP_BACK, true);
         ObjectSet   ("Chanal"+t2, OBJPROP_TIME1,t1);
         ObjectSet   ("Chanal"+t2, OBJPROP_PRICE1,p1);
         ObjectSet   ("Chanal"+t2, OBJPROP_TIME2,t2);
         ObjectSet   ("Chanal"+t2, OBJPROP_PRICE2,p2);
      }
}