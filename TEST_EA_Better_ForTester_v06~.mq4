/*
   Generated by EX4-TO-MQ4 decompiler V4.0.224.1 []
   Website: http://purebeam.biz
   E-mail : purebeam@gmail.com
*/
#property copyright "Copyright � 2008, AutoTrader fx-auto-trader@mail.ru"
#property link      "fx-auto-trader@mail.ru"

#include <stdlib.mqh>
extern string SignalBaseName = "EABetter";
extern double lots = 0.1;
extern int Slippage = 2;
extern int Warp = -22;
extern double Deviation = 0.23;
extern int Amplitude = 59;
extern double Distortion = 0.13;
extern bool SL_long_EQUAL_SL_short = FALSE;
extern double SL_long = 700.0;
extern double SL_short = 65.0;
extern double MM = 0.0;
extern bool UseSound = TRUE;
extern int MagicNumber = 55555;
double gd_148;
string gs_156 = "PNN Shell � 2008, FX-Systems Co Ltd";
int g_time_164 = 0;
int gi_168 = 6;
double gd_172 = 5.0;
double gd_180 = 25.0;

void init() {
   if (Point == 0.001 || Point == 0.00001) gd_148 = 10.0 * Point;
   else gd_148 = Point;
   if (SL_long_EQUAL_SL_short == TRUE) SL_short = SL_long;
}
#include <SAN_Systems\Common\Utils\SAN_Statistical.mqh>
void deinit() {
   if (IsTesting()){         
      if (!IsOptimization()){
         Stat_HistOrdersToFile(false, 1000, "history_"+SignalBaseName+".txt");
         Stat_DropDownToFile(false, 1000, "dropdown_"+SignalBaseName+".txt");
         Stat_AvgAnnualReturn(1000);
         Stat_SumMonthlyProfitToFile("monthly_profit_"+SignalBaseName+".txt");
         Stat_CalcMO(true);                                   
      }                      
      Stat_HistOrdersToDll(SignalBaseName);
   } 
}

void start() {
   int l_spread_0;
   int li_4;
   int l_ord_total_8;
   int l_ticket_16;
   Comment("... This is a trial version not for live trading  ...", 
   "\n", "... You are allowed to use it in tester mode only ...");
   ExternalParametersCheck();
   CheckConditions();
   if (Time[0] != g_time_164) {
      g_time_164 = Time[0];
      l_spread_0 = 3;
      if (IsTradeAllowed()) {
         RefreshRates();
         l_spread_0 = MarketInfo(Symbol(), MODE_SPREAD);
      } else {
         g_time_164 = Time[1];
         return;
      }
      li_4 = -1;
      l_ord_total_8 = OrdersTotal();
      for (int l_pos_12 = l_ord_total_8 - 1; l_pos_12 >= 0; l_pos_12--) {
         OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            l_ticket_16 = OrderTicket();
            if (OrderType() == OP_BUY) {
               if (Bid <= OrderStopLoss() + (2.0 * SL_long + l_spread_0) * gd_148) return;
               if (Direction(Warp, Deviation, Amplitude, Distortion) < 0.0) {
                  li_4 = OrderSendReliable(Symbol(), OP_SELL, GetLots(), Bid, Slippage, Ask + SL_short * gd_148, 0, gs_156, MagicNumber, 0, Red);
                  Sleep(30000);
                  if (li_4 < 0) {
                     g_time_164 = Time[1];
                     return;
                  }
                  OrderSelect(l_ticket_16, SELECT_BY_TICKET);
                  OrderClose(l_ticket_16, OrderLots(), Bid, 3, Blue);
                  return;
               }
               if (!(!OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Bid - SL_long * gd_148, 0, 0, Blue))) return;
               Sleep(30000);
               g_time_164 = Time[1];
               return;
            }
            if (Ask >= OrderStopLoss() - (2.0 * SL_short + l_spread_0) * gd_148) return;
            if (Direction(Warp, Deviation, Amplitude, Distortion) > 0.0) {
               li_4 = OrderSendReliable(Symbol(), OP_BUY, GetLots(), Ask, Slippage, Bid - SL_long * gd_148, 0, gs_156, MagicNumber, 0, Blue);
               Sleep(30000);
               if (li_4 < 0) {
                  g_time_164 = Time[1];
                  return;
               }
               OrderSelect(l_ticket_16, SELECT_BY_TICKET);
               OrderClose(l_ticket_16, OrderLots(), Ask, 3, Blue);
               return;
            }
            if (!(!OrderModifyReliable(OrderTicket(), OrderOpenPrice(), Ask + SL_short * gd_148, 0, 0, Blue))) return;
            Sleep(30000);
            g_time_164 = Time[1];
            return;
         }
      }
      if (Direction(Warp, Deviation, Amplitude, Distortion) > 0.0) {
         li_4 = OrderSendReliable(Symbol(), OP_BUY, GetLots(), Ask, Slippage, Bid - SL_long * gd_148, 0, gs_156, MagicNumber, 0, Blue);
         if (li_4 < 0) {
            Sleep(30000);
            g_time_164 = Time[1];
         }
      } else {
         li_4 = OrderSendReliable(Symbol(), OP_SELL, GetLots(), Bid, Slippage, Ask + SL_short * gd_148, 0, gs_156, MagicNumber, 0, Red);
         if (li_4 < 0) {
            Sleep(30000);
            g_time_164 = Time[1];
         }
      }
   }
}

double Direction(int ai_0, double ad_4, int ai_12, double ad_16) {
   double ld_ret_24 = 0;
   double l_iac_32 = iAC(Symbol(), 0, 0);
   double l_iac_40 = iAC(Symbol(), 0, 7);
   double l_iac_48 = iAC(Symbol(), 0, 14);
   double l_iac_56 = iAC(Symbol(), 0, 21);
   ld_ret_24 = ai_0 * l_iac_32 + 100.0 * (ad_4 - 1.0) * l_iac_40 + (ai_12 - 100) * l_iac_48 + 100.0 * ad_16 * l_iac_56;
   return (ld_ret_24);
}

void ExternalParametersCheck() {
   if (Slippage > 10) {
      Comment("... ������ ������� ������� �������� ��������������� Slippage,", 
      "\n", "... �������������� ����� ���� �� ����� 10� � ������������� �������.");
      return;
   }
   if (Warp > 100 || Warp < -100) {
      Comment("... ����������� ����� �������� ��������� Warp,", 
         "\n", "... �������� ���������� �������� �� -100 �� +100 � ����� 1,", 
      "\n", "... �������������� � ������������� �������.");
      return;
   }
   if (Deviation > 2.0 || Deviation < 0.0) {
      Comment("... ����������� ����� �������� �������� Deviation,", 
         "\n", "... �������� ���������� �������� �� 0 �� +2 � ����� 0.01,", 
      "\n", "... �������������� � ������������� �������.");
      return;
   }
   if (Amplitude > 200 || Amplitude < 0) {
      Comment("... ����������� ����� �������� �������� Amplitude,", 
         "\n", "... �������� ���������� �������� �� 0 �� +200 � ����� 1,", 
      "\n", "... �������������� � ������������� �������.");
      return;
   }
   if (Distortion > 1.0 || Distortion < -1.0) {
      Comment("... ����������� ����� �������� �������� Distortion,", 
         "\n", "... �������� ���������� �������� �� -1 �� +1 � ����� 0.01,", 
      "\n", "... �������������� � ������������� �������.");
      return;
   }
}

double GetLots() {
   if (MM > 0.0) return (NormalizeDouble(MM * AccountFreeMargin() / 100000.0, 1));
   return (lots);
}

void CheckConditions() {
   if (IsConnected() == FALSE) {
      Comment(" ... ����������� ����� � �������� ��������\n" + " ... ���� �������� ������ ����������");
      return;
   }
   if (IsTradeContextBusy() == TRUE) {
      Comment(" ... �������� ����� �����\n" + " ... �������� ������� �� ������ �� ��������");
      return;
   }
   Comment(" ");
}

int OrderSendReliable(string a_symbol_0, int a_cmd_8, double a_lots_12, double a_price_20, int a_slippage_28, double a_price_32, double a_price_40, string a_comment_48, int a_magic_56, int a_datetime_60 = 0, color a_color_64 = -1) {
   double ld_96;
   if (!IsConnected()) {
      Print("OrderSendReliable:  error: IsConnected() == false");
      return (-1);
   }
   if (IsStopped()) {
      Print("OrderSendReliable:  error: IsStopped() == true");
      return (-1);
   }
   for (int l_count_68 = 0; !IsTradeAllowed() && l_count_68 < gi_168; l_count_68++) OrderReliable_SleepRandomTime(gd_172, gd_180);
   if (!IsTradeAllowed()) {
      Print("OrderSendReliable: error: no operation possible because IsTradeAllowed()==false, even after retries.");
      return (-1);
   }
   int l_digits_72 = MarketInfo(a_symbol_0, MODE_DIGITS);
   if (l_digits_72 > 0) {
      a_price_20 = NormalizeDouble(a_price_20, l_digits_72);
      a_price_32 = NormalizeDouble(a_price_32, l_digits_72);
      a_price_40 = NormalizeDouble(a_price_40, l_digits_72);
   }
   if (a_price_32 != 0.0) OrderReliable_EnsureValidStop(a_symbol_0, a_price_20, a_price_32);
   int l_error_76 = GetLastError();
   l_error_76 = 0;
   bool li_80 = FALSE;
   bool li_84 = FALSE;
   int l_ticket_88 = -1;
   if (a_cmd_8 == OP_BUYSTOP || a_cmd_8 == OP_SELLSTOP) {
      l_count_68 = 0;
      while (!li_80) {
         if (IsTradeAllowed()) {
            l_ticket_88 = OrderSend(a_symbol_0, a_cmd_8, a_lots_12, a_price_20, a_slippage_28, a_price_32, a_price_40, a_comment_48, a_magic_56, a_datetime_60, a_color_64);
            l_error_76 = GetLastError();
         } else l_count_68++;
         switch (l_error_76) {
         case 0/* NO_ERROR */:
            li_80 = TRUE;
            break;
         case 4/* SERVER_BUSY */:
         case 6/* NO_CONNECTION */:
         case 129/* INVALID_PRICE */:
         case 136/* OFF_QUOTES */:
         case 137/* BROKER_BUSY */:
         case 146/* TRADE_CONTEXT_BUSY */:
            l_count_68++;
            break;
         case 135/* PRICE_CHANGED */:
         case 138/* REQUOTE */:
            RefreshRates();
            continue;
            break;
         case 130/* INVALID_STOPS */:
            ld_96 = MarketInfo(a_symbol_0, MODE_STOPLEVEL) * MarketInfo(a_symbol_0, MODE_POINT);
            if (a_cmd_8 == OP_BUYSTOP) {
               if (MathAbs(Ask - a_price_20) <= ld_96) li_84 = TRUE;
            } else {
               if (a_cmd_8 == OP_SELLSTOP)
                  if (MathAbs(Bid - a_price_20) <= ld_96) li_84 = TRUE;
            }
            li_80 = TRUE;
            break;
         default:
            li_80 = TRUE;
         }
         if (l_count_68 > gi_168) li_80 = TRUE;
         if (li_80) {
            if (l_error_76 != 0/* NO_ERROR */) Print("OrderSendReliable: non-retryable error: " + ErrorDescription(l_error_76));
            if (l_count_68 > gi_168) Print("OrderSendReliable: retry attempts maxed at " + gi_168);
         }
         if (!li_80) {
            Print("OrderSendReliable: retryable error (" + l_count_68 + "/" + gi_168 + "): " + ErrorDescription(l_error_76));
            OrderReliable_SleepRandomTime(gd_172, gd_180);
            RefreshRates();
         }
      }
      if (l_error_76 == 0/* NO_ERROR */) {
         Print("OrderSendReliable: apparently successful OP_BUYSTOP or OP_SELLSTOP order placed, details follow.");
         OrderSelect(l_ticket_88, SELECT_BY_TICKET, MODE_TRADES);
         OrderPrint();
         return (l_ticket_88);
      }
      if (!li_84) {
         Print("OrderSendReliable: failed to execute OP_BUYSTOP/OP_SELLSTOP, after " + l_count_68 + " retries");
         Print("OrderSendReliable: failed trade: " + OrderReliable_CommandString(a_cmd_8) + " " + a_symbol_0 + "@" + a_price_20 + " tp@" + a_price_40 + " sl@" + a_price_32);
         Print("OrderSendReliable: last error: " + ErrorDescription(l_error_76));
         return (-1);
      }
   }
   if (li_84) {
      Print("OrderSendReliable: going from limit order to market order because market is too close.");
      if (a_cmd_8 == OP_BUYSTOP) {
         a_cmd_8 = 0;
         a_price_20 = Ask;
      } else {
         if (a_cmd_8 == OP_SELLSTOP) {
            a_cmd_8 = 1;
            a_price_20 = Bid;
         }
      }
   }
   l_error_76 = GetLastError();
   l_error_76 = 0;
   l_ticket_88 = -1;
   if (a_cmd_8 == OP_BUY || a_cmd_8 == OP_SELL && IsTesting() == TRUE || IsOptimization() == TRUE) {
      l_count_68 = 0;
      while (!li_80) {
         if (IsTradeAllowed()) {
            l_ticket_88 = OrderSend(a_symbol_0, a_cmd_8, a_lots_12, a_price_20, a_slippage_28, a_price_32, a_price_40, a_comment_48, a_magic_56, a_datetime_60, a_color_64);
            l_error_76 = GetLastError();
         } else l_count_68++;
         switch (l_error_76) {
         case 0/* NO_ERROR */:
            li_80 = TRUE;
            break;
         case 4/* SERVER_BUSY */:
         case 6/* NO_CONNECTION */:
         case 129/* INVALID_PRICE */:
         case 136/* OFF_QUOTES */:
         case 137/* BROKER_BUSY */:
         case 146/* TRADE_CONTEXT_BUSY */:
            l_count_68++;
            break;
         case 135/* PRICE_CHANGED */:
         case 138/* REQUOTE */:
            RefreshRates();
            continue;
            break;
         default:
            li_80 = TRUE;
         }
         if (l_count_68 > gi_168) li_80 = TRUE;
         if (!li_80) {
            Print("OrderSendReliable: retryable error (" + l_count_68 + "/" + gi_168 + "): " + ErrorDescription(l_error_76));
            OrderReliable_SleepRandomTime(gd_172, gd_180);
            RefreshRates();
         }
         if (li_80) {
            if (l_error_76 != 0/* NO_ERROR */) Print("OrderSendReliable: non-retryable error: " + ErrorDescription(l_error_76));
            if (l_count_68 > gi_168) Print("OrderSendReliable: retry attempts maxed at " + gi_168);
         }
      }
      if (l_error_76 == 0/* NO_ERROR */) {
         Print("OrderSendReliable: apparently successful OP_BUY or OP_SELL order placed, details follow.");
         OrderSelect(l_ticket_88, SELECT_BY_TICKET, MODE_TRADES);
         OrderPrint();
         return (l_ticket_88);
      }
      Print("OrderSendReliable: failed to execute OP_BUY/OP_SELL, after " + l_count_68 + " retries");
      Print("OrderSendReliable: failed trade: " + OrderReliable_CommandString(a_cmd_8) + " " + a_symbol_0 + "@" + a_price_20 + " tp@" + a_price_40 + " sl@" + a_price_32);
      Print("OrderSendReliable: last error: " + ErrorDescription(l_error_76));
      return (-1);
   }
   return (0);
}

bool OrderModifyReliable(int a_ticket_0, double a_price_4, double a_price_12, double a_price_20, int a_datetime_28, color a_color_32 = -1) {
   string ls_40;
   if (!IsConnected()) {
      Print("OrderModifyReliable:  error: IsConnected() == false");
      return (-1);
   }
   if (IsStopped()) {
      Print("OrderModifyReliable:  error: IsStopped() == true");
      return (-1);
   }
   for (int l_count_36 = 0; !IsTradeAllowed() && l_count_36 < gi_168; l_count_36++) OrderReliable_SleepRandomTime(gd_172, gd_180);
   if (!IsTradeAllowed()) {
      Print("OrderModifyReliable: error: no operation possible because IsTradeAllowed()==false, even after retries.");
      return (-1);
   }
   int l_error_52 = GetLastError();
   l_error_52 = 0;
   bool li_56 = FALSE;
   l_count_36 = 0;
   bool l_bool_60 = FALSE;
   while (!li_56) {
      if (IsTradeAllowed()) {
         l_bool_60 = OrderModify(a_ticket_0, a_price_4, a_price_12, a_price_20, a_datetime_28, a_color_32);
         l_error_52 = GetLastError();
      } else l_count_36++;
      if (l_bool_60 == TRUE) li_56 = TRUE;
      switch (l_error_52) {
      case 0/* NO_ERROR */:
         li_56 = TRUE;
         break;
      case 1/* NO_RESULT */:
         li_56 = TRUE;
         break;
      case 4/* SERVER_BUSY */:
      case 6/* NO_CONNECTION */:
      case 129/* INVALID_PRICE */:
      case 136/* OFF_QUOTES */:
      case 137/* BROKER_BUSY */:
      case 146/* TRADE_CONTEXT_BUSY */:
         l_count_36++;
         break;
      case 135/* PRICE_CHANGED */:
      case 138/* REQUOTE */:
         RefreshRates();
         continue;
         break;
      default:
         li_56 = TRUE;
      }
      if (l_count_36 > gi_168) li_56 = TRUE;
      if (!li_56) {
         Print("OrderModifyReliable: retryable error (" + l_count_36 + "/" + gi_168 + "): " + ErrorDescription(l_error_52));
         OrderReliable_SleepRandomTime(gd_172, gd_180);
         RefreshRates();
      }
      if (li_56) {
         if (l_error_52 != 0/* NO_ERROR */ && l_error_52 != 1/* NO_RESULT */) Print("OrderModifyReliable: non-retryable error: " + ErrorDescription(l_error_52));
         if (l_count_36 > gi_168) Print("OrderModifyReliable: retry attempts maxed at " + gi_168);
      }
   }
   if (l_error_52 == 0/* NO_ERROR */) {
      Print("OrderModifyReliable: apparently successful modification order, updated trade details follow.");
      OrderSelect(a_ticket_0, SELECT_BY_TICKET, MODE_TRADES);
      OrderPrint();
      return (TRUE);
   }
   if (l_error_52 == 1/* NO_RESULT */) {
      Print("OrderModifyReliable:  Server reported modify order did not actually change parameters.");
      Print("OrderModifyReliable:  redundant modification: " + a_ticket_0 + " " + ls_40 + "@" + a_price_4 + " tp@" + a_price_20 + " sl@" + a_price_12);
      Print("OrderModifyReliable:  Suggest modifying code logic");
   }
   Print("OrderModifyReliable: failed to execute modify after " + l_count_36 + " retries");
   Print("OrderModifyReliable: failed modification: " + a_ticket_0 + " " + ls_40 + "@" + a_price_4 + " tp@" + a_price_20 + " sl@" + a_price_12);
   Print("OrderModifyReliable: last error: " + ErrorDescription(l_error_52));
   return (FALSE);
}

void OrderReliable_EnsureValidStop(string a_symbol_0, double ad_8, double &ad_16) {
   double ld_24;
   if (ad_16 != 0.0) {
      ld_24 = MarketInfo(a_symbol_0, MODE_STOPLEVEL) * MarketInfo(a_symbol_0, MODE_POINT);
      if (MathAbs(ad_8 - ad_16) <= ld_24) {
         if (ad_8 > ad_16) ad_16 = ad_8 - ld_24;
         else {
            if (ad_8 < ad_16) ad_16 = ad_8 + ld_24;
            else Print("OrderReliable_EnsureValidStop: error, passed in price == sl, cannot adjust");
         }
         ad_16 = NormalizeDouble(ad_16, MarketInfo(a_symbol_0, MODE_DIGITS));
      }
   }
}

string OrderReliable_CommandString(int ai_0) {
   if (ai_0 == 0) return ("OP_BUY");
   if (ai_0 == 1) return ("OP_SELL");
   if (ai_0 == 4) return ("OP_BUYSTOP");
   if (ai_0 == 5) return ("OP_SELLSTOP");
   return ("(CMD==" + ai_0 + ")");
}

void OrderReliable_SleepRandomTime(double ad_0, double ad_8) {
   double ld_16;
   int li_24;
   double ld_28;
   if (IsTesting() == 0) {
      ld_16 = MathCeil(ad_0 / 0.1);
      if (ld_16 > 0.0) {
         li_24 = MathRound(ad_8 / 0.1);
         ld_28 = 1.0 - 1.0 / ld_16;
         Sleep(1000);
         for (int l_count_36 = 0; l_count_36 < li_24; l_count_36++) {
            if (MathRand() > 32768.0 * ld_28) break;
            Sleep(1000);
         }
      }
   }
}