
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files\MetaTrader 4 Demo STS New\experts\include\SAN_Systems\Signal\N019\N019_Header.mqh 
at 01.08.2011 13:15
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ string N019_Ichimoku_TimeFrameS;
int N019_Ichimoku_TimeFrame;
/* extern */ int N019_TenkanSen;
/* extern */ int N019_KijinSen;
/* extern */ int N019_SencouSpanB;
/* extern */ int N019_SignalCount;
/* extern */ int N019_StochK;
/* extern */ int N019_StochSlow;
/* extern */ int N019_MAExitPeriod;
/* extern */ int N019_MAExitShift;


//-------------- variable indexes SNI_

/* extern */ int SNI_N019_Ichimoku_TimeFrameS = 0;
int SNI_N019_Ichimoku_TimeFrame = 0;
/* extern */ int SNI_N019_TenkanSen = 0;
/* extern */ int SNI_N019_KijinSen = 0;
/* extern */ int SNI_N019_SencouSpanB = 0;
/* extern */ int SNI_N019_SignalCount = 0;
/* extern */ int SNI_N019_StochK = 0;
/* extern */ int SNI_N019_StochSlow = 0;
/* extern */ int SNI_N019_MAExitPeriod = 0;
/* extern */ int SNI_N019_MAExitShift = 0;


//-------------- InitVars() section

void N019_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("N019_Ichimoku_TimeFrameS", SNI_N019_Ichimoku_TimeFrameS);
	SAV_Settings_SetMapping("N019_Ichimoku_TimeFrame", SNI_N019_Ichimoku_TimeFrame);
	SAV_Settings_SetMapping("N019_TenkanSen", SNI_N019_TenkanSen);
	SAV_Settings_SetMapping("N019_KijinSen", SNI_N019_KijinSen);
	SAV_Settings_SetMapping("N019_SencouSpanB", SNI_N019_SencouSpanB);
	SAV_Settings_SetMapping("N019_SignalCount", SNI_N019_SignalCount);
	SAV_Settings_SetMapping("N019_StochK", SNI_N019_StochK);
	SAV_Settings_SetMapping("N019_StochSlow", SNI_N019_StochSlow);
	SAV_Settings_SetMapping("N019_MAExitPeriod", SNI_N019_MAExitPeriod);
	SAV_Settings_SetMapping("N019_MAExitShift", SNI_N019_MAExitShift);
}

//-------------- UpdateVars( int settID ) section

void N019_Signal_UpdateVars(int settID) 
{ 
	N019_Ichimoku_TimeFrameS = 	SAV_Settings_GetValueI( settID, SNI_N019_Ichimoku_TimeFrameS);
	N019_Ichimoku_TimeFrame = 	SAV_Settings_GetIntValueI( settID, SNI_N019_Ichimoku_TimeFrame);
	N019_TenkanSen = 	SAV_Settings_GetIntValueI( settID, SNI_N019_TenkanSen);
	N019_KijinSen = 	SAV_Settings_GetIntValueI( settID, SNI_N019_KijinSen);
	N019_SencouSpanB = 	SAV_Settings_GetIntValueI( settID, SNI_N019_SencouSpanB);
	N019_SignalCount = 	SAV_Settings_GetIntValueI( settID, SNI_N019_SignalCount);
	N019_StochK = 	SAV_Settings_GetIntValueI( settID, SNI_N019_StochK);
	N019_StochSlow = 	SAV_Settings_GetIntValueI( settID, SNI_N019_StochSlow);
	N019_MAExitPeriod = 	SAV_Settings_GetIntValueI( settID, SNI_N019_MAExitPeriod);
	N019_MAExitShift = 	SAV_Settings_GetIntValueI( settID, SNI_N019_MAExitShift);
}

//-------------- UpdateCalcVars( int settID ) section

void N019_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetValueI( settID, SNI_N019_Ichimoku_TimeFrameS, N019_Ichimoku_TimeFrameS);
	SAV_Settings_SetIntValueI( settID, SNI_N019_Ichimoku_TimeFrame, N019_Ichimoku_TimeFrame);
	SAV_Settings_SetIntValueI( settID, SNI_N019_TenkanSen, N019_TenkanSen);
	SAV_Settings_SetIntValueI( settID, SNI_N019_KijinSen, N019_KijinSen);
	SAV_Settings_SetIntValueI( settID, SNI_N019_SencouSpanB, N019_SencouSpanB);
	SAV_Settings_SetIntValueI( settID, SNI_N019_SignalCount, N019_SignalCount);
	SAV_Settings_SetIntValueI( settID, SNI_N019_StochK, N019_StochK);
	SAV_Settings_SetIntValueI( settID, SNI_N019_StochSlow, N019_StochSlow);
	SAV_Settings_SetIntValueI( settID, SNI_N019_MAExitPeriod, N019_MAExitPeriod);
	SAV_Settings_SetIntValueI( settID, SNI_N019_MAExitShift, N019_MAExitShift);
}
