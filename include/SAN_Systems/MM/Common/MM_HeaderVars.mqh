
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files (x86)\MetaTrader 4 STS Finance\experts\include\SAN_Systems\MM\Common\MM_Header.mqh 
at 24.12.2010 г. 22:49 ч.
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ string MMBaseName;
int MMBaseIndex;
/* extern */ double MM_LotStep;
/* extern */ string MM_TimeStartS;
double MM_TimeStart;


//-------------- variable indexes SNI_

/* extern */ int SNI_MMBaseName = 0;
int SNI_MMBaseIndex = 0;
/* extern */ int SNI_MM_LotStep = 0;
/* extern */ int SNI_MM_TimeStartS = 0;
int SNI_MM_TimeStart = 0;


//-------------- InitVars() section

void Common_MM_InitVars() 
{ 
	SAV_Settings_SetMapping("MMBaseName", SNI_MMBaseName);
	SAV_Settings_SetMapping("MMBaseIndex", SNI_MMBaseIndex);
	SAV_Settings_SetMapping("MM_LotStep", SNI_MM_LotStep);
	SAV_Settings_SetMapping("MM_TimeStartS", SNI_MM_TimeStartS);
	SAV_Settings_SetMapping("MM_TimeStart", SNI_MM_TimeStart);
}

//-------------- UpdateVars( int settID ) section

void Common_MM_UpdateVars(int settID) 
{ 
	MMBaseName = 	SAV_Settings_GetValueI( settID, SNI_MMBaseName);
	MMBaseIndex = 	SAV_Settings_GetIntValueI( settID, SNI_MMBaseIndex);
	MM_LotStep = 	SAV_Settings_GetDoubleValueI( settID, SNI_MM_LotStep);
	MM_TimeStartS = 	SAV_Settings_GetValueI( settID, SNI_MM_TimeStartS);
	MM_TimeStart = 	SAV_Settings_GetDoubleValueI( settID, SNI_MM_TimeStart);
}

//-------------- UpdateCalcVars( int settID ) section

void Common_MM_UpdateCalcVars(int settID) 
{ 
	//SAV_Settings_SetValueI( settID, SNI_MMBaseName, MMBaseName);
	SAV_Settings_SetIntValueI( settID, SNI_MMBaseIndex, MMBaseIndex);
	SAV_Settings_SetDoubleValueI( settID, SNI_MM_LotStep, MM_LotStep);
	SAV_Settings_SetValueI( settID, SNI_MM_TimeStartS, MM_TimeStartS);
	SAV_Settings_SetDoubleValueI( settID, SNI_MM_TimeStart, MM_TimeStart);
}