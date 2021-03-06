int TA001_ExtDepth = 15;
int TA001_ZZIndex_Trend;

int SNI_TA001_ExtDepth = 0;
int SNI_TA001_ZZIndex_Trend = 0;


void TA001_Trend_InitVars()
{
   SAV_Settings_SetMapping("TA001_ExtDepth", SNI_TA001_ExtDepth);
   SAV_Settings_SetMapping("TA001_ZZIndex_Trend", SNI_TA001_ZZIndex_Trend);
}

void TA001_Trend_UpdateVars( int settID )
{
   TA001_ExtDepth = SAV_Settings_GetIntValueI(settID, SNI_TA001_ExtDepth);
   TA001_ZZIndex_Trend = SAV_Settings_GetIntValueI(settID, SNI_TA001_ZZIndex_Trend);
}

void TA001_Trend_UpdateCalcVars( int settID )
{   
   SAV_Settings_SetIntValueI(settID, SNI_TA001_ZZIndex_Trend, TA001_ZZIndex_Trend);
}