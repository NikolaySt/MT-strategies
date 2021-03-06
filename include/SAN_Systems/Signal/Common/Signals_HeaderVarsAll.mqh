#include <SAN_Systems\Signal\Common\Signals_HeaderVars.mqh>

#include <SAN_Systems\Signal\A001\A001_HeaderVars.mqh>
#include <SAN_Systems\Signal\A002\A002_HeaderVars.mqh>
#include <SAN_Systems\Signal\A003\A003_HeaderVars.mqh>
#include <SAN_Systems\Signal\A004\A004_HeaderVars.mqh>
#include <SAN_Systems\Signal\A005\A005_HeaderVars.mqh>
#include <SAN_Systems\Signal\A006\A006_HeaderVars.mqh>
#include <SAN_Systems\Signal\A007\A007_HeaderVars.mqh>

#include <SAN_Systems\Signal\N001\N001_HeaderVars.mqh>
#include <SAN_Systems\Signal\N002\N002_HeaderVars.mqh>
#include <SAN_Systems\Signal\N003\N003_HeaderVars.mqh>
#include <SAN_Systems\Signal\N004\N004_HeaderVars.mqh>
#include <SAN_Systems\Signal\N005\N005_HeaderVars.mqh>
#include <SAN_Systems\Signal\N006\N006_HeaderVars.mqh>
#include <SAN_Systems\Signal\N007\N007_HeaderVars.mqh>
#include <SAN_Systems\Signal\N008\N008_HeaderVars.mqh>
#include <SAN_Systems\Signal\N009\N009_HeaderVars.mqh>
#include <SAN_Systems\Signal\N010\N010_HeaderVars.mqh>
#include <SAN_Systems\Signal\N011\N011_HeaderVars.mqh>
#include <SAN_Systems\Signal\N012\N012_HeaderVars.mqh>
#include <SAN_Systems\Signal\N013\N013_HeaderVars.mqh>
#include <SAN_Systems\Signal\N014\N014_HeaderVars.mqh>
#include <SAN_Systems\Signal\N015\N015_HeaderVars.mqh>
#include <SAN_Systems\Signal\N016\N016_HeaderVars.mqh>
//ADD
#include <SAN_Systems\Signal\N017\N017_HeaderVars.mqh>
#include <SAN_Systems\Signal\N018\N018_HeaderVars.mqh>
#include <SAN_Systems\Signal\N019\N019_HeaderVars.mqh>
#include <SAN_Systems\Signal\N020\N020_HeaderVars.mqh>
#include <SAN_Systems\Signal\N021\N021_HeaderVars.mqh>
#include <SAN_Systems\Signal\N022\N022_HeaderVars.mqh>
#include <SAN_Systems\Signal\N023\N023_HeaderVars.mqh>

void Common_Signal_InitVarsAll()
{

   Common_Signal_InitVars();
   
   A001_Signal_InitVars();
   A002_Signal_InitVars();
   A003_Signal_InitVars();
   A004_Signal_InitVars();
   A005_Signal_InitVars();
   A006_Signal_InitVars();   
   A007_Signal_InitVars(); 
  
   N001_Signal_InitVars();
   N002_Signal_InitVars();
   N003_Signal_InitVars();
   N004_Signal_InitVars();
   N005_Signal_InitVars();
   N006_Signal_InitVars();
   N007_Signal_InitVars();
   N008_Signal_InitVars();
   N009_Signal_InitVars();
   N010_Signal_InitVars();
   N011_Signal_InitVars();
   N012_Signal_InitVars();
   N013_Signal_InitVars();
   N014_Signal_InitVars();
   N015_Signal_InitVars();
   N016_Signal_InitVars();        
   
   //ADD 
   N017_Signal_InitVars();
   N018_Signal_InitVars();
   N019_Signal_InitVars();
   N020_Signal_InitVars();
   N021_Signal_InitVars();
   N022_Signal_InitVars();
   N023_Signal_InitVars();    
}


void Common_Signal_UpdateVarsAll(int settID)
{

   Common_Signal_UpdateVars(settID);
   
   //Print("[Common_Signal_UpdateVarsAll] SignalBaseIndex=",SignalBaseIndex,";SignalBaseName=",SignalBaseName);
   // SignalBaseIndex e 0 kogato z pryv pyt chete ot settingite
   
   if(SignalBaseIndex != 0 && Common_OptimizedProcess)
   {
      switch(SignalBaseIndex)
      {
         case A001: A001_Signal_UpdateVars(settID); break;
         case A002: A002_Signal_UpdateVars(settID); break;
         case A003: A003_Signal_UpdateVars(settID); break;
         case A004: A004_Signal_UpdateVars(settID); break;
         case A005: A005_Signal_UpdateVars(settID); break;
         case A006: A006_Signal_UpdateVars(settID); break;         
         case A007: A007_Signal_UpdateVars(settID); break;

         case N001: N001_Signal_UpdateVars(settID); break;
         case N002: N002_Signal_UpdateVars(settID); break;
         case N003: N003_Signal_UpdateVars(settID); break;
         case N004: N004_Signal_UpdateVars(settID); break;
         case N005: N005_Signal_UpdateVars(settID); break;
         case N006: N006_Signal_UpdateVars(settID); break;
         case N007: N007_Signal_UpdateVars(settID); break;
         case N008: N008_Signal_UpdateVars(settID); break;
         case N009: N009_Signal_UpdateVars(settID); break;
         case N010: N010_Signal_UpdateVars(settID); break;
         case N011: N011_Signal_UpdateVars(settID); break;
         case N012: N012_Signal_UpdateVars(settID); break;
         case N013: N013_Signal_UpdateVars(settID); break;
         case N014: N014_Signal_UpdateVars(settID); break;
         case N015: N015_Signal_UpdateVars(settID); break;
         case N016: N016_Signal_UpdateVars(settID); break;    
         
         //ADD                       
         case N017: N017_Signal_UpdateVars(settID); break;
         case N018: N018_Signal_UpdateVars(settID); break;
         case N019: N019_Signal_UpdateVars(settID); break;
         case N020: N020_Signal_UpdateVars(settID); break;
         case N021: N021_Signal_UpdateVars(settID); break;
         case N022: N022_Signal_UpdateVars(settID); break;
         case N023: N023_Signal_UpdateVars(settID); break;           
      }
   }
   else
   { 
      A001_Signal_UpdateVars(settID);
      A002_Signal_UpdateVars(settID);
      A003_Signal_UpdateVars(settID);
      A004_Signal_UpdateVars(settID);
      A005_Signal_UpdateVars(settID);
      A006_Signal_UpdateVars(settID);      
      A007_Signal_UpdateVars(settID);

      N001_Signal_UpdateVars(settID);
      N002_Signal_UpdateVars(settID);
      N003_Signal_UpdateVars(settID);
      N004_Signal_UpdateVars(settID);
      N005_Signal_UpdateVars(settID);
      N006_Signal_UpdateVars(settID);
      N007_Signal_UpdateVars(settID);
      N008_Signal_UpdateVars(settID);
      N009_Signal_UpdateVars(settID);
      N010_Signal_UpdateVars(settID);
      N011_Signal_UpdateVars(settID);
      N012_Signal_UpdateVars(settID);
      N013_Signal_UpdateVars(settID);
      N014_Signal_UpdateVars(settID);
      N015_Signal_UpdateVars(settID);
      N016_Signal_UpdateVars(settID);   
      
      //Add
		   N017_Signal_UpdateVars(settID);
         N018_Signal_UpdateVars(settID);
         N019_Signal_UpdateVars(settID);
         N020_Signal_UpdateVars(settID);
         N021_Signal_UpdateVars(settID);
         N022_Signal_UpdateVars(settID);
         N023_Signal_UpdateVars(settID);           
   }   

}
   
void Common_Signal_UpdateCalcVarsAll(int settID)
{   
   Common_Signal_UpdateCalcVars(settID);
   //Print("[Common_Signal_UpdateCalcVarsAll] SignalBaseIndex=",SignalBaseIndex);
   if(Common_OptimizedProcess)
   {
      switch(SignalBaseIndex)
         {
         case A001: A001_Signal_UpdateCalcVars(settID); break;
         case A002: A002_Signal_UpdateCalcVars(settID); break;
         case A003: A003_Signal_UpdateCalcVars(settID); break;
         case A004: A004_Signal_UpdateCalcVars(settID); break;
         case A005: A005_Signal_UpdateCalcVars(settID); break;
         case A006: A006_Signal_UpdateCalcVars(settID); break;         
         case A007: A007_Signal_UpdateCalcVars(settID); break;
         
         case N001: N001_Signal_UpdateCalcVars(settID); break;
         case N002: N002_Signal_UpdateCalcVars(settID); break;
         case N003: N003_Signal_UpdateCalcVars(settID); break;
         case N004: N004_Signal_UpdateCalcVars(settID); break;
         case N005: N005_Signal_UpdateCalcVars(settID); break;
         case N006: N006_Signal_UpdateCalcVars(settID); break;
         case N007: N007_Signal_UpdateCalcVars(settID); break;
         case N008: N008_Signal_UpdateCalcVars(settID); break;
         case N009: N009_Signal_UpdateCalcVars(settID); break;
         case N010: N010_Signal_UpdateCalcVars(settID); break;
         case N011: N011_Signal_UpdateCalcVars(settID); break;
         case N012: N012_Signal_UpdateCalcVars(settID); break;
         case N013: N013_Signal_UpdateCalcVars(settID); break;
         case N014: N014_Signal_UpdateCalcVars(settID); break;
         case N015: N015_Signal_UpdateCalcVars(settID); break;
         case N016: N016_Signal_UpdateCalcVars(settID); break; 
         
         //ADD
         case N017: N017_Signal_UpdateCalcVars(settID); break;
         case N018: N018_Signal_UpdateCalcVars(settID); break;
         case N019: N019_Signal_UpdateCalcVars(settID); break;
         case N020: N020_Signal_UpdateCalcVars(settID); break;
         case N021: N021_Signal_UpdateCalcVars(settID); break;
         case N022: N022_Signal_UpdateCalcVars(settID); break;
         case N023: N023_Signal_UpdateCalcVars(settID); break;            
         }
      }
   else
   { 
      A001_Signal_UpdateCalcVars(settID);
      A002_Signal_UpdateCalcVars(settID);
      A003_Signal_UpdateCalcVars(settID);
      A004_Signal_UpdateCalcVars(settID);
      A005_Signal_UpdateCalcVars(settID);
      A006_Signal_UpdateCalcVars(settID);   
      A007_Signal_UpdateCalcVars(settID);

      N001_Signal_UpdateCalcVars(settID);
      N002_Signal_UpdateCalcVars(settID);
      N003_Signal_UpdateCalcVars(settID);
      N004_Signal_UpdateCalcVars(settID);
      N005_Signal_UpdateCalcVars(settID);
      N006_Signal_UpdateCalcVars(settID);
      N007_Signal_UpdateCalcVars(settID);
      N008_Signal_UpdateCalcVars(settID);
      N009_Signal_UpdateCalcVars(settID);
      N010_Signal_UpdateCalcVars(settID);
      N011_Signal_UpdateCalcVars(settID);
      N012_Signal_UpdateCalcVars(settID);
      N013_Signal_UpdateCalcVars(settID);
      N014_Signal_UpdateCalcVars(settID);
      N015_Signal_UpdateCalcVars(settID);
      N016_Signal_UpdateCalcVars(settID); 
      
      //add
		   N017_Signal_UpdateCalcVars(settID);
         N018_Signal_UpdateCalcVars(settID);
         N019_Signal_UpdateCalcVars(settID);
         N020_Signal_UpdateCalcVars(settID);
         N021_Signal_UpdateCalcVars(settID);
         N022_Signal_UpdateCalcVars(settID);
         N023_Signal_UpdateCalcVars(settID);        
   } 
}