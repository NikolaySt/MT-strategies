extern string InitialStop_Info = "============ ������� ���� ���� ��������� =============";
// ��������� �� �������� ����
extern string InitialStop_Descr = "��������:NONE;FIXPIPS;LOHI;ATR;";
extern string InitialStop_TypeS = "FIXPIPS";
       int    InitialStop_Type;
extern string InitialStop_TimeFrameS = "H1";
int           InitialStop_TimeFrame = PERIOD_H1;
extern double InitialStop_Param1 = 50;
extern double InitialStop_Param2 = 0;
extern int    InitialStop_MaxPips = 0; // � �������
extern int    InitialStop_MinPips = 0; // � �������
extern int    InitialStop_OffsetPips = 0; // � �������

// ��������� �� �������� �� ������
extern string ZeroStop_Info = "����������: param1 < 10 - ����. �� ����; param1 > 10 - ������. �� ���� �� ��������";
extern string ZeroStop_TypeS;
extern double ZeroStop_Param1 = 1;
extern double ZeroStop_Param2 = 0;

extern string Stop_Info = "============ ���������� �� ����� ���� ��������� ============";
// ��������� �� ���������� �� ����� ���� ���� ���� � ��������
extern string  StopBaseName = "SA002";
          int  StopBaseIndex;
extern string  Stop_TimeFrameS = "H1"; 
          int  Stop_TimeFrame = PERIOD_H1;
extern int     Stop_MinPips = 0;
extern int     Stop_MaxPips = 0;
extern int     Stop_OffsetPips = 0; // � �������













