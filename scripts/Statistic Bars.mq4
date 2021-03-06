//+------------------------------------------------------------------+
//|                                               Statistic Bars.mq4 |
//|                                    Copyright � 2009 Ariadna Ltd. |
//|                                              revision 29.10.2009 |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2009 Ariadna Ltd."
#property link      "revision 29.10.2009"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {

   int d1_up, d2_up, d3_up, d4_up, d5_up = 0;
   int d1_down, d2_down, d3_down, d4_down, d5_down = 0;
   for (int i = Bars; i > 0; i--){
      switch(TimeDayOfWeek(Time[i])){
         case 1: if (Open[i] < Close[i]) d1_up++; if (Open[i] > Close[i]) d1_down++; break;
         case 2: if (Open[i] < Close[i]) d2_up++; if (Open[i] > Close[i]) d2_down++; break;
         case 3: if (Open[i] < Close[i]) d3_up++; if (Open[i] > Close[i]) d3_down++; break;
         case 4: if (Open[i] < Close[i]) d4_up++; if (Open[i] > Close[i]) d4_down++; break;
         case 5: if (Open[i] < Close[i]) d5_up++; if (Open[i] > Close[i]) d5_down++; break;
      }
   }
   
   Comment("����������:", " ��������� ��� = ", d1_up, " ���������� ��� = ", d1_down, "\n",
   "�������:", " ��������� ��� = ", d2_up, " ���������� ��� = ", d2_down, "\n",
   "�����:", " ��������� ��� = ", d3_up, " ���������� ��� = ", d3_down, "\n",
   "���������:", " ��������� ��� = ", d4_up, " ���������� ��� = ", d4_down, "\n",
   "�����:", " ��������� ��� = ", d5_up, " ���������� ��� = ", d5_down);

   return(0);
  }
//+------------------------------------------------------------------+