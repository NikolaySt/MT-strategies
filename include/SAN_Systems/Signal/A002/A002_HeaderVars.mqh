
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files\MetaTrader 4 Demo STS New\experts\include\SAN_Systems\Signal\A002\A002_Header.mqh 
at 01.07.2011 16:35
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ int A002_ZZExtDepth;
int A002_ZZIndex;
/* extern */ int A002_TrendOptions;


//-------------- variable indexes SNI_

/* extern */ int SNI_A002_ZZExtDepth = 0;
int SNI_A002_ZZIndex = 0;
/* extern */ int SNI_A002_TrendOptions = 0;


//-------------- InitVars() section

void A002_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("A002_ZZExtDepth", SNI_A002_ZZExtDepth);
	SAV_Settings_SetMapping("A002_ZZIndex", SNI_A002_ZZIndex);
	SAV_Settings_SetMapping("A002_TrendOptions", SNI_A002_TrendOptions);
}

//-------------- UpdateVars( int settID ) section

void A002_Signal_UpdateVars(int settID) 
{ 
	A002_ZZExtDepth = 	SAV_Settings_GetIntValueI( settID, SNI_A002_ZZExtDepth);
	A002_ZZIndex = 	SAV_Settings_GetIntValueI( settID, SNI_A002_ZZIndex);
	A002_TrendOptions = 	SAV_Settings_GetIntValueI( settID, SNI_A002_TrendOptions);
}

//-------------- UpdateCalcVars( int settID ) section

void A002_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetIntValueI( settID, SNI_A002_ZZExtDepth, A002_ZZExtDepth);
	SAV_Settings_SetIntValueI( settID, SNI_A002_ZZIndex, A002_ZZIndex);
	SAV_Settings_SetIntValueI( settID, SNI_A002_TrendOptions, A002_TrendOptions);
}