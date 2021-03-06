
#include <SAN_Systems\Trend\Common\Trend.mqh>

#include <SAN_Systems\Trend\TA001\TA001.mqh>
#include <SAN_Systems\Trend\TN001\TN001.mqh>
#include <SAN_Systems\Trend\TN002\TN002.mqh>


void Common_Trend_InitAll( int settID )
{
   Common_Trend_Init( settID );
   
   if(TrendBaseName == "TA001" )      TrendBaseIndex = TA001;
   else if(TrendBaseName == "TN001" ) TrendBaseIndex = TN001;
   else if(TrendBaseName == "TN002" ) TrendBaseIndex = TN002;
   else                               TrendBaseIndex = T0000;
      
   if(Common_OptimizedProcess)
   {
      switch(TrendBaseIndex)
      {
      case TA001:TA001_Trend_Init(settID); break;
      case TN001:TN001_Trend_Init(settID); break;
      case TN002:TN002_Trend_Init(settID); break;
      }
   }
   else
   { 
      if(TrendBaseName == "TA001" )
      {
         TA001_Trend_Init(settID);
      }
      else if(TrendBaseName == "TN001" )
      {  
         TN001_Trend_Init(settID);
      }   
      else if(TrendBaseName == "TN002" )
      {  
         TN002_Trend_Init(settID);
      }
   }   
   
}

int Common_Trend_Get( int settID )
{
   return (Common_Trend_GetByIndex(settID,0));
}

int Common_Trend_GetByIndex( int settID, int index )
{
   int result = 0;
   
   if(Common_OptimizedProcess)
   {
      switch(TrendBaseIndex)
      {
      case TA001:result = TA001_Trend_GetByIndex(settID, index); break;
      case TN001:result = TN001_Trend_GetByIndex(settID, index); break;
      case TN002:result = TN002_Trend_GetByIndex(settID, index); break;
      }
   }
   else
   {
      if( TrendBaseName == "" )
      {
         if( Trend_Trace == true ) Print("[Common_Trend_GetByIndex] TrendBaseName not set!!!!!");
      }
      else if(TrendBaseName == "TA001" )
      {
         result = TA001_Trend_GetByIndex(settID, index);
      }     
      else if(TrendBaseName == "TN001" )
      {
         result = TN001_Trend_GetByIndex(settID, index);      
      }   
      else if(TrendBaseName == "TN002" )
      {
         result = TN002_Trend_GetByIndex(settID, index);      
      }
   }             
   return(result);   
}

int Common_Trend_GetLengthByIndex( int settID, int index )
{
   int result = 0;
   
   if(Common_OptimizedProcess)
   {
      switch(TrendBaseIndex)
      {
      case TA001:result = TA001_Trend_GetLenghtByIndex(settID, index); break;
      case TN001:result = TN001_Trend_GetLenghtByIndex(settID, index); break;
      case TN002:result = TN002_Trend_GetLenghtByIndex(settID, index); break;
      }
   }
   else
   {
      if( TrendBaseName == "" )
      {
         if( Trend_Trace == true ) Print("[Common_Trend_GetLengthByIndex] TrendBaseName not set!!!!!");
      }
      else if(TrendBaseName == "TA001" )
      {
         result = TA001_Trend_GetLenghtByIndex(settID, index);
      }     
      else if(TrendBaseName == "TN001" )
      {
         result = TN001_Trend_GetLenghtByIndex(settID, index);
      }   
      else if(TrendBaseName == "TN002" )
      {
         result = TN002_Trend_GetLenghtByIndex(settID, index);
      }  
   }           
   return(result);   
}



int Common_Trend_GetTimeByIndex( int settID, int index )
{
   int result = 0;
   
   if(Common_OptimizedProcess)
   {
      switch(TrendBaseIndex)
      {
      case TA001:result = TA001_Trend_GetTimeByIndex(settID, index); break;
      case TN001:result = TN001_Trend_GetTimeByIndex(settID, index); break;
      case TN002:result = TN002_Trend_GetTimeByIndex(settID, index); break;
      }
   }
   else
   {
      if( TrendBaseName == "" )
      {
         if( Trend_Trace == true ) Print("[Common_Trend_GetTimeByIndex] TrendBaseName not set!!!!!");
      }
      else if(TrendBaseName == "TA001" )
      {
         result = TA001_Trend_GetTimeByIndex(settID, index);
      }     
      else if(TrendBaseName == "TN001" )
      {
         result = TN001_Trend_GetTimeByIndex(settID, index);
      }  
      else if(TrendBaseName == "TN002" )
      {
         result = TN002_Trend_GetTimeByIndex(settID, index);
      }
   }              
   return(result);   
}

