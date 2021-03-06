
bool Stop_Trace = false;

void Common_Stop_Init(int settID)
{
   //----------------------------------------------------------------------------
   InitialStop_Type = SAN_StopType_Parse(InitialStop_TypeS);
   InitialStop_TimeFrame = SAN_AUtl_TimeFrameFromStr(InitialStop_TimeFrameS);            
   InitialStop_MaxPips = InitialStop_MaxPips*DigMode();
   InitialStop_MinPips = InitialStop_MinPips*DigMode();   
   InitialStop_OffsetPips = InitialStop_OffsetPips*DigMode();
   
   double none_var = 0;
   SAN_Stop_InitializeLevel(InitialStop_Type, InitialStop_TimeFrame, 0, none_var, InitialStop_Param1, InitialStop_Param1);        
   
   //----------------------------------------------------------------------------
   Stop_TimeFrame = SAN_AUtl_TimeFrameFromStr(Stop_TimeFrameS);    
   Stop_MinPips = Stop_MinPips*DigMode();
   Stop_MaxPips = Stop_MaxPips*DigMode();
   Stop_OffsetPips = Stop_OffsetPips*DigMode();
   
   //---------------------------------------------------------------------
   if( ZeroStop_Param1 > 0 ) SAN_Stop_InitializeLevel(SAN_DEF_STOP_ZERO, Stop_TimeFrame, 0, none_var, ZeroStop_Param1, ZeroStop_Param2);          
}



