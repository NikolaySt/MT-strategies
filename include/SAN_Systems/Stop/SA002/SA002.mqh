
void SA002_Stop_Init(int settID)
{      
   SA002_TimeFrame_Lev1 = SAN_AUtl_TimeFrameFromStr(SA002_TimeFrameS_Lev1);
   SA002_TimeFrame_Lev2 = SAN_AUtl_TimeFrameFromStr(SA002_TimeFrameS_Lev2);
   SA002_TimeFrame_Lev3 = SAN_AUtl_TimeFrameFromStr(SA002_TimeFrameS_Lev3);
     
   int stopTypes[3];
   
   SAN_StopTypes_Parse(SA002_Stop_TypeS, stopTypes, 3);
   
   SA002_Stop_Type_Lev1 = stopTypes[0];
   SA002_Stop_Type_Lev2 = stopTypes[1];
   SA002_Stop_Type_Lev3 = stopTypes[2];

   SAN_Stop_InitializeLevel(SA002_Stop_Type_Lev1,SA002_TimeFrame_Lev1,0, SA002_Stop_Lev1, SA002_Stop_Param1_Lev1, SA002_Stop_Param2_Lev1);
   SAN_Stop_InitializeLevel(SA002_Stop_Type_Lev2,SA002_TimeFrame_Lev2,1, SA002_Stop_Lev2, SA002_Stop_Param1_Lev2, SA002_Stop_Param2_Lev2);
   SAN_Stop_InitializeLevel(SA002_Stop_Type_Lev3,SA002_TimeFrame_Lev3,2, SA002_Stop_Lev3, SA002_Stop_Param1_Lev3, SA002_Stop_Param2_Lev3);                                                                   
}

void SA002_Stop_Process(int settID)
{  
   if( Common_HasNewShift(Stop_TimeFrame) == false ) return;  
      
   static int types[3], timeframes[3];
   static double params1[3], params2[3], levels[3];
  
   types[0] = SA002_Stop_Type_Lev1; types[1] = SA002_Stop_Type_Lev2; types[2] = SA002_Stop_Type_Lev3;
   
   levels[0] = SA002_Stop_Lev1; levels[1] = SA002_Stop_Lev2; levels[2] = SA002_Stop_Lev3;
   
   params1[0] = SA002_Stop_Param1_Lev1;    params1[1] = SA002_Stop_Param1_Lev2;   params1[2] = SA002_Stop_Param1_Lev3;
   params2[0] = SA002_Stop_Param2_Lev1;    params2[1] = SA002_Stop_Param2_Lev2;   params2[2] = SA002_Stop_Param2_Lev3;
   
   timeframes[0] = SA002_TimeFrame_Lev1; timeframes[1] = SA002_TimeFrame_Lev2; timeframes[2] = SA002_TimeFrame_Lev3;
   
   SAN_Stop_Process(settID, Stop_TimeFrame,
                     types, levels, 3,
                     params1, params2, timeframes,
                     Stop_MinPips, Stop_MaxPips, Stop_OffsetPips );   
                                
}