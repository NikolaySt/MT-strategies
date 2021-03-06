#property copyright "Copyright © 2011 SANTeam"
#property link      "revision 18.02.2011"

#include <stdlib.mqh>
#include <stderror.mqh>
#include <SAN_Systems\Common\Utils\SAN_Statistical.mqh>
int start(){
   Stat_HistOrdersToDll("Acc:"+AccountNumber());
   Print("[History]:To DLL");
   Stat_HistOrdersToFile(false, 0, "history_"+"Acc:"+AccountNumber()+".txt");
   return(0);
}