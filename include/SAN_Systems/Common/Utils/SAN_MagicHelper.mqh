//|                                           SAN_MagicHelper.mqh   |
//|                   #include <SAV_Framework/SAN_OrdersHelper.mqh>  |
//|                            Copyright © 2011, SAN Andrey&Nikolai. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

//-------------------------------------------------------------------
int DateHash_GetPrecision()
{
   int result;

   result = 60*60;//hours precision
  
   return (result);
}

//-------------------------------------------------------------------
//конвертиране от дата до 16 битово число
int DateHash_FromDateTime(datetime value)
{
   //konverrtiame ot sekundi v chasove
   //imame garancia za unikalno chislo za 8 godini gore dolu
   int dateInHours = value/(DateHash_GetPrecision());
   //samo 16 bita ni triabvat
   int out = dateInHours%0xFFFF; 
   
   return (out);
}
//-------------------------------------------------------------------
//конвериране от 16 битово число до дата със дадена дата близка до текущата
datetime DateHash_ToDateTime(int value, datetime orderOpenTime)
{ 
   int dateInHours = (orderOpenTime/(DateHash_GetPrecision()))/0xFFFF;
   int result = value*(DateHash_GetPrecision())+dateInHours*0xFFFF*DateHash_GetPrecision();
   if(result > orderOpenTime)
   {
      result = result - 0xFFFF*DateHash_GetPrecision();
   }
   
   return (result);
}

//magic gornite 16 bita za signalTime
// 9 bita za stop 0 - 511   maska 0xFF80 maks stojnost 0x1FF
// 7 bita za settID 0 -127  maska 0x7F

// |        time | |stop    |sID |
// |       16-bit| |9 bit   |7 b |
// 0000000 0000000 0000000 0000000
int Magic_Create( int settID, datetime signalTime, int sl )
{
   //return (settID*100000) ;
   int datehash = DateHash_FromDateTime(signalTime)<<16;
   return (datehash | (((sl&0x1FF)<<7)&0xFF80) | (settID&0x7F));
   //int datehash = DateHash_FromDateTime(signalTime)<<16;
   //datehash = ShiftLeft(datehash,16);
   //return (datehash | (ShiftLeft(sl&0x1FF,7)&0xFF80) | (settID&0x7F));
}
/*
#define SAV_MAGIC_SETTINGS_SHIFT  100000

int Magic_Create( int settID, int signalType, datetime signalTime, int sl )
{
   if( signalType > (SAV_MAGIC_SETTINGS_SHIFT -1) )
   {
      Print("[SAV_Magic_Create] Error! type is too big type=", signalType );
   }
   return ((settID*SAV_MAGIC_SETTINGS_SHIFT) | signalType);
}*/

datetime Magic_GetSignalTime( int magic, datetime orderOpenTime )
{
   
   datetime result;
   result = DateHash_ToDateTime(Magic_GetDateHash(magic), orderOpenTime);
   
   return (result);
}

int Magic_GetSettingsID( int magic )
{
   //int result = magic/100000;
   int result = magic&0x7F;
   return (result);
}
int Magic_GetStop(int magic)
{
   return ((magic&0xFF80)>>7);
}

int Magic_GetDateHash(int magic)
{
   int datehash = ((magic&0xFFFF0000)>>16) & 0xFFFF;
   return (datehash);
}