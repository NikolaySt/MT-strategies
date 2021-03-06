//+------------------------------------------------------------------+
//|                                                 TA001_ZigZag.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2010, Andrey Kunchev"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Aqua
#property indicator_width1 2
#property indicator_color2 Blue
#property indicator_width2 2
#property indicator_color3 Red
#property indicator_width3 2
//---- indicator parameters
extern int ExtDepth=12;
//---- indicator buffers
double zz[];
double zzL[];
double zzH[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
datetime lasthightime = 0,lastlowtime = 0, lastcalcshifttime = 0;
int bars_count = 0;

int init()
  {
 //  IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexArrow(2,159);
   SetIndexArrow(1,159);
//---- indicator buffers mapping
   SetIndexBuffer(0,zz);
   SetIndexBuffer(1,zzH);
   SetIndexBuffer(2,zzL);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
     
//---- indicator short name
   IndicatorShortName("TA001_ZigZag("+ExtDepth+")");
   lasthightime = 0;
   lastlowtime = 0;
   lastcalcshifttime = 0;
   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
  {
   int lasthighpos,lastlowpos;
   static double lasthigh,lastlow;
     
   int    i,shift,pos;
   int curhighpos,curlowpos;
   double curlow,curhigh;
   bool update_low,update_high;
   
   double min, max;
   int limit;
   
   int min_shift = 1;
   
   if( (lasthightime == 0 || lastlowtime == 0) ||  (Bars - bars_count > 1) )
   {

      ArrayInitialize(zz,0.0);
      ArrayInitialize(zzL,0.0);
      ArrayInitialize(zzH,0.0);
   
      lasthighpos=Bars; 
      lastlowpos=Bars;
      lastlow=Low[Bars];
      lasthigh=High[Bars];
   
      limit = Bars-ExtDepth;
      //first_start = false;
      //INIT VARS
      lasthightime = 0;
      lastlowtime = 0;
      lastcalcshifttime = 0;      
   }
   else
   {     
      limit = iBarShift( NULL, 0, lastcalcshifttime );
      
      if( limit < min_shift )  return (0);
      
      //limit++;
      
      lasthighpos = iBarShift( NULL, 0, lasthightime );
      lastlowpos = iBarShift( NULL, 0, lastlowtime );
      //lastlow = zzL[lastlowpos];
      //lasthigh = zzH[lasthighpos]; 
      //int max_limit = MathMin(  lasthighpos, lastlowpos );    
   }
//TODO: ���� �� �������������� ��� ��� ������ �� ���� ��� ���
   bars_count = Bars; // 
  
  for(shift=limit; shift>=min_shift; shift--)
    {
      curlowpos=Lowest(NULL,0,MODE_LOW,ExtDepth,shift);
      curlow=Low[curlowpos];
      curhighpos=Highest(NULL,0,MODE_HIGH,ExtDepth,shift);
      curhigh=High[curhighpos];
     //------------------------------------------------

      //Print("ZZEx lasthighpos=",lasthighpos,";lastlowpos=",lastlowpos,";",curlowpos,":curlow=", curlow,
      //      ";lastlow=", lastlow,":", zzL[lastlowpos], ";",curhighpos, ":curhigh=",curhigh,";lasthigh=", lasthigh,":",zzH[lasthighpos] );
            
      update_high = false;
      update_low = false;
      
      if( curhigh<=lasthigh )  
      { 
         lasthigh=curhigh;
      }
      else
      {  
         //ako posledniat vryh e high da go updatva
         //samo ako tekushtata stojnost e po-goliama
         if( lasthighpos < lastlowpos )
         {
            update_high = (curhigh > zzH[lasthighpos]);
         }
         else
         {
            update_high = true;
         }    
      }       
      
      if( curlow>=lastlow ) 
      { 
         lastlow=curlow; 
      }
      else //if( lastlowpos > lasthighpos )
      { 
         //ako posledniat vryh e Low
         //togava da updatva samo ako tekushtata stojnost e po-malka
         if( lasthighpos > lastlowpos )
         {
            update_low = (curlow < zzL[lastlowpos]);
         }
         else
         {
            update_low = true;
         }  
      }
      
      
      if( update_low && update_high )
      {
         //Print(" update_low && update_high Oops we have complicated situation !!! shift=", shift );
         if( lasthighpos > lastlowpos  && curlow >= zzL[lastlowpos] )  //posleden e low
         {
            update_low = false;
         }
         else if( lastlowpos > lasthighpos && curhigh > zzH[lasthighpos] ) 
         //posleden e high i samo toj triabva da se uodatne
         {
            update_low = false;
         }
      }
      
      if( update_low )
      {
         //���� ����
         //if( lasthighpos>curlowpos )//(curlow <= zzL[lastlowpos]) ) 
         //if( lasthighpos > lastlowpos )
         
         if( lasthighpos>curlowpos )
         { 
            zzL[curlowpos]=curlow;
            ///*
            min=100000; pos=lasthighpos;
            for(i=lasthighpos; i>=curlowpos; i--)
            { 
              if (zzL[i]==0.0) continue;
              if (zzL[i]<min) { min=zzL[i]; pos=i; }
              zz[i]=0.0;
            } 
            zz[pos]=min;
            //Print("update min=", min,";pos=", pos, ";lasthight=", lasthighpos,";shift=", shift  );
            //*/
         } 
         lastlowpos=curlowpos;
         lastlow=curlow; 
       }
       if( update_high )
       {
         if( lastlowpos>curhighpos ) 
         {  
            zzH[curhighpos]=curhigh;
        ///*
            max=-100000; pos=lastlowpos;
            for(i=lastlowpos; i>=curhighpos; i--)
               { 
                 if (zzH[i]==0.0) continue;
                 if (zzH[i]>max) { max=zzH[i]; pos=i; }
                 zz[i]=0.0;
               } 
            zz[pos]=max;
            //Print("update max=", max,";pos=", pos, ";lastlow=",lastlowpos, ";shift=", shift  );
        //*/  
         }  
         lasthighpos=curhighpos;
         lasthigh=curhigh;  
       }  
      
    //----------------------------------------------------------------------
    }
    
    lasthightime = Time[lasthighpos];
    lastlowtime = Time[lastlowpos];
    lastcalcshifttime = Time[shift];
 return(0);
}
//+------------------------------------------------------------------+