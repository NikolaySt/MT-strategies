
//includi an biblioteki

#include <SAN_Systems\Common\CommonInclude.mqh>

#include <SAN_Systems\Order\Common\OrdersAll.mqh>
#include <SAN_Systems\Limit\Common\Limit.mqh>
#include <SAN_Systems\Stop\Common\StopAll.mqh>
#include <SAN_Systems\Signal\Common\SignalsAll.mqh>
#include <SAN_Systems\Trend\Common\TrendAll.mqh>
#include <SAN_Systems\MM\Common\MM.mqh>


void Common_InitAll(int settID)
{
   Common_Init(settID);   
   
   Common_Limit_InitAll(settID);
   Common_Trend_InitAll(settID);
   Common_Stop_InitAll(settID);
   Common_MM_Init(settID);
   Common_Signals_InitAll(settID);
   Common_Orders_InitAll(settID); 
}