#include <SAN_Systems\Order\Common\Orders_HeaderVars.mqh>


void Common_Orders_InitVarsAll()
{
   Common_Order_InitVars();
}


void Common_Orders_UpdateVarsAll(int settID)
{
   Common_Order_UpdateVars(settID);
}
   
void Common_Orders_UpdateCalcVarsAll(int settID)
{   
   Common_Order_UpdateCalcVars(settID);
}