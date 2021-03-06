

#include <stdlib.mqh>
#include <stderror.mqh>

#include <SAN_Systems\Common\Utils\SAN_A_Utils.mqh>
#include <SAN_Systems\Common\Utils\SAN_N_Utils.mqh>

#include <SAN_Systems\Common\Utils\SAN_ZZHelper.mqh>
#include <SAN_Systems\Common\Utils\SAN_MMHelper.mqh>
#include <SAN_Systems\Common\Utils\SAN_StopHelper.mqh>

//NEW PROCESS
#include <SAN_Systems\Common\Utils\SAN_Stops.mqh>
#include <SAN_Systems\Common\Utils\SAN_StopsAll.mqh>
#include <SAN_Systems\Common\Utils\SAN_StopUtils.mqh>

#include <SAN_Systems\Common\Utils\SAN_Statistical.mqh>
#include <SAN_Systems\Common\Utils\SAN_Settings.mqh>
#include <SAN_Systems\Common\Utils\SAN_MagicHelper.mqh>
#include <SAN_Systems\Common\Utils\SAN_OrdersHelper.mqh>

//define some constants used everywhere

//constants for Signals
#define A001   1001
#define A002   1002
#define A003   1003
#define A004   1004
#define A005   1005
#define A006   1006
#define A007   1007

#define N001   2001
#define N002   2002
#define N003   2003
#define N004   2004
#define N005   2005
#define N006   2006
#define N007   2007
#define N008   2008
#define N009   2009
#define N010   2010
#define N011   2011
#define N012   2012
#define N013   2013
#define N014   2014
#define N015   2015
#define N016   2016
//ADD
#define N017   2017
#define N018   2018
#define N019   2019
#define N020   2020
#define N021   2021
#define N022   2022
#define N023   2023

//constants for stops
#define  S0000    1
#define  SA002    200


//constants for trends
#define  T0000    1
#define  TA001    100
#define  TN001    1100
#define  TN002    1200

#define  M000             1000 //default MM no Money management default 0.1 lot size
#define  M001             1100 //MM_FP_FF
#define  M002             1200 //MM_FF
#define  M003             1300 //MM_MAXLOSS   
#define  M004             1400 //MM_MARTINGALE
#define  M005             1500 //MM_VIRTUAL        

void SAV_Settings_SetMapping( string name, int& index )
{
   index = SAV_Settings_GetMappingIndex(name);
}