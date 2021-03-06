
string SignalBaseName = "3";

bool Use_Reversal = true;  

extern string CommentSys3="==== 3 ====";

extern int Magic3 = 333;
extern int Slippage = 2;
extern string GMT="***GMT Offset is very important parameter!!!***";
extern int GMT_Offset= 3; // this is very important parameter - it shows the GMT offset from GMT 0 /GMT_Offset= 2 is for FXDD/

bool UseAgresiveMM=false;


string MMSys3 ="==== Reversal MM Parameters ====";

double LotsSys3=0.1;
double TradeMMSys3=0.1;             
double LossFactorSys3=1;
int    MMStartSys3=1;         
int    MMResetSys3=2;       
int    WinResetPipsSys3=0;

extern string CommonMM ="==== Main MM Parameters ====";
         
double MMMax=20; 
double MaximalLots =50;

string MM_TimeStartS = "";
double MM_TimeStart = 0;

extern double MM_LotStep = 0.1;
extern string M001_1_Descr = "Параметри: Фиксирано пропорционален метод с преминаване към Фиксирано Фракционен чрез риска";
extern double M001_FP_BeginBalance = 3200;
// AvailableBalance - Наличен първоначален баланс по сметката коийто имем и може да е различен от BeginBalance който задаваме за да пресметнем таблиците
// Примерно задаваме BeginBalance = 2000, но в сметката разполагаме с AvailableBalance=5000 долара и реално започваме от 6-то ниво на ММ а не от 1-во.
extern string M001_FP_AvailBal_1_Descr = "Начален калитал наличен в сметката ако е различен от BeginBalance който дефинира ММ";
extern string M001_FP_AvailBal_2_Descr = "ако е 0 това означава, че наличния капитал по сметката е равен на BeginBalance";
extern double M001_FP_AvailableBalance = 0;
extern double M001_FP_MaxDD = 640;
extern double M001_FP_Delta = 320; 
extern string M001_2_Descr = "PersentDD ниво на риска при което става превключване --- ";
extern double M001_FF_PersentDD = 10;



extern string Reversal ="==== Reversal System Parameters ====";

extern int       BegHourSys_III      = 22;           
extern int       EndHourSys_III      = 0;  	
extern double    TakeProfit_III      = 160;         
extern int       StopLoss_III        = 70;
extern int       DelayTrailing3      = 300;                   
extern int       MaxPipsTrailing3    = 60;
extern int       MinPipsTrailing3    = 20;
extern int       ATRPeriod3          = 60;         
extern double    ATRTrailingFactor3  = 13;         
extern int       BOL_period          = 26;
extern int       PrevBreak           = -3; 
extern int       BolRangeMin         = 30;

bool   Initialized=true;   
#include <stdlib.mqh>
#include <stderror.mqh>

#include <SAN_Systems\Common\Utils\SAN_Statistical.mqh>
#include <SAN_Systems\Common\Utils\SAN_MMHelper.mqh>
#include <SAN_Systems\MM\M001\M001.mqh>

void init()
{
   M001_MM_SetTrace(true);
   if(MM_LotStep <= 0) MM_LotStep = 0.1; // стойност по подразбиране;   
   if(MM_TimeStartS != "") MM_TimeStart = StrToTime(MM_TimeStartS); else MM_TimeStart = 0;   
   M001_MM_Init(0);
   
   Initialized=true;
}       

int deinit(){ 
   if (IsTesting()){         
      if (!IsOptimization()){
         Stat_HistOrdersToFile(false, 1000, "history_"+SignalBaseName+".txt");
         Stat_DropDownToFile(false, 1000, "dropdown_"+SignalBaseName+".txt");
         Stat_AvgAnnualReturn(1000);
         Stat_SumMonthlyProfitToFile("monthly_profit_"+SignalBaseName+".txt");
         Stat_CalcMO(true);                                   
      }                      
      Stat_HistOrdersToDll(SignalBaseName);
   } 
   return(0); 
}
   
	

void start()
{  
   
   double price, stop, target;
   int Color, orderOp;
   static double   MinLots=0;
   static double   MaxLots=0;
   static int      Leverage=0;
   static int      LotSize=0;
   static int      StopLevel=0;

   bool   flOk2;
   bool   flOk3;
   
      //////////// PRICE DIGITS NORMALISATOION ///////////////
   if(Digits==4) int DigMode=1;
   if(Digits==5)     DigMode=10;
   if(Digits==2)     DigMode=1;
   if(Digits==3)     DigMode=10;
   
   if(Initialized)
     {
      Initialized=false;
      MinLots = MarketInfo(Symbol(),MODE_MINLOT);
      MaxLots = MarketInfo(Symbol(),MODE_MAXLOT);
      Leverage= AccountLeverage();
      LotSize = MarketInfo(Symbol(),MODE_LOTSIZE);
      StopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL); 
     }          
     
   if (UseAgresiveMM==true) 
       {
        LossFactorSys3=LossFactorSys3;
       }       
       else        
       {
        LossFactorSys3=1;
       }
       
   //if (iVolume(NULL,PERIOD_M5,0)>5) return;      
         
   HideTestIndicators(false);
   
   //System III - M5_Reversals
   double atrStops=iATR(NULL,60,ATRPeriod3,1);
   double PrevHigh=iHigh(NULL,PERIOD_H1,1);
   double PrevLow=iLow(NULL,PERIOD_H1,1); 
   double BolHi=iBands(NULL,PERIOD_H1,BOL_period,2,0,PRICE_CLOSE,MODE_UPPER,1);
   double BolLo=iBands(NULL,PERIOD_H1,BOL_period,2,0,PRICE_CLOSE,MODE_LOWER,1);
   HideTestIndicators(false);

   //////////// STOP LEVELS CALCULATION ///////////////
   if (TakeProfit_III<StopLevel/DigMode) TakeProfit_III=StopLevel/DigMode ;
   if (StopLoss_III<StopLevel/DigMode) StopLoss_III=StopLevel/DigMode ;
   
   //////////// TIME HOUR GMT CALCULATION ///////////////
   int StartHour3=BegHourSys_III+GMT_Offset;           
   int EndHour3=EndHourSys_III+GMT_Offset;
   
   //////////// TIME HOUR NORMALISATION START ///////////////
   if (StartHour3>23) StartHour3=StartHour3-24;
   if (StartHour3<0) StartHour3=StartHour3+24;
   
   if (EndHour3>23) EndHour3=EndHour3-24;
   if (EndHour3<0) EndHour3=EndHour3+24;
      
   int BreakHour1=18+GMT_Offset; 
   int BreakHour2=13+GMT_Offset; 
   int BreakHour3=19+GMT_Offset; 
   int BreakHour4=14+GMT_Offset; 
   int BreakHour5=7+GMT_Offset;
   int BreakHour6=6+GMT_Offset; 
   int BreakHour7=1+GMT_Offset; 
   int BreakHour8=17+GMT_Offset; 
   int BreakHour9=12+GMT_Offset;
   int BreakHour10=9+GMT_Offset; 
   int BreakHour11=8+GMT_Offset; 
   
   if (BreakHour1>23) BreakHour1=BreakHour1-24;
   if (BreakHour1<0) BreakHour1=BreakHour1+24;
   if (BreakHour2>23) BreakHour2=BreakHour2-24;
   if (BreakHour2<0) BreakHour2=BreakHour2+24;
   if (BreakHour3>23) BreakHour3=BreakHour3-24;
   if (BreakHour3<0) BreakHour3=BreakHour3+24;
   if (BreakHour4>23) BreakHour4=BreakHour4-24;
   if (BreakHour4<0) BreakHour4=BreakHour4+24;
   if (BreakHour5>23) BreakHour5=BreakHour5-24;
   if (BreakHour5<0) BreakHour5=BreakHour5+24;
   if (BreakHour6>23) BreakHour6=BreakHour6-24;
   if (BreakHour6<0) BreakHour6=BreakHour6+24;
   if (BreakHour7>23) BreakHour7=BreakHour7-24;
   if (BreakHour7<0) BreakHour7=BreakHour7+24;
   if (BreakHour8>23) BreakHour8=BreakHour8-24;
   if (BreakHour8<0) BreakHour8=BreakHour8+24;
   if (BreakHour9>23) BreakHour9=BreakHour9-24;
   if (BreakHour9<0) BreakHour9=BreakHour9+24;
   if (BreakHour10>23) BreakHour10=BreakHour10-24;
   if (BreakHour10<0) BreakHour10=BreakHour10+24;
   if (BreakHour11>23) BreakHour11=BreakHour11-24;
   if (BreakHour11<0) BreakHour11=BreakHour11+24;
   //////////// TIME HOUR NORMALISATION END ///////////////
   
   Slippage=Slippage*DigMode;
   
	int BuyCount3=0, SellCount3=0;
	
  
   static datetime LastTrailTime3=0;
	datetime NewTrailTime3=LastTrailTime3;
   datetime GoTrailTime3=LastTrailTime3+DelayTrailing3;
	
	int    ticket_3;
	
	Print(StartHour3, " - ", EndHour3);
	//*
	for (int i = OrdersTotal()-1; i >= 0; i--)
	 {
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		   {
			Print("Error in OrderSelect! Position:", i);
			continue;	   
		}
		if ( (OrderType() <= OP_SELL) &&(OrderSymbol() == Symbol())){

///////////////////// CLOSING SYSTEM 3 /////////////////////////////////////////////////////////////////////		    
		 if (OrderMagicNumber() == Magic3) {			
			if (OrderType() == OP_BUY)
			 {
				if (				   				  						
				   ((StartHour3<=EndHour3 && TimeHour(TimeCurrent())>=StartHour3 && TimeHour(TimeCurrent())<=EndHour3)||
               (StartHour3>EndHour3 && (TimeHour(TimeCurrent())>=StartHour3 || TimeHour(TimeCurrent())<=EndHour3))) &&
	            (BolHi-BolLo)>=BolRangeMin*Point*DigMode &&
	            PrevHigh>BolHi+PrevBreak*Point*DigMode						   
					)					
					{					
					RefreshRates();					
					OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid,Digits), Slippage, Violet);
					}
				else 
				   {
               BuyCount3=BuyCount3+1;              
				   }
				   
				if(TimeCurrent()>=GoTrailTime3)  
              {
                 double StopValue = atrStops*ATRTrailingFactor3;
                 if(StopValue > MaxPipsTrailing3*Point*DigMode) StopValue = MaxPipsTrailing3*Point*DigMode;
                 if(StopValue < MinPipsTrailing3*Point*DigMode) StopValue = MinPipsTrailing3*Point*DigMode; 
                 
                 double TrailPrice=NormalizeDouble(Bid-StopValue,Digits);                 
               if(Bid-OrderOpenPrice()>StopValue)
                 {
                  if(OrderStopLoss()<Bid-StopValue)
                    {
                     flOk3=OrderModify(OrderTicket(),OrderOpenPrice(),TrailPrice,OrderTakeProfit(),0,Blue);
                     if(flOk3)
                       {
                        NewTrailTime3=TimeCurrent();
                        LastTrailTime3=NewTrailTime3;
                        //MakeComment("Stop is moved at "+DoubleToStr(Bid-StopValue,Digits), false); 
                       }
                    }
                 }
              } 
                 
			} else {
				
				if (				   					
				   ((StartHour3<=EndHour3 && TimeHour(TimeCurrent())>=StartHour3 && TimeHour(TimeCurrent())<=EndHour3)||
               (StartHour3>EndHour3 && (TimeHour(TimeCurrent())>=StartHour3 || TimeHour(TimeCurrent())<=EndHour3))) &&	
	    	      (BolHi-BolLo)>=BolRangeMin*Point*DigMode &&
               PrevLow<BolLo-PrevBreak*Point*DigMode				  
					)					
					{					
					RefreshRates();
					OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask,Digits), Slippage, Violet);
					}
				else 
				   {
               SellCount3=SellCount3+1;                       
				   }
				   
			   if(TimeCurrent()>=GoTrailTime3)  
              {
                 StopValue = atrStops * ATRTrailingFactor3;
                 if(StopValue > MaxPipsTrailing3*Point*DigMode)  StopValue = MaxPipsTrailing3*Point*DigMode;                 
                 if(StopValue < MinPipsTrailing3*Point*DigMode)  StopValue = MinPipsTrailing3*Point*DigMode; 
                 
                 TrailPrice = NormalizeDouble(Ask + StopValue, Digits);                 
               if(OrderOpenPrice()-Ask>StopValue)
                 {
                  if(OrderStopLoss()>Ask+StopValue)
                    {
                     flOk3=OrderModify(OrderTicket(),OrderOpenPrice(),TrailPrice,OrderTakeProfit(),0,Red);
                     if(flOk3)
                       {
                        NewTrailTime3=TimeCurrent();
                        LastTrailTime3=NewTrailTime3;
                        //MakeComment("Stop is moved at "+DoubleToStr(Ask+StopValue,Digits), false);  
                       }
                    }
                 }
              }                             
				}
		    }
       }
    }   
      //*/ 
     
/////////////////////////////////////////////////////////////////////////////
// System 3 entry //////////////////////////////////////////////////////////	
////////////////////////////////////////////////////////////////////////////
      
   string ord = "";  	 
  	orderOp = -1;
   while (true) { 
    
  if (Use_Reversal == false) break;  
  if (LotsSys3==0) break; 
     

  double TrueLotsSys3 = MathMin(MaxLots, MathMax(MinLots, LotsSys3));   
  
  if(TradeMMSys3>0)
     TrueLotsSys3 = MathMax(MinLots, 
                        MathMin(MaxLots, 
                                NormalizeDouble(CalcTradeMMSys3()/StopLoss_III*AccountFreeMargin()/MinLots/(LotSize/Leverage),0)*MinLots));
  
   if(TrueLotsSys3>MaximalLots) TrueLotsSys3=MaximalLots;   


	  //double TrueLotsSys3 = M001_MM_Get(0);	  
	  
	  if (
	  	    BuyCount3<1 && 
	       ((StartHour3<=EndHour3 && TimeHour(TimeCurrent())>=StartHour3 && TimeHour(TimeCurrent())<=EndHour3)||
          (StartHour3>EndHour3 && (TimeHour(TimeCurrent())>=StartHour3 || TimeHour(TimeCurrent())<=EndHour3))) &&	          
	    	 (BolHi-BolLo)>=BolRangeMin*Point*DigMode &&
          PrevLow<BolLo-PrevBreak*Point*DigMode	
          
          
		  )
		  
		  {
		  ord="BUY";		
		  orderOp = OP_BUY;
		  Color=Aqua;
		  RefreshRates();
		  price =NormalizeDouble(Ask,Digits);
		  stop = price - StopLoss_III*Point*DigMode;
		  target = price + TakeProfit_III*Point*DigMode;
		  Print(
		    "[OPEN BUY]: BolHi = ", BolHi, 
		    ", BolLo = ", BolLo, 
		    ", PrevLow = ", PrevLow, 
		    ", PrevHigh = ", PrevHigh,
		    ", PrevBreak = ", PrevBreak,
		    ", Cond1 = ", (BolHi-BolLo)>=BolRangeMin*Point*DigMode,
		    ", Cond2 = ", PrevLow<BolLo-PrevBreak*Point*DigMode 
		    );
	    }
	
	  if (	  
	      SellCount3<1 && 
	      ((StartHour3<=EndHour3 && TimeHour(TimeCurrent())>=StartHour3 && TimeHour(TimeCurrent())<=EndHour3)||
         (StartHour3>EndHour3 && (TimeHour(TimeCurrent())>=StartHour3 || TimeHour(TimeCurrent())<=EndHour3))) &&
	      (BolHi-BolLo)>=BolRangeMin*Point*DigMode &&
	      PrevHigh>BolHi+PrevBreak*Point*DigMode		      
		  ) 
		  
		  {
		  ord="SELL";	
		  orderOp = OP_SELL;
		  Color=DeepPink;
		  RefreshRates();
		  price = NormalizeDouble(Bid,Digits);
		  stop = price + StopLoss_III*Point*DigMode;
		  target = price - TakeProfit_III*Point*DigMode;
		  Print(
		    "[OPEN SELL]: BolHi = ", BolHi, 
		    ", BolLo = ", BolLo, 
		    ", PrevLow = ", PrevLow, 
		    ", PrevHigh = ", PrevHigh,
		    ", PrevBreak = ", PrevBreak,
		    ", Cond1 = ", (BolHi-BolLo)>=BolRangeMin*Point*DigMode,
		    ", Cond2 = ", PrevHigh>BolHi+PrevBreak*Point*DigMode 
		    );		  
	     }
	  
	  break;
   }
   	
	if (orderOp >= 0){
	   TrueLotsSys3 = LotsSys3;//M001_MM_Get(0);
      ticket_3 = OrderSend(Symbol(), orderOp, TrueLotsSys3, price, Slippage, stop, target, CommentSys3, Magic3, 0, Color);
      if (ticket_3 <= 0) Print("Error opening "+ord+" order!: ",GetLastError()); 
   }
	
   return;
}

double CalcTradeMMSys3()
  {double ResultSys3=TradeMMSys3;
   int MullCountSys3;
   int ConsecutiveLossesSys3=0;
   if(Digits==4) int DigMode=1;
   if(Digits==5)     DigMode=10;
   for(int cnt=HistoryTotal();cnt>=0;cnt--)
     if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
        if(
           (OrderType() <= OP_SELL) &&
           (OrderSymbol() == Symbol()) &&
           (OrderMagicNumber() == Magic3)
          )
           if(OrderProfit()>0)
           
             {                   
              if(WinResetPipsSys3==0)
                 break;
              else
              if(MathAbs(OrderClosePrice()-OrderOpenPrice())/(Point*DigMode)>WinResetPipsSys3)
                 break;
             } 
           else   
              ConsecutiveLossesSys3=ConsecutiveLossesSys3+1;
                           
   if(ConsecutiveLossesSys3>MMStartSys3 && MMResetSys3>1)
     {
      MullCountSys3=MathMod(ConsecutiveLossesSys3,MMResetSys3);
      ResultSys3=ResultSys3*MathPow(LossFactorSys3,MullCountSys3);
     }
   if(MMMax>0 && ResultSys3>MMMax)  ResultSys3=MMMax;   
   return(ResultSys3);
  }
  
  


