//+------------------------------------------------------------------+
//|                                      SAN_OrderCommentInChart.mq4 |
//|                                        Copyright � 2011, SANTeam |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2011, SANTeam"
#property link      ""

#property indicator_chart_window
//---- input parameters

#import "SAN_libraries\OrderHelper.ex4"
//� ��������� �� ����� ����� �������
string OrderComment_Build( int settID, string name, datetime ctime, int stopPips );
string OrderComment_GetName( string comment );
datetime OrderComment_GetTime( string comment );
int OrderComment_GetStop( string comment );
int OrderComment_GetSettID( string comment );
#import

//---- buffers

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int total = OrdersTotal();
   int ticket, type;
   double lots;
   string print_comm_open, print_comm_pend, name, order_comm;
   datetime time;
   
   for(int i = 0; i < total; i++){
      if( OrderSelect(i, SELECT_BY_POS) == false) continue;      
      
      lots = OrderLots();
      ticket = OrderTicket();
      order_comm = OrderComment();
      name = OrderComment_GetName(order_comm);
      time = OrderComment_GetTime(order_comm);
      type = OrderType();
      
      if (type == OP_SELL || type == OP_BUY) {
         print_comm_open = print_comm_open + "\n\n" + "�����: "+ticket + " .....  ���: " + DoubleToStr(lots, 1) +  " ..... ���: " + name + " .....  ����� �� �������: " + TimeToStr(time) + " .....  ��������: " + order_comm;
      }else{
         print_comm_pend = print_comm_pend + "\n\n" + "�����: "+ticket + " .....  ���: " + DoubleToStr(lots, 1) +  " ..... ���: " + name + " .....  ����� �� �������: " + TimeToStr(time) + " .....  ��������: " + order_comm;
      }         
      
   }
   Comment("\n\n" +"�������� �������" + print_comm_open + "\n\n" + "�������� �������" +   print_comm_pend);
   

   return(0);
  }
//+------------------------------------------------------------------+