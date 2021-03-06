extern string InitialStop_Info = "============ Начален Стоп общи параметри =============";
// параметри на началния стоп
extern string InitialStop_Descr = "Възможни:NONE;FIXPIPS;LOHI;ATR;";
extern string InitialStop_TypeS = "FIXPIPS";
       int    InitialStop_Type;
extern string InitialStop_TimeFrameS = "H1";
int           InitialStop_TimeFrame = PERIOD_H1;
extern double InitialStop_Param1 = 50;
extern double InitialStop_Param2 = 0;
extern int    InitialStop_MaxPips = 0; // в пипсове
extern int    InitialStop_MinPips = 0; // в пипсове
extern int    InitialStop_OffsetPips = 0; // в пипсове

// параметри за нулиране на сделка
extern string ZeroStop_Info = "Зануляване: param1 < 10 - коеф. от стоп; param1 > 10 - отклон. от Цена на отваряне";
extern string ZeroStop_TypeS;
extern double ZeroStop_Param1 = 1;
extern double ZeroStop_Param2 = 0;

extern string Stop_Info = "============ Управление на Стопа общи параметри ============";
// параметри на управление на стопа след като вече е поставен
extern string  StopBaseName = "SA002";
          int  StopBaseIndex;
extern string  Stop_TimeFrameS = "H1"; 
          int  Stop_TimeFrame = PERIOD_H1;
extern int     Stop_MinPips = 0;
extern int     Stop_MaxPips = 0;
extern int     Stop_OffsetPips = 0; // в пипсове













