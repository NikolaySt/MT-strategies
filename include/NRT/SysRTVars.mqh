/***************���� ����������*********************************************************/
extern string SignalBaseName = "Panic";

extern string GROUP1 = "------------------------���������� �� SL-------------------------------";
extern bool ActiveMngSLSave = true;
extern double MngSLZeroRatio = 0.1;

extern string GROUP2 = "------------------------������������ ��������� �� ���������-------------------------";
extern int TakeProfit = 0;
extern bool OneOrderCloseInSignalTime = true;
extern bool CloseReverseOrder = false;
extern bool CloseSameOrder = false;

extern string GROUP3 = "------------------------��������� �� ���������� �� �������---------------------";
extern string info_LargeLOCFilter = "//time: 1, price: 2, bias: 3, ��� � 0 ������ �� ������";
extern int LargeLOCFilter = 0;
/****************************************************************************************/

int SIGNAL_TIMEFRAME = PERIOD_H1;
int TREND_TIMEFRAME = PERIOD_D1;


//�������������� �� ������������
//������ ������ �� �� ����
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