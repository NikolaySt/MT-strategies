
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files\MetaTrader 4 Demo STS New\experts\include\SAN_Systems\Signal\N005\N005_Header.mqh 
at 01.07.2011 13:45
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ int N005_CountCloseExtremumBar;
/* extern */ int N005_BackBarsD1;
/* extern */ int N005_ExtremumBars_Close;


//-------------- variable indexes SNI_

/* extern */ int SNI_N005_CountCloseExtremumBar = 0;
/* extern */ int SNI_N005_BackBarsD1 = 0;
/* extern */ int SNI_N005_ExtremumBars_Close = 0;


//-------------- InitVars() section

void N005_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("N005_CountCloseExtremumBar", SNI_N005_CountCloseExtremumBar);
	SAV_Settings_SetMapping("N005_BackBarsD1", SNI_N005_BackBarsD1);
	SAV_Settings_SetMapping("N005_ExtremumBars_Close", SNI_N005_ExtremumBars_Close);
}

//-------------- UpdateVars( int settID ) section

void N005_Signal_UpdateVars(int settID) 
{ 
	N005_CountCloseExtremumBar = 	SAV_Settings_GetIntValueI( settID, SNI_N005_CountCloseExtremumBar);
	N005_BackBarsD1 = 	SAV_Settings_GetIntValueI( settID, SNI_N005_BackBarsD1);
	N005_ExtremumBars_Close = 	SAV_Settings_GetIntValueI( settID, SNI_N005_ExtremumBars_Close);
}

//-------------- UpdateCalcVars( int settID ) section

void N005_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetIntValueI( settID, SNI_N005_CountCloseExtremumBar, N005_CountCloseExtremumBar);
	SAV_Settings_SetIntValueI( settID, SNI_N005_BackBarsD1, N005_BackBarsD1);
	SAV_Settings_SetIntValueI( settID, SNI_N005_ExtremumBars_Close, N005_ExtremumBars_Close);
}
