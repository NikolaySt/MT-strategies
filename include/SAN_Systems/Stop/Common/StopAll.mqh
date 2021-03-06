

#include <SAN_Systems\Stop\Common\Stop.mqh>

//#include <SAN_Systems\Stop\SN001\SN001.mqh>
//#include <SAN_Systems\Stop\SN002\SN002.mqh>

//#include <SAN_Systems\Stop\SA001\SA001.mqh>
#include <SAN_Systems\Stop\SA002\SA002.mqh>

void Common_Stop_InitAll(int settID)
{
   Common_Stop_Init(settID);
     
   if( StopBaseName == "SA002" ) StopBaseIndex = SA002;  
   else                               StopBaseIndex = S0000;
       
   SA002_Stop_Init(settID);
}

void Common_Stop_ProcessAll(int settID)
{
            
   //управление на стопа на вече отворените поръчки      
   if(Common_OptimizedProcess)
   {
      switch(StopBaseIndex)
      {      
         case SA002:SA002_Stop_Process(settID); 
         break;      
      }
   }
   else
   {    
      if( StopBaseName == "" )
      {
         //без управление на стоп лосса
         return(0);
      }
      else if (StopBaseName == "SA002" ) SA002_Stop_Process(settID);     
   }   
   if( ZeroStop_Param1 > 0 )
      SAN_Stop_ProcessLevel(settID, Stop_TimeFrame,
               SAN_DEF_STOP_ZERO, 
               ZeroStop_Param1, ZeroStop_Param2, Stop_TimeFrame,//param1, 2 timeframe
               0, 0, 1*DigMode() //min & max =0 offset = 1 pips ot cenata na otvariane
               );       
}

double Common_InitialStop_Get(int settID, int signalType, double signalLevel)
{
   // пресмятане на началния стоп при подаване на ордера;
   // управление на стопа на вече отворените поръчки
   return(SAN_Stop_GetInitialStopLoss(
            signalType, signalLevel, 
            
            InitialStop_TimeFrame, 
            
            InitialStop_Type, 
            
            InitialStop_Param1, 
            InitialStop_Param2,         
            
            InitialStop_MinPips,
            InitialStop_MaxPips,         
            InitialStop_OffsetPips
            )
         );      
}