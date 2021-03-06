//+------------------------------------------------------------------+
//|                                           VisualTestingTools.mq4 |
//|                                      Copyright © 2006, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, komposter"
#property link      "mailto:komposterius@mail.ru"

extern string		VisualTestingTools	= "< - - - VisualTestingTools - - - >";
extern int			TerminalRows			= 50;
extern int			HistoryRows				= 50;

extern bool			BigText					= false;
extern int			SignalPoints			= 10;
extern bool			ShowCancelled			= true;
extern bool			ShowExpired				= true;

extern color		MainColor				= White;

extern color		BuyColor					= Green;
extern color		BuyOPColor				= Lime;
extern color		BuySLColor				= Lime;
extern color		BuyTPColor				= Lime;

extern color		SellColor				= Brown;
extern color		SellOPColor				= Red;
extern color		SellSLColor				= Red;
extern color		SellTPColor				= Red;

string MarketOrders[1][11], PendingOrders[1][11];
int vTerminal_win = -1, curMarketOrder = 0, curPendingOrder = 0;

int vHistory_win = -1, preHistoryTotal = -1;

int fontsize = 8, vshift = 13, shift1 = 3, shift2 = 60, shift3 = 160, shift4 = 220, shift5 = 260, shift6 = 325, shift7 = 385, shift8 = 445, shift9 = 500, shift10 = 555, shift11 = 610;

void vTerminalInit()
{
	if ( TerminalRows <= 0 ) { return(0); }

	vTerminal_win = WindowFind( "vTerminal" );
	if ( IsTesting() ) { vTerminal_win = 1; }
	if ( vTerminal_win < 0 ) { return(-1); }

	ArrayResize( MarketOrders, TerminalRows );
	ArrayResize( PendingOrders, TerminalRows );

	if ( BigText )
	{
		fontsize = 9; vshift = 15; shift1 = 3; shift2 = 70; shift3 = 185; shift4 = 255; shift5 = 305; shift6 = 380; shift7 = 450; shift8 = 520; shift9 = 605; shift10 = 660; shift11 = 725;
	}

	vLabel( vTerminal_win, "Ticket_Head"		, shift1	, vshift ); SetText( "Ticket_Head"			, "Ticket"		, MainColor );
	vLabel( vTerminal_win, "OpenTime_Head"		, shift2	, vshift ); SetText( "OpenTime_Head"		, "OpenTime"	, MainColor );
	vLabel( vTerminal_win, "Type_Head"			, shift3	, vshift ); SetText( "Type_Head"				, "Type"			, MainColor );
	vLabel( vTerminal_win, "Lots_Head"			, shift4	, vshift ); SetText( "Lots_Head"				, "Lots"			, MainColor );
	vLabel( vTerminal_win, "OpenPrice_Head"	, shift5	, vshift ); SetText( "OpenPrice_Head"		, "OpenPrice"	, MainColor );
	vLabel( vTerminal_win, "StopLoss_Head"		, shift6	, vshift ); SetText( "StopLoss_Head"		, "StopLoss"	, MainColor );
	vLabel( vTerminal_win, "TakeProfit_Head"	, shift7	, vshift ); SetText( "TakeProfit_Head"		, "TakeProfit"	, MainColor );
	vLabel( vTerminal_win, "CurPrice_Head"		, shift8	, vshift ); SetText( "CurPrice_Head"		, "CurPrice"	, MainColor );
	vLabel( vTerminal_win, "Swap_Head"			, shift9	, vshift ); SetText( "Swap_Head"				, "Swap"			, MainColor );
	vLabel( vTerminal_win, "Profit_Head"		, shift10, vshift ); SetText( "Profit_Head"			, "Profit"		, MainColor );
	vLabel( vTerminal_win, "Comment_Head"		, shift11, vshift ); SetText( "Comment_Head"			, "Comment"		, MainColor );

	for ( int i = 0; i < TerminalRows; i ++ )
	{
		vLabel( vTerminal_win, "Ticket_" 		+ i, shift1 , vshift*(i+2) );
		vLabel( vTerminal_win, "OpenTime_" 		+ i, shift2 , vshift*(i+2) );
		vLabel( vTerminal_win, "Type_" 			+ i, shift3 , vshift*(i+2) );
		vLabel( vTerminal_win, "Lots_" 			+ i, shift4 , vshift*(i+2) );
		vLabel( vTerminal_win, "OpenPrice_" 	+ i, shift5 , vshift*(i+2) );
		vLabel( vTerminal_win, "StopLoss_" 		+ i, shift6 , vshift*(i+2) );
		vLabel( vTerminal_win, "TakeProfit_"	+ i, shift7 , vshift*(i+2) );
		vLabel( vTerminal_win, "CurPrice_" 		+ i, shift8 , vshift*(i+2) );
		vLabel( vTerminal_win, "Swap_" 			+ i, shift9 , vshift*(i+2) );
		vLabel( vTerminal_win, "Profit_" 		+ i, shift10, vshift*(i+2) );
		vLabel( vTerminal_win, "Comment_" 		+ i, shift11, vshift*(i+2) );
	}
}
void vTerminalRefresh()
{
	if ( TerminalRows <= 0 ) { return(0); }
	if ( vTerminal_win < 0 ) { return(-1); }

	int _GetLastError, _OrdersTotal = OrdersTotal(), digits;
	curMarketOrder = 0; curPendingOrder = 0;
	double SummProfit = 0.0;

	for ( int z = _OrdersTotal - 1; z >= 0; z -- )
	{
		if ( !OrderSelect( z, SELECT_BY_POS, MODE_TRADES ) )
		{
			_GetLastError = GetLastError();
			//Print( "OrderSelect( ", z, ", SELECT_BY_POS, MODE_TRADES ) - Error #", _GetLastError );
			continue;
		}

		digits = MarketInfo( OrderSymbol(), MODE_DIGITS );

		if ( OrderType() < 2 )
		{
			MarketOrders[curMarketOrder][0] = OrderTicket();
			MarketOrders[curMarketOrder][1] = TimeToStr( OrderOpenTime() );
			MarketOrders[curMarketOrder][2] = vOrderType( OrderType() );
			MarketOrders[curMarketOrder][3] = DoubleToStr( OrderLots(), 1 );
			MarketOrders[curMarketOrder][4] = DoubleToStr( OrderOpenPrice(), digits );
			MarketOrders[curMarketOrder][5] = DoubleToStr( OrderStopLoss(), digits );
			MarketOrders[curMarketOrder][6] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_BUY )
			{ MarketOrders[curMarketOrder][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ MarketOrders[curMarketOrder][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			MarketOrders[curMarketOrder][8] = DoubleToStr( OrderSwap(), 2 );
			MarketOrders[curMarketOrder][9] = DoubleToStr( OrderProfit(), 2 );
			MarketOrders[curMarketOrder][10] = OrderComment();

			SummProfit += OrderProfit();
			curMarketOrder ++;
			if ( curMarketOrder >= TerminalRows ) { break; }
		}
		else
		{
			PendingOrders[curPendingOrder][0] = OrderTicket();
			PendingOrders[curPendingOrder][1] = TimeToStr( OrderOpenTime() );
			PendingOrders[curPendingOrder][2] = vOrderType( OrderType() );
			PendingOrders[curPendingOrder][3] = DoubleToStr( OrderLots(), 1 );
			PendingOrders[curPendingOrder][4] = DoubleToStr( OrderOpenPrice(), digits );
			PendingOrders[curPendingOrder][5] = DoubleToStr( OrderStopLoss(), digits );
			PendingOrders[curPendingOrder][6] = DoubleToStr( OrderTakeProfit(), digits );

			if ( OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT )
			{ PendingOrders[curPendingOrder][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_BID ), digits ); }
			else
			{ PendingOrders[curPendingOrder][7] = DoubleToStr( MarketInfo( OrderSymbol(), MODE_ASK ), digits ); }

			PendingOrders[curPendingOrder][8] = DoubleToStr( OrderSwap(), 2 );
			PendingOrders[curPendingOrder][9] = DoubleToStr( OrderProfit(), 2 );
			PendingOrders[curPendingOrder][10] = OrderComment();

			curPendingOrder ++;
			if ( curMarketOrder + curPendingOrder >= TerminalRows ) { break; }
		}
	}

	//+------------------------------------------------------------------+
	//| Сортировка массивов ордеров
	//+------------------------------------------------------------------+
	string tmp[11];
	for ( int i = curMarketOrder - 1; i >= 0; i-- )
	{
		for ( int j = curMarketOrder - 1; j >= 0; j-- )
		{
			if ( StrToInteger( MarketOrders[i][0] ) > StrToInteger( MarketOrders[j][0] ) )
			{
				for ( int n = 0; n < 11; n ++ ) { tmp[n] = MarketOrders[i][n]; }
				for ( n = 0; n < 11; n ++ ) { MarketOrders[i][n] = MarketOrders[j][n]; }
				for ( n = 0; n < 11; n ++ ) { MarketOrders[j][n] = tmp[n]; }
			}
		}
	}
	for ( i = curPendingOrder - 1; i >= 0; i-- )
	{
		for ( j = curPendingOrder - 1; j >= 0; j-- )
		{
			if ( StrToInteger( PendingOrders[i][0] ) > StrToInteger( PendingOrders[j][0] ) )
			{
				for ( n = 0; n < 11; n ++ ) { tmp[n] = PendingOrders[i][n]; }
				for ( n = 0; n < 11; n ++ ) { PendingOrders[i][n] = PendingOrders[j][n]; }
				for ( n = 0; n < 11; n ++ ) { PendingOrders[j][n] = tmp[n]; }
			}
		}
	}

	bool SummLineOK = false;
	color tmp_MainColor, tmp_SLColor, tmp_TPColor, tmp_OPColor;
	for ( i = 0; i < TerminalRows; i ++ )
	{
		if ( i < curMarketOrder )
		{
			if ( MarketOrders[i][2] == "Buy" )
			{
				tmp_MainColor = BuyColor;

				if ( StrToDouble( MarketOrders[i][5] ) > 0 &&  NormalizeDouble( SignalPoints*Point - ( StrToDouble( MarketOrders[i][7] ) - StrToDouble( MarketOrders[i][5] ) ), Digits ) >= 0.0 )
				{ tmp_SLColor = BuySLColor; }
				else
				{ tmp_SLColor = BuyColor; }

				if ( StrToDouble( MarketOrders[i][6] ) > 0 && NormalizeDouble( SignalPoints*Point - ( StrToDouble( MarketOrders[i][6] ) - StrToDouble( MarketOrders[i][7] ) ), Digits ) >= 0.0 )
				{ tmp_TPColor = BuyTPColor; }
				else
				{ tmp_TPColor = BuyColor; }
			}
			else
			{
				tmp_MainColor = SellColor;

				if ( StrToDouble( MarketOrders[i][5] ) > 0 &&  NormalizeDouble( SignalPoints*Point - ( StrToDouble( MarketOrders[i][5] ) - StrToDouble( MarketOrders[i][7] ) ), Digits ) >= 0.0 )
				{ tmp_SLColor = SellSLColor; }
				else
				{ tmp_SLColor = SellColor; }

				if ( StrToDouble( MarketOrders[i][6] ) > 0 && NormalizeDouble( SignalPoints*Point - ( StrToDouble( MarketOrders[i][7] ) - StrToDouble( MarketOrders[i][6] ) ), Digits ) >= 0.0 )
				{ tmp_TPColor = SellTPColor; }
				else
				{ tmp_TPColor = SellColor; }
			}

			SetText( "Ticket_" 		+ i, MarketOrders[i][0]		, tmp_MainColor );
			SetText( "OpenTime_" 	+ i, MarketOrders[i][1]		, tmp_MainColor );
			SetText( "Type_" 			+ i, MarketOrders[i][2]		, tmp_MainColor );
			SetText( "Lots_" 			+ i, MarketOrders[i][3]		, tmp_MainColor );
			SetText( "OpenPrice_" 	+ i, MarketOrders[i][4]		, tmp_MainColor );
			SetText( "StopLoss_" 	+ i, MarketOrders[i][5]		, tmp_SLColor );
			SetText( "TakeProfit_" 	+ i, MarketOrders[i][6]		, tmp_TPColor );
			SetText( "CurPrice_" 	+ i, MarketOrders[i][7]		, tmp_MainColor );
			SetText( "Swap_" 			+ i, MarketOrders[i][8]		, tmp_MainColor );
			SetText( "Profit_" 		+ i, MarketOrders[i][9]		, tmp_MainColor );
			SetText( "Comment_" 		+ i, MarketOrders[i][10]	, tmp_MainColor );
		}
		else
		{
			if ( !SummLineOK )
			{
				string tmp_margin = StringConcatenate( "Margin: ", DoubleToStr( AccountMargin(), 2 ) );
				string tmp_marginLevel = "";
				if ( AccountMargin() > 0 )
				{
					tmp_marginLevel = StringConcatenate( "  MarginLevel: ", DoubleToStr( AccountEquity()/AccountMargin()*100, 2 ), "%" );
				}
				SetText( "Ticket_" 		+ i, StringConcatenate( "Balance: ", DoubleToStr( AccountBalance(), 2 ), "  Equity: ", DoubleToStr( AccountEquity(), 2 ) ), MainColor );
				SetText( "OpenTime_" 	+ i );
				SetText( "Type_" 			+ i );
				SetText( "Lots_" 			+ i, StringConcatenate( tmp_margin, "  FreeMargin: ", DoubleToStr( AccountFreeMargin(), 2 ), tmp_marginLevel ), MainColor );
				SetText( "OpenPrice_" 	+ i );
				SetText( "StopLoss_" 	+ i );
				SetText( "TakeProfit_" 	+ i );
				SetText( "CurPrice_" 	+ i );
				SetText( "Swap_" 			+ i );
				SetText( "Profit_" 		+ i, DoubleToStr( SummProfit, 2 ), MainColor );
				SetText( "Comment_" 		+ i );
				i ++;
				SummLineOK = true;
			}

			if ( i <= curMarketOrder + curPendingOrder )
			{
				if ( PendingOrders[i-curMarketOrder-1][2] == "BuyLimit" || PendingOrders[i-curMarketOrder-1][2] == "BuyStop" )
				{
					tmp_MainColor = BuyColor;

					if ( NormalizeDouble( SignalPoints*Point - MathAbs( StrToDouble( PendingOrders[i-curMarketOrder-1][4] ) - StrToDouble( PendingOrders[i-curMarketOrder-1][7] ) ), Digits ) >= 0.0 )
					{ tmp_OPColor = BuyOPColor; }
					else
					{ tmp_OPColor = BuyColor; }
				}
				else
				{
					tmp_MainColor = SellColor;

					if ( NormalizeDouble( SignalPoints*Point - MathAbs( StrToDouble( PendingOrders[i-curMarketOrder-1][4] ) - StrToDouble( PendingOrders[i-curMarketOrder-1][7] ) ), Digits ) >= 0.0 )
					{ tmp_OPColor = SellOPColor; }
					else
					{ tmp_OPColor = SellColor; }
				}

				SetText( "Ticket_" 		+ i, PendingOrders[i-curMarketOrder-1][0], tmp_MainColor );
				SetText( "OpenTime_" 	+ i, PendingOrders[i-curMarketOrder-1][1], tmp_MainColor );
				SetText( "Type_" 			+ i, PendingOrders[i-curMarketOrder-1][2], tmp_MainColor );
				SetText( "Lots_" 			+ i, PendingOrders[i-curMarketOrder-1][3], tmp_MainColor );
				SetText( "OpenPrice_" 	+ i, PendingOrders[i-curMarketOrder-1][4], tmp_OPColor	);
				SetText( "StopLoss_" 	+ i, PendingOrders[i-curMarketOrder-1][5], tmp_MainColor );
				SetText( "TakeProfit_" 	+ i, PendingOrders[i-curMarketOrder-1][6], tmp_MainColor );
				SetText( "CurPrice_" 	+ i, PendingOrders[i-curMarketOrder-1][7], tmp_MainColor );
				SetText( "Swap_" 			+ i, PendingOrders[i-curMarketOrder-1][8], tmp_MainColor );
				SetText( "Profit_" 		+ i, PendingOrders[i-curMarketOrder-1][9], tmp_MainColor );
				SetText( "Comment_" 		+ i, PendingOrders[i-curMarketOrder-1][10],tmp_MainColor );
			}
			else
			{
				SetText( "Ticket_" 		+ i );
				SetText( "OpenTime_" 	+ i );
				SetText( "Type_" 			+ i );
				SetText( "Lots_" 			+ i );
				SetText( "OpenPrice_" 	+ i );
				SetText( "StopLoss_" 	+ i );
				SetText( "TakeProfit_" 	+ i );
				SetText( "CurPrice_" 	+ i );
				SetText( "Swap_" 			+ i );
				SetText( "Profit_" 		+ i );
				SetText( "Comment_" 		+ i );
			}
		}
	}
	ObjectsRedraw();
	return(0);
}

void vHistoryInit()
{
	if ( HistoryRows <= 0 ) { return(0); }

	vHistory_win = WindowFind( "vHistory" );
	if ( IsTesting() ) { vHistory_win = 2; }
	if ( vHistory_win < 0 ) { return(-1); }

	int vshift = 13, shift1 = 3, shift2 = 60, shift3 = 160, shift4 = 220, shift5 = 260, shift6 = 325, shift7 = 385, shift8 = 445, shift9 = 545, shift10 = 610, shift11 = 665, shift12 = 720;
	if ( BigText )
	{
		fontsize = 9; vshift = 15; shift1 = 3; shift2 = 70; shift3 = 185; shift4 = 255; shift5 = 305; shift6 = 380; shift7 = 450; shift8 = 520; shift9 = 635; shift10 = 710; shift11 = 775; shift12 = 840;
	}

	vLabel( vHistory_win, "vhTicket_Head"		, shift1	, vshift ); SetText( "vhTicket_Head"		, "Ticket"		, MainColor );
	vLabel( vHistory_win, "vhOpenTime_Head"	, shift2	, vshift ); SetText( "vhOpenTime_Head"		, "OpenTime"	, MainColor );
	vLabel( vHistory_win, "vhType_Head"			, shift3	, vshift ); SetText( "vhType_Head"			, "Type"			, MainColor );
	vLabel( vHistory_win, "vhLots_Head"			, shift4	, vshift ); SetText( "vhLots_Head"			, "Lots"			, MainColor );
	vLabel( vHistory_win, "vhOpenPrice_Head"	, shift5	, vshift ); SetText( "vhOpenPrice_Head"	, "OpenPrice"	, MainColor );
	vLabel( vHistory_win, "vhStopLoss_Head"	, shift6	, vshift ); SetText( "vhStopLoss_Head"		, "StopLoss"	, MainColor );
	vLabel( vHistory_win, "vhTakeProfit_Head"	, shift7	, vshift ); SetText( "vhTakeProfit_Head"	, "TakeProfit"	, MainColor );
	vLabel( vHistory_win, "vhCloseTime_Head"	, shift8	, vshift ); SetText( "vhCloseTime_Head"	, "CloseTime"	, MainColor );
	vLabel( vHistory_win, "vhClosePrice_Head"	, shift9	, vshift ); SetText( "vhClosePrice_Head"	, "ClosePrice"	, MainColor );
	vLabel( vHistory_win, "vhSwap_Head"			, shift10, vshift ); SetText( "vhSwap_Head"			, "Swap"			, MainColor );
	vLabel( vHistory_win, "vhProfit_Head"		, shift11, vshift ); SetText( "vhProfit_Head"		, "Profit"		, MainColor );
	vLabel( vHistory_win, "vhComment_Head"		, shift12, vshift ); SetText( "vhComment_Head"		, "Comment"		, MainColor );

	for ( int i = 0; i < HistoryRows; i ++ )
	{
		vLabel( vHistory_win, "vhTicket_" 		+ i, shift1 , vshift*(i+2) );
		vLabel( vHistory_win, "vhOpenTime_" 	+ i, shift2 , vshift*(i+2) );
		vLabel( vHistory_win, "vhType_" 			+ i, shift3 , vshift*(i+2) );
		vLabel( vHistory_win, "vhLots_"			+ i, shift4 , vshift*(i+2) );
		vLabel( vHistory_win, "vhOpenPrice_" 	+ i, shift5 , vshift*(i+2) );
		vLabel( vHistory_win, "vhStopLoss_" 	+ i, shift6 , vshift*(i+2) );
		vLabel( vHistory_win, "vhTakeProfit_"	+ i, shift7 , vshift*(i+2) );
		vLabel( vHistory_win, "vhCloseTime_" 	+ i, shift8 , vshift*(i+2) );
		vLabel( vHistory_win, "vhClosePrice_" 	+ i, shift9 , vshift*(i+2) );
		vLabel( vHistory_win, "vhSwap_" 			+ i, shift10, vshift*(i+2) );
		vLabel( vHistory_win, "vhProfit_" 		+ i, shift11, vshift*(i+2) );
		vLabel( vHistory_win, "vhComment_" 		+ i, shift12, vshift*(i+2) );
	}
}
void vHistoryRefresh()
{
	if ( HistoryRows <= 0 ) { return(0); }
	if ( vHistory_win < 0 ) { return(-1); }

	int _GetLastError, nowHistoryTotal = HistoryTotal(), curRowHistory = 0, digits;
	color tmp_Color, slColor, tpColor;

	if ( preHistoryTotal == nowHistoryTotal ) { return(0); }
	preHistoryTotal = nowHistoryTotal;

	for ( int z = nowHistoryTotal - 1; z >= 0; z -- )
	{
		if ( !OrderSelect( z, SELECT_BY_POS, MODE_HISTORY ) )
		{
			_GetLastError = GetLastError();
			Print( "OrderSelect( ", z, ", SELECT_BY_POS, MODE_HISTORY ) - Error #", _GetLastError );
			continue;
		}

		if ( !ShowCancelled )
		{
			if ( StringFind( OrderComment(), "cancelled" ) >= 0 ) { continue; }
		}
		if ( !ShowExpired )
		{
			if ( StringFind( OrderComment(), "expiration" ) >= 0 ) { continue; }
		}

		if ( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP )
		{
			tmp_Color = BuyColor;
			if ( OrderClosePrice() - OrderStopLoss() 		== 0.0 ) { slColor = BuySLColor; } else { slColor = BuyColor; }
			if ( OrderClosePrice() - OrderTakeProfit() 	== 0.0 ) { tpColor = BuyTPColor; } else { tpColor = BuyColor; }
		}
		else
		{
			tmp_Color = SellColor;
			if ( OrderClosePrice() - OrderStopLoss() 		== 0.0 ) { slColor = SellSLColor; } else { slColor = SellColor; }
			if ( OrderClosePrice() - OrderTakeProfit() 	== 0.0 ) { tpColor = SellTPColor; } else { tpColor = SellColor; }
		}

		digits = MarketInfo( OrderSymbol(), MODE_DIGITS );

		SetText( "vhTicket_" 		+ curRowHistory, OrderTicket()										, tmp_Color );
		SetText( "vhOpenTime_" 		+ curRowHistory, TimeToStr( OrderOpenTime() )					, tmp_Color );
		SetText( "vhType_" 			+ curRowHistory, vOrderType( OrderType() )						, tmp_Color );
		SetText( "vhLots_" 			+ curRowHistory, DoubleToStr( OrderLots(), 1 )					, tmp_Color );
		SetText( "vhOpenPrice_" 	+ curRowHistory, DoubleToStr( OrderOpenPrice(), digits )		, tmp_Color );
		SetText( "vhStopLoss_" 		+ curRowHistory, DoubleToStr( OrderStopLoss(), digits )		, slColor	);
		SetText( "vhTakeProfit_" 	+ curRowHistory, DoubleToStr( OrderTakeProfit(), digits )	, tpColor	);
		SetText( "vhCloseTime_" 	+ curRowHistory, TimeToStr( OrderCloseTime() )					, tmp_Color );
		SetText( "vhClosePrice_" 	+ curRowHistory, DoubleToStr( OrderClosePrice(), digits )	, tmp_Color );
		SetText( "vhSwap_" 			+ curRowHistory, DoubleToStr( OrderSwap(), 2 )					, tmp_Color );
		SetText( "vhProfit_" 		+ curRowHistory, DoubleToStr( OrderProfit(), 2 )				, tmp_Color );
		SetText( "vhComment_" 		+ curRowHistory, OrderComment()										, tmp_Color );

		curRowHistory ++;
		if ( curRowHistory >= HistoryRows ) { break; }
	}
}


//+------------------------------------------------------------------+
// Создание объекта "Текстовая метка" с именем _LabelName в окне win.
// Координаты: х = _LabelXDistance, у = _LabelYDistance, угол - _LabelCorner.
//+------------------------------------------------------------------+
void vLabel ( int win, string _LabelName, int _LabelXDistance, int _LabelYDistance, int _LabelCorner = 0 )
{
	int _GetLastError;

	ObjectDelete( _LabelName );

	if ( !ObjectCreate( _LabelName, OBJ_LABEL, win, 0, 0 ) )
	{
		_GetLastError = GetLastError();
		if ( _GetLastError != 4200 )
		{
			//Print( "ObjectCreate( \"", _LabelName, "\", OBJ_LABEL,0,0,0 ) - Error #", _GetLastError );
			return(-1);
		}
	}
	if ( !ObjectSet( _LabelName, OBJPROP_CORNER, _LabelCorner ) )
	{
		_GetLastError = GetLastError();
		//Print( "ObjectSet( \"", _LabelName, "\", OBJPROP_CORNER, ", _LabelCorner, " ) - Error #", _GetLastError );
	}
	if ( !ObjectSet( _LabelName, OBJPROP_XDISTANCE, _LabelXDistance ) )
	{
		_GetLastError = GetLastError();
		//Print( "ObjectSet( \"", _LabelName, "\", OBJPROP_XDISTANCE, ", _LabelXDistance, " ) - Error #", _GetLastError );
	}
	if ( !ObjectSet( _LabelName, OBJPROP_YDISTANCE, _LabelYDistance ) )
	{
		_GetLastError = GetLastError();
		//Print( "ObjectSet( \"", _LabelName, "\", OBJPROP_YDISTANCE, ", _LabelYDistance, " ) - Error #", _GetLastError );
	}
	if ( !ObjectSetText ( _LabelName, "", 8 ) )
	{
		_GetLastError = GetLastError();
		//Print( "ObjectSetText( \"", _LabelName, "\", \"\", 8 ) - Error #", _GetLastError );
	}
}

//+------------------------------------------------------------------+
// Присвоение текста _LabelText объекту "Текстовая метка" с именем _LabelName.
//+------------------------------------------------------------------+
void SetText( string _LabelName, string _LabelText = "", color _LabelColor = Black )
{
	if ( !ObjectSetText( _LabelName, _LabelText, fontsize, "Arial", _LabelColor ) )
	{
		int _GetLastError = GetLastError();
		//Print( "ObjectSetText( \"", _LabelName, "\", \"", _LabelText, "\", ", fontsize, "\"Arial\", ", _LabelColor, " ) - Error #", _GetLastError );
	}
}

//+------------------------------------------------------------------+
// возвращает OrderType в виде текста
//+------------------------------------------------------------------+
string vOrderType( int intOrderType )
{
	switch ( intOrderType )
	{
		case OP_BUY:			return("Buy"					);
		case OP_SELL:			return("Sell"					);
		case OP_BUYLIMIT:		return("BuyLimit"				);
		case OP_BUYSTOP:		return("BuyStop"				);
		case OP_SELLLIMIT:	return("SellLimit"			);
		case OP_SELLSTOP:		return("SellStop"				);
		default:					return("UnknownOrderType"	);
	}
}

