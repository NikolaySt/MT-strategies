//+------------------------------------------------------------------+
//|                                 Copyright 2010, ������� �������  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2010 Forex-Consult"
//------------------------������ � ����� �� ��������� � ���������� ��������� -------------------------------------
#include <StdDevUtils\StdDev_2_Vars.mqh>
#include <StdDevUtils\StdDev_2_Utils.mqh>
#include <StdDevUtils\StdDev_2_Create.mqh>
//---------------------------------------------------------------------------------------------------------------
#import "SAN_libraries\OrderHelper.ex4"
//� ��������� �� ����� ����� �������
string OrderComment_Build( int settID, string name, datetime ctime, int stopPips );
string OrderComment_GetName( string comment );
datetime OrderComment_GetTime( string comment );
int OrderComment_GetStop( string comment );
int OrderComment_GetSettID( string comment );
#import

#import "SAN_libraries\SLHelper.ex4"
//+------------------------------------------------------------------+
//| ��������� �������� ���� ���� ����� �� �� ��������/��������       |
//+------------------------------------------------------------------+
//����� ������������ ����� �� 0 � ���� ���� �� �������
//OffsetTimeMinutes - ����� � ������ �� ���������� �� ��������� ���� ����� �� �������� ��������� �� ����-�, ��� � "0" �� �� ������
void MngSLSave(int MAGIC, int TimeFrame, int OffsetTimeMinutes, 
               int StopLossZeroOffset = 3, int StopLossProfitOffset = 3, 
               double MngSLRatio = 1, double MngSLZeroRatio = 0.7);
#import

int init(){                               
   StdDev_System_2_Init();             
   return(0);  
       
}

//--------------------------------------------------------------
#import "SAN_libraries\StatisticalHelper.ex4"
void Histroy_TradesToDll(string SignalBaseName);
#import
int deinit(){    
   if (IsTesting()){                              
      Histroy_TradesToDll(SignalBaseName);      
   }    
   return(0); 
}
//--------------------------------------------------------------


double CalcLotSizeMM(int MAGIC, int SLPoints, int CountOpenOrders){      
   double value = Lots;
   for (int i = 1; i <= CountOpenOrders; i++){
      value = value*(Multiplier - 1) + value;
   }
   
   double LotStep = MarketInfo(Symbol(), MODE_LOTSTEP); 
   double MaxLots = MarketInfo(Symbol(), MODE_MAXLOT);
   double MinLots = MarketInfo(Symbol(), MODE_MINLOT);
  
   if (Lots >  MaxLots) value = MaxLots;           
   if (Lots < MinLots) value = MinLots;   
      
   double RoundDigLots = 0;
   switch(LotStep){
      case 0.00001: RoundDigLots = 5; break;
      case 0.0001: RoundDigLots = 4; break;
      case 0.001: RoundDigLots = 3; break;
      case 0.01: RoundDigLots = 2; break;
      case 0.1: RoundDigLots = 1; break;
      case 1: RoundDigLots = 0; break;
   } 

   value = NormalizeDouble( value,  RoundDigLots);           
   return(value);   
}


int start(){   
   if (Period() > SIGNAL_TIMEFRAME){   
      //�������� �� �������� ���� �� ����� ������ ��������� //���� � ���-������� ������ ���� ����� �� ������      
      Print("������: ", SignalBaseName ," ������ �� ������ ���� ��-����� ��� ����� �� " + SignalTimeFrame);
      return;
   }
   
   //------------------------------------������� ������ �� ������� �� ���������----------------------
   //������� �����, ��������� ������ ���� � ��������� ������ �� ������ ���� ����
   // ��� � 0 - 23 ������ ���� ����� ���
   int hour = TimeHour(iTime(NULL, PERIOD_H1, 1)); 
   if (!(hour >= TimeWorkStart && hour <= TimeWorkEnd)) return;   
   //------------------------------------------------------------------------------------------------   
   
   StdDev_System_2_Process(1001);  //MAGIC = 1001 - �� �������� �������, 1002 - �� ���������;             
   CalcLimitAndSL(1001, OP_BUY);
   CalcLimitAndSL(1001, OP_SELL); 
   if (SN002_Stop_Save == 1){
      //MngSLSave(1001, PERIOD_H1, 0, SN002_Stop_ZeroOffset, SN002_Stop_ProfitOffset, SN002_Stop_Ratio, SN002_Stop_ZeroRatio);                            
   }
}











