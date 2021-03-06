//+------------------------------------------------------------------+
//|                                                  vHandsTrade.mq4 |
//|                                      Copyright � 2006, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, komposter"
#property link      "mailto:komposterius@mail.ru"

extern string		vHandsTrade			= "< - - - vHandsTrade - - - >";
extern int			CommentsCount		= 10;
extern color		SelectColor			= Magenta;
extern color		ModifyColor			= Yellow;
extern color		TrailingColor		= Yellow;

//+------------------------------------------------------------------+
//| vHandsTrade.mq4 - ������� ��� "������" �������� �� ������� ��4
//| ��������� �������� - http://articles.mql4.com/ru/195
//| 
//| ����� �������������� ����� ��������� ��������� ���������:
//| RISK         - % ��������, ������� ����� �������������� ��� �������� �������
//| LOT          - ������ ����, ������� ����� �������������� ��� �������� �������, ���� ������ RISK = 0
//| STOPLOSS     - ������ �������� ��� ����������� ������� (���� ��� �������� �� ��������� ����� ��������)
//| TAKEPROFIT   - ������ ���������� ��� ����������� ������� (���� ��� �������� �� ��������� ����� ����������)
//| TRAILINGSTOP - ������ �������������, ������� ����� �������������� ��� �������
//| EXPIRATION   - ����� ��������� ���������� ������� (� �����)
//|
//| ������� �� ���� ���������� ������������� 2 ����������:
//| ������ (�������� RISK[]) - 5 �����, �� ������� ����� ����� �������� �������� ��������� � �������� ������.
//| � ���������� SELECTED_*** (��������, SELECTED_RISK) - � ����� �� �������, ������� ����� �������� �� ���������.
//|
//| ��������, ���� �� ����������� ��������� 20, 40, 60 � 80 ������� (� 0, �.�. �� �����������), ��������� ������
//| STOPLOSS ��� ���: "int STOPLOSS[] = { 0, 20, 40, 60, 80 };"
//| ��� ������������� �� ��������� ��������� 40 �������, ������� "int SELECTED_STOPLOSS = 3;" (����� 40 - 3-� � ������)

	 int RISK[] = { 0, 2, 5, 10, 25 };
	 int SELECTED_RISK = 1;

	 double LOT[] = { 0.1, 0.2, 0.5, 1.0, 5.0 };
	 int SELECTED_LOT = 1;

	 int STOPLOSS[] = { 0, 15, 25, 50, 100 };
	 int SELECTED_STOPLOSS = 4;

	 int TAKEPROFIT[] = { 0, 50, 100, 150, 250 };
	 int SELECTED_TAKEPROFIT = 1;

	 int TRAILINGSTOP[] = { 0, 15, 25, 50, 100 };
	 int SELECTED_TRAILINGSTOP = 4;

	 double EXPIRATION[] = { 0, 0.5, 1, 12, 24 };
	 int SELECTED_EXPIRATION = 1;

//| ������ ������� ������ �� ������� ;)
//+------------------------------------------------------------------+

#include <VisualTestingTools.mq4>

int preTime = 0, BarsInWindow = 0, preBarsInWindow = 0, SecondsInBar = 0, Panel_Width = 0, Panel_T1 = 0, Panel_T2 = 0, left[3], right[3];
double WindowHighest = 0.0, WindowLowest = 0.0, preWindowHighest = 0.0, preWindowLowest = 0.0, Panel_P1 = 0.0, Panel_P2 = 0.0;
double Shag_X = 0.0, Zazor_X = 0.0, Dlina_X = 0.0, Shag_Y = 0.0, up[14];

double Lot = 0.1;
int Risk = 0, StopLoss = 50, TakeProfit = 150, TrailingStop = 50, Expiration = 0;

bool NeedRedrawObjects = true;
bool error = false;

string comment[];

int init()
{
	error = false;

	if ( !IsTesting() ) { Alert( "vHandsTrade: �������� ������������ ������ ��� ������������!" ); error = true; return(-1); }

	//---- ��������� ��������� ������������� ���������
	if ( SELECTED_RISK					< 1 || SELECTED_RISK					> 5 ) { Alert( "������������ �������� SELECTED_RISK!" );								error = true; }
	if ( ArraySize( RISK )				< 1 || ArraySize( RISK )			> 5 ) { Alert( "������������ ���������� �������� � ������� RISK!" );				error = true; }

	if ( SELECTED_LOT						< 1 || SELECTED_LOT					> 5 ) { Alert( "������������ �������� SELECTED_LOT!" );								error = true; }
	if ( ArraySize( LOT )				< 1 || ArraySize( LOT )				> 5 ) { Alert( "������������ ���������� �������� � ������� LOT!" );				error = true; }

	if ( SELECTED_STOPLOSS				< 1 || SELECTED_STOPLOSS			> 5 ) { Alert( "������������ �������� SELECTED_STOPLOSS!" );						error = true; }
	if ( ArraySize( STOPLOSS )			< 1 || ArraySize( STOPLOSS )		> 5 ) { Alert( "������������ ���������� �������� � ������� STOPLOSS!" );		error = true; }

	if ( SELECTED_TAKEPROFIT			< 1 || SELECTED_TAKEPROFIT			> 5 ) { Alert( "������������ �������� SELECTED_TAKEPROFIT!" );						error = true; }
	if ( ArraySize( TAKEPROFIT )		< 1 || ArraySize( TAKEPROFIT )	> 5 ) { Alert( "������������ ���������� �������� � ������� TAKEPROFIT!" );		error = true; }

	if ( SELECTED_TRAILINGSTOP			< 1 || SELECTED_TRAILINGSTOP		> 5 ) { Alert( "������������ �������� SELECTED_TRAILINGSTOP!" );					error = true; }
	if ( ArraySize( TRAILINGSTOP )	< 1 || ArraySize( TRAILINGSTOP )	> 5 ) { Alert( "������������ ���������� �������� � ������� TRAILINGSTOP!" );	error = true; }

	if ( SELECTED_EXPIRATION			< 1 || SELECTED_EXPIRATION			> 5 ) { Alert( "������������ �������� SELECTED_EXPIRATION!" );						error = true; }
	if ( ArraySize( EXPIRATION )		< 1 || ArraySize( EXPIRATION )	> 5 ) { Alert( "������������ ���������� �������� � ������� EXPIRATION!" );		error = true; }

	if ( error ) { return(-1); }

	//---- ���������� �������� �� ���������
	Risk				= RISK[SELECTED_RISK-1];
	Lot				= LOT[SELECTED_LOT-1];
	StopLoss			= STOPLOSS[SELECTED_STOPLOSS-1];
	TakeProfit		= TAKEPROFIT[SELECTED_TAKEPROFIT-1];
	TrailingStop	= TRAILINGSTOP[SELECTED_TRAILINGSTOP-1];
	Expiration		= EXPIRATION[SELECTED_EXPIRATION-1]*3600.0;

	//---- ������ ������� � ����������� ��������
	NeedRedrawObjects = true;

	//---- ������������ ���������� ��������
	vHandsTrade_ReCount();

	//---- �������������� �������
	vHandsTrade_RefreshObjects();

	//---- �������������� �������� "��������" � "������� �����"
	vTerminalInit();
	vHistoryInit();

	ArrayResize( comment, CommentsCount );

	return(0);
}

int deinit()
{
	if ( error ) { return(-1); }

	//---- ������� ��� ����� ������
	vHandsTrade_DeleteObjects();

	Comment( "" );

	return(0);
}
int start()
{
	if ( error ) { return(-1); }

	//---- ���������, �� ������ �� ������������ ������ �������� ��/��/��/���� � �.�.
	vHandsTrade_CheckSelection();

	//---- ���������, �� ���� �� ������� �������
	vHandsTrade_Open();
	//---- ���������, �� ���� �� ������� �������
	vHandsTrade_Close();
	//---- ���������, �� ���� �� �������������� �������
	vHandsTrade_Modify();
	//---- ���������� ��������
	vHandsTrade_TrailingStop();


	//---- ������������� ���������� ��������
	vHandsTrade_ReCount();

	//---- �������������� �������
	vHandsTrade_RefreshObjects();

	//---- ��������� �������� "��������" � "������� �����"
	vTerminalRefresh();
	vHistoryRefresh();

	return(0);
}

void vHandsTrade_CheckSelection()
{
	string name;
	for ( int i = 1; i < 6; i ++ )
	{
		name = "vHT_Risk" + i;
		if ( Panel_T1+(i+1)*Shag_X == ObjectGet( name, OBJPROP_TIME1 ) && up[8] == ObjectGet( name, OBJPROP_PRICE1 ) ) { continue; }

		NeedRedrawObjects = true;
		SELECTED_RISK = i;
		Risk = RISK[SELECTED_RISK-1];
		break;
	}

	for ( i = 1; i < 6; i ++ )
	{
		name = "vHT_Lot" + i;
		if ( Panel_T1+(i+1)*Shag_X == ObjectGet( name, OBJPROP_TIME1 ) && up[9] == ObjectGet( name, OBJPROP_PRICE1 ) ) { continue; }

		NeedRedrawObjects = true;
		SELECTED_LOT = i;
		Lot = LOT[SELECTED_LOT-1];
		break;
	}

	for ( i = 1; i < 6; i ++ )
	{
		name = "vHT_StopLoss" + i;
		if ( Panel_T1+(i+1)*Shag_X == ObjectGet( name, OBJPROP_TIME1 ) && up[10] == ObjectGet( name, OBJPROP_PRICE1 ) ) { continue; }

		NeedRedrawObjects = true;
		SELECTED_STOPLOSS = i;
		StopLoss = STOPLOSS[SELECTED_STOPLOSS-1];
		break;
	}

	for ( i = 1; i < 6; i ++ )
	{
		name = "vHT_TakeProfit" + i;
		if ( Panel_T1+(i+1)*Shag_X == ObjectGet( name, OBJPROP_TIME1 ) && up[11] == ObjectGet( name, OBJPROP_PRICE1 ) ) { continue; }

		NeedRedrawObjects = true;
		SELECTED_TAKEPROFIT = i;
		TakeProfit = TAKEPROFIT[SELECTED_TAKEPROFIT-1];
		break;
	}

	for ( i = 1; i < 6; i ++ )
	{
		name = "vHT_TrailingStop" + i;
		if ( Panel_T1+(i+1)*Shag_X == ObjectGet( name, OBJPROP_TIME1 ) && up[12] == ObjectGet( name, OBJPROP_PRICE1 ) ) { continue; }

		NeedRedrawObjects = true;
		SELECTED_TRAILINGSTOP = i;
		TrailingStop = TRAILINGSTOP[SELECTED_TRAILINGSTOP-1];
		break;
	}

	for ( i = 1; i < 6; i ++ )
	{
		name = "vHT_Expiration" + i;
		if ( Panel_T1+(i+1)*Shag_X == ObjectGet( name, OBJPROP_TIME1 ) && up[13] == ObjectGet( name, OBJPROP_PRICE1 ) ) { continue; }

		NeedRedrawObjects = true;
		SELECTED_EXPIRATION = i;
		Expiration = EXPIRATION[SELECTED_EXPIRATION-1]*3600.0;
		break;
	}
}
void vHandsTrade_Open()
{
	vHandsTrade_OpenBuy();
	vHandsTrade_OpenSell();
	vHandsTrade_OpenBuyStop();
	vHandsTrade_OpenSellStop();
	vHandsTrade_OpenBuyLimit();
	vHandsTrade_OpenSellLimit();
}
void vHandsTrade_Close()
{
	if ( TerminalRows <= 0 ) { return(0); }
	if ( vTerminal_win < 0 ) { return(-1); }

	int _GetLastError;

	//---- ���������� ��� �������, ������������ � ���������
	for ( int i = 0; i < TerminalRows; i ++ )
	{
		//---- ���� ���������� ���� �� ��������� ������� "�����",
		if ( ObjectGet( "Ticket_" + i, OBJPROP_XDISTANCE ) != shift1 || ObjectGet( "Ticket_" + i, OBJPROP_YDISTANCE ) != vshift*(i+2) )
		{
			//---- ���� ������ �� ������,
			if ( GetLastError() != 4202 )
			{
				//---- ���������� � �������� ������� ��������������� �����
				int ticket = StrToInteger( ObjectDescription( "Ticket_" + i ) );
				if ( ticket > 0 )
				{
					if ( !OrderSelect( ticket, SELECT_BY_TICKET ) )
					{
						_GetLastError = GetLastError();
						Print( "OrderSelect( ", ticket, ", SELECT_BY_TICKET ) - Error #", _GetLastError );
					}
					else
					{
						//---- ���� ����� ����� ����, � �� �� ������,
						if ( OrderCloseTime() <= 0 )
						{
							//---- ���� ��� ������-������� (��� ��� ����)
							if ( OrderType() < 2 )
							{
								//---- ��������� �������
								if ( OrderType() == OP_BUY )
								{
									if ( !OrderClose( ticket, OrderLots(), Bid, 3, BuyOPColor ) )
									{
										_GetLastError = GetLastError();
										MultiComment( "������ #" + _GetLastError + " ��� �������� ������ �" + ticket + "!!!" );
									}
									else
									{
										MultiComment( "����� �" + ticket + " ������ �������!" );
									}
								}
								else
								{
									if ( !OrderClose( ticket, OrderLots(), Ask, 3, SellOPColor ) )
									{
										_GetLastError = GetLastError();
										MultiComment( "������ #" + _GetLastError + " ��� �������� ������ �" + ticket + "!!!" );
									}
									else
									{
										MultiComment( "����� �" + ticket + " ������ �������!" );
									}
								}
							}
							//---- ���� ��� ���������� �����, ������� ���
							else
							{
								if ( !OrderDelete( ticket ) )
								{
									_GetLastError = GetLastError();
									MultiComment( "������ #" + _GetLastError + " ��� �������� ������ �" + ticket + "!!!" );
								}
								else
								{
									MultiComment( "����� �" + ticket + " ������ �������!" );
								}
							}
						}
					}
				}
			}
			//---- ������� ������������/��������� ������ "�����"
			vLabel( vTerminal_win, "Ticket_" + i, shift1 , vshift*(i+2) );
		}
	}
}
void vHandsTrade_Modify()
{
	if ( TerminalRows <= 0 ) { return(0); }
	if ( vTerminal_win < 0 ) { return(-1); }

	int _GetLastError, tmp, ticket;
	bool modifyOP = false, modifySL = false, modifyTP = false;
	bool deleteOP = false, deleteSL = false, deleteTP = false;

	//---- ���������� ��� �������, ������������ � ���������
	for ( int i = 0; i < TerminalRows; i ++ )
	{
		//---- �������� ����� �������� � �����������
		modifyOP = false; modifySL = false; modifyTP = false;
		deleteOP = false; deleteSL = false; deleteTP = false;
		//---- ���� ���������� ���������� ������� OpenPrice,
		if ( ObjectGet( "OpenPrice_" + i, OBJPROP_XDISTANCE ) != shift5 || ObjectGet( "OpenPrice_" + i, OBJPROP_YDISTANCE ) != vshift*(i+2) )
		{
			//---- ������ �������, ������ ���� ������ ��� ������ ���������
			if ( GetLastError() == 4202 )
			{ deleteOP = true; }
			else
			{ modifyOP = true; }
			//---- ������ ��� ������
			vLabel( vTerminal_win, "OpenPrice_" + i, shift5 , vshift*(i+2) );
		}
		//---- �� �� ����� ��� StopLoss
		if ( ObjectGet( "StopLoss_" + i, OBJPROP_XDISTANCE ) != shift6 || ObjectGet( "StopLoss_" + i, OBJPROP_YDISTANCE ) != vshift*(i+2) )
		{
			if ( GetLastError() == 4202 )
			{ deleteSL = true; }
			else
			{ modifySL = true; }
			vLabel( vTerminal_win, "StopLoss_" + i, shift6 , vshift*(i+2) );
		}
		//---- �� �� ����� ��� TakeProfit
		if ( ObjectGet( "TakeProfit_" + i, OBJPROP_XDISTANCE ) != shift7 || ObjectGet( "TakeProfit_" + i, OBJPROP_YDISTANCE ) != vshift*(i+2) )
		{
			if ( GetLastError() == 4202 )
			{ deleteTP = true; }
			else
			{ modifyTP = true; }
			vLabel( vTerminal_win, "TakeProfit_" + i, shift7 , vshift*(i+2) );
		}

		//---- ���� �� ��������� �� ������ ����������, ��������� � ���������� ������
		if ( !modifyOP && !modifySL && !modifyTP && !deleteOP && !deleteSL && !deleteTP ) { continue; }

		//---- ���� ��������� ����, �������� ��� ������������:
		//---- ���������� �����
		ticket = StrToInteger( ObjectDescription( "Ticket_" + i ) );
		if ( ticket <= 0 ) { continue; }

		//---- �������� ���
		if ( !OrderSelect( ticket, SELECT_BY_TICKET ) )
		{
			_GetLastError = GetLastError();
			Print( "OrderSelect( ", ticket, ", SELECT_BY_TICKET ) - Error #", _GetLastError );
			continue;
		}

		//---- ���������, �� �������� �� ��
		if ( OrderCloseTime() > 0 ) { continue; }

		//---- ���� ��� ������ ������ OpenPrice,
		if ( deleteOP )
		{
			//---- ���� ��� ������-�����, ��������� ���
			if ( OrderType() < 2 )
			{
				if ( OrderType() == OP_BUY )
				{
					if ( !OrderClose( ticket, OrderLots(), Bid, 3, BuyOPColor ) )
					{
						_GetLastError = GetLastError();
						MultiComment( "������ #" + _GetLastError + " ��� �������� ������ �" + ticket + "!!!" );
					}
					else
					{
						MultiComment( "����� �" + ticket + " ������ �������!" );
					}
				}
				else
				{
					if ( !OrderClose( ticket, OrderLots(), Ask, 3, SellOPColor ) )
					{
						_GetLastError = GetLastError();
						MultiComment( "������ #" + _GetLastError + " ��� �������� ������ �" + ticket + "!!!" );
					}
					else
					{
						MultiComment( "����� �" + ticket + " ������ �������!" );
					}
				}
			}
			//---- � ���� ����������, �������
			else
			{
				if ( !OrderDelete( ticket ) )
				{
					_GetLastError = GetLastError();
					MultiComment( "������ #" + _GetLastError + " ��� �������� ������ �" + ticket + "!!!" );
				}
				else
				{
					MultiComment( "����� �" + ticket + " ������ �������!" );
				}
			}
		}

		//---- ���� ������ OpenPrice ��� ���������, 
		if ( modifyOP )
		{
			//---- ���� ��� ���������� �����, ������ �����, � ������� ������� ����� ����� �������� ������
			if ( OrderType() > 1 )
			{
				CreateHLine( "vHT_Modify_OP_" + ticket, OrderOpenPrice(), STYLE_SOLID, 1, ModifyColor, ticket + ": modify OpenPrice" );
			}
		}


		//---- ���� ������ �������� ��� ������, ������� �������� � ������
		if ( deleteSL )
		{
			if ( OrderStopLoss() > 0 )
			{
				if ( !OrderModify( ticket, OrderOpenPrice(), 0.0, OrderTakeProfit(), OrderExpiration(), ModifyColor ) )
				{
					_GetLastError = GetLastError();
					MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + ticket + "!!!" );
				}
				else
				{
					MultiComment( "����� �" + ticket + " ������������� �������!" );
				}
			}
		}
		//---- ���� ������ �������� ��� ���������,
		if ( modifySL )
		{
			//---- �������, ���� �������� ����� ����������� ��, � ������
			if ( OrderStopLoss() > 0 )
			{
				CreateHLine( "vHT_Modify_SL_" + ticket, OrderStopLoss(), STYLE_DASHDOT, 1, ModifyColor, ticket + ": modify StopLoss" );
			}
			else
			{
				tmp = StopLoss;
				if ( tmp <= 0 ) { tmp = 50; }

				if ( OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT )
				{ CreateHLine( "vHT_Modify_SL_" + ticket, OrderOpenPrice() - tmp*Point, STYLE_DASHDOT, 1, ModifyColor, ticket + ": modify StopLoss" ); }
				else
				{ CreateHLine( "vHT_Modify_SL_" + ticket, OrderOpenPrice() + tmp*Point, STYLE_DASHDOT, 1, ModifyColor, ticket + ": modify StopLoss" ); }
			}
		}


		//---- �� �� ����� ��� ��
		if ( deleteTP )
		{
			if ( OrderTakeProfit() > 0 )
			{
				if ( !OrderModify( ticket, OrderOpenPrice(), OrderStopLoss(), 0.0, OrderExpiration(), ModifyColor ) )
				{
					_GetLastError = GetLastError();
					MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + ticket + "!!!" );
				}
				else
				{
					MultiComment( "����� �" + ticket + " ������������� �������!" );
				}
			}
		}
		if ( modifyTP )
		{
			if ( OrderTakeProfit() > 0 )
			{
				CreateHLine( "vHT_Modify_TP_" + ticket, OrderTakeProfit(), STYLE_DASHDOT, 1, ModifyColor, ticket + ": modify TakeProfit" );
			}
			else
			{
				tmp = TakeProfit;
				if ( tmp <= 0 ) { tmp = 50; }

				if ( OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT )
				{ CreateHLine( "vHT_Modify_TP_" + ticket, OrderOpenPrice() + tmp*Point, STYLE_DOT, 1, ModifyColor, ticket + ": modify TakeProfit" ); }
				else
				{ CreateHLine( "vHT_Modify_TP_" + ticket, OrderOpenPrice() - tmp*Point, STYLE_DOT, 1, ModifyColor, ticket + ": modify TakeProfit" ); }
			}
		}
	}
	ObjectsRedraw();

	//---- ������ ��������� ����� �����������...
	int objectstotal = ObjectsTotal(); string name = "", modify; double newValue, oldValue, stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;
	//---- ���������� �������,
	for ( i = objectstotal; i >= 0; i -- )
	{
		//---- ���� � ����� ������� ���� ������ "vHT_Modify_",
		name = ObjectName(i);
		if ( StringSubstr( name, 0, 11 ) == "vHT_Modify_" )
		{
			//---- ���������� �����
			ticket = StrToInteger( StringSubstr( name, 14 ) );
			if ( ticket <= 0 ) { continue; }
			//---- ������� ������� � ���, ��� ������ ���� ������
			modify = StringSubstr( name, 11, 2 );
			//---- ���������� �������, �� ������� ����� ��������� ������� ��������/��/��
			newValue = ObjectGet( name, OBJPROP_PRICE1 );
			if ( newValue <= 0 ) { continue; }

			if ( !OrderSelect( ticket, SELECT_BY_TICKET ) )
			{
				_GetLastError = GetLastError();
				Print( "OrderSelect( ", ticket, ", SELECT_BY_TICKET ) - Error #", _GetLastError );
				continue;
			}
			if ( OrderCloseTime() > 0 ) { ObjectDelete( name ); continue; }

			//---- ���� �������������� ���� ���� ��������,
			if ( modify == "OP" )
			{
				//---- ���� ��� ���������� �����,
				if ( OrderType() > 1 )
				{
					//---- ���� ����� �����������,
					if ( NormalizeDouble( OrderOpenPrice() - newValue, Digits ) > 0 || NormalizeDouble( newValue - OrderOpenPrice(), Digits ) > 0 )
					{
						if ( OrderType() == OP_BUYSTOP )
						{
							if ( NormalizeDouble( ( newValue - Ask ) - stoplevel, Digits ) <= 0.0  )
							{
								MultiComment( "������������ ���� �������� ��� ������ �" + ticket + "!!!" );
								continue;
							}
						}
						if ( OrderType() == OP_BUYLIMIT )
						{
							if ( NormalizeDouble( ( Ask - newValue ) - stoplevel, Digits ) <= 0.0  )
							{
								MultiComment( "������������ ���� �������� ��� ������ �" + ticket + "!!!" );
								continue;
							}
						}
						if ( OrderType() == OP_SELLSTOP )
						{
							if ( NormalizeDouble( ( Bid - newValue ) - stoplevel, Digits ) <= 0.0  )
							{
								MultiComment( "������������ ���� �������� ��� ������ �" + ticket + "!!!" );
								continue;
							}
						}
						if ( OrderType() == OP_SELLLIMIT )
						{
							if ( NormalizeDouble( ( newValue - Bid ) - stoplevel, Digits ) <= 0.0  )
							{
								MultiComment( "������������ ���� �������� ��� ������ �" + ticket + "!!!" );
								continue;
							}
						}

						//---- ������������ �����
						if ( !OrderModify( ticket, newValue, OrderStopLoss(), OrderTakeProfit(), OrderExpiration(), ModifyColor ) )
						{
							_GetLastError = GetLastError();
							MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + ticket + "!!!" );
						}
						else
						{
							MultiComment( "����� �" + ticket + " ������������� �������!" );
							//---- � ������ �����
							ObjectDelete( name );
						}
					}
				}
			}
			//---- ���� �������������� ���� ��������,
			if ( modify == "SL" )
			{
				//---- ������� �������� ��������� �����
				if ( OrderStopLoss() > 0 )
				{
					oldValue = OrderStopLoss();
				}
				else
				{
					tmp = StopLoss;
					if ( tmp <= 0 ) { tmp = 50; }

					if ( OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT )
					{ oldValue = OrderOpenPrice() - tmp*Point; }
					else
					{ oldValue = OrderOpenPrice() + tmp*Point; }
				}

				//---- �, ���� ����� ���� ����������, ������������ �����
				if ( NormalizeDouble( oldValue - newValue, Digits ) > 0 || NormalizeDouble( newValue - oldValue, Digits ) > 0 )
				{
					if ( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP )
					{
						if ( NormalizeDouble( MathAbs( Bid - newValue ) - stoplevel, Digits ) <= 0.0 )
						{
							MultiComment( "������������ �������� ��� ������ �" + ticket + "!!!" );
							continue;
						}
					}
					else
					{
						if ( NormalizeDouble( MathAbs( Ask - newValue ) - stoplevel, Digits ) <= 0.0 )
						{
							MultiComment( "������������ �������� ��� ������ �" + ticket + "!!!" );
							continue;
						}
					}

					if ( !OrderModify( ticket, OrderOpenPrice(), newValue, OrderTakeProfit(), OrderExpiration(), ModifyColor ) )
					{
						_GetLastError = GetLastError();
						MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + ticket + "!!!" );
					}
					else
					{
						MultiComment( "����� �" + ticket + " ������������� �������!" );
						ObjectDelete( name );
					}
				}
			}
			//---- �� �� ����� ��� ��
			if ( modify == "TP" )
			{
				if ( OrderTakeProfit() > 0 )
				{
					oldValue = OrderTakeProfit();
				}
				else
				{
					tmp = TakeProfit;
					if ( tmp <= 0 ) { tmp = 50; }

					if ( OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT )
					{ oldValue = OrderOpenPrice() + tmp*Point; }
					else
					{ oldValue = OrderOpenPrice() - tmp*Point; }
				}

				if ( NormalizeDouble( oldValue - newValue, Digits ) > 0 || NormalizeDouble( newValue - oldValue, Digits ) > 0 )
				{
					if ( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP )
					{
						if ( NormalizeDouble( MathAbs( Bid - newValue ) - stoplevel, Digits ) <= 0.0 )
						{
							MultiComment( "������������ ���������� ��� ������ �" + ticket + "!!!" );
							continue;
						}
					}
					else
					{
						if ( NormalizeDouble( MathAbs( Ask - newValue ) - stoplevel, Digits ) <= 0.0 )
						{
							MultiComment( "������������ ���������� ��� ������ �" + ticket + "!!!" );
							continue;
						}
					}

					if ( !OrderModify( ticket, OrderOpenPrice(), OrderStopLoss(), newValue, OrderExpiration(), ModifyColor ) )
					{
						_GetLastError = GetLastError();
						MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + ticket + "!!!" );
					}
					else
					{
						MultiComment( "����� �" + ticket + " ������������� �������!" );
						ObjectDelete( name );
					}
				}
			}
		}
	}
	GetLastError();
}
void vHandsTrade_TrailingStop()
{
	//---- ���� �������� ������ 0 (�������), ���������� ��� �������� ������� � ������� �� ����� �� ���� ;)
	if ( TrailingStop > 0 )
	{
		int _GetLastError, _OrdersTotal = OrdersTotal();

		for ( int z = _OrdersTotal - 1; z >= 0; z -- )
		{
			if ( !OrderSelect( z, SELECT_BY_POS, MODE_TRADES ) )
			{
				_GetLastError = GetLastError();
				Print( "OrderSelect( ", z, ", SELECT_BY_POS, MODE_TRADES ) - Error #", _GetLastError );
				continue;
			}

			if ( TrailingStop <= MarketInfo( OrderSymbol(), MODE_STOPLEVEL )+1 ) { continue; }

			if ( OrderType() == OP_BUY )
			{
				if ( NormalizeDouble( Bid - OrderOpenPrice() - TrailingStop*Point, Digits ) > 0.0 )
				{
					if ( NormalizeDouble( Bid - TrailingStop*Point - OrderStopLoss(), Digits ) > 0.0 )
					{
						if ( !OrderModify( OrderTicket(), OrderOpenPrice(), Bid - TrailingStop*Point, OrderTakeProfit(), 0, TrailingColor ) )
						{
							_GetLastError = GetLastError();
							MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + OrderTicket() + "!!!" );
						}
					}
				}
				continue;
			}
			if ( OrderType() == OP_SELL )
			{
				if ( NormalizeDouble( OrderOpenPrice() - Ask - TrailingStop*Point, Digits ) > 0.0 )
				{
					if ( NormalizeDouble( OrderStopLoss() - ( Ask + TrailingStop*Point ), Digits ) > 0.0 || OrderStopLoss() <= 0 )
					{
						if ( !OrderModify( OrderTicket(), OrderOpenPrice(), Ask + TrailingStop*Point, OrderTakeProfit(), 0, TrailingColor ) )
						{
							_GetLastError = GetLastError();
							MultiComment( "������ #" + _GetLastError + " ��� ����������� ������ �" + OrderTicket() + "!!!" );
						}
					}
				}
				continue;
			}
		}
	}
}

//---- �������� ��� �������
void vHandsTrade_OpenBuy()
{
	//---- ���� ����� �������� ��� ���� ����������,
	double _OpenPriceLevel, _StopLossLevel, _TakeProfitLevel; int _GetLastError;
	if ( left[1] != ObjectGet( "vHT_Buy_OP", OBJPROP_TIME1 )  || right[1]!= ObjectGet( "vHT_Buy_OP", OBJPROP_TIME2 ) ||
		  up[2]   != ObjectGet( "vHT_Buy_OP", OBJPROP_PRICE1 ) || up[2]   != ObjectGet( "vHT_Buy_OP", OBJPROP_PRICE2 ) )
	{
		//---- ���� ����� �������, �������
		if ( GetLastError() == 4202 ) { NeedRedrawObjects = true; return(0); }

		double stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;

		//---- � ���� ���, ����������� ������� ��������,
		_OpenPriceLevel = NormalizeDouble( Ask, Digits );

		//---- ���� ����� �� ��� ������� ���� ����������, 
		if ( left[1] != ObjectGet( "vHT_Buy_SL", OBJPROP_TIME1 )  || right[1]!= ObjectGet( "vHT_Buy_SL", OBJPROP_TIME2 ) ||
			  up[3]   != ObjectGet( "vHT_Buy_SL", OBJPROP_PRICE1 ) || up[3]   != ObjectGet( "vHT_Buy_SL", OBJPROP_PRICE2 ) )
		{
			//---- ������� �� ������ - ��� ���������� �����
			_StopLossLevel = NormalizeDouble( ObjectGet( "vHT_Buy_SL", OBJPROP_PRICE1 ), Digits );
		}
		//---- � ���� ����� �� �� �����, 
		else
		{
			//---- ���� ������� ��������� �� ������ 0 (�������), ������� ������� �� �� ���� ��������
			if ( StopLoss > 0 )
			{ _StopLossLevel = NormalizeDouble( _OpenPriceLevel - StopLoss*Point, Digits ); }
			else
			{ _StopLossLevel = 0.0; }
		}
		if ( _StopLossLevel > 0.0 && NormalizeDouble( Bid - _StopLossLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ �������� ��� Buy-�������!!!" );
			return(0);
		}

		//---- �� - �� �� ����� 
		if ( left[1] != ObjectGet( "vHT_Buy_TP", OBJPROP_TIME1 )  || right[1]!= ObjectGet( "vHT_Buy_TP", OBJPROP_TIME2 ) ||
			  up[1]   != ObjectGet( "vHT_Buy_TP", OBJPROP_PRICE1 ) || up[1]   != ObjectGet( "vHT_Buy_TP", OBJPROP_PRICE2 ) )
		{
			_TakeProfitLevel = NormalizeDouble( ObjectGet( "vHT_Buy_TP", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( TakeProfit > 0 )
			{ _TakeProfitLevel = NormalizeDouble( _OpenPriceLevel + TakeProfit*Point, Digits ); }
			else
			{ _TakeProfitLevel = 0.0; }
		}
		if ( _TakeProfitLevel > 0.0 && NormalizeDouble( _TakeProfitLevel - Bid - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ���������� ��� Buy-�������!!!" );
			return(0);
		}

		//---- ����������� ���
		double UseLot = LotSize();
		if ( UseLot < 0 ) { return(0); }

		//---- � ��������� ������� ;)
		if ( OrderSend( Symbol(), OP_BUY, UseLot, _OpenPriceLevel, 3, _StopLossLevel, _TakeProfitLevel, "vHandsTrade", 0, BuyOPColor ) < 0 )
		{
			_GetLastError = GetLastError();
			MultiComment( "������ #" + _GetLastError + " ��� �������� Buy-�������!!!" );
		}
		else
		{
			//---- ������ �������, ��� ���� ��������������...
			NeedRedrawObjects = true;
			MultiComment( "Buy-������� ������� �������!" );
		}
	}
}
void vHandsTrade_OpenBuyStop()
{
	double _OpenPriceLevel, _StopLossLevel, _TakeProfitLevel; int _Expiration, _GetLastError;
	if ( left[0] != ObjectGet( "vHT_BuyStop_OP", OBJPROP_TIME1 )  || right[0]!= ObjectGet( "vHT_BuyStop_OP", OBJPROP_TIME2 ) ||
		  up[2]   != ObjectGet( "vHT_BuyStop_OP", OBJPROP_PRICE1 ) || up[2]   != ObjectGet( "vHT_BuyStop_OP", OBJPROP_PRICE2 ) )
	{
		//---- ���� ����� �������, �������
		if ( GetLastError() == 4202 ) { NeedRedrawObjects = true; return(0); }

		double stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;
		double spread    = MarketInfo( Symbol(), MODE_SPREAD )*Point;

		_OpenPriceLevel = NormalizeDouble( ObjectGet( "vHT_BuyStop_OP", OBJPROP_PRICE1 ), Digits );
		if ( NormalizeDouble( _OpenPriceLevel - Ask - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ������� �������� BuyStop-������!!!" );
			return(0);
		}

		if ( left[0] != ObjectGet( "vHT_BuyStop_SL", OBJPROP_TIME1 )  || right[0]!= ObjectGet( "vHT_BuyStop_SL", OBJPROP_TIME2 ) ||
		     up[3]   != ObjectGet( "vHT_BuyStop_SL", OBJPROP_PRICE1 ) || up[3]   != ObjectGet( "vHT_BuyStop_SL", OBJPROP_PRICE2 ) )
		{
			_StopLossLevel = NormalizeDouble( ObjectGet( "vHT_BuyStop_SL", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( StopLoss > 0 )
			{ _StopLossLevel = NormalizeDouble( _OpenPriceLevel - StopLoss*Point, Digits ); }
			else
			{ _StopLossLevel = 0.0; }
		}
		if ( _StopLossLevel > 0.0 && NormalizeDouble( (_OpenPriceLevel - spread) - _StopLossLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ �������� ��� BuyStop-������!!!" );
			return(0);
		}

		if ( left[0] != ObjectGet( "vHT_BuyStop_TP", OBJPROP_TIME1 )  || right[0]!= ObjectGet( "vHT_BuyStop_TP", OBJPROP_TIME2 ) ||
			  up[1]   != ObjectGet( "vHT_BuyStop_TP", OBJPROP_PRICE1 ) || up[1]   != ObjectGet( "vHT_BuyStop_TP", OBJPROP_PRICE2 ) )
		{
			_TakeProfitLevel = NormalizeDouble( ObjectGet( "vHT_BuyStop_TP", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( TakeProfit > 0 )
			{ _TakeProfitLevel = NormalizeDouble( _OpenPriceLevel + TakeProfit*Point, Digits ); }
			else
			{ _TakeProfitLevel = 0.0; }
		}
		if ( _TakeProfitLevel > 0.0 && NormalizeDouble( _TakeProfitLevel - (_OpenPriceLevel - spread) - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ���������� ��� BuyStop-������!!!" );
			return(0);
		}

		if ( Expiration > 0 )
		{ _Expiration = CurTime() + Expiration; }
		else
		{ _Expiration = 0; }

		double UseLot = LotSize();
		if ( UseLot < 0 ) { return(0); }

		if ( OrderSend( Symbol(), OP_BUYSTOP, UseLot, _OpenPriceLevel, 3, _StopLossLevel, _TakeProfitLevel, "vHandsTrade", 0, _Expiration, BuyOPColor ) < 0 )
		{
			_GetLastError = GetLastError();
			MultiComment( "������ #" + _GetLastError + " ��� ��������� BuyStop-������!!!" );
		}
		else
		{
			NeedRedrawObjects = true;
			MultiComment( "BuyStop-����� ���������� �������!" );
		}
	}
}
void vHandsTrade_OpenBuyLimit()
{
	double _OpenPriceLevel, _StopLossLevel, _TakeProfitLevel; int _Expiration, _GetLastError;
	if ( left[0] != ObjectGet( "vHT_BuyLimit_OP", OBJPROP_TIME1 )  || right[0]!= ObjectGet( "vHT_BuyLimit_OP", OBJPROP_TIME2 ) ||
		up[6]   != ObjectGet( "vHT_BuyLimit_OP", OBJPROP_PRICE1 ) || up[6]   != ObjectGet( "vHT_BuyLimit_OP", OBJPROP_PRICE2 ) )
	{
		//---- ���� ����� �������, �������
		if ( GetLastError() == 4202 ) { NeedRedrawObjects = true; return(0); }

		double stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;
		double spread    = MarketInfo( Symbol(), MODE_SPREAD )*Point;

		_OpenPriceLevel = NormalizeDouble( ObjectGet( "vHT_BuyLimit_OP", OBJPROP_PRICE1 ), Digits );
		if ( NormalizeDouble( Ask - _OpenPriceLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ������� �������� BuyLimit-������!!!" );
			return(0);
		}

		if ( left[0] != ObjectGet( "vHT_BuyLimit_SL", OBJPROP_TIME1 )  || right[0]!= ObjectGet( "vHT_BuyLimit_SL", OBJPROP_TIME2 ) ||
			  up[7]   != ObjectGet( "vHT_BuyLimit_SL", OBJPROP_PRICE1 ) || up[7]   != ObjectGet( "vHT_BuyLimit_SL", OBJPROP_PRICE2 ) )
		{
			_StopLossLevel = NormalizeDouble( ObjectGet( "vHT_BuyLimit_SL", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( StopLoss > 0 )
			{ _StopLossLevel = NormalizeDouble( _OpenPriceLevel - StopLoss*Point, Digits ); }
			else
			{ _StopLossLevel = 0.0; }
		}
		if ( _StopLossLevel > 0.0 && NormalizeDouble( (_OpenPriceLevel - spread) - _StopLossLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ �������� ��� BuyLimit-������!!!" );
			return(0);
		}

		if ( left[0] != ObjectGet( "vHT_BuyLimit_TP", OBJPROP_TIME1 )  || right[0]!= ObjectGet( "vHT_BuyLimit_TP", OBJPROP_TIME2 ) ||
			  up[5]   != ObjectGet( "vHT_BuyLimit_TP", OBJPROP_PRICE1 ) || up[5]   != ObjectGet( "vHT_BuyLimit_TP", OBJPROP_PRICE2 ) )
		{
			_TakeProfitLevel = NormalizeDouble( ObjectGet( "vHT_BuyLimit_TP", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( TakeProfit > 0 )
			{ _TakeProfitLevel = NormalizeDouble( _OpenPriceLevel + TakeProfit*Point, Digits ); }
			else
			{ _TakeProfitLevel = 0.0; }
		}
		if ( _TakeProfitLevel > 0.0 && NormalizeDouble( _TakeProfitLevel - (_OpenPriceLevel - spread) - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ���������� ��� BuyLimit-������!!!" );
			return(0);
		}

		if ( Expiration > 0 )
		{ _Expiration = CurTime() + Expiration; }
		else
		{ _Expiration = 0; }

		double UseLot = LotSize();
		if ( UseLot < 0 ) { return(0); }

		if ( OrderSend( Symbol(), OP_BUYLIMIT, UseLot, _OpenPriceLevel, 3, _StopLossLevel, _TakeProfitLevel, "vHandsTrade", 0, _Expiration, BuyOPColor ) < 0 )
		{
			_GetLastError = GetLastError();
			MultiComment( "������ #" + _GetLastError + " ��� ��������� BuyLimit-������!!!" );
		}
		else
		{
			NeedRedrawObjects = true;
			MultiComment( "BuyLimit-����� ���������� �������!" );
		}
	}
}
void vHandsTrade_OpenSell()
{
	double _OpenPriceLevel, _StopLossLevel, _TakeProfitLevel; int _GetLastError;
	if ( left[1] != ObjectGet( "vHT_Sell_OP", OBJPROP_TIME1 )  || right[1]!= ObjectGet( "vHT_Sell_OP", OBJPROP_TIME2 ) ||
		  up[6]   != ObjectGet( "vHT_Sell_OP", OBJPROP_PRICE1 ) || up[6]   != ObjectGet( "vHT_Sell_OP", OBJPROP_PRICE2 ) )
	{
		//---- ���� ����� �������, �������
		if ( GetLastError() == 4202 ) { NeedRedrawObjects = true; return(0); }

		double stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;

		_OpenPriceLevel = NormalizeDouble( Bid, Digits );

		if ( left[1] != ObjectGet( "vHT_Sell_SL", OBJPROP_TIME1 )  || right[1]!= ObjectGet( "vHT_Sell_SL", OBJPROP_TIME2 ) ||
			  up[5]   != ObjectGet( "vHT_Sell_SL", OBJPROP_PRICE1 ) || up[5]   != ObjectGet( "vHT_Sell_SL", OBJPROP_PRICE2 ) )
		{
			_StopLossLevel = NormalizeDouble( ObjectGet( "vHT_Sell_SL", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( StopLoss > 0 )
			{ _StopLossLevel = NormalizeDouble( _OpenPriceLevel + StopLoss*Point, Digits ); }
			else
			{ _StopLossLevel = 0.0; }
		}
		if ( _StopLossLevel > 0.0 && NormalizeDouble( _StopLossLevel - Ask - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ �������� ��� Sell-�������!!!" );
			return(0);
		}

		if ( left[1] != ObjectGet( "vHT_Sell_TP", OBJPROP_TIME1 )  || right[1]!= ObjectGet( "vHT_Sell_TP", OBJPROP_TIME2 ) ||
			  up[7]   != ObjectGet( "vHT_Sell_TP", OBJPROP_PRICE1 ) || up[7]   != ObjectGet( "vHT_Sell_TP", OBJPROP_PRICE2 ) )
		{
			_TakeProfitLevel = NormalizeDouble( ObjectGet( "vHT_Sell_TP", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( TakeProfit > 0 )
			{ _TakeProfitLevel = NormalizeDouble( _OpenPriceLevel - TakeProfit*Point, Digits ); }
			else
			{ _TakeProfitLevel = 0.0; }
		}
		if ( _TakeProfitLevel > 0.0 && NormalizeDouble( Ask - _TakeProfitLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ���������� ��� Sell-�������!!!" );
			return(0);
		}

		double UseLot = LotSize();
		if ( UseLot < 0 ) { return(0); }

		if ( OrderSend( Symbol(), OP_SELL, UseLot, _OpenPriceLevel, 3, _StopLossLevel, _TakeProfitLevel, "vHandsTrade", 0, SellOPColor ) < 0 )
		{
			_GetLastError = GetLastError();
			MultiComment( "������ #" + _GetLastError + " ��� �������� Sell-�������!!!" );
		}
		else
		{
			NeedRedrawObjects = true;
			MultiComment( "Sell-������� ������� �������!" );
		}
	}
}
void vHandsTrade_OpenSellStop()
{
	double _OpenPriceLevel, _StopLossLevel, _TakeProfitLevel; int _Expiration, _GetLastError;
	if ( left[2] != ObjectGet( "vHT_SellStop_OP", OBJPROP_TIME1 )  || right[2]!= ObjectGet( "vHT_SellStop_OP", OBJPROP_TIME2 ) ||
		  up[6]   != ObjectGet( "vHT_SellStop_OP", OBJPROP_PRICE1 ) || up[6]   != ObjectGet( "vHT_SellStop_OP", OBJPROP_PRICE2 ) )
	{
		//---- ���� ����� �������, �������
		if ( GetLastError() == 4202 ) { NeedRedrawObjects = true; return(0); }

		double stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;
		double spread    = MarketInfo( Symbol(), MODE_SPREAD )*Point;

		_OpenPriceLevel = NormalizeDouble( ObjectGet( "vHT_SellStop_OP", OBJPROP_PRICE1 ), Digits );
		if ( NormalizeDouble( Bid - _OpenPriceLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ������� �������� SellStop-������!!!" );
			return(0);
		}

		if ( left[2] != ObjectGet( "vHT_SellStop_SL", OBJPROP_TIME1 )  || right[2]!= ObjectGet( "vHT_SellStop_SL", OBJPROP_TIME2 ) ||
			  up[5]   != ObjectGet( "vHT_SellStop_SL", OBJPROP_PRICE1 ) || up[5]   != ObjectGet( "vHT_SellStop_SL", OBJPROP_PRICE2 ) )
		{
			_StopLossLevel = NormalizeDouble( ObjectGet( "vHT_SellStop_SL", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( StopLoss > 0 )
			{ _StopLossLevel = NormalizeDouble( _OpenPriceLevel + StopLoss*Point, Digits ); }
			else
			{ _StopLossLevel = 0.0; }
		}
		if ( _StopLossLevel > 0.0 && NormalizeDouble( _StopLossLevel - (_OpenPriceLevel + spread) - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ �������� ��� SellStop-������!!!" );
			return(0);
		}

		if ( left[2] != ObjectGet( "vHT_SellStop_TP", OBJPROP_TIME1 )  || right[2]!= ObjectGet( "vHT_SellStop_TP", OBJPROP_TIME2 ) ||
			  up[7]   != ObjectGet( "vHT_SellStop_TP", OBJPROP_PRICE1 ) || up[7]   != ObjectGet( "vHT_SellStop_TP", OBJPROP_PRICE2 ) )
		{
			_TakeProfitLevel = NormalizeDouble( ObjectGet( "vHT_SellStop_TP", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( TakeProfit > 0 )
			{ _TakeProfitLevel = NormalizeDouble( _OpenPriceLevel - TakeProfit*Point, Digits ); }
			else
			{ _TakeProfitLevel = 0.0; }
		}
		if ( _TakeProfitLevel > 0.0 && NormalizeDouble( (_OpenPriceLevel + spread) - _TakeProfitLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ���������� ��� SellStop-������!!!" );
			return(0);
		}

		if ( Expiration > 0 )
		{ _Expiration = CurTime() + Expiration; }
		else
		{ _Expiration = 0; }

		double UseLot = LotSize();
		if ( UseLot < 0 ) { return(0); }

		if ( OrderSend( Symbol(), OP_SELLSTOP, UseLot, _OpenPriceLevel, 3, _StopLossLevel, _TakeProfitLevel, "vHandsTrade", 0, _Expiration, SellOPColor ) < 0 )
		{
			_GetLastError = GetLastError();
			MultiComment( "������ #" + _GetLastError + " ��� ��������� SellStop-������!!!" );
		}
		else
		{
			NeedRedrawObjects = true;
			MultiComment( "SellStop-����� ���������� �������!" );
		}
	}
}
void vHandsTrade_OpenSellLimit()
{
	double _OpenPriceLevel, _StopLossLevel, _TakeProfitLevel; int _Expiration, _GetLastError;
	if ( left[2] != ObjectGet( "vHT_SellLimit_OP", OBJPROP_TIME1 )  || right[2]!= ObjectGet( "vHT_SellLimit_OP", OBJPROP_TIME2 ) ||
		  up[2]   != ObjectGet( "vHT_SellLimit_OP", OBJPROP_PRICE1 ) || up[2]   != ObjectGet( "vHT_SellLimit_OP", OBJPROP_PRICE2 ) )
	{
		//---- ���� ����� �������, �������
		if ( GetLastError() == 4202 ) { NeedRedrawObjects = true; return(0); }

		double stoplevel = MarketInfo( Symbol(), MODE_STOPLEVEL )*Point + Point;
		double spread    = MarketInfo( Symbol(), MODE_SPREAD )*Point;

		_OpenPriceLevel = NormalizeDouble( ObjectGet( "vHT_SellLimit_OP", OBJPROP_PRICE1 ), Digits );
		if ( NormalizeDouble( _OpenPriceLevel - Bid - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ������� �������� SellLimit-������!!!" );
			return(0);
		}

		if ( left[2] != ObjectGet( "vHT_SellLimit_SL", OBJPROP_TIME1 )  || right[2]!= ObjectGet( "vHT_SellLimit_SL", OBJPROP_TIME2 ) ||
			  up[1]   != ObjectGet( "vHT_SellLimit_SL", OBJPROP_PRICE1 ) || up[1]   != ObjectGet( "vHT_SellLimit_SL", OBJPROP_PRICE2 ) )
		{
			_StopLossLevel = NormalizeDouble( ObjectGet( "vHT_SellLimit_SL", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( StopLoss > 0 )
			{ _StopLossLevel = NormalizeDouble( _OpenPriceLevel + StopLoss*Point, Digits ); }
			else
			{ _StopLossLevel = 0.0; }
		}
		if ( _StopLossLevel > 0.0 && NormalizeDouble( _StopLossLevel - (_OpenPriceLevel + spread) - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ �������� ��� SellLimit-������!!!" );
			return(0);
		}

		if ( left[2] != ObjectGet( "vHT_SellLimit_TP", OBJPROP_TIME1 )  || right[2]!= ObjectGet( "vHT_SellLimit_TP", OBJPROP_TIME2 ) ||
			  up[3]   != ObjectGet( "vHT_SellLimit_TP", OBJPROP_PRICE1 ) || up[3]   != ObjectGet( "vHT_SellLimit_TP", OBJPROP_PRICE2 ) )
		{
			_TakeProfitLevel = NormalizeDouble( ObjectGet( "vHT_SellLimit_TP", OBJPROP_PRICE1 ), Digits );
		}
		else
		{
			if ( TakeProfit > 0 )
			{ _TakeProfitLevel = NormalizeDouble( _OpenPriceLevel - TakeProfit*Point, Digits ); }
			else
			{ _TakeProfitLevel = 0.0; }
		}
		if ( _TakeProfitLevel > 0.0 && NormalizeDouble( (_OpenPriceLevel + spread) - _TakeProfitLevel - stoplevel, Digits ) <= 0.0 )
		{
			MultiComment( "������������ ���������� ��� SellLimit-������!!!" );
			return(0);
		}

		if ( Expiration > 0 )
		{ _Expiration = CurTime() + Expiration; }
		else
		{ _Expiration = 0; }

		double UseLot = LotSize();
		if ( UseLot < 0 ) { return(0); }

		if ( OrderSend( Symbol(), OP_SELLLIMIT, UseLot, _OpenPriceLevel, 3, _StopLossLevel, _TakeProfitLevel, "vHandsTrade", 0, _Expiration, SellOPColor ) < 0 )
		{
			_GetLastError = GetLastError();
			MultiComment( "������ #" + _GetLastError + " ��� ��������� SellLimit-������!!!" );
		}
		else
		{
			NeedRedrawObjects = true;
			MultiComment( "SellLimit-����� ���������� �������!" );
		}
	}
}

void vHandsTrade_ReCount()
{
	BarsInWindow	= BarsPerWindow();
	SecondsInBar	= Period() * 60;
	WindowHighest	= High[Highest(NULL,0,MODE_HIGH,BarsInWindow*4/5,0)];
	WindowLowest	= Low [Lowest (NULL,0,MODE_LOW, BarsInWindow*4/5,0)];

	//---- ���� �������� ����� ���, ��� ���������� ���������� - ���� ��������������
	if ( preTime != Time[0] ) { NeedRedrawObjects = true; }
	preTime = Time[0];

	//---- ���� ��������� ������ ����, �� �� ������� - ���� ��������������
	if ( BarsInWindow != preBarsInWindow || WindowHighest != preWindowHighest || WindowLowest != preWindowLowest ) { NeedRedrawObjects = true; }
	preBarsInWindow = BarsInWindow; preWindowHighest = WindowHighest; preWindowLowest = WindowLowest;

	//---- � ���� �� ���� ��������������, �� � ������������� �� ���� =)
	if ( NeedRedrawObjects == false ) { return(0); }

	Panel_Width	= MathMax( 7, (MathCeil(BarsInWindow/5.0/3.0)*3+1-3) )*SecondsInBar;
	Panel_T1		= Time[0] + (BarsInWindow/75+1)*SecondsInBar;
	Panel_T2		= Panel_T1+Panel_Width;
	Panel_P1		= WindowHighest-(WindowHighest-WindowLowest)/10;
	Panel_P2		= WindowLowest +(WindowHighest-WindowLowest)/10;

   Shag_X	= MathFloor( Panel_Width/7.0 );
	Zazor_X	= SecondsInBar*MathMax(1.0, MathCeil(Panel_Width/SecondsInBar/25));
	Dlina_X	= MathMax(1.0, MathCeil((Panel_Width-4*Zazor_X)/3) );
	Shag_Y	= (Panel_P1-Panel_P2)/17;

	left[0]  = Panel_T1 + Zazor_X;
	left[1]  = left[0] + Dlina_X + Zazor_X;
	left[2]  = left[1] + Dlina_X + Zazor_X;
	right[0] = left[0] + Dlina_X;
	right[1] = left[1] + Dlina_X;
	right[2] = left[2] + Dlina_X;
	up[0]		= Panel_P1 -  0.5*Shag_Y;
	up[1]		= Panel_P1 -  2.0*Shag_Y;
	up[2]		= Panel_P1 -  3.0*Shag_Y;
	up[3]		= Panel_P1 -  4.0*Shag_Y;
	up[4]		= Panel_P1 -  5.0*Shag_Y;
	up[5]		= Panel_P1 -  6.5*Shag_Y;
	up[6]		= Panel_P1 -  7.5*Shag_Y;
	up[7]		= Panel_P1 -  8.5*Shag_Y;
	up[8]		= Panel_P1 -  9.6*Shag_Y;
	up[9]		= Panel_P1 - 10.8*Shag_Y;
	up[10]	= Panel_P1 - 12.0*Shag_Y;
	up[11]	= Panel_P1 - 13.2*Shag_Y;
	up[12]	= Panel_P1 - 14.4*Shag_Y;
	up[13]	= Panel_P1 - 15.6*Shag_Y;
}
void vHandsTrade_RefreshObjects()
{
	//---- �� ���� �������� - �������
	if ( NeedRedrawObjects == false ) { return(0); }

	//---- ������ )
	ObjectDelete( "vHT_Panel" );
	ObjectCreate( "vHT_Panel", OBJ_RECTANGLE, 0, Panel_T1, Panel_P1, Panel_T2, Panel_P2 );
	ObjectSet   ( "vHT_Panel", OBJPROP_COLOR,		MainColor );
	ObjectSet   ( "vHT_Panel", OBJPROP_BACK,		false );
	GetLastError();

	CreateText( "vHT_BuyStop", left[0]+Dlina_X/2, up[0], "BuyStop", 8, "Arial", MainColor );
	CreateLine( "vHT_BuyStop_TP", left[0], up[1], right[0], up[1], STYLE_DOT, 1, BuyColor );
	CreateLine( "vHT_BuyStop_OP", left[0], up[2], right[0], up[2], STYLE_DASH, 1, BuyColor );
	CreateLine( "vHT_BuyStop_SL", left[0], up[3], right[0], up[3], STYLE_DASHDOT, 1, BuyColor );

	CreateText( "vHT_Buy", left[1]+Dlina_X/2, up[0], "Buy", 8, "Arial", MainColor );
	CreateLine( "vHT_Buy_TP", left[1], up[1], right[1], up[1], STYLE_DOT, 1, BuyOPColor );
	CreateLine( "vHT_Buy_OP", left[1], up[2], right[1], up[2], STYLE_SOLID, 1, BuyOPColor );
	CreateLine( "vHT_Buy_SL", left[1], up[3], right[1], up[3], STYLE_DASHDOT, 1, BuyOPColor );

	CreateText( "vHT_SellLimit", left[2]+Dlina_X/2, up[0], "SellLimit", 8, "Arial", MainColor );
	CreateLine( "vHT_SellLimit_SL", left[2], up[1], right[2], up[1], STYLE_DASHDOT, 1, SellColor );
	CreateLine( "vHT_SellLimit_OP", left[2], up[2], right[2], up[2], STYLE_DASH, 1, SellColor );
	CreateLine( "vHT_SellLimit_TP", left[2], up[3], right[2], up[3], STYLE_DOT, 1, SellColor );

	CreateText( "vHT_BuyLimit", left[0]+Dlina_X/2, up[4], "BuyLimit", 8, "Arial", MainColor );
	CreateLine( "vHT_BuyLimit_TP", left[0], up[5], right[0], up[5], STYLE_DOT, 1, BuyColor );
	CreateLine( "vHT_BuyLimit_OP", left[0], up[6], right[0], up[6], STYLE_DASH, 1, BuyColor );
	CreateLine( "vHT_BuyLimit_SL", left[0], up[7], right[0], up[7], STYLE_DASHDOT, 1, BuyColor );

	CreateText( "vHT_Sell", left[1]+Dlina_X/2, up[4], "Sell", 8, "Arial", MainColor );
	CreateLine( "vHT_Sell_SL", left[1], up[5], right[1], up[5], STYLE_DASHDOT, 1, SellOPColor );
	CreateLine( "vHT_Sell_OP", left[1], up[6], right[1], up[6], STYLE_SOLID, 1, SellOPColor );
	CreateLine( "vHT_Sell_TP", left[1], up[7], right[1], up[7], STYLE_DOT, 1, SellOPColor );

	CreateText( "vHT_SellStop", left[2]+Dlina_X/2, up[4], "SellStop", 8, "Arial", MainColor );
	CreateLine( "vHT_SellStop_SL", left[2], up[5], right[2], up[5], STYLE_DASHDOT, 1, SellColor );
	CreateLine( "vHT_SellStop_OP", left[2], up[6], right[2], up[6], STYLE_DASH, 1, SellColor );
	CreateLine( "vHT_SellStop_TP", left[2], up[7], right[2], up[7], STYLE_DOT, 1, SellColor );


	CreateText( "vHT_Risk0", Panel_T1+1*Shag_X, up[8], "Risk", 8, "Arial", MainColor );
	for ( int i = 1; i < 6; i ++ )
	{
		CreateText( "vHT_Risk" + i, Panel_T1+(i+1)*Shag_X, up[8], RISK[i-1], 8, "Arial", MainColor );
	}
	ObjectSet ( "vHT_Risk" + SELECTED_RISK, OBJPROP_COLOR, SelectColor );

	CreateText( "vHT_Lot0", Panel_T1+1*Shag_X, up[9], "Lot", 8, "Arial", MainColor );
	for ( i = 1; i < 6; i ++ )
	{
		CreateText( "vHT_Lot" + i, Panel_T1+(i+1)*Shag_X, up[9], DoubleToStr( LOT[i-1], 1 ), 8, "Arial", MainColor );
	}
	ObjectSet ( "vHT_Lot" + SELECTED_LOT, OBJPROP_COLOR, SelectColor );

	CreateText( "vHT_StopLoss0", Panel_T1+1*Shag_X, up[10], "SL", 8, "Arial", MainColor );
	for ( i = 1; i < 6; i ++ )
	{
		CreateText( "vHT_StopLoss" + i, Panel_T1+(i+1)*Shag_X, up[10], STOPLOSS[i-1], 8, "Arial", MainColor );
	}
	ObjectSet ( "vHT_StopLoss" + SELECTED_STOPLOSS, OBJPROP_COLOR, SelectColor );

	CreateText( "vHT_TakeProfit0", Panel_T1+1*Shag_X, up[11], "TP", 8, "Arial", MainColor );
	for ( i = 1; i < 6; i ++ )
	{
		CreateText( "vHT_TakeProfit" + i, Panel_T1+(i+1)*Shag_X, up[11], TAKEPROFIT[i-1], 8, "Arial", MainColor );
	}
	ObjectSet ( "vHT_TakeProfit" + SELECTED_TAKEPROFIT, OBJPROP_COLOR, SelectColor );

	CreateText( "vHT_TrailingStop0", Panel_T1+1*Shag_X, up[12], "TS", 8, "Arial", MainColor );
	for ( i = 1; i < 6; i ++ )
	{
		CreateText( "vHT_TrailingStop" + i, Panel_T1+(i+1)*Shag_X, up[12], TRAILINGSTOP[i-1], 8, "Arial", MainColor );
	}
	ObjectSet ( "vHT_TrailingStop" + SELECTED_TRAILINGSTOP, OBJPROP_COLOR, SelectColor );

	CreateText( "vHT_Expiration0", Panel_T1+1*Shag_X, up[13], "Exp", 8, "Arial", MainColor );
	for ( i = 1; i < 6; i ++ )
	{
		string exp = DoubleToStr( EXPIRATION[i-1], 0 );
		if ( EXPIRATION[i-1]-NormalizeDouble(EXPIRATION[i-1],0) != 0 ) { exp = DoubleToStr( EXPIRATION[i-1], 1 ); }
		CreateText( "vHT_Expiration" + i, Panel_T1+(i+1)*Shag_X, up[13], exp, 8, "Arial", MainColor );
	}
	ObjectSet ( "vHT_Expiration" + SELECTED_EXPIRATION, OBJPROP_COLOR, SelectColor );

	GetLastError();
	ObjectsRedraw();
	NeedRedrawObjects = false;
}
void CreateLine( string name, datetime t1, double p1, datetime t2, double p2, int style, int width, color col )
{
	ObjectDelete( name );
	ObjectCreate( name, OBJ_TREND, 0, t1, p1, t2, p2 );
	ObjectSet	( name, OBJPROP_COLOR	, col		);
	ObjectSet	( name, OBJPROP_RAY		, false	);
	ObjectSet	( name, OBJPROP_STYLE	, style	);
	ObjectSet	( name, OBJPROP_WIDTH	, width	);
	GetLastError();
}
void CreateHLine( string name, double p1, int style, int width, color col, string description )
{
	ObjectDelete( name );
	ObjectCreate( name, OBJ_HLINE, 0, CurTime(), p1 );
	ObjectSet	( name, OBJPROP_COLOR	, col		);
	ObjectSet	( name, OBJPROP_STYLE	, style	);
	ObjectSet	( name, OBJPROP_WIDTH	, width	);
	ObjectSetText( name, description, 8 );
	GetLastError();
}
void CreateText( string name, datetime t1, double p1, string text, int font_size, string font_name, color col )
{
	ObjectDelete( name );
	ObjectCreate	( name, OBJ_TEXT, 0, t1, p1 );
	ObjectSetText	( name, text, font_size, font_name, col );
	GetLastError();
}
void vHandsTrade_DeleteObjects()
{
	int objectstotal = ObjectsTotal(); string name = "";
	for ( int i = objectstotal; i >= 0; i -- )
	{
		name = ObjectName(i);
		if ( StringSubstr( name, 0, 4 ) == "vHT_" ) { ObjectDelete( name ); }
	}
	GetLastError();
}
double LotSize()
{
	double 	lot_min		= MarketInfo( Symbol(), MODE_MINLOT  );
	double 	lot_max		= MarketInfo( Symbol(), MODE_MAXLOT  );
	double 	lot_step		= MarketInfo( Symbol(), MODE_LOTSTEP );
	double 	freemargin	= AccountFreeMargin();
	int		leverage		= AccountLeverage();
	int 		lotsize		= MarketInfo( Symbol(), MODE_LOTSIZE );

	if( lot_min < 0 || lot_max <= 0.0 || lot_step <= 0.0 || lotsize <= 0 ) 
	{
		MultiComment( "LotSize: invalid MarketInfo() results [" + lot_min + "," + lot_max + "," + lot_step + "," + lotsize + "]" );
		return(-1);
	}
	if( leverage <= 0 )
	{
		MultiComment( "LotSize: invalid AccountLeverage() [" + leverage + "]" );
		return(-1);
	}

	double lot = NormalizeDouble( Lot, 2 );
	if ( Risk > 0 ) { lot = NormalizeDouble( freemargin * Risk*0.01 * leverage / lotsize, 2 ); }

	lot = NormalizeDouble( lot / lot_step, 0 ) * lot_step;
	if ( lot < lot_min ) lot = lot_min;
	if ( lot > lot_max ) lot = lot_max;

	double needmargin = NormalizeDouble( lotsize / leverage * Ask * lot, 2 );

	if ( freemargin < needmargin )
	{
		MultiComment( "������������ ��������� ������� ��� �������� ������� " + DoubleToStr( lot, 2 ) + " ��� ( FreeMargin = " + DoubleToStr( freemargin, 2 ) + ")!!!" );
		return(-1);
	}

	return(lot);
}
void MultiComment( string text )
{
	string multi = "";
	for ( int i = CommentsCount-1; i > 0; i -- )
	{
		comment[i] = comment[i-1];
	}
	comment[0] = TimeToStr( CurTime(), TIME_DATE | TIME_SECONDS ) + "  -  " + text + "\n";
	for ( i = 0; i < CommentsCount; i ++ )
	{
		multi = multi + comment[i];
	}
	Comment( multi );
}