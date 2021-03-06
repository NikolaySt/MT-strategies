

#include <SAN_Systems\Trend\Common\Trend_HeaderVars.mqh>

#include <SAN_Systems\Trend\TA001\TA001_HeaderVars.mqh>

#include <SAN_Systems\Trend\TN001\TN001_HeaderVars.mqh>
#include <SAN_Systems\Trend\TN002\TN002_HeaderVars.mqh>

void Common_Trend_InitVarsAll()
{
   Common_Trend_InitVars();
   TA001_Trend_InitVars();
   TN001_Trend_InitVars();
   TN002_Trend_InitVars();
}


void Common_Trend_UpdateVarsAll(int settID)
{
   Common_Trend_UpdateVars(settID);
   
   if(TrendBaseIndex !=0 && Common_OptimizedProcess)
   {
      switch(TrendBaseIndex)
      {
      case TA001:TA001_Trend_UpdateVars(settID); break;
      case TN001:TN001_Trend_UpdateVars(settID); break;
      case TN002:TN002_Trend_UpdateVars(settID); break;
      }
   }
   else
   { 
      TA001_Trend_UpdateVars(settID);
      TN001_Trend_UpdateVars(settID);
      TN002_Trend_UpdateVars(settID);
   }
}
   
void Common_Trend_UpdateCalcVarsAll(int settID)
{   
   Common_Trend_UpdateCalcVars(settID);
   
   if(Common_OptimizedProcess)
   {
      switch(TrendBaseIndex)
      {
      case TA001:TA001_Trend_UpdateCalcVars(settID); break;
      case TN001:TN001_Trend_UpdateCalcVars(settID); break;
      case TN002:TN002_Trend_UpdateCalcVars(settID); break;
      }
   }
   else
   { 
      TA001_Trend_UpdateCalcVars(settID);
      TN001_Trend_UpdateCalcVars(settID);
      TN002_Trend_UpdateCalcVars(settID);   
   }
}