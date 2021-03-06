/***************ОБЩИ ПРОМЕНЛИВИ*********************************************************/
extern string SignalBaseName = "Panic";

extern string GROUP1 = "------------------------УПРАВЛЕНИЕ НА SL-------------------------------";
extern bool ActiveMngSLSave = true;
extern double MngSLZeroRatio = 0.1;

extern string GROUP2 = "------------------------ДОПЪЛНИТЕЛНИ ПАРАМЕТРИ за поръчките-------------------------";
extern int TakeProfit = 0;
extern bool OneOrderCloseInSignalTime = true;
extern bool CloseReverseOrder = false;
extern bool CloseSameOrder = false;

extern string GROUP3 = "------------------------ПАРАМЕТРИ ЗА ГЕНЕРИРАНЕ НА СИГНАЛА---------------------";
extern string info_LargeLOCFilter = "//time: 1, price: 2, bias: 3, ако е 0 работи за всички";
extern int LargeLOCFilter = 0;
/****************************************************************************************/

int SIGNAL_TIMEFRAME = PERIOD_H1;
int TREND_TIMEFRAME = PERIOD_D1;


//Инициализиране на променливите
//Винаги трябва да се вика
void SAN_N_Systems_Init_Common(){
   double ratio = DigMode();
   TakeProfit = TakeProfit*ratio;
}

int DigMode(){
   if (Digits == 4) return(1);
   if (Digits == 5) return(10);
   if (Digits == 2) return(1);
   if (Digits == 3) return(10);   
}