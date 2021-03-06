int    TN001_MAPeriod   = 0;
int    TN001_MAShift    = 0;
double TN001_MA_Env_Dev = 0;
int    TN001_Atr_Period = 0;
double TN001_Atr_Ratio  = 0;
int    TN001_Bars_Break = 0;
int    TN001_ZZIndex_Trend; //calc

int SNI_TN001_MAPeriod = 0;
int SNI_TN001_MAShift = 0;
int SNI_TN001_MA_Env_Dev = 0;
int SNI_TN001_Atr_Period = 0;
int SNI_TN001_Atr_Ratio = 0;
int SNI_TN001_Bars_Break = 0;
int SNI_TN001_ZZIndex_Trend = 0;

void TN001_Trend_InitVars()
{
   SAV_Settings_SetMapping("TN001_MAPeriod", SNI_TN001_MAPeriod);
   SAV_Settings_SetMapping("TN001_MAShift", SNI_TN001_MAShift);
   SAV_Settings_SetMapping("TN001_MA_Env_Dev", SNI_TN001_MA_Env_Dev);
   SAV_Settings_SetMapping("TN001_Atr_Period", SNI_TN001_Atr_Period);
   SAV_Settings_SetMapping("TN001_Atr_Ratio", SNI_TN001_Atr_Ratio);
   SAV_Settings_SetMapping("TN001_Bars_Break", SNI_TN001_Bars_Break);
   SAV_Settings_SetMapping("TN001_ZZIndex_Trend", SNI_TN001_ZZIndex_Trend);
}

void TN001_Trend_UpdateVars( int settID )
{
   TN001_MAPeriod = SAV_Settings_GetIntValueI(settID, SNI_TN001_MAPeriod);
   TN001_MAShift = SAV_Settings_GetIntValueI(settID, SNI_TN001_MAShift);
   TN001_MA_Env_Dev = SAV_Settings_GetDoubleValueI(settID, SNI_TN001_MA_Env_Dev);
   TN001_Atr_Period = SAV_Settings_GetIntValueI(settID, SNI_TN001_Atr_Period);
   TN001_Atr_Ratio = SAV_Settings_GetDoubleValueI(settID, SNI_TN001_Atr_Ratio);
   TN001_Bars_Break = SAV_Settings_GetIntValueI(settID, SNI_TN001_Bars_Break);
   TN001_ZZIndex_Trend = SAV_Settings_GetIntValueI(settID, SNI_TN001_ZZIndex_Trend);
}


void TN001_Trend_UpdateCalcVars( int settID )
{   
   SAV_Settings_SetIntValueI(settID, SNI_TN001_ZZIndex_Trend, TN001_ZZIndex_Trend);
}

