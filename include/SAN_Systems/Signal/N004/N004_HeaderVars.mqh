
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files\MetaTrader 4 Demo STS New\experts\include\SAN_Systems\Signal\N004\N004_Header.mqh 
at 01.07.2011 13:42
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ int N004_MAPeriod;
/* extern */ int N004_BiasPeriod;
/* extern */ int N004_ST_AtdPeriod;
/* extern */ double N004_ST_Multiplier;
/* extern */ int N004_CountCloseExtremumBar;


//-------------- variable indexes SNI_

/* extern */ int SNI_N004_MAPeriod = 0;
/* extern */ int SNI_N004_BiasPeriod = 0;
/* extern */ int SNI_N004_ST_AtdPeriod = 0;
/* extern */ int SNI_N004_ST_Multiplier = 0;
/* extern */ int SNI_N004_CountCloseExtremumBar = 0;


//-------------- InitVars() section

void N004_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("N004_MAPeriod", SNI_N004_MAPeriod);
	SAV_Settings_SetMapping("N004_BiasPeriod", SNI_N004_BiasPeriod);
	SAV_Settings_SetMapping("N004_ST_AtdPeriod", SNI_N004_ST_AtdPeriod);
	SAV_Settings_SetMapping("N004_ST_Multiplier", SNI_N004_ST_Multiplier);
	SAV_Settings_SetMapping("N004_CountCloseExtremumBar", SNI_N004_CountCloseExtremumBar);
}

//-------------- UpdateVars( int settID ) section

void N004_Signal_UpdateVars(int settID) 
{ 
	N004_MAPeriod = 	SAV_Settings_GetIntValueI( settID, SNI_N004_MAPeriod);
	N004_BiasPeriod = 	SAV_Settings_GetIntValueI( settID, SNI_N004_BiasPeriod);
	N004_ST_AtdPeriod = 	SAV_Settings_GetIntValueI( settID, SNI_N004_ST_AtdPeriod);
	N004_ST_Multiplier = 	SAV_Settings_GetDoubleValueI( settID, SNI_N004_ST_Multiplier);
	N004_CountCloseExtremumBar = 	SAV_Settings_GetIntValueI( settID, SNI_N004_CountCloseExtremumBar);
}

//-------------- UpdateCalcVars( int settID ) section

void N004_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetIntValueI( settID, SNI_N004_MAPeriod, N004_MAPeriod);
	SAV_Settings_SetIntValueI( settID, SNI_N004_BiasPeriod, N004_BiasPeriod);
	SAV_Settings_SetIntValueI( settID, SNI_N004_ST_AtdPeriod, N004_ST_AtdPeriod);
	SAV_Settings_SetDoubleValueI( settID, SNI_N004_ST_Multiplier, N004_ST_Multiplier);
	SAV_Settings_SetIntValueI( settID, SNI_N004_CountCloseExtremumBar, N004_CountCloseExtremumBar);
}
