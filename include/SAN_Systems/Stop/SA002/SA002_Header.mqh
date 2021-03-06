extern string SA002_Stop_Descr = "Възможни:NONE;PER;PIPS;LOHI;ZZ;FIXPIPS;ATR;FRAC;";
   
//0 niama stop 1 po zigzag 2 po niva samo
//3 - SA002_Stop_ParamLev1 - 3 процент от текущата печалба 
//4 - SA002_Stop_ParamLev1 - 3 пипсове от текущата печалба
//5 - SA002_Stop_ParamLev1 - 3 стопът върви по зигзаг със таймфрейм SA002_TimeFrameSLev1- 3
//6 - SA002_Stop_ParamLev1 - 3 стопът върви по мин (buy) или макс (sell) 
//това са брой барове със таймфрейм SA002_TimeFrameSLev1- 3


extern string SA002_Stop_TypeS = "";
       int SA002_Stop_Type_Lev1;
       int SA002_Stop_Type_Lev2;
       int SA002_Stop_Type_Lev3;

//ostariali promenlivi veche niama da se polzvat
//extern int SA002_Stop_t1_ZZDepth = 10; 
//int SA002_Stop_t1_ZZIndex;

extern string SA002_Stop_Lev_Info = "---------LEVELS---------";
extern double SA002_Stop_Lev1 = 0;
extern double SA002_Stop_Lev2 = 0;
extern double SA002_Stop_Lev3 = 0;

extern string SA002_Stop_Param1_Info = "---------PARAM 1---------";
extern double SA002_Stop_Param1_Lev1 = 0;
extern double SA002_Stop_Param1_Lev2 = 0;
extern double SA002_Stop_Param1_Lev3 = 0;

extern string SA002_Stop_Param2_Info = "---------PARAM 2---------";
extern double SA002_Stop_Param2_Lev1 = 0;
extern double SA002_Stop_Param2_Lev2 = 0;
extern double SA002_Stop_Param2_Lev3 = 0;

extern string SA002_Stop_TF_Info = "---------TIMEFRAMES---------";
extern string SA002_TimeFrameS_Lev1 = "H1"; 
extern string SA002_TimeFrameS_Lev2 = "H1";
extern string SA002_TimeFrameS_Lev3 = "H1"; 

int SA002_TimeFrame_Lev1 = PERIOD_H1;
int SA002_TimeFrame_Lev2 = PERIOD_H1;
int SA002_TimeFrame_Lev3 = PERIOD_H1;





