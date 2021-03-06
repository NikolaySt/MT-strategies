
bool MM_Trace = false;

#include <SAN_Systems\MM\M001\M001.mqh>
#include <SAN_Systems\MM\M002\M002.mqh>
#include <SAN_Systems\MM\M003\M003.mqh>
#include <SAN_Systems\MM\M004\M004.mqh>
#include <SAN_Systems\MM\M005\M005.mqh>


void Common_MM_Init(int settID)
{  
   if(MM_LotStep <= 0) MM_LotStep = 0.1; // стойност по подразбиране;
   if(MM_TimeStartS != "") MM_TimeStart = StrToTime(MM_TimeStartS); else MM_TimeStart = 0;
   
   if(MMBaseName == "MM_FP_FF" )      MMBaseIndex = M001;
   else if(MMBaseName == "MM_FF" )      MMBaseIndex = M002;
   else if(MMBaseName == "MM_MAXLOSS" )      MMBaseIndex = M003;
   else if(MMBaseName == "MM_MARTINGALE" )      MMBaseIndex = M004;
   else if(MMBaseName == "MM_VIRTUAL" )      MMBaseIndex = M005;
   else MMBaseIndex = M000;
      
   if(Common_OptimizedProcess)
   {
      switch(MMBaseIndex)
      {
      case M000:  break;
      case M001:M001_MM_Init(settID); break;
      case M002:M002_MM_Init(settID); break;
      case M003:M003_MM_Init(settID); break;
      case M004:M004_MM_Init(settID); break;
      case M005:M005_MM_Init(settID); break;
      }
   }
   else
   { 
      M001_MM_Init(settID);   
      M002_MM_Init(settID);   
      M003_MM_Init(settID);      
      M004_MM_Init(settID);  
      M005_MM_Init(settID);
   }
}

double Common_MM_Get(int settID, int SLPips)
{
   double result = MM_LotStep;
   
   if(Common_OptimizedProcess)
   {
      switch(MMBaseIndex)
      {
      case M000:  break;
      case M001: result = M001_MM_Get(settID); break;
      case M002: result = M002_MM_Get(settID, SLPips); break;
      case M003: result = M003_MM_Get(settID); break;
      case M004: result = M004_MM_Get(settID); break;
      case M005: result = M005_MM_Get(settID); break;
      }
   }
   else
   {    
      if (MMBaseName == "")      
         return(MM_LotStep);
      else if (MMBaseName == "MM_FP_FF"){ 
         return(M001_MM_Get(settID));
      }
      else if (MMBaseName == "MM_FF"){ 
         return(M002_MM_Get(settID, SLPips));
      }
      else if (MMBaseName == "MM_MAXLOSS"){ 
         return(M003_MM_Get(settID));
      }     
      else if (MMBaseName == "MM_MARTINGALE"){ 
         return(M004_MM_Get(settID));
      }       
      else if (MMBaseName == "MM_VIRTUAL"){ 
         return(M005_MM_Get(settID));
      }            
      else   
         return(MM_LotStep);      
   }
   
   return (result);
}



