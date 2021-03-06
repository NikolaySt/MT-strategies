
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files\MetaTrader 4 Demo STS New\experts\include\SAN_Systems\Signal\N001\N001_Header.mqh 
at 01.07.2011 13:29
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ int N001_HeadFr_Bar;
/* extern */ int N001_MinorFr_Bar;
/* extern */ int N001_CountBarFindFr_Sec;
/* extern */ double N001_LimitRatioLevel;
/* extern */ double N001_MinCorrWaveRatio;
/* extern */ double N001_LevelRatio1;
/* extern */ double N001_LevelRatio2;
/* extern */ int N001_CountCloseExtremumBar;
/* extern */ int N001_ActiveTrendLine;
/* extern */ int N001_OneLimitByTrend;


//-------------- variable indexes SNI_

/* extern */ int SNI_N001_HeadFr_Bar = 0;
/* extern */ int SNI_N001_MinorFr_Bar = 0;
/* extern */ int SNI_N001_CountBarFindFr_Sec = 0;
/* extern */ int SNI_N001_LimitRatioLevel = 0;
/* extern */ int SNI_N001_MinCorrWaveRatio = 0;
/* extern */ int SNI_N001_LevelRatio1 = 0;
/* extern */ int SNI_N001_LevelRatio2 = 0;
/* extern */ int SNI_N001_CountCloseExtremumBar = 0;
/* extern */ int SNI_N001_ActiveTrendLine = 0;
/* extern */ int SNI_N001_OneLimitByTrend = 0;


//-------------- InitVars() section

void N001_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("N001_HeadFr_Bar", SNI_N001_HeadFr_Bar);
	SAV_Settings_SetMapping("N001_MinorFr_Bar", SNI_N001_MinorFr_Bar);
	SAV_Settings_SetMapping("N001_CountBarFindFr_Sec", SNI_N001_CountBarFindFr_Sec);
	SAV_Settings_SetMapping("N001_LimitRatioLevel", SNI_N001_LimitRatioLevel);
	SAV_Settings_SetMapping("N001_MinCorrWaveRatio", SNI_N001_MinCorrWaveRatio);
	SAV_Settings_SetMapping("N001_LevelRatio1", SNI_N001_LevelRatio1);
	SAV_Settings_SetMapping("N001_LevelRatio2", SNI_N001_LevelRatio2);
	SAV_Settings_SetMapping("N001_CountCloseExtremumBar", SNI_N001_CountCloseExtremumBar);
	SAV_Settings_SetMapping("N001_ActiveTrendLine", SNI_N001_ActiveTrendLine);
	SAV_Settings_SetMapping("N001_OneLimitByTrend", SNI_N001_OneLimitByTrend);
}

//-------------- UpdateVars( int settID ) section

void N001_Signal_UpdateVars(int settID) 
{ 
	N001_HeadFr_Bar = 	SAV_Settings_GetIntValueI( settID, SNI_N001_HeadFr_Bar);
	N001_MinorFr_Bar = 	SAV_Settings_GetIntValueI( settID, SNI_N001_MinorFr_Bar);
	N001_CountBarFindFr_Sec = 	SAV_Settings_GetIntValueI( settID, SNI_N001_CountBarFindFr_Sec);
	N001_LimitRatioLevel = 	SAV_Settings_GetDoubleValueI( settID, SNI_N001_LimitRatioLevel);
	N001_MinCorrWaveRatio = 	SAV_Settings_GetDoubleValueI( settID, SNI_N001_MinCorrWaveRatio);
	N001_LevelRatio1 = 	SAV_Settings_GetDoubleValueI( settID, SNI_N001_LevelRatio1);
	N001_LevelRatio2 = 	SAV_Settings_GetDoubleValueI( settID, SNI_N001_LevelRatio2);
	N001_CountCloseExtremumBar = 	SAV_Settings_GetIntValueI( settID, SNI_N001_CountCloseExtremumBar);
	N001_ActiveTrendLine = 	SAV_Settings_GetIntValueI( settID, SNI_N001_ActiveTrendLine);
	N001_OneLimitByTrend = 	SAV_Settings_GetIntValueI( settID, SNI_N001_OneLimitByTrend);
}

//-------------- UpdateCalcVars( int settID ) section

void N001_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetIntValueI( settID, SNI_N001_HeadFr_Bar, N001_HeadFr_Bar);
	SAV_Settings_SetIntValueI( settID, SNI_N001_MinorFr_Bar, N001_MinorFr_Bar);
	SAV_Settings_SetIntValueI( settID, SNI_N001_CountBarFindFr_Sec, N001_CountBarFindFr_Sec);
	SAV_Settings_SetDoubleValueI( settID, SNI_N001_LimitRatioLevel, N001_LimitRatioLevel);
	SAV_Settings_SetDoubleValueI( settID, SNI_N001_MinCorrWaveRatio, N001_MinCorrWaveRatio);
	SAV_Settings_SetDoubleValueI( settID, SNI_N001_LevelRatio1, N001_LevelRatio1);
	SAV_Settings_SetDoubleValueI( settID, SNI_N001_LevelRatio2, N001_LevelRatio2);
	SAV_Settings_SetIntValueI( settID, SNI_N001_CountCloseExtremumBar, N001_CountCloseExtremumBar);
	SAV_Settings_SetIntValueI( settID, SNI_N001_ActiveTrendLine, N001_ActiveTrendLine);
	SAV_Settings_SetIntValueI( settID, SNI_N001_OneLimitByTrend, N001_OneLimitByTrend);
}
