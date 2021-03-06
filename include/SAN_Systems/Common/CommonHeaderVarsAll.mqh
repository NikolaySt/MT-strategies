#include <SAN_Systems\Common\CommonHeaderVars.mqh>


#include <SAN_Systems\Order\Common\Orders_HeaderVarsAll.mqh>
#include <SAN_Systems\Limit\Common\Limit_HeaderVarsAll.mqh>
#include <SAN_Systems\Stop\Common\Stop_HeaderVarsAll.mqh>
#include <SAN_Systems\Trend\Common\Trend_HeaderVarsAll.mqh>
#include <SAN_Systems\Signal\Common\Signals_HeaderVarsAll.mqh>
#include <SAN_Systems\MM\Common\MM_HeaderVarsAll.mqh>


void Common_InitVarsAll()
{   
   //Init Arras-----------------   
   //Инит на всички масиви в сетингите
   SAV_Settings_Init();
   //Инит на всички масиви които пазят ZZ
   ZZInit();
         
   Common_InitVars();
   Common_Signal_InitVarsAll();   
   Common_Stop_InitVarsAll();      
   Common_Limit_InitVarsAll();      
   Common_Trend_InitVarsAll();      
   Common_Orders_InitVarsAll();     
   Common_MM_InitVarsAll();              
}


void Common_UpdateVarsAll(int settID)
{
   Common_UpdateVars(settID);
   Common_Stop_UpdateVarsAll(settID);
   Common_Limit_UpdateVarsAll(settID);
   Common_Trend_UpdateVarsAll(settID);
   Common_Signal_UpdateVarsAll(settID);
   Common_Orders_UpdateVarsAll(settID);
   Common_MM_UpdateVarsAll(settID);
}
   
void Common_UpdateCalcVarsAll(int settID)
{   
   Common_UpdateCalcVars(settID);
   Common_Stop_UpdateCalcVarsAll(settID);   
   Common_Limit_UpdateCalcVarsAll(settID);
   Common_Trend_UpdateCalcVarsAll(settID);
   Common_Signal_UpdateCalcVarsAll(settID);
   Common_Orders_UpdateCalcVarsAll(settID);
   Common_MM_UpdateCalcVarsAll(settID);   
}


