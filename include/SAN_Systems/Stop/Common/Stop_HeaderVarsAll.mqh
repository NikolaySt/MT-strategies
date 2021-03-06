#include <SAN_Systems\Stop\Common\Stop_HeaderVars.mqh>


#include <SAN_Systems\Stop\SA002\SA002_HeaderVars.mqh>

//TODO: samo SA002 stop li se polzva da se proveri ot men i ot Nikito
//ako se polzvat drugite stopove da se dobaviat inicializacionnite funkcii

void Common_Stop_InitVarsAll()
{  
   Common_Stop_InitVars();
   SA002_Stop_InitVars();         
}


void Common_Stop_UpdateVarsAll(int settID)
{
   Common_Stop_UpdateVars(settID);
   
   if(StopBaseIndex != 0 && Common_OptimizedProcess)
   {
      switch(StopBaseIndex)
      {
      case SA002:SA002_Stop_UpdateVars(settID); break;
      }
   }
   else
   { 
      SA002_Stop_UpdateVars(settID);
   }
}
   
void Common_Stop_UpdateCalcVarsAll(int settID)
{   
   Common_Stop_UpdateCalcVars(settID);
   
   if(Common_OptimizedProcess)
   {
      switch(StopBaseIndex)
      {
      case SA002:SA002_Stop_UpdateCalcVars(settID); break;
      }
   }
   else
   {

      SA002_Stop_UpdateCalcVars(settID);
   }
}