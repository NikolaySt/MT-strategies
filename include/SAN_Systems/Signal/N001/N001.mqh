
#include <SAN_Systems\Signal\N001\N001_Utils.mqh>

//--------------------------ДЕФЕНИРАНЕ НА ЛОКАЛНИ КОНСТАНТИ ЗА СИСТЕМАТА-------------------
int N001_TF_FIND_CORRECTION = PERIOD_H1; // часови интервал на който търси и пресмята процента корекция 
int N001_TF_CORRECTION_FR_1 = PERIOD_H1; //часово ниво на което тръси фрактал от 7 бара (Signal1_MinorFr_Bar)
int N001_TF_CORRECTION_FR_2 = PERIOD_H4; //часово ниво на което тръси фрактал от 3 бара
int N001_TF_PIVOT_1 = PERIOD_D1; //часово ниво - Пивот точка за ден от предишния бар 
int N001_TF_PIVOT_2 = PERIOD_W1; //часово ниво - Пивот точка за седмица от предишния бар 
//------------------------------------------------------------------------------------------


void N001_Signals_Init(int settID)
{       
}

void N001_Signals_PreProcess(int settID)
{  
}

void N001_Signals_Process(int settID)
{    
   
   N001_Signals_PreProcess(settID);
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;
     
   //Проверка за часовото ниво на което работи системата
   //това е най-ниското часово ниво което се ползва
   if (Period() > Signal_TimeFrame){         
      Print("Грешка: ", SignalBaseName ," работи на часово ниво по-малко или равно от " + Signal_TimeFrame);
      return;
   }
   //--------------------------------------------------ПРЕСМЯТАНЕ НА ТРЕНДА----------------------------------------------------         
    
   //---------------------------------------------------------------------------------------------------------------------------    
   Common_Stop_ProcessAll(settID);

   //------------------------------------ВРЕМЕВИ ФИЛТЪР НА СИГНАЛА НА СИСТЕМАТА----------------------
   //времеви фитър, системата работи само в зададения период от часове през деня
   // ако е 0 - 24 работи през цения ден
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;
   //------------------------------------------------------------------------------------------------

   //-------------------------------ГЕНЕРИРАМЕ СИГНАЛА ЗА ВХОД----------------------------------------   
   int signalTypes[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersMagic[2];
   int ordersTickets[2];
 
   ArrayInitialize(signalTypes,0);
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(ordersMagic,0);
   ArrayInitialize(ordersTickets,0);

   //----------------------------------------------------------------------------------------------------------------------
   if (Common_Signals_IsActive()){
      N001_Signals_Create(settID, signalTypes, signalTimes, signalLevels);      
   }else{
      Orders_Close(settID);
   }
  
   if (OpenOrders_GetCount(settID) > 0){
      N001_CloseOrders(settID);
      Common_Orders_CloseRemove(settID, signalTypes, signalLevels);      
   }
   
   //-------------------------------------------------ПРОВЕРКА при игра по направление----------------------------------------       
   
   if (N001_OneLimitByTrend == 1){
      //Една сделка с лимит по тренда  
      //по едма сделка на тренд затворена от лимит когато Orders_OneLimitByTrend = true;    
      datetime trend_begin_time = Common_Trend_GetTimeByIndex(settID, 1);
      if (signalTypes[0] == 1){
         if (HOrders_CloseWithLimit_Time(settID, trend_begin_time, OP_BUY)) signalTypes[0] = 0;
      }         
      if (signalTypes[1] == -1){   
         if (HOrders_CloseWithLimit_Time(settID, trend_begin_time, OP_SELL)) signalTypes[1] = 0;
      }                        
   }   
   //---------------------------------------------------------------------------------------------------------------------------      
      
   Common_Orders_ProcessAll(settID, signalTypes, signalTimes, signalLevels, ordersTickets);      
}

void N001_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[]){

   //пресмята текущото направление по което се играе ако се ползва такова
   int N001_trend = Common_Trend_GetByIndex(settID, 0);        
   if (N001_trend == TD_NONE) return;
        
   //--------------------------------------------------------------------------------------------
   //Намираме фрактал в посоката на тренда по висок ред   
   datetime signal_time;
   double fr_master = N001_FindMasterFractals(settID, Trend_TimeFrame, N001_trend, signal_time, N001_HeadFr_Bar);                                        
   if (!(fr_master > 0 || N001_HeadFr_Bar == 0)) return;      
      
   //--------------------------------------------------------------------------------------------
   //Определяме дълбочината на корекцията   
   double ratio_corr = 0;
   if (N001_HeadFr_Bar != 0){              
      double corr_time_ratio = 0; // не се ползва (записва съотнешение на време между импусла и корекцията)
      //кординати на корекцията до момента по екстемум / x1 - начало, x2 - екстремум в края / в барове
      int x1_corr = 0; int x2_corr = 0;       
      ratio_corr = N001_RatioCorection(settID, Trend_TimeFrame, N001_TF_FIND_CORRECTION, N001_trend, signal_time, corr_time_ratio, x1_corr, x2_corr);     
   }  
                  
   //Намираме последния формиран фрактал в коререкцията по посоката на главния фрактал
   datetime time;  //не се ползва, служи само като параметър за извикване на функцията защото е указател      
   double fr = SearchFractalInPeriod(N001_trend, N001_TF_CORRECTION_FR_1, N001_MinorFr_Bar, 30, time);                
   double fr_sec = SearchFractalInPeriod(N001_trend, N001_TF_CORRECTION_FR_2, 3, N001_CountBarFindFr_Sec, time);         
   double pivot_level_1 = PivotLevel(N001_trend, N001_TF_PIVOT_1, N001_LevelRatio1);
   double pivot_level_2 = PivotLevel(N001_trend, N001_TF_PIVOT_2, N001_LevelRatio2);        

   // праг на корекцията при който нивото за пробив е базовия фрактал
   // ако корекцията е по голяма от 0.3 но е по-малка от 0.382 то пробива е по главния фрактал      
   if (N001_LimitRatioLevel != 0 && ratio_corr != 0 && ratio_corr <= N001_LimitRatioLevel ) fr = fr_master;  

   double HiLo;
   if (N001_trend == 1) HiLo = iLow(NULL, Signal_TimeFrame, 1); else HiLo = iHigh(NULL, Signal_TimeFrame, 1);
         
   if ( 
       //-----------------------------------------------------------------------------------------------------------------------------------------        
       N001_trend*(iClose(NULL, Signal_TimeFrame, 1) - fr) >= 0  && 
            (N001_trend*(iClose(NULL, Signal_TimeFrame, 2) - fr) <= 0 || N001_trend*(HiLo - fr) <= 0 )                          
       
       && (N001_CountCloseExtremumBar == 0 || CloseHiLo(N001_trend, Signal_TimeFrame, N001_CountCloseExtremumBar, 2, 1))
       && (N001_CountBarFindFr_Sec == 0 || (N001_trend*(iClose(NULL, Signal_TimeFrame, 1) - fr_sec) >= 0 && fr_sec > 0))
       //добавянето на долните две условия повишава ефективността но с малко
             
       &&(N001_LevelRatio1 == 0 || N001_trend*(iClose(NULL, Signal_TimeFrame, 1) - pivot_level_1) >= 0)
       &&(N001_LevelRatio2 == 0 || N001_trend*(iClose(NULL, Signal_TimeFrame, 1) - pivot_level_2) >= 0)                        
       
       && (N001_HeadFr_Bar == 0 || ratio_corr >= N001_MinCorrWaveRatio)
       //----------------------------------------------------------------------------------------------------------------------------------------           
       ){      
                  
         double TL_Level = 0;
         if (N001_ActiveTrendLine == 1){
            //подобрява ефективноста за сметка на риска да се пропусни сделка   
            int TLDirection[1];
            TL_Level = TL_LevelTwoPoint(N001_trend, N001_TF_CORRECTION_FR_2, 3, 0, 3, IsVisualMode(), false, TLDirection);
         }         
         if ( N001_ActiveTrendLine == 0 || N001_trend*(iClose(NULL, Signal_TimeFrame, 1) - TL_Level) >= 0)  {                 
            if (N001_trend == TD_UP){                             
               signalTypes[0] = N001_trend;
               signalTimes[0] = signal_time;
            }            
            if (N001_trend == TD_DOWN){                                                                    
               signalTypes[1] = N001_trend;
               signalTimes[1] = signal_time;      
            }               
         }               
   }   
          
}

void N001_CloseOrders(int settID){   
   double close = iClose(NULL, Trend_TimeFrame, 1);

   double ma_h = TN001_MALine(Trend_TimeFrame, MODE_UPPER, 1);
   double ma_l = TN001_MALine(Trend_TimeFrame, MODE_LOWER, 1);   
      
   if (close < ma_l) Orders_CloseByType(settID, OP_BUY);
   if (close > ma_h) Orders_CloseByType(settID, OP_SELL);     
}



