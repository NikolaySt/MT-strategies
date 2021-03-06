
/*************************************

This file was Generated by MT4Generator 
from file C:\Program Files\MetaTrader 4 Demo STS New\experts\include\SAN_Systems\Signal\A005\A005_Header.mqh 
at 01.07.2011 16:37
Do not modify it!!!!

**************************************/

//-------------- variable defines

/* extern */ int A005_TenkanKijunSenCross;
/* extern */ int A005_TenkanSenCross;
/* extern */ int A005_KijunSenCross;
/* extern */ int A005_KumoBreakout;
/* extern */ int A005_SenkouSpanCross;
/* extern */ int A005_TrendOptions;
/* extern */ int A005_SignalZZDepth;
int A005_SignalZZIndex;
/* extern */ string A005_iChimoku_TimeFrameS;
int A005_iChimoku_TimeFrame;
/* extern */ int A005_TenkanSen;
/* extern */ int A005_KijinSen;
/* extern */ int A005_SencouSpanB;


//-------------- variable indexes SNI_

/* extern */ int SNI_A005_TenkanKijunSenCross = 0;
/* extern */ int SNI_A005_TenkanSenCross = 0;
/* extern */ int SNI_A005_KijunSenCross = 0;
/* extern */ int SNI_A005_KumoBreakout = 0;
/* extern */ int SNI_A005_SenkouSpanCross = 0;
/* extern */ int SNI_A005_TrendOptions = 0;
/* extern */ int SNI_A005_SignalZZDepth = 0;
int SNI_A005_SignalZZIndex = 0;
/* extern */ int SNI_A005_iChimoku_TimeFrameS = 0;
int SNI_A005_iChimoku_TimeFrame = 0;
/* extern */ int SNI_A005_TenkanSen = 0;
/* extern */ int SNI_A005_KijinSen = 0;
/* extern */ int SNI_A005_SencouSpanB = 0;


//-------------- InitVars() section

void A005_Signal_InitVars() 
{ 
	SAV_Settings_SetMapping("A005_TenkanKijunSenCross", SNI_A005_TenkanKijunSenCross);
	SAV_Settings_SetMapping("A005_TenkanSenCross", SNI_A005_TenkanSenCross);
	SAV_Settings_SetMapping("A005_KijunSenCross", SNI_A005_KijunSenCross);
	SAV_Settings_SetMapping("A005_KumoBreakout", SNI_A005_KumoBreakout);
	SAV_Settings_SetMapping("A005_SenkouSpanCross", SNI_A005_SenkouSpanCross);
	SAV_Settings_SetMapping("A005_TrendOptions", SNI_A005_TrendOptions);
	SAV_Settings_SetMapping("A005_SignalZZDepth", SNI_A005_SignalZZDepth);
	SAV_Settings_SetMapping("A005_SignalZZIndex", SNI_A005_SignalZZIndex);
	SAV_Settings_SetMapping("A005_iChimoku_TimeFrameS", SNI_A005_iChimoku_TimeFrameS);
	SAV_Settings_SetMapping("A005_iChimoku_TimeFrame", SNI_A005_iChimoku_TimeFrame);
	SAV_Settings_SetMapping("A005_TenkanSen", SNI_A005_TenkanSen);
	SAV_Settings_SetMapping("A005_KijinSen", SNI_A005_KijinSen);
	SAV_Settings_SetMapping("A005_SencouSpanB", SNI_A005_SencouSpanB);
}

//-------------- UpdateVars( int settID ) section

void A005_Signal_UpdateVars(int settID) 
{ 
	A005_TenkanKijunSenCross = 	SAV_Settings_GetIntValueI( settID, SNI_A005_TenkanKijunSenCross);
	A005_TenkanSenCross = 	SAV_Settings_GetIntValueI( settID, SNI_A005_TenkanSenCross);
	A005_KijunSenCross = 	SAV_Settings_GetIntValueI( settID, SNI_A005_KijunSenCross);
	A005_KumoBreakout = 	SAV_Settings_GetIntValueI( settID, SNI_A005_KumoBreakout);
	A005_SenkouSpanCross = 	SAV_Settings_GetIntValueI( settID, SNI_A005_SenkouSpanCross);
	A005_TrendOptions = 	SAV_Settings_GetIntValueI( settID, SNI_A005_TrendOptions);
	A005_SignalZZDepth = 	SAV_Settings_GetIntValueI( settID, SNI_A005_SignalZZDepth);
	A005_SignalZZIndex = 	SAV_Settings_GetIntValueI( settID, SNI_A005_SignalZZIndex);
	A005_iChimoku_TimeFrameS = 	SAV_Settings_GetValueI( settID, SNI_A005_iChimoku_TimeFrameS);
	A005_iChimoku_TimeFrame = 	SAV_Settings_GetIntValueI( settID, SNI_A005_iChimoku_TimeFrame);
	A005_TenkanSen = 	SAV_Settings_GetIntValueI( settID, SNI_A005_TenkanSen);
	A005_KijinSen = 	SAV_Settings_GetIntValueI( settID, SNI_A005_KijinSen);
	A005_SencouSpanB = 	SAV_Settings_GetIntValueI( settID, SNI_A005_SencouSpanB);
}

//-------------- UpdateCalcVars( int settID ) section

void A005_Signal_UpdateCalcVars(int settID) 
{ 
	SAV_Settings_SetIntValueI( settID, SNI_A005_TenkanKijunSenCross, A005_TenkanKijunSenCross);
	SAV_Settings_SetIntValueI( settID, SNI_A005_TenkanSenCross, A005_TenkanSenCross);
	SAV_Settings_SetIntValueI( settID, SNI_A005_KijunSenCross, A005_KijunSenCross);
	SAV_Settings_SetIntValueI( settID, SNI_A005_KumoBreakout, A005_KumoBreakout);
	SAV_Settings_SetIntValueI( settID, SNI_A005_SenkouSpanCross, A005_SenkouSpanCross);
	SAV_Settings_SetIntValueI( settID, SNI_A005_TrendOptions, A005_TrendOptions);
	SAV_Settings_SetIntValueI( settID, SNI_A005_SignalZZDepth, A005_SignalZZDepth);
	SAV_Settings_SetIntValueI( settID, SNI_A005_SignalZZIndex, A005_SignalZZIndex);
	SAV_Settings_SetValueI( settID, SNI_A005_iChimoku_TimeFrameS, A005_iChimoku_TimeFrameS);
	SAV_Settings_SetIntValueI( settID, SNI_A005_iChimoku_TimeFrame, A005_iChimoku_TimeFrame);
	SAV_Settings_SetIntValueI( settID, SNI_A005_TenkanSen, A005_TenkanSen);
	SAV_Settings_SetIntValueI( settID, SNI_A005_KijinSen, A005_KijinSen);
	SAV_Settings_SetIntValueI( settID, SNI_A005_SencouSpanB, A005_SencouSpanB);
}
