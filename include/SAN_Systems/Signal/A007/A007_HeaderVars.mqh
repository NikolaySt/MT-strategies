
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files (x86)\MetaTrader 4 STS Finance\experts\include\SAN_Systems\Signal\A007\A007_Header.mqh 
at 4.7.2011 г. 22:17 ч.
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ int A007_MinSignalBar;
/* extern */ int A007_MaxSearchBarsBack;
/* extern */ int A007_TrendOptions;


//-------------- variable indexes SNI_

/* extern */ int SNI_A007_MinSignalBar = 0;
/* extern */ int SNI_A007_MaxSearchBarsBack = 0;
/* extern */ int SNI_A007_TrendOptions = 0;


//-------------- InitVars() section

void A007_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("A007_MinSignalBar", SNI_A007_MinSignalBar);
	SAV_Settings_SetMapping("A007_MaxSearchBarsBack", SNI_A007_MaxSearchBarsBack);
	SAV_Settings_SetMapping("A007_TrendOptions", SNI_A007_TrendOptions);
}

//-------------- UpdateVars( int settID ) section

void A007_Signal_UpdateVars(int settID) 
{ 
	A007_MinSignalBar = 	SAV_Settings_GetIntValueI( settID, SNI_A007_MinSignalBar);
	A007_MaxSearchBarsBack = 	SAV_Settings_GetIntValueI( settID, SNI_A007_MaxSearchBarsBack);
	A007_TrendOptions = 	SAV_Settings_GetIntValueI( settID, SNI_A007_TrendOptions);
}

//-------------- UpdateCalcVars( int settID ) section

void A007_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetIntValueI( settID, SNI_A007_MinSignalBar, A007_MinSignalBar);
	SAV_Settings_SetIntValueI( settID, SNI_A007_MaxSearchBarsBack, A007_MaxSearchBarsBack);
	SAV_Settings_SetIntValueI( settID, SNI_A007_TrendOptions, A007_TrendOptions);
}