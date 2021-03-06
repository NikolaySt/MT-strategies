
#include <SAN_Systems\Order\Common\Orders.mqh>

void Common_Orders_InitAll(int settID)
{
   Common_Orders_Init(settID);
}

void Common_Orders_ProcessAll(int settID, int signalTypes[], datetime signalTime[], double signalLevels[], int& ordersTickets[])
{      
   Common_Orders_Process(settID, signalTypes, signalTime, signalLevels, ordersTickets);
}