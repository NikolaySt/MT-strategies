int    TN002_Atr_Period = 27;
double TN002_Atr_Ratio  = 3;
int    TN002_Bars_Break = 6;
int    TN002_ZZIndex_Trend; //calc


int SNI_TN002_Atr_Period = 0;
int SNI_TN002_Atr_Ratio = 0;
int SNI_TN002_Bars_Break = 0;
int SNI_TN002_ZZIndex_Trend = 0;

void TN002_Trend_InitVars()
{
   SAV_Settings_SetMapping("TN002_Atr_Period", SNI_TN002_Atr_Period);
   SAV_Settings_SetMapping("TN002_Atr_Ratio", SNI_TN002_Atr_Ratio);
   SAV_Settings_SetMapping("TN002_Bars_Break", SNI_TN002_Bars_Break);
   SAV_Settings_SetMapping("TN002_ZZIndex_Trend", SNI_TN002_ZZIndex_Trend);
}

void TN002_Trend_UpdateVars( int settID )
{

   TN002_Atr_Period = SAV_Settings_GetIntValueI(settID, SNI_TN002_Atr_Period);
   TN002_Atr_Ratio = SAV_Settings_GetDoubleValueI(settID, SNI_TN002_Atr_Ratio);
   TN002_Bars_Break = SAV_Settings_GetIntValueI(settID, SNI_TN002_Bars_Break);
   TN002_ZZIndex_Trend = SAV_Settings_GetIntValueI(settID, SNI_TN002_ZZIndex_Trend);
}


void TN002_Trend_UpdateCalcVars( int settID )
{   
   SAV_Settings_SetIntValueI(settID, SNI_TN002_ZZIndex_Trend, TN002_ZZIndex_Trend);
}

