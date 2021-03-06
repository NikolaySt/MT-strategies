//+------------------------------------------------------------------+
//|                                           VolatilityChannels.mq4 |
//|                                    Copyright © 2007, Mario & VGC |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Mario & VGC"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Aqua
#property indicator_color6 Aqua
#property indicator_color7 Blue
#property indicator_color8 Blue

extern int    ATRTimeFrame = PERIOD_D1;  //По кой времеви интервал се смята АТ
extern int    ATRPeriod    = 50;        //Период на ATR.
extern double ATRUnit      = 0.5;          //Отстояние на канала спрямо цената на отваряне
extern int    CenterType   = 2;          //0-центъра на канала е цената на отваряне на всеки фрейм
                                         //1-центъра динамично да се сменя по вече направена най-ниска/висока стойност за съответния фрейм
                                         //2-центъра на каналите е общ и това е отварянето на бара от ATRTimeFrame
                                         //3-същото като 2, но центъра за старшите фреймове си е по тяхната цена на отваряне
                                         //4-същото като 3, но центъра за старшите фреймове динамично да се сменя по вече направена най-ниска/висока стойност
extern int    MaxCalcBars  = 999;        //Този параметър е с цел скорост. При стойност по-голяма от нула имаме ограничение за изчислението на индикатора назад във времето
                                         //При стойност 0 се извежда само коментар. При стойност -1 нямаме ограничение

//---- buffers
double Channel1Up[],Channel1Dn[],Channel2Up[],Channel2Dn[],Channel3Up[],Channel3Dn[],Channel4Up[],Channel4Dn[];

string Names[20]={"","M1  ","M5  ","M15 ","M30 ","1H  ","4H  ","D1  ","W1  ","MN  ","","","","","","","","","",""};
int    TimeFrames[20]={0,1,5,15,30,60,240,1440,10080,43200,0,0,0,0,0,0,0,0,0,0};
int    StartInd=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ArraySetAsSeries(Channel1Up,true);
   ArraySetAsSeries(Channel1Dn,true);
   ArraySetAsSeries(Channel2Up,true);
   ArraySetAsSeries(Channel2Dn,true);
   ArraySetAsSeries(Channel3Up,true);
   ArraySetAsSeries(Channel3Dn,true);
   ArraySetAsSeries(Channel4Up,true);
   ArraySetAsSeries(Channel4Dn,true);
//---- drawing settings
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   SetIndexDrawBegin(0,ATRPeriod);
   SetIndexDrawBegin(1,ATRPeriod);
   SetIndexDrawBegin(2,ATRPeriod);
   SetIndexDrawBegin(3,ATRPeriod);
   SetIndexDrawBegin(4,ATRPeriod);
   SetIndexDrawBegin(5,ATRPeriod);
   SetIndexDrawBegin(6,ATRPeriod);
   SetIndexDrawBegin(7,ATRPeriod);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID);
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID);
   
//   IndicatorDigits(Digits);
   SetIndexBuffer(0,Channel1Up);
   SetIndexBuffer(1,Channel1Dn);
   SetIndexBuffer(2,Channel2Up);
   SetIndexBuffer(3,Channel2Dn);
   SetIndexBuffer(4,Channel3Up);
   SetIndexBuffer(5,Channel3Dn);
   SetIndexBuffer(6,Channel4Up);
   SetIndexBuffer(7,Channel4Dn);
   
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Volatility Channels ("+ATRTimeFrame+","+ATRPeriod+","+DoubleToStr(ATRUnit,2)+")");
   if(Period()==PERIOD_M1)
      StartInd=1;
   else   
   if(Period()==PERIOD_M5)
      StartInd=2;
   else   
   if(Period()==PERIOD_M15)
      StartInd=3;
   else   
   if(Period()==PERIOD_M30)
      StartInd=4;
   else   
   if(Period()==PERIOD_H1)
      StartInd=5;
   else   
   if(Period()==PERIOD_H4)
      StartInd=6;
   else   
   if(Period()==PERIOD_D1)
      StartInd=7;
   else   
   if(Period()==PERIOD_W1)
      StartInd=8;
   if(Period()==PERIOD_MN1)
      StartInd=9;

   if(ATRTimeFrame==0) 
      ATRTimeFrame=Period();
   
   for(int cnt=1;cnt<=4;cnt++)
      {
       SetIndexLabel((cnt-1)*2  ,Names[StartInd+cnt-1]+" - горна граница");
       SetIndexLabel((cnt-1)*2+1,Names[StartInd+cnt-1]+" - долна граница");
      }
//----
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   SetIndexEmptyValue(3,0);
   SetIndexEmptyValue(4,0);
   SetIndexEmptyValue(5,0);
   SetIndexEmptyValue(6,0);
   SetIndexEmptyValue(7,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
     int limit;
     int counted_bars=IndicatorCounted();
     double dATR,dUp,dDn,dd,ddB;
     double Volatility[20];
     string ss;
     datetime t1,t2;
     int    ii;
  //---- check for possible errors
     if(counted_bars<0) return(-1);
  //---- last counted bar will be recounted
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;
  //---- main loop
     for(int i=0; i<limit; i++)
       {
        //Лимит за скорост
        if(MaxCalcBars>0 && i>=MaxCalcBars)
           break;
        // Изчисляваме волатилността на основния фрейм
        dATR=iATR(NULL,ATRTimeFrame,ATRPeriod,i);
        //изчисление
        for(int cnt=1; cnt<=20; cnt++)
           {
            if(TimeFrames[cnt]!=0)
              {
               if(ATRTimeFrame>=TimeFrames[cnt])
                  Volatility[cnt]=dATR/MathSqrt(ATRTimeFrame/TimeFrames[cnt]);
               else
                  Volatility[cnt]=dATR*MathSqrt(TimeFrames[cnt]/ATRTimeFrame);
              } 
            else
               Volatility[cnt]=0;
           } 
        //Извеждане на коментар    
        if(i==0)
          {    
           ss="\nBasis Frame  ";
           for(cnt=1; cnt<=9; cnt++)
               if(TimeFrames[cnt]==ATRTimeFrame)
                  ss=ss+Names[cnt]+":";
           for(cnt=1; cnt<=9; cnt++)
               ss=ss+"\n"+Names[cnt]+" - "+DoubleToStr(Volatility[cnt]/Point,2)+"";
           Comment(ss);
          }
        //Поискано е само извеждането на коментар
        if(MaxCalcBars==0)
           break;
        //Няколко инициализации  
        ddB=0;
        t1=iTime(NULL,Period(),i);
        //Когато са с общ център
        if(CenterType==2 || CenterType==3 || CenterType==4)
          {
           ii=0;
           while(true)
             {
              t2=iTime(NULL,ATRTimeFrame,ii);
              if(t2<=t1)
                 break;
              ii=ii+1;   
             }
           ddB=iOpen(NULL,ATRTimeFrame,ii);
          }
        //Наместване на индикаторите  
        for(cnt=1;cnt<=4;cnt++)
           {
            dUp=0;
            dDn=0;
            if(Volatility[StartInd+cnt-1]!=0)
              {
               if(CenterType==2 || ((CenterType==3 || CenterType==4) && TimeFrames[StartInd+cnt-1]<=ATRTimeFrame))
                  dd=ddB;
               else   
                 {
                  ii=0;
                  if(cnt==1)
                     ii=i;
                  else
                    {//Не може с директно изчисление да се получи отместването на най-близкият старши фрейм
                     while(true)
                       {
                        t2=iTime(NULL,TimeFrames[StartInd+cnt-1],ii);
                        if(t2<=t1)
                           break;
                        ii=ii+1;   
                       }
                    } 
                  dd=iOpen(NULL,TimeFrames[StartInd+cnt-1],ii);//
                  //if(CenterType==1 || CenterType==4) //Дали центъра на канала е цената на отваряне 
                  //или динамично да се сменя по вече направена най-ниска/висока стойност
                     /*if((iHigh(NULL,TimeFrames[StartInd+cnt-1],ii)-dd)>
                        (dd-iLow(NULL,TimeFrames[StartInd+cnt-1],ii))
                       )
                        dd=iLow(NULL,TimeFrames[StartInd+cnt-1],ii);
                     else   
                        dd=iHigh(NULL,TimeFrames[StartInd+cnt-1],ii);*/
                 }       
               if(dd!=0)
                 {
                  dUp=dd+Volatility[StartInd+cnt-1]*ATRUnit;
                  dDn=dd-Volatility[StartInd+cnt-1]*ATRUnit;
                 } 
              } 
            if(cnt==1)
              {
               Channel1Up[i]=dUp;
               Channel1Dn[i]=dDn;
              }
            else   
            if(cnt==2)
              {
               Channel2Up[i]=dUp;
               Channel2Dn[i]=dDn;
              }
            else   
            if(cnt==3)
              {
               Channel3Up[i]=dUp;
               Channel3Dn[i]=dDn;
              }
            else   
            if(cnt==4)
              {
               Channel4Up[i]=dUp;
               Channel4Dn[i]=dDn;
              }
           }
       } 
  //---- done
     return(0);
  }
//+------------------------------------------------------------------+