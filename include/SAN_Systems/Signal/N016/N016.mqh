bool N016_Signal_Trace = false;



void N016_Signals_Init(int settID)
{       

}

void N016_Signals_PreProcess(int settID)
{
   
}

void N016_Signals_Process(int settID)
{    
   N016_Signals_PreProcess(settID);
   
   if( Common_HasNewShift(Signal_TimeFrame) == false ) return;   
     
   //Проверка за часовото ниво на което работи системата
   //това е най-ниското часово ниво което се ползва
   if (Period() > Signal_TimeFrame){         
      Print("Грешка: ", SignalBaseName ," работи на часово ниво по-малко или равно от " + Signal_TimeFrame);
      return;
   }                    
   
   Common_Stop_ProcessAll(settID);
   
   int hour = TimeHour(iTime(NULL, Signal_TimeFrame, 1)); 
   if (!(hour >= Signal_TimeStart && hour <= Signal_TimeEnd)) return;


   //-------------------------------ГЕНЕРИРАМЕ СИГНАЛА ЗА ВХОД----------------------------------------   
   int signalTypes[2];
   double signalLevels[2];
   datetime signalTimes[2];
   int ordersTickets[2];
   
   double signalLimits[2];
   double signalStops[2];
   string signalComments[2];
 
   ArrayInitialize(signalTypes,0);   
   ArrayInitialize(signalLevels,0);
   ArrayInitialize(signalTimes,0);
   ArrayInitialize(ordersTickets,0);
   
   ArrayInitialize(signalLimits,0);   
   ArrayInitialize(signalStops,0);   


   if (Common_Signals_IsActive()){   
      N016_Signals_Create(settID, signalTypes, signalTimes, signalLevels, signalStops); 
   }else{
      Orders_Close(settID);
   }         
   
   Common_Orders_ProcessEx(settID, signalTypes, signalTimes, signalLevels, signalLimits, signalStops, signalComments, ordersTickets);     
}

void N016_Signals_Create(int settID, int& signalTypes[], datetime& signalTimes[], double& signalLevels[], double& signalStops[]){                      
   //*
   double mahigh1 = iMA(NULL, Signal_TimeFrame, N016_MAPeriod, 0, MODE_LWMA, PRICE_HIGH, 1);
   double malow1 =  iMA(NULL, Signal_TimeFrame, N016_MAPeriod, 0, MODE_LWMA, PRICE_LOW, 1);
   
   double ad = iCustom(NULL, Signal_TimeFrame, "SAN_WilliamsAD", N016_WAD_MAPeriod, 0, 1);
   double ad_ma = iCustom(NULL, Signal_TimeFrame, "SAN_WilliamsAD", N016_WAD_MAPeriod, 1, 1);
   
   int zoneCount;
   datetime zoneTime;
   int zone1 = N016_Zone(settID, zoneCount, zoneTime);
   
   if (
     iLow(NULL, Signal_TimeFrame, 1) > mahigh1
     &&
     ad > ad_ma     
     //---------------AOAC - ZONA /зелена зона/------------
      &&
      zoneCount <= N016_ZoneCount
      &&
      zone1 == 1 
      && 
      zone1*(iClose(NULL, Signal_TimeFrame, 1) - iClose(NULL, Signal_TimeFrame, 2)) > 0     
     //-------------------------------
   ){
      signalTypes[0] = 1;
      signalTimes[0] = iTime(NULL, Signal_TimeFrame, 1);
   }     
   
   if (
     iHigh(NULL, Signal_TimeFrame, 1) < malow1
     &&
     ad < ad_ma
     //---------------AOAC - ZONA /червена зона/------------
      &&
      zoneCount <= N016_ZoneCount
      &&
      zone1 == -1 
      && 
      zone1*(iClose(NULL, Signal_TimeFrame, 1) - iClose(NULL, Signal_TimeFrame, 2)) > 0     
     //-------------------------------     
   ){
      signalTypes[1] = -1;
      signalTimes[1] = iTime(NULL, Signal_TimeFrame, 1);
   }    
   //*/ 
   
   if (N016_Signal_Trace){
      Print(
         "[N016_Signals_Create]: ",
         "N016_MAPeriod = ", N016_MAPeriod,
         ", N016_WAD_MAPeriod = ", N016_WAD_MAPeriod,
         ", N016_MAFast = ", N016_MAFast,
         ", N016_MASlow = ", N016_MASlow,
         ", N016_MASignal = ", N016_MASignal,
         ", N016_ZoneCount = ", N016_ZoneCount
         );
   }
}

int N016_Zone(int settID, int &zoneCount, datetime &zoneTime){
   int curr_zone = iCustom(NULL, Signal_TimeFrame, "SAN_AOACZone", N016_MAFast, N016_MASlow, N016_MASignal, 2, 1);
   if (curr_zone == 0){
      zoneCount = 0;
      zoneTime = 0;
      return(0);
   }
   
   int zone = 0;
   bool bl_exit = false;
   int i = 2;
   zoneCount = 1;
   zoneTime = iTime(NULL, Signal_TimeFrame, 1);
   while (!bl_exit){
      zone = iCustom(NULL, Signal_TimeFrame, "SAN_AOACZone", N016_MAFast, N016_MASlow, N016_MASignal, 2, i);   
      if (zone == curr_zone){
         zoneCount++;
         zoneTime = iTime(NULL, Signal_TimeFrame, i);  
      }else{
         bl_exit = true;  
         zoneCount++;
         zoneTime = iTime(NULL, Signal_TimeFrame, i);               
      }
      i++;
   }
   return(curr_zone);
}




