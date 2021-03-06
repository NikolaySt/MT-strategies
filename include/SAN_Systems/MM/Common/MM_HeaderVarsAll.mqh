
#include <SAN_Systems\MM\Common\MM_HeaderVars.mqh>
#include <SAN_Systems\MM\M001\M001_HeaderVars.mqh>
#include <SAN_Systems\MM\M002\M002_HeaderVars.mqh>
#include <SAN_Systems\MM\M003\M003_HeaderVars.mqh>
#include <SAN_Systems\MM\M004\M004_HeaderVars.mqh>
#include <SAN_Systems\MM\M005\M005_HeaderVars.mqh>

void Common_MM_InitVarsAll()
{
   Common_MM_InitVars();
   M001_MM_InitVars();
   M002_MM_InitVars();
   M003_MM_InitVars();
   M004_MM_InitVars();
   M005_MM_InitVars();   
}


void Common_MM_UpdateVarsAll(int settID)
{
   Common_MM_UpdateVars(settID);
   
   if( MMBaseIndex!=0 && Common_OptimizedProcess)
   {
      switch(MMBaseIndex)
      {
      case M001: M001_MM_UpdateVars(settID); break;
      case M002: M002_MM_UpdateVars(settID); break;
      case M003: M003_MM_UpdateVars(settID); break;
      case M004: M004_MM_UpdateVars(settID); break;
      case M005: M005_MM_UpdateVars(settID); break;
      }
   }
   else
   { 
      M001_MM_UpdateVars(settID);
      M002_MM_UpdateVars(settID);
      M003_MM_UpdateVars(settID);
      M004_MM_UpdateVars(settID);
      M005_MM_UpdateVars(settID);   
   }
}
   
void Common_MM_UpdateCalcVarsAll(int settID)
{   
   Common_MM_UpdateCalcVars(settID);
   
   if(Common_OptimizedProcess)
   {
      switch(MMBaseIndex)
      {
      case M001: M001_MM_UpdateCalcVars(settID); break;
      case M002: M002_MM_UpdateCalcVars(settID); break;
      case M003: M003_MM_UpdateCalcVars(settID); break;
      case M004: M004_MM_UpdateCalcVars(settID); break;
      case M005: M005_MM_UpdateCalcVars(settID); break;
      }
   }
   else
   { 
      M001_MM_UpdateCalcVars(settID);
      M002_MM_UpdateCalcVars(settID);
      M003_MM_UpdateCalcVars(settID);
      M004_MM_UpdateCalcVars(settID);
      M005_MM_UpdateCalcVars(settID);
   }
}