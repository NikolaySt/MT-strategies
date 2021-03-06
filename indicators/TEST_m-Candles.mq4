//+------------------------------------------------------------------+
//|                                                    M-Candles.mq4 |
//|         ������������ ���� ��� H1 � ���� - ��� ����� �. aka KimIV |
//|                                              http://www.kimiv.ru |
//|            ��������� ��� ����������� ����������� - ������ ������ |
//|                                                    ICQ 138092006 |
//|         2008.09.05  �� ����� ������� ���������� ����� ������� �� |
//+------------------------------------------------------------------+
#property copyright "������ ������ aka MikeZTN"
#property link      "ICQ 138092006"

#property indicator_chart_window

//------- ������� ��������� ------------------------------------------
extern int TFBar       = 240;           // ������ ������� ������
extern int NumberOfBar = 100;           // ���������� ������� ������
extern color ColorUp   = 0x003300;      // ���� ���������� �����
extern color ColorDown = 0x000033;      // ���� ���������� �����

//------- ���������� ���������� --------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  int i;

  for (i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyTF"+TFBar+"Bar"+i);
    ObjectDelete("ShadowTF"+TFBar+"Bar" + i);
  }
  for (i=0; i<NumberOfBar; i++) {
    ObjectCreate("BodyTF"+TFBar+"Bar"+i, OBJ_RECTANGLE, 0, 0,0, 0,0);
    ObjectCreate("ShadowTF"+TFBar+"Bar"+i, OBJ_TREND, 0, 0,0, 0,0);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  // �������� ��������
  for (int i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyTF"+TFBar+"Bar"+i);
    ObjectDelete("ShadowTF"+TFBar+"Bar" + i);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int shb=0, sh1=1, d;
  double   po, pc;       // ���� �������� � �������� ������� ������
  double   ph=0, pl=500; // ���� ��� � ��� ������� ������
  datetime to, tc, ts;   // ����� ��������, �������� � ����� ������� ������

  
  bool OK_Period=false;   
  switch (TFBar)
  {    
    case 1:OK_Period=true;break;
    case 5:OK_Period=true;break;
    case 15:OK_Period=true;break;
    case 30:OK_Period=true;break;
    case 60:OK_Period=true;break;
    case 240:OK_Period=true;break;
    case 1440:OK_Period=true;break;
    case 10080:OK_Period=true;break;
    case 43200:OK_Period=true;break;
  }
  if (OK_Period==false)
     {
       Comment("�� ����� ������������� ����� ���������� TFBar! ���������� ������ ���� �� ���������: 1,5,15,30,60,240,1440 � �.�.");   
       return(0);
     }
  if (Period()>TFBar) 
  {
    Comment("���������� ����������� ������ ������ ���� ������ ��������! (������� ����� " + Period() + ")");
    return(0);
  }
    
    shb=0;
    // ����� �� ������� �������  
    while (shb<NumberOfBar) 
    {
      to = iTime(Symbol(), TFBar, shb);
      tc = iTime(Symbol(), TFBar, shb) + TFBar*60;
      po = iOpen(Symbol(), TFBar, shb);
      pc = iClose(Symbol(), TFBar, shb);
      ph = iHigh(Symbol(), TFBar, shb); 
      pl = iLow(Symbol(), TFBar, shb); 
      //�������������  ����������
      ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_TIME1, to);  //����� ��������
      ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_PRICE1, po); //���� ��������
      ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_TIME2, tc);  //����� ��������
      ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_PRICE2, pc); //���� ��������
      ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_BACK, True);
      //������������� ����
      ts = to + MathRound((TFBar*60)/2);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_TIME1, ts);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_PRICE1, ph);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_TIME2, ts);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_PRICE2, pl);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_WIDTH, 3);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_BACK, True);
      ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_RAY, False);            
      //������������� ����� ��� ���� ��������
      if (po<pc) {
          ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorUp);
          ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorUp);
        } else {
          ObjectSet("BodyTF"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorDown);
          ObjectSet("ShadowTF"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorDown);
        }
      shb++;
     }       
      
  
  return(0);
}
//+------------------------------------------------------------------+