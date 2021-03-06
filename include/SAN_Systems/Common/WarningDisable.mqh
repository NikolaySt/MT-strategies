

/*
TOva d se vika v nachaloto tazi funkciq
samo i edinstveno da ne izkarva waringi compilatora
ima falshivi izvikvania na vsichki funkcii koito ne se rererensirat

*/
void DisableCompilerWarning()
{
   bool somv = false;
   if( somv == false ) return;
   double da[];
   datetime ta[];
   int ia[];
   string sa[];
   int iv;
   double dv;
   datetime tv;
   //autils not referenced functions
   SAN_AUtl_TimeFrame“ÓStr("");
   SAN_AUtl_BarValueByDir(0,0,0);
   SAN_AUtl_GetLongestSequence(da,0,0);
   SAN_AUtl_StrToBool("");
   SAN_AUtl_StrCompare("","");
   
   //nutils not referenced functions
   TrendLineLevelTwoPoint(0,0,0,0,0,false,false);	
   TL_LevelTwoPoint(0,0,0,0,0,false,false,ia);	
   InternalLineFunction(0,0,0,0,0);	
   InternalFindTriplePoint(0,0,iv,iv,iv,iv,iv,iv);	
   InternalDrawLine(0,0,0,0,0,"","",0,0);	
   DrawLine("","",0,0,0,0,"","",0,0);	
   CloseOverHighest(0,0,0);	
   CloseUnderLowest(0,0,0);		
   CloseOverHighestEx(0,0,0);	
   CloseUnderLowestEx(0,0,0);		
   SearchFractalInPeriod(0,0,0,0,tv);	
   PivotLevel(0,0,0);	
   UpFractalFloat(0,0,0);	
   DownFractalFloat(0,0,0);	
   SetPoint(0,0,0,0);	
   SetLine(0,0,0,0);	
   SetText(0,0,"");
   
   MP_MODA(0,0,0,0);	
	ObjGetUniqueName("");	
	ObjDeleteObjectsByPrefix("");	
	
	//ZZ functions not referenced
	ZZSetDebugType(0);	
	ZZGetDebugType();	
	ZZInit();	
	ZZFindIndexFromDepth(0,0);	
	ZZSetDebugForIndex(0,false);	
	ZZGetIndexForDepthOrCreate(0,0);	
	ZZSetParams(0,0,0,0,0);	
	ZZGetLastPeakValue(0,dv,iv,0);	
	ZZGetSubsequentTendenceCount(0,0,0);	
	ZZGetLastTendence(0,0,0,ia);	
	
	SL_MngSteps(0,0,da,da);	
	Stat_HistOrdersToJurnal();	
	Stat_HistOrdersToDll_Params("","");	
	SAV_Settings_Init();	
	SAV_Settings_SetTrace(false);	
	SAV_Settings_GetTotalCount();	
	SAV_Settings_Create("");	
	SAV_Settings_AddRawValue(0,"");	
	SAV_Settings_SetValueByName(0,"","");	
	SAV_Settings_SetIntValueI(0,0,0);	
	SAV_Settings_SetValueI(0,"","");	
	SAV_Settings_GetNameIndex("");	
	SAV_Settings_GetValueI(0,"");	
	SAV_Settings_GetIntValueI(0,0);	
	SAV_Settings_GetBoolValueI(0,0);	
	SAV_Settings_SetDoubleValueI(0,0,0);	
	SAV_Settings_SetBoolValueI(0,0,0);	
	SAV_Settings_GetNameValue("",sa);	
	SAV_Settings_GetDoubleValueI(0,0);	
	SAV_Settings_GetMappingIndex("");	
	OrderComment_GetName("");	
	OrderComment_GetSettID("");	
	Orders_CloseByTypeInProfit(0,0);	
	Orders_CloseByType(0,0);	
	Orders_Close(0);	
	Orders_CloseAll();	
	Orders_CloseByTimeSignal(0,0,0);	
	PendingOrders_RemoveByDir(0,0);	
	PendingOrders_Remove(0);	
	PendingOrders_RemoveByLevel(0,0,0);	
	PendingOrders_RemoveBySigTime(0,0);	
	OpenOrders_GetCount(0);	
	OpenOrders_GetCountAll();	
	OpenOrders_GetProfitByType(0,0);	
	OpenOrders_GetProfitInPipsAll();	
	HOrders_CloseWithLimit_Time(0,0,0);	
	HOrders_CloseWithLimit_Ticket(0,0);	
	HOrders_IsOrderClose(0);	
	HOrders_IsOpenCloseInCurrentBar(0,0);	
	SAV_Settings_SetMapping("",iv);	

	
}