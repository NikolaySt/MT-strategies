
#include <SAN_Systems\Signal\Common\Signals.mqh>

#include <SAN_Systems\Signal\N001\N001.mqh>
#include <SAN_Systems\Signal\N002\N002.mqh>
#include <SAN_Systems\Signal\N003\N003.mqh>
#include <SAN_Systems\Signal\N004\N004.mqh>
#include <SAN_Systems\Signal\N005\N005.mqh>
#include <SAN_Systems\Signal\N006\N006.mqh>
#include <SAN_Systems\Signal\N007\N007.mqh>
#include <SAN_Systems\Signal\N008\N008.mqh>
#include <SAN_Systems\Signal\N009\N009.mqh>
#include <SAN_Systems\Signal\N010\N010.mqh>
#include <SAN_Systems\Signal\N011\N011.mqh>
#include <SAN_Systems\Signal\N012\N012.mqh>
#include <SAN_Systems\Signal\N013\N013.mqh>
#include <SAN_Systems\Signal\N014\N014.mqh>
#include <SAN_Systems\Signal\N015\N015.mqh>
#include <SAN_Systems\Signal\N016\N016.mqh>
//ADD
#include <SAN_Systems\Signal\N017\N017.mqh>
#include <SAN_Systems\Signal\N018\N018.mqh>
#include <SAN_Systems\Signal\N019\N019.mqh>
#include <SAN_Systems\Signal\N020\N020.mqh>
#include <SAN_Systems\Signal\N021\N021.mqh>
#include <SAN_Systems\Signal\N022\N022.mqh>
#include <SAN_Systems\Signal\N023\N023.mqh>



#include <SAN_Systems\Signal\A001\A001.mqh>
#include <SAN_Systems\Signal\A002\A002.mqh>
#include <SAN_Systems\Signal\A003\A003.mqh>
#include <SAN_Systems\Signal\A004\A004.mqh>
#include <SAN_Systems\Signal\A005\A005.mqh>
#include <SAN_Systems\Signal\A006\A006.mqh>
#include <SAN_Systems\Signal\A007\A007.mqh>

void Common_Signals_InitAll(int settID)
{
   Common_Signals_Init(settID);
   
   if( SignalBaseName == "" ) Print("[Common_Signals_Create] Unknown SignalType=", SignalBaseName );
   else if( SignalBaseName == "A001" ) SignalBaseIndex = A001;
   else if( SignalBaseName == "A002" ) SignalBaseIndex = A002;
   else if( SignalBaseName == "A003" ) SignalBaseIndex = A003;
   else if( SignalBaseName == "A004" ) SignalBaseIndex = A004;
   else if( SignalBaseName == "A005" ) SignalBaseIndex = A005;
   else if( SignalBaseName == "A006" ) SignalBaseIndex = A006;   
   else if( SignalBaseName == "A007" ) SignalBaseIndex = A007;
   
   else if( SignalBaseName == "N001" ) SignalBaseIndex = N001;
   else if( SignalBaseName == "N002" ) SignalBaseIndex = N002;
   else if( SignalBaseName == "N003" ) SignalBaseIndex = N003;
   else if( SignalBaseName == "N004" ) SignalBaseIndex = N004;
   else if( SignalBaseName == "N005" ) SignalBaseIndex = N005;
   else if( SignalBaseName == "N006" ) SignalBaseIndex = N006;
   else if( SignalBaseName == "N007" ) SignalBaseIndex = N007;
   else if( SignalBaseName == "N008" ) SignalBaseIndex = N008;
   else if( SignalBaseName == "N009" ) SignalBaseIndex = N009;
   else if( SignalBaseName == "N010" ) SignalBaseIndex = N010;
   else if( SignalBaseName == "N011" ) SignalBaseIndex = N011;
   else if( SignalBaseName == "N012" ) SignalBaseIndex = N012;
   else if( SignalBaseName == "N013" ) SignalBaseIndex = N013;
   else if( SignalBaseName == "N014" ) SignalBaseIndex = N014;
   else if( SignalBaseName == "N015" ) SignalBaseIndex = N015;
   else if( SignalBaseName == "N016" ) SignalBaseIndex = N016;         
   
   else if( SignalBaseName == "N017" ) SignalBaseIndex = N017;
   else if( SignalBaseName == "N018" ) SignalBaseIndex = N018;
   else if( SignalBaseName == "N019" ) SignalBaseIndex = N019;
   else if( SignalBaseName == "N020" ) SignalBaseIndex = N020;
   else if( SignalBaseName == "N021" ) SignalBaseIndex = N021;
   else if( SignalBaseName == "N022" ) SignalBaseIndex = N022;
   else if( SignalBaseName == "N023" ) SignalBaseIndex = N023;     

   if(Common_OptimizedProcess)
   {
      switch(SignalBaseIndex)
      {
         case A001:A001_Signals_Init(settID); break;
         case A002:A002_Signals_Init(settID); break;
         case A003:A003_Signals_Init(settID); break;
         case A004:A004_Signals_Init(settID); break;
         case A005:A005_Signals_Init(settID); break;
         case A006:A006_Signals_Init(settID); break;         
         case A007:A007_Signals_Init(settID); break; 
         
         case N001: N001_Signals_Init(settID); break;
         case N002: N002_Signals_Init(settID); break;
         case N003: N003_Signals_Init(settID); break;
         case N004: N004_Signals_Init(settID); break;
         case N005: N005_Signals_Init(settID); break;
         case N006: N006_Signals_Init(settID); break;
         case N007: N007_Signals_Init(settID); break;
         case N008: N008_Signals_Init(settID); break;
         case N009: N009_Signals_Init(settID); break;
         case N010: N010_Signals_Init(settID); break;
         case N011: N011_Signals_Init(settID); break;
         case N012: N012_Signals_Init(settID); break;
         case N013: N013_Signals_Init(settID); break;
         case N014: N014_Signals_Init(settID); break;
         case N015: N015_Signals_Init(settID); break;
         case N016: N016_Signals_Init(settID); break;       
         
         case N017: N017_Signals_Init(settID); break;
         case N018: N018_Signals_Init(settID); break;
         case N019: N019_Signals_Init(settID); break;
         case N020: N020_Signals_Init(settID); break;
         case N021: N021_Signals_Init(settID); break;
         case N022: N022_Signals_Init(settID); break;
         case N023: N023_Signals_Init(settID); break;                                 
      }
   }
   else
   {   
      if( SignalBaseName == "" ) Print("[Common_Signals_Create] Unknown SignalType=", SignalBaseName );
      else if( SignalBaseName == "A001" ) A001_Signals_Init(settID);
      else if( SignalBaseName == "A002" ) A002_Signals_Init(settID);  
      else if( SignalBaseName == "A003" ) A003_Signals_Init(settID);
      else if( SignalBaseName == "A004" ) A004_Signals_Init(settID);
      else if( SignalBaseName == "A005" ) A005_Signals_Init(settID);  
      else if( SignalBaseName == "A006" ) A006_Signals_Init(settID);      
      else if( SignalBaseName == "A007" ) A007_Signals_Init(settID);
                

      else if( SignalBaseName == "N001" )N001_Signals_Init(settID);
      else if( SignalBaseName == "N002" )N002_Signals_Init(settID);
      else if( SignalBaseName == "N003" )N003_Signals_Init(settID);
      else if( SignalBaseName == "N004" )N004_Signals_Init(settID);
      else if( SignalBaseName == "N005" )N005_Signals_Init(settID);
      else if( SignalBaseName == "N006" )N006_Signals_Init(settID);
      else if( SignalBaseName == "N007" )N007_Signals_Init(settID);
      else if( SignalBaseName == "N008" )N008_Signals_Init(settID);
      else if( SignalBaseName == "N009" )N009_Signals_Init(settID);
      else if( SignalBaseName == "N010" )N010_Signals_Init(settID);
      else if( SignalBaseName == "N011" )N011_Signals_Init(settID);
      else if( SignalBaseName == "N012" )N012_Signals_Init(settID);
      else if( SignalBaseName == "N013" )N013_Signals_Init(settID);
      else if( SignalBaseName == "N014" )N014_Signals_Init(settID);
      else if( SignalBaseName == "N015" )N015_Signals_Init(settID);
      else if( SignalBaseName == "N016" )N016_Signals_Init(settID);
      
      //ADD
      else if( SignalBaseName == "N017" )N017_Signals_Init(settID);
      else if( SignalBaseName == "N018" )N018_Signals_Init(settID);
      else if( SignalBaseName == "N019" )N019_Signals_Init(settID);
      else if( SignalBaseName == "N020" )N020_Signals_Init(settID);
      else if( SignalBaseName == "N021" )N021_Signals_Init(settID);
      else if( SignalBaseName == "N022" )N022_Signals_Init(settID);
      else if( SignalBaseName == "N023" )N023_Signals_Init(settID);	      
                         
   }
}

void Common_Signals_ProcessAll(int settID)
{
   Common_Process(settID);
   
   if(Common_OptimizedProcess)
   {
      switch(SignalBaseIndex)
      {
         case A001: A001_Signals_Process(settID); break;
         case A002: A002_Signals_Process(settID); break;
         case A003: A003_Signals_Process(settID); break;
         case A004: A004_Signals_Process(settID); break;
         case A005: A005_Signals_Process(settID); break;
         case A006: A006_Signals_Process(settID); break;         
         case A007: A007_Signals_Process(settID); break; 
         
         case N001: N001_Signals_Process(settID); break;
         case N002: N002_Signals_Process(settID); break;
         case N003: N003_Signals_Process(settID); break;
         case N004: N004_Signals_Process(settID); break;
         case N005: N005_Signals_Process(settID); break;
         case N006: N006_Signals_Process(settID); break;
         case N007: N007_Signals_Process(settID); break;
         case N008: N008_Signals_Process(settID); break;
         case N009: N009_Signals_Process(settID); break;
         case N010: N010_Signals_Process(settID); break;
         case N011: N011_Signals_Process(settID); break;
         case N012: N012_Signals_Process(settID); break;
         case N013: N013_Signals_Process(settID); break;
         case N014: N014_Signals_Process(settID); break;
         case N015: N015_Signals_Process(settID); break;
         case N016: N016_Signals_Process(settID); break;   
         //ADD
         case N017: N017_Signals_Process(settID); break;
         case N018: N018_Signals_Process(settID); break;
         case N019: N019_Signals_Process(settID); break;
         case N020: N020_Signals_Process(settID); break;
         case N021: N021_Signals_Process(settID); break;
         case N022: N022_Signals_Process(settID); break;
         case N023: N023_Signals_Process(settID); break;            
      }
   }
   else
   { 
      
      if( SignalBaseName == "" )  Print("[Common_Signals_Process] Unknown SignalType=", SignalBaseName );
      else if( SignalBaseName == "A001" )  A001_Signals_Process(settID);
      else if( SignalBaseName == "A002" )  A002_Signals_Process(settID);    
      else if( SignalBaseName == "A003" )  A003_Signals_Process(settID);                
      else if( SignalBaseName == "A004" )  A004_Signals_Process(settID);
      else if( SignalBaseName == "A005" )  A005_Signals_Process(settID);    
      else if( SignalBaseName == "A006" )  A006_Signals_Process(settID);        
      else if( SignalBaseName == "A007" )  A007_Signals_Process(settID); 
      
      else if( SignalBaseName == "N001" )N001_Signals_Process(settID);
      else if( SignalBaseName == "N002" )N002_Signals_Process(settID);
      else if( SignalBaseName == "N003" )N003_Signals_Process(settID);
      else if( SignalBaseName == "N004" )N004_Signals_Process(settID);
      else if( SignalBaseName == "N005" )N005_Signals_Process(settID);
      else if( SignalBaseName == "N006" )N006_Signals_Process(settID);
      else if( SignalBaseName == "N007" )N007_Signals_Process(settID);
      else if( SignalBaseName == "N008" )N008_Signals_Process(settID);
      else if( SignalBaseName == "N009" )N009_Signals_Process(settID);
      else if( SignalBaseName == "N010" )N010_Signals_Process(settID);
      else if( SignalBaseName == "N011" )N011_Signals_Process(settID);
      else if( SignalBaseName == "N012" )N012_Signals_Process(settID);
      else if( SignalBaseName == "N013" )N013_Signals_Process(settID);
      else if( SignalBaseName == "N014" )N014_Signals_Process(settID);
      else if( SignalBaseName == "N015" )N015_Signals_Process(settID);
      else if( SignalBaseName == "N016" )N016_Signals_Process(settID);
      
      //ADD
      else if( SignalBaseName == "N017" )N017_Signals_Process(settID);
      else if( SignalBaseName == "N018" )N018_Signals_Process(settID);
      else if( SignalBaseName == "N019" )N019_Signals_Process(settID);
      else if( SignalBaseName == "N020" )N020_Signals_Process(settID);
      else if( SignalBaseName == "N021" )N021_Signals_Process(settID);
      else if( SignalBaseName == "N022" )N022_Signals_Process(settID);
      else if( SignalBaseName == "N023" )N023_Signals_Process(settID);	      
            
   }
}