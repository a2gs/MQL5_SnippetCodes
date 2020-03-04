#property copyright "André Augusto Giannotti Scotá"
#property link "https://sites.google.com/view/a2gs"
#property version "1.0"
#property description "A transaction (trade transaction / request / result) and account (info / orders / positions / deals) dump"

//#include <Trade\Trade.mqh>

input bool DUMP_ORDERS = true; // Dump Orders
input bool DUMP_POSITIONS = true; // Dump Positions
input bool DUMP_DEALS = false; // Dump Deals
input bool DUMP_TRADE = true; // Dump Trade Transaction
input bool DUMP_ALL_FIELDS = true; // Dump ALL Trade fields

bool reload = true;

int OnInit()
{
   if(reload == true){
      printf("=== USER ====================");
      printf("Login......................................: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
      printf("User.......................................: " + AccountInfoString(ACCOUNT_NAME) + " - " + AccountInfoString(ACCOUNT_COMPANY));
      printf("Server.....................................: " + AccountInfoString(ACCOUNT_SERVER));
      printf("Account....................................: " + (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL ? "REAL" : "DEMO/CONTEST"));
      printf("Leverage...................................: " + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)));
      printf("Max number of active pending orders........: " + IntegerToString(AccountInfoInteger(ACCOUNT_LIMIT_ORDERS)));
      printf("Mode for setting the minimal allowed margin: " + (AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE) == ACCOUNT_STOPOUT_MODE_PERCENT ? "Account stop out mode in percents" : "Account stop out mode in money"));
      printf("Margin calculation mode....................: " + ENUM_ACCOUNT_MARGIN_MODE_message((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)));
      printf("Allowed trade for the current account......: " + (AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) == true ? "YES" : "NO"));
      printf("Allowed trade for an Expert Advisor........: " + (AccountInfoInteger(ACCOUNT_TRADE_EXPERT) == true ? "YES" : "NO"));
      printf("Positions can only be closed by FIFO rule..: " + (AccountInfoInteger(ACCOUNT_FIFO_CLOSE) == true ? "YES" : "NO"));
      printf("Chart......................................: " + Symbol() + "/" + ENUM_TIMEFRAMES_message(Period()));
      printf("N. of decimal in the account currency......: " + IntegerToString(AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS)));
   
      string currency = AccountInfoString(ACCOUNT_CURRENCY);
      printf("=== VALUES ====================");
      printf("Balance..............: %f %s", AccountInfoDouble(ACCOUNT_BALANCE), currency);
      printf("Credit...............: %f %s", AccountInfoDouble(ACCOUNT_CREDIT), currency);
      printf("Profit...............: %f %s", AccountInfoDouble(ACCOUNT_PROFIT), currency);
      printf("Equity...............: %f %s", AccountInfoDouble(ACCOUNT_EQUITY), currency);
      printf("Margin...............: %f %s", AccountInfoDouble(ACCOUNT_MARGIN), currency);
      printf("Free margin..........: %f %s", AccountInfoDouble(ACCOUNT_MARGIN_FREE), currency);
      printf("Account margin level.: %f%%" , AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
      printf("Margin call level....: %f%%" , AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
      printf("Margin stop out level: %f%%" , AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
      printf("Initial margin.......: %f %s", AccountInfoDouble(ACCOUNT_MARGIN_INITIAL), currency);
      printf("Assets...............: %f %s", AccountInfoDouble(ACCOUNT_ASSETS), currency);
      printf("Liabilities..........: %f %s", AccountInfoDouble(ACCOUNT_LIABILITIES), currency);
      printf("Blocked commission...: %f %s", AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED), currency);
      
      printf("=== PENDING ORDERS (book) [%s] / DEALS [%s] / POSITIONS [%s] ====================",
             TrueFalseYESNO(DUMP_ORDERS), TrueFalseYESNO(DUMP_POSITIONS), TrueFalseYESNO(DUMP_DEALS));

      if(DUMP_ORDERS    == true) listOrders();

      printf("");
      if(DUMP_POSITIONS == true) listPositions();

      printf("");
      if(DUMP_DEALS     == true) listDeals();

      reload = false;
   }

   return(INIT_SUCCEEDED);
}

string TrueFalseYESNO(bool f)
{
   string fs = "YES";

   if(f == false) fs = "NO";
   
   return(fs);
}

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{

   if(DUMP_TRADE == true){
      printf("=== OnTradeTransaction ============================");
      dumpTradeTransactionToLog(trans);
      dumpTradeRequestToLog(request);
      dumpTradeResultToLog(result);
      printf(">>> Equity...............: %f", AccountInfoDouble(ACCOUNT_EQUITY));
   }
}

void listOrders(void)
{
   ulong ticket;
   uint  total;

   total = OrdersTotal();
   printf("Number of current/pending orders: [%d]", total);
   
   for(uint i=0; i < total; i++){
      if((ticket = OrderGetTicket(i)) > 0){
         printf("%d) Ticket: [%lu]", i+1, OrderGetInteger(ORDER_TICKET));
         printf("   Symbol: [%s]", OrderGetString(ORDER_SYMBOL));
         printf("   Type: [%s]", ENUM_ORDER_TYPE_message((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)));
         printf("   State: [%s]", ENUM_ORDER_STATE_message((ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE)));
         printf("   Setup time: [%s]", TimeToString(OrderGetInteger(ORDER_TIME_SETUP), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         printf("   Expiration time: [%s]", TimeToString(OrderGetInteger(ORDER_TIME_EXPIRATION), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         printf("   Execution or cancellation time: [%s]", TimeToString(OrderGetInteger(ORDER_TIME_DONE), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         printf("   Initial volume: [%f]", OrderGetDouble(ORDER_VOLUME_INITIAL));
         printf("   Current volume: [%f]", OrderGetDouble(ORDER_VOLUME_CURRENT));
         printf("   Price specified in the order: [%f]", OrderGetDouble(ORDER_PRICE_OPEN));
         printf("   Stop Loss value: [%f]", OrderGetDouble(ORDER_SL));
         printf("   Take Profit value: [%f]", OrderGetDouble(ORDER_TP));
         printf("   The current price of the order symbol: [%f]", OrderGetDouble(ORDER_PRICE_CURRENT));
         printf("   The Limit order price for the StopLimit order: [%f]", OrderGetDouble(ORDER_PRICE_STOPLIMIT));
         printf("   The time of placing an order for execution in milliseconds since 01.01.1970: [%lu]", OrderGetInteger(ORDER_TIME_SETUP_MSC));
         printf("   Order execution/cancellation time in milliseconds since 01.01.1970: [%lu]", OrderGetInteger(ORDER_TIME_DONE_MSC));
         printf("   Filling type: [%s]", ENUM_ORDER_TYPE_FILLING_message((ENUM_ORDER_TYPE_FILLING)OrderGetInteger(ORDER_TYPE_FILLING)));
         printf("   Lifetime: [%s]", ENUM_ORDER_TYPE_TIME_message((ENUM_ORDER_TYPE_TIME)OrderGetInteger(ORDER_TYPE_TIME)));
         printf("   Comment: [%s]", OrderGetString(ORDER_COMMENT));
         printf("   Identifier in an external trading system (on the Exchange): [%s]", OrderGetString(ORDER_EXTERNAL_ID));
         printf("   ID of an EA that has placed the order: [%lu]", OrderGetInteger(ORDER_MAGIC));
         printf("   The reason or source for placing an order: [%s]", ENUM_ORDER_REASON_message((ENUM_ORDER_REASON)OrderGetInteger(ORDER_REASON)));
         printf("   Position identifier that is set to an order as soon as it is executed: [%lu]", OrderGetInteger(ORDER_POSITION_ID));
         printf("   Identifier of an opposite position used for closing by order ORDER_TYPE_CLOSE_BY: [%lu]", OrderGetInteger(ORDER_POSITION_BY_ID));
      }
   }
}

void listPositions(void)
{
   ulong ticket;
   uint  total;

   total = PositionsTotal();
   printf("Number of open positions: [%d]", total);
   
   for(uint i=0; i < total; i++){
      if((ticket = PositionGetTicket(i)) > 0){
         printf("%d) Ticket: [%lu]", i+1, PositionGetInteger(POSITION_TICKET));
         printf("   Symbol: [%s]", PositionGetString(POSITION_SYMBOL));
         printf("   Open time: [%lu]", TimeToString(PositionGetInteger(POSITION_TIME), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         printf("   Opening time in milliseconds since 01.01.1970: [%lu]", PositionGetInteger(POSITION_TIME_MSC));
         printf("   Changing time: [%lu]", TimeToString(PositionGetInteger(POSITION_TIME_UPDATE), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         printf("   Changing time in milliseconds since 01.01.1970: [%lu]", PositionGetInteger(POSITION_TIME_UPDATE_MSC));
         printf("   Type: [%s]", ENUM_POSITION_TYPE_message((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)));
         printf("   Volume: [%f]", PositionGetDouble(POSITION_VOLUME));
         printf("   Open price: [%f]", PositionGetDouble(POSITION_PRICE_OPEN));
         printf("   Stop Loss level of opened: [%f]", PositionGetDouble(POSITION_SL));
         printf("   Take Profit level of opened: [%f]", PositionGetDouble(POSITION_TP));
         printf("   Current price symbol: [%f]", PositionGetDouble(POSITION_PRICE_CURRENT));
         printf("   Cumulative swap: [%f]", PositionGetDouble(POSITION_SWAP));
         printf("   Current profit: [%f]", PositionGetDouble(POSITION_PROFIT));
         printf("   Magic number: [%lu]", PositionGetInteger(POSITION_MAGIC));
         printf("   Position identifier: [%lu]", PositionGetInteger(POSITION_IDENTIFIER));
         printf("   The reason for opening: [%s]", ENUM_POSITION_REASON_message((ENUM_POSITION_REASON)PositionGetInteger(POSITION_REASON)));
         printf("   Comment: [%s]", PositionGetString(POSITION_COMMENT));
         printf("   Identifier in an external trading system (on the Exchange): [%s]", PositionGetString(POSITION_EXTERNAL_ID));
      }
   }
}

void listDeals(void)
{
   ulong ticket;
   uint  total;
   
   HistorySelect(0,TimeCurrent());

   total = HistoryDealsTotal();
   printf("Number of deals: [%d]", total);
   
   for(uint i=0; i < total; i++){
      if((ticket = HistoryDealGetTicket(i)) > 0){
         printf("%d) Ticket: [%lu]", i+1, HistoryDealGetInteger(ticket, DEAL_TICKET));
         printf("   Symbol: [%s]", HistoryDealGetString(ticket, DEAL_SYMBOL));
         printf("   Order number: [%lu]", HistoryDealGetInteger(ticket, DEAL_ORDER));
         printf("   Time: [%s]", TimeToString(HistoryDealGetInteger(ticket, DEAL_TIME), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
         printf("   The time of a deal execution in milliseconds since 01.01.1970: [%lu]", HistoryDealGetInteger(ticket, DEAL_TIME_MSC));
         printf("   Type: [%s]", ENUM_DEAL_TYPE_message((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE)));
         printf("   Volume: [%f]", HistoryDealGetDouble(ticket, DEAL_VOLUME));
         printf("   Price: [%f]", HistoryDealGetDouble(ticket, DEAL_PRICE));
         printf("   Commission: [%f]", HistoryDealGetDouble(ticket, DEAL_COMMISSION));
         printf("   Cumulative swap on close: [%f]", HistoryDealGetDouble(ticket, DEAL_SWAP));
         printf("   Profit: [%f]", HistoryDealGetDouble(ticket, DEAL_PROFIT));
         /*printf("   Fee: [%f]", HistoryDealGetDouble(ticket, DEAL_FEE));*/
         printf("   Entry: [%s]", ENUM_DEAL_ENTRY_message((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY)));
         printf("   Deal magic number (see ORDER_MAGIC): [%lu]", HistoryDealGetInteger(ticket, DEAL_MAGIC));
         printf("   The reason or source for deal execution: [%s]", ENUM_DEAL_REASON_message((ENUM_DEAL_REASON)HistoryDealGetInteger(ticket, DEAL_REASON)));
         printf("   Identifier of a position: [%lu]", HistoryDealGetInteger(ticket, DEAL_POSITION_ID));
         printf("   Comment: [%s]", HistoryDealGetString(ticket, DEAL_COMMENT));
         printf("   Identifier in an external trading system (on the Exchange): [%s]", HistoryDealGetString(ticket, DEAL_EXTERNAL_ID));
      }
   }
}

void OnDeinit(const int reason)
{
   if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS || reason == REASON_TEMPLATE){
      reload = false;
      return;
   }
   
   reload = true;
}

void OnChartEvent(const int EventID,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

   if(EventID == CHARTEVENT_KEYDOWN){
      int   opt;
      short KeyThatWasPressed = TranslateKey((int) lparam);
      
       switch(KeyThatWasPressed){
         case 'p':
            Print("****************************************************");
            Print("****************************************************");
            Print("****************************************************");
            Print("****************************************************");
            Print("****************************************************");
            Print("****************************************************");
            Print("****************************************************");
            Print("****************************************************");
            break;
         
         default:
         break;
      }
   }
   
   return;
}
  
string ENUM_POSITION_TYPE_message(ENUM_POSITION_TYPE pt)
{
   string ret;
   
   switch(pt){
      case POSITION_TYPE_BUY:
         ret = "POSITION_TYPE_BUY - Buy";
         break;
      
      case POSITION_TYPE_SELL:
         ret = "POSITION_TYPE_SELL - Sell";
         break;
      
      default:
        ret = "UNDEF - UNDEF";
   }
   
   return(ret);
}
  
string ENUM_ORDER_TYPE_message(ENUM_ORDER_TYPE ot)
{
	string ret;

	switch(ot){
		case ORDER_TYPE_BUY:
			ret = "ORDER_TYPE_BUY - Market Buy order";
			break;

		case ORDER_TYPE_SELL:
			ret = "ORDER_TYPE_SELL - Market Sell order";
			break;

		case ORDER_TYPE_BUY_LIMIT:
			ret = "ORDER_TYPE_BUY_LIMIT - Buy Limit pending order";
			break;

		case ORDER_TYPE_SELL_LIMIT:
			ret = "ORDER_TYPE_SELL_LIMIT - Sell Limit pending order";
			break;

		case ORDER_TYPE_BUY_STOP:
			ret = "ORDER_TYPE_BUY_STOP - Buy Stop pending order";
			break;

		case ORDER_TYPE_SELL_STOP:
			ret = "ORDER_TYPE_SELL_STOP - Sell Stop pending order";
			break;

		case ORDER_TYPE_BUY_STOP_LIMIT:
			ret = "ORDER_TYPE_BUY_STOP_LIMIT - Upon reaching the order price, a pending Buy Limit order is placed at the StopLimit price";
			break;

		case ORDER_TYPE_SELL_STOP_LIMIT:
			ret = "ORDER_TYPE_SELL_STOP_LIMIT - Upon reaching the order price, a pending Sell Limit order is placed at the StopLimit price";
			break;

		case ORDER_TYPE_CLOSE_BY:
			ret = "ORDER_TYPE_CLOSE_BY - Order to close a position by an opposite one";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_ORDER_STATE_message(ENUM_ORDER_STATE os)
{
	string ret;

	switch(os){
		case ORDER_STATE_STARTED:
			ret = "ORDER_STATE_STARTED - Order checked, but not yet accepted by broker";
			break;

		case ORDER_STATE_PLACED:
			ret = "ORDER_STATE_PLACED - Order accepted";
			break;

		case ORDER_STATE_CANCELED:
			ret = "ORDER_STATE_CANCELED - Order canceled by client";
			break;

		case ORDER_STATE_PARTIAL:
			ret = "ORDER_STATE_PARTIAL - Order partially executed";
			break;

		case ORDER_STATE_FILLED:
			ret = "ORDER_STATE_FILLED - Order fully executed";
			break;

		case ORDER_STATE_REJECTED:
			ret = "ORDER_STATE_REJECTED - Order rejected";
			break;

		case ORDER_STATE_EXPIRED:
			ret = "ORDER_STATE_EXPIRED - Order expired";
			break;

		case ORDER_STATE_REQUEST_ADD:
			ret = "ORDER_STATE_REQUEST_ADD - Order is being registered (placing to the trading system)";
			break;

		case ORDER_STATE_REQUEST_MODIFY:
			ret = "ORDER_STATE_REQUEST_MODIFY - Order is being modified (changing its parameters)";
			break;

		case ORDER_STATE_REQUEST_CANCEL:
			ret = "ORDER_STATE_REQUEST_CANCEL - Order is being deleted (deleting from the trading system)";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_ORDER_TYPE_FILLING_message(ENUM_ORDER_TYPE_FILLING otf)
{
	string ret;

	switch(otf){
		case ORDER_FILLING_FOK:
			ret = "ORDER_FILLING_FOK - This filling policy means that an order can be filled only in the specified amount. If the necessary amount of a financial instrument is currently unavailable in the market, the order will not be executed. The required volume can be filled using several offers available on the market at the moment.";
			break;

		case ORDER_FILLING_IOC:
			ret = "ORDER_FILLING_IOC - This mode means that a trader agrees to execute a deal with the volume maximally available in the market within that indicated in the order. In case the the entire volume of an order cannot be filled, the available volume of it will be filled, and the remaining volume will be canceled.";
			break;

		case ORDER_FILLING_RETURN:
			ret = "ORDER_FILLING_RETURN - This policy is used only for market orders (ORDER_TYPE_BUY and ORDER_TYPE_SELL), limit and stop limit orders (ORDER_TYPE_BUY_LIMIT, ORDER_TYPE_SELL_LIMIT, ORDER_TYPE_BUY_STOP_LIMIT and ORDER_TYPE_SELL_STOP_LIMIT ) and only for the symbols with Market or Exchange execution. In case of partial filling a market or limit order with remaining volume is not canceled but processed further. For the activation of the ORDER_TYPE_BUY_STOP_LIMIT and ORDER_TYPE_SELL_STOP_LIMIT orders, a corresponding limit order ORDER_TYPE_BUY_LIMIT/ORDER_TYPE_SELL_LIMIT with the ORDER_FILLING_RETURN execution type is created.";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_ORDER_TYPE_TIME_message(ENUM_ORDER_TYPE_TIME ott)
{
	string ret;

	switch(ott){
		case ORDER_TIME_GTC:
			ret = "ORDER_TIME_GTC - Good till cancel order";
			break;

		case ORDER_TIME_DAY:
			ret = "ORDER_TIME_DAY - Good till current trade day order";
			break;

		case ORDER_TIME_SPECIFIED:
			ret = "ORDER_TIME_SPECIFIED - Good till expired order";
			break;

		case ORDER_TIME_SPECIFIED_DAY:
			ret = "ORDER_TIME_SPECIFIED_DAY - The order will be effective till 23:59:59 of the specified day. If this time is outside a trading session, the order expires in the nearest trading time.";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_ORDER_REASON_message(ENUM_ORDER_REASON or)
{
	string ret;

	switch(or){
		case ORDER_REASON_CLIENT:
			ret = "ORDER_REASON_CLIENT - The order was placed from a desktop terminal";
			break;

		case ORDER_REASON_MOBILE:
			ret = "ORDER_REASON_MOBILE - The order was placed from a mobile application";
			break;

		case ORDER_REASON_WEB:
			ret = "ORDER_REASON_WEB - The order was placed from a web platform";
			break;

		case ORDER_REASON_EXPERT:
			ret = "ORDER_REASON_EXPERT - The order was placed from an MQL5-program, i.e. by an Expert Advisor or a script";
			break;

		case ORDER_REASON_SL:
			ret = "ORDER_REASON_SL - The order was placed as a result of Stop Loss activation";
			break;

		case ORDER_REASON_TP:
			ret = "ORDER_REASON_TP - The order was placed as a result of Take Profit activation";
			break;

		case ORDER_REASON_SO:
			ret = "ORDER_REASON_SO - The order was placed as a result of the Stop Out event";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_POSITION_REASON_message(ENUM_POSITION_REASON pr)
{
   string ret;
   
   switch(pr){
      case POSITION_REASON_CLIENT:
         ret = "POSITION_REASON_CLIENT - The position was opened as a result of activation of an order placed from a desktop terminal";
         break;
      
      case POSITION_REASON_MOBILE:
         ret = "POSITION_REASON_MOBILE - The position was opened as a result of activation of an order placed from a mobile application";
         break;
      
      case POSITION_REASON_WEB:
         ret = "POSITION_REASON_WEB - The position was opened as a result of activation of an order placed from the web platform";
         break;
      
      case POSITION_REASON_EXPERT:
         ret = "POSITION_REASON_EXPERT - The position was opened as a result of activation of an order placed from an MQL5 program, i.e. an Expert Advisor or a script";
         break;
      
      default:
         ret = "UNDEF - UNDEF";
   }

   return(ret);
}

string ENUM_TIMEFRAMES_message(ENUM_TIMEFRAMES tf)
{
   string ret;

	switch(tf){
		case PERIOD_CURRENT:
         ret = "Current timeframe";
			break;

		case PERIOD_M1:
			ret = "1min";
			break;

		case PERIOD_M2:
			ret = "2min";
			break;

		case PERIOD_M3:
			ret = "3min";
			break;

		case PERIOD_M4:
			ret = "4min";
			break;

		case PERIOD_M5:
			ret = "5min";
			break;

		case PERIOD_M6:
			ret = "6min";
			break;

		case PERIOD_M10:
			ret = "10min";
			break;

		case PERIOD_M12:
			ret = "12min";
			break;

		case PERIOD_M15:
			ret = "15min";
			break;

		case PERIOD_M20:
			ret = "20min";
			break;

		case PERIOD_M30:
			ret = "30min";
			break;

		case PERIOD_H1:
			ret = "1h";
			break;

		case PERIOD_H2:
			ret = "2h";
			break;

		case PERIOD_H3:
			ret = "3h";
			break;

		case PERIOD_H4:
			ret = "4h";
			break;

		case PERIOD_H6:
			ret = "6h";
			break;

		case PERIOD_H8:
			ret = "8h";
			break;

		case PERIOD_H12:
			ret = "12h";
			break;

		case PERIOD_D1:
			ret = "1D";
			break;

		case PERIOD_W1:
			ret = "1W";
			break;

		case PERIOD_MN1:
			ret = "1M";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_DEAL_TYPE_message(ENUM_DEAL_TYPE dt)
{
   string ret;
   
   switch(dt){
      case DEAL_TYPE_BUY:
         ret = "DEAL_TYPE_BUY - Buy";
         break;
      
      case DEAL_TYPE_SELL:
         ret = "DEAL_TYPE_SELL - Sell";
         break;
      
      case DEAL_TYPE_BALANCE:
         ret = "DEAL_TYPE_BALANCE - Balance";
         break;
      
      case DEAL_TYPE_CREDIT:
         ret = "DEAL_TYPE_CREDIT - Credit";
         break;
      
      case DEAL_TYPE_CHARGE:
         ret = "DEAL_TYPE_CHARGE - Additional charge";
         break;
      
      case DEAL_TYPE_CORRECTION:
         ret = "DEAL_TYPE_CORRECTION - Correction";
         break;
      
      case DEAL_TYPE_BONUS:
         ret = "DEAL_TYPE_BONUS - Bonus";
         break;
      
      case DEAL_TYPE_COMMISSION:
         ret = "DEAL_TYPE_COMMISSION - Additional commission";
         break;
      
      case DEAL_TYPE_COMMISSION_DAILY:
         ret = "DEAL_TYPE_COMMISSION_DAILY - Daily commission";
         break;
      
      case DEAL_TYPE_COMMISSION_MONTHLY:
         ret = "DEAL_TYPE_COMMISSION_MONTHLY - Monthly commission";
         break;
      
      case DEAL_TYPE_COMMISSION_AGENT_DAILY:
         ret = "DEAL_TYPE_COMMISSION_AGENT_DAILY - Daily agent commission";
         break;
      
      case DEAL_TYPE_COMMISSION_AGENT_MONTHLY:
         ret = "DEAL_TYPE_COMMISSION_AGENT_MONTHLY - Monthly agent commission";
         break;
      
      case DEAL_TYPE_INTEREST:
         ret = "DEAL_TYPE_INTEREST - Interest rate";
         break;
      
      case DEAL_TYPE_BUY_CANCELED:
         ret = "DEAL_TYPE_BUY_CANCELED - Canceled buy deal. There can be a situation when a previously executed buy deal is canceled. In this case, the type of the previously executed deal (DEAL_TYPE_BUY) is changed to DEAL_TYPE_BUY_CANCELED, and its profit/loss is zeroized. Previously obtained profit/loss is charged/withdrawn using a separated balance operation";
         break;
      
      case DEAL_TYPE_SELL_CANCELED:
         ret = "DEAL_TYPE_SELL_CANCELED - Canceled sell deal. There can be a situation when a previously executed sell deal is canceled. In this case, the type of the previously executed deal (DEAL_TYPE_SELL) is changed to DEAL_TYPE_SELL_CANCELED, and its profit/loss is zeroized. Previously obtained profit/loss is charged/withdrawn using a separated balance operation";
         break;
      
      case DEAL_DIVIDEND:
         ret = "DEAL_DIVIDEND - Dividend operations";
         break;
      
      case DEAL_DIVIDEND_FRANKED:
         ret = "DEAL_DIVIDEND_FRANKED - Franked (non-taxable) dividend operations";
         break;
      
      case DEAL_TAX:
         ret = "DEAL_TAX - Tax charges";
         break;
      
      default:
         ret = "UNDEF - UNDEF";
   }
   
   return(ret);
}

string ENUM_DEAL_REASON_message(ENUM_DEAL_REASON dr)
{
   string ret;
   
   switch(dr){
      case DEAL_REASON_CLIENT:
         ret = "DEAL_REASON_CLIENT - The deal was executed as a result of activation of an order placed from a desktop terminal";
         break;

      case DEAL_REASON_MOBILE:
         ret = "DEAL_REASON_MOBILE - The deal was executed as a result of activation of an order placed from a mobile application";
         break;

      case DEAL_REASON_WEB:
         ret = "DEAL_REASON_WEB - The deal was executed as a result of activation of an order placed from the web platform";
         break;

      case DEAL_REASON_EXPERT:
         ret = "DEAL_REASON_EXPERT - The deal was executed as a result of activation of an order placed from an MQL5 program, i.e. an Expert Advisor or a script";
         break;

      case DEAL_REASON_SL:
         ret = "DEAL_REASON_SL - The deal was executed as a result of Stop Loss activation";
         break;

      case DEAL_REASON_TP:
         ret = "DEAL_REASON_TP - The deal was executed as a result of Take Profit activation";
         break;
      
      case DEAL_REASON_SO:
         ret = "DEAL_REASON_SO - The deal was executed as a result of the Stop Out event";
         break;
      
      case DEAL_REASON_ROLLOVER:
         ret = "DEAL_REASON_ROLLOVER - The deal was executed due to a rollover";
         break;
      
      case DEAL_REASON_VMARGIN:
         ret = "DEAL_REASON_VMARGIN - The deal was executed after charging the variation margin";
         break;
      
      case DEAL_REASON_SPLIT:
         ret = "DEAL_REASON_SPLIT - The deal was executed after the split (price reduction) of an instrument, which had an open position during split announcement";
         break;
      
      default:
         ret = "UNDEF - UNDEF";
   }
   
   return(ret);
}

string ENUM_DEAL_ENTRY_message(ENUM_DEAL_ENTRY de)
{
   string ret;
   
   switch(de){
      case DEAL_ENTRY_IN:
         ret = "DEAL_ENTRY_IN - Entry in";
         break;
      
      case DEAL_ENTRY_OUT:
         ret = "DEAL_ENTRY_OUT - Entry out";
         break;
      
      case DEAL_ENTRY_INOUT:
         ret = "DEAL_ENTRY_INOUT - Reverse";
         break;
      
      case DEAL_ENTRY_OUT_BY:
         ret = "DEAL_ENTRY_OUT_BY - Close a position by an opposite one";
         break;

      default:
         ret = "UNDEF - UNDEF";
   }
   
   return(ret);
}


void dumpTradeTransactionToLog(const MqlTradeTransaction &trans)
{
   /* https://www.mql5.com/en/docs/constants/structures/mqltradetransaction */
   if(DUMP_ALL_FIELDS == true){
      printf(StringFormat("> TradeTransaction:\n"
                            "Ticket........................: [%lu]\n"
                            "Order.........................: [%lu]\n"
                            "Symbol........................: [%s]\n"
                            "Type trade....................: [%s]\n"
                            "Type order....................: [%s]\n"
                            "Status........................: [%s]\n"
                            "Type deal.....................: [%s]\n"
                            "Expiration type...............: [%s]\n"
                            "Expiration time...............: [%s]\n"
                            "Price.........................: [%f]\n"
                            "Price that triggers...........: [%f]\n"
                            "Stop Loss.....................: [%f]\n"
                            "Take Profit...................: [%f]\n"
                            "Volume........................: [%f]\n"
                            "Position ticket...............: [%lu]\n"
                            "Ticket of an opposite position: [%lu]\n",
                            trans.deal,
                            trans.order,
                            trans.symbol,
                            ENUM_TRADE_TRANSACTION_TYPE_message(trans.type),
                            ENUM_ORDER_TYPE_message(trans.order_type),
                            ENUM_ORDER_STATE_message(trans.order_state),
                            ENUM_DEAL_TYPE_message(trans.deal_type),
                            ENUM_ORDER_TYPE_TIME_message(trans.time_type),
                            TimeToString(trans.time_expiration, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                            trans.price,
                            trans.price_trigger,
                            trans.price_sl,
                            trans.price_tp,
                            trans.volume,
                            trans.position,
                            trans.position_by));

      return;
   }

   /* ENUM_TRADE_TRANSACTION_TYPE
   https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_transaction_type
   */
   switch(trans.type){

      case TRADE_TRANSACTION_ORDER_ADD:
      case TRADE_TRANSACTION_ORDER_UPDATE:
      case TRADE_TRANSACTION_ORDER_DELETE:
      case TRADE_TRANSACTION_HISTORY_ADD:
      case TRADE_TRANSACTION_HISTORY_UPDATE:
      case TRADE_TRANSACTION_HISTORY_DELETE:
         printf(StringFormat("> TradeTransaction:\n"
                               "Order.........................: [%lu]\n"
                               "Symbol........................: [%s]\n"
                               "Type trade....................: [%s]\n"
                               "Type order....................: [%s]\n"
                               "Status........................: [%s]\n"
                               "Expiration type...............: [%s]\n"
                               "Expiration time...............: [%s]\n"
                               "Price.........................: [%f]\n"
                               "Price that triggers...........: [%f]\n"
                               "Stop Loss.....................: [%f]\n"
                               "Take Profit...................: [%f]\n"
                               "Volume........................: [%f]\n"
                               "Position ticket...............: [%lu]\n"
                               "Ticket of an opposite position: [%lu]\n",
                               trans.order,
                               trans.symbol,
                               ENUM_TRADE_TRANSACTION_TYPE_message(trans.type),
                               ENUM_ORDER_TYPE_message(trans.order_type),
                               ENUM_ORDER_STATE_message(trans.order_state),
                               ENUM_ORDER_TYPE_TIME_message(trans.time_type),
                               TimeToString(trans.time_expiration, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                               trans.price,
                               trans.price_trigger,
                               trans.price_sl,
                               trans.price_tp,
                               trans.volume,
                               trans.position,
                               trans.position_by));
         break;
      
      case TRADE_TRANSACTION_DEAL_ADD:
      case TRADE_TRANSACTION_DEAL_UPDATE:
      case TRADE_TRANSACTION_DEAL_DELETE:
         printf(StringFormat("> TradeTransaction:\n"
                               "Ticket........................: [%lu]\n"
                               "Order.........................: [%lu]\n"
                               "Symbol........................: [%s]\n"
                               "Type trade....................: [%s]\n"
                               "Type deal.....................: [%s]\n"
                               "Price.........................: [%f]\n"
                               "Stop Loss.....................: [%f]\n"
                               "Take Profit...................: [%f]\n"
                               "Volume........................: [%f]\n"
                               "Position ticket...............: [%lu]\n"
                               "Ticket of an opposite position: [%lu]\n",
                               trans.deal,
                               trans.order,
                               trans.symbol,
                               ENUM_TRADE_TRANSACTION_TYPE_message(trans.type),
                               ENUM_DEAL_TYPE_message(trans.deal_type),
                               trans.price,
                               trans.price_sl,
                               trans.price_tp,
                               trans.volume,
                               trans.position,
                               trans.position_by));
         break;
      
      case TRADE_TRANSACTION_POSITION:
         printf(StringFormat("> TradeTransaction:\n"
                               "Symbol........................: [%s]\n"
                               "Type trade....................: [%s]\n"
                               "Type deal.....................: [%s]\n"
                               "Price.........................: [%f]\n"
                               "Stop Loss.....................: [%f]\n"
                               "Take Profit...................: [%f]\n"
                               "Volume........................: [%f]\n",
                               trans.symbol,
                               ENUM_TRADE_TRANSACTION_TYPE_message(trans.type),
                               ENUM_DEAL_TYPE_message(trans.deal_type),
                               trans.price,
                               trans.price_sl,
                               trans.price_tp,
                               trans.volume));
         break;
      
      case TRADE_TRANSACTION_REQUEST:
         printf(StringFormat("> TradeTransaction:\n"
                               "Type trade....................: [%s]\n",
                               ENUM_TRADE_TRANSACTION_TYPE_message(trans.type)));
         break;

      default:
         printf("TradeTransaction UNKNOW! [%d][%s]", trans.type, ENUM_TRADE_TRANSACTION_TYPE_message(trans.type));
   }

   return;
}


void dumpTradeRequestToLog(const MqlTradeRequest &request)
{
   /* https://www.mql5.com/en/docs/constants/structures/mqltraderequest */
   if(DUMP_ALL_FIELDS == true){
      printf(StringFormat("> TradeRequest:\n"
                            "Trade operation type...........................: [%s]\n"
                            "Magic number (EA Id)...........................: [%lu]\n"
                            "Order ticket...................................: [%lu]\n"
                            "Trade symbol...................................: [%s]\n"
                            "Requested volume for a deal in lots............: [%f]\n"
                            "Price..........................................: [%f]\n"
                            "StopLimit level of the order...................: [%f]\n"
                            "Stop Loss level of the order...................: [%f]\n"
                            "Take Profit level of the order.................: [%f]\n"
                            "Max possible deviation from the requested price: [%lu]\n"
                            "Order type.....................................: [%s]\n"
                            "Order execution type...........................: [%s]\n"
                            "Order expiration type..........................: [%s]\n"
                            "Order expiration time..........................: [%s]\n"
                            "Order comment..................................: [%s]\n"
                            "Position ticket................................: [%lu]\n"
                            "The ticket of an opposite position.............: [%lu]\n",
                            ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                            request.magic,
                            request.order,
                            request.symbol,
                            request.volume,
                            request.price,
                            request.stoplimit,
                            request.sl,
                            request.tp,
                            request.deviation,
                            ENUM_ORDER_TYPE_message(request.type),
                            ENUM_ORDER_TYPE_FILLING_message(request.type_filling),
                            ENUM_ORDER_TYPE_TIME_message(request.type_time),
                            TimeToString(request.expiration, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                            request.comment,
                            request.position,
                            request.position_by));

      return;
   }
   
   /* ENUM_TRADE_REQUEST_ACTIONS
   https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
   */
   switch(request.action){

      case TRADE_ACTION_DEAL:
         printf(StringFormat("> TradeRequest:\n"
                               "Trade operation type...........................: [%s]\n"
                               "Magic number (EA Id)...........................: [%lu]\n"
                               "Trade symbol...................................: [%s]\n"
                               "Requested volume for a deal in lots............: [%f]\n"
                               "Price..........................................: [%f]\n"
                               "Stop Loss level of the order...................: [%f]\n"
                               "Take Profit level of the order.................: [%f]\n"
                               "Max possible deviation from the requested price: [%lu]\n"
                               "Order type.....................................: [%s]\n"
                               "Order execution type...........................: [%s]\n"
                               "Order comment..................................: [%s]\n"
                               "Position ticket................................: [%lu]\n"
                               "The ticket of an opposite position.............: [%lu]\n",
                               ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                               request.magic,
                               request.symbol,
                               request.volume,
                               request.price,
                               request.sl,
                               request.tp,
                               request.deviation,
                               ENUM_ORDER_TYPE_message(request.type),
                               ENUM_ORDER_TYPE_FILLING_message(request.type_filling),
                               request.comment,
                               request.position,
                               request.position_by));
         break;

      case TRADE_ACTION_PENDING:
         printf(StringFormat("> TradeRequest:\n"
                               "Trade operation type...........................: [%s]\n"
                               "Magic number (EA Id)...........................: [%lu]\n"
                               "Trade symbol...................................: [%s]\n"
                               "Requested volume for a deal in lots............: [%f]\n"
                               "Price..........................................: [%f]\n"
                               "StopLimit level of the order...................: [%f]\n"
                               "Stop Loss level of the order...................: [%f]\n"
                               "Take Profit level of the order.................: [%f]\n"
                               "Order type.....................................: [%s]\n"
                               "Order execution type...........................: [%s]\n"
                               "Order expiration type..........................: [%s]\n"
                               "Order expiration time..........................: [%s]\n"
                               "Order comment..................................: [%s]\n"
                               "Position ticket................................: [%lu]\n"
                               "The ticket of an opposite position.............: [%lu]\n",
                               ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                               request.magic,
                               request.symbol,
                               request.volume,
                               request.price,
                               request.stoplimit,
                               request.sl,
                               request.tp,
                               ENUM_ORDER_TYPE_message(request.type),
                               ENUM_ORDER_TYPE_FILLING_message(request.type_filling),
                               ENUM_ORDER_TYPE_TIME_message(request.type_time),
                               TimeToString(request.expiration, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                               request.comment,
                               request.position,
                               request.position_by));
         break;

      case TRADE_ACTION_SLTP:
         printf(StringFormat("> TradeRequest:\n"
                               "Trade operation type...........................: [%s]\n"
                               "Magic number (EA Id)...........................: [%lu]\n"
                               "Trade symbol...................................: [%s]\n"
                               "Stop Loss level of the order...................: [%f]\n"
                               "Take Profit level of the order.................: [%f]\n"
                               "Order comment..................................: [%s]\n"
                               "Position ticket................................: [%lu]\n"
                               "The ticket of an opposite position.............: [%lu]\n",
                               ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                               request.magic,
                               request.symbol,
                               request.sl,
                               request.tp,
                               request.comment,
                               request.position,
                               request.position_by));
         break;

      case TRADE_ACTION_MODIFY:
         printf(StringFormat("> TradeRequest:\n"
                               "Trade operation type...........................: [%s]\n"
                               "Magic number (EA Id)...........................: [%lu]\n"
                               "Order ticket...................................: [%lu]\n"
                               "Price..........................................: [%f]\n"
                               "Stop Loss level of the order...................: [%f]\n"
                               "Take Profit level of the order.................: [%f]\n"
                               "Order expiration type..........................: [%s]\n"
                               "Order expiration time..........................: [%s]\n"
                               "Order comment..................................: [%s]\n"
                               "Position ticket................................: [%lu]\n"
                               "The ticket of an opposite position.............: [%lu]\n",
                               ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                               request.magic,
                               request.order,
                               request.price,
                               request.sl,
                               request.tp,
                               ENUM_ORDER_TYPE_TIME_message(request.type_time),
                               TimeToString(request.expiration, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                               request.comment,
                               request.position,
                               request.position_by));
         break;

      case TRADE_ACTION_REMOVE:
         printf(StringFormat("> TradeRequest:\n"
                               "Trade operation type...........................: [%s]\n"
                               "Magic number (EA Id)...........................: [%lu]\n"
                               "Order ticket...................................: [%lu]\n"
                               "Order comment..................................: [%s]\n"
                               "Position ticket................................: [%lu]\n"
                               "The ticket of an opposite position.............: [%lu]\n",
                               ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                               request.magic,
                               request.order,
                               request.comment,
                               request.position,
                               request.position_by));
         break;

      case TRADE_ACTION_CLOSE_BY:
         printf(StringFormat("> TradeRequest:\n"
                               "Trade operation type...........................: [%s]\n"
                               "Magic number (EA Id)...........................: [%lu]\n"
                               "Order ticket...................................: [%lu]\n"
                               "Trade symbol...................................: [%s]\n"
                               "Requested volume for a deal in lots............: [%f]\n"
                               "Price..........................................: [%f]\n"
                               "StopLimit level of the order...................: [%f]\n"
                               "Stop Loss level of the order...................: [%f]\n"
                               "Take Profit level of the order.................: [%f]\n"
                               "Max possible deviation from the requested price: [%lu]\n"
                               "Order type.....................................: [%s]\n"
                               "Order execution type...........................: [%s]\n"
                               "Order expiration type..........................: [%s]\n"
                               "Order expiration time..........................: [%s]\n"
                               "Order comment..................................: [%s]\n"
                               "Position ticket................................: [%lu]\n"
                               "The ticket of an opposite position.............: [%lu]\n",
                               ENUM_TRADE_REQUEST_ACTIONS_message(request.action),
                               request.magic,
                               request.order,
                               request.symbol,
                               request.volume,
                               request.price,
                               request.stoplimit,
                               request.sl,
                               request.tp,
                               request.deviation,
                               ENUM_ORDER_TYPE_message(request.type),
                               ENUM_ORDER_TYPE_FILLING_message(request.type_filling),
                               ENUM_ORDER_TYPE_TIME_message(request.type_time),
                               TimeToString(request.expiration, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                               request.comment,
                               request.position,
                               request.position_by));
         break;
      
      default:
         printf("TradeRequest UNKNOW! [%d][%s]", request.action, ENUM_TRADE_REQUEST_ACTIONS_message(request.action));
   }

   return;
}

void dumpTradeResultToLog(const MqlTradeResult &result)
{
   /* https://www.mql5.com/en/docs/constants/structures/mqltraderesult */
   if(result.retcode == 0){
      printf("TradeResult UNKNOW! [%d][%s]", result.retcode, retcode_message(result.retcode));
      return;
   }

   printf(StringFormat("> TradeResult:\n"
                         "Operation return code.............................: [%s]\n"
                         "Deal ticket, if it is performed...................: [%lu]\n"
                         "Order ticket, if it is placed.....................: [%lu]\n"
                         "Deal volume, confirmed by broker..................: [%f]\n"
                         "Deal price, confirmed by broker...................: [%f]\n"
                         "Current Bid price.................................: [%f]\n"
                         "Current Ask price.................................: [%f]\n"
                         "Broker comment to operation.......................: [%s]\n"
                         "Request ID set by the terminal during the dispatch: [%u]\n"
                         "Return code of an external trading system.........: [%u]\n",
                         retcode_message(result.retcode),
                         result.deal,
                         result.order,
                         result.volume,
                         result.price,
                         result.bid,
                         result.ask,
                         result.comment,
                         result.request_id,
                         result.retcode_external));
   return;
}

string ENUM_TRADE_TRANSACTION_TYPE_message(ENUM_TRADE_TRANSACTION_TYPE ttt)
{
	string ret;

	switch(ttt){
      case TRADE_TRANSACTION_ORDER_ADD:
         ret = "TRADE_TRANSACTION_ORDER_ADD - Adding a new open order.";
         break;

      case TRADE_TRANSACTION_ORDER_UPDATE:
         ret = "TRADE_TRANSACTION_ORDER_UPDATE - Updating an open order. The updates include not only evident changes from the client terminal or a trade server sides but also changes of an order state when setting it (for example, transition from ORDER_STATE_STARTED to ORDER_STATE_PLACED or from ORDER_STATE_PLACED to ORDER_STATE_PARTIAL, etc.).";
         break;

      case TRADE_TRANSACTION_ORDER_DELETE:
         ret = "TRADE_TRANSACTION_ORDER_DELETE - Removing an order from the list of the open ones. An order can be deleted from the open ones as a result of setting an appropriate request or execution (filling) and moving to the history.";
         break;

      case TRADE_TRANSACTION_DEAL_ADD:
         ret = "TRADE_TRANSACTION_DEAL_ADD - Adding a deal to the history. The action is performed as a result of an order execution or performing operations with an account balance.";
         break;

      case TRADE_TRANSACTION_DEAL_UPDATE:
         ret = "TRADE_TRANSACTION_DEAL_UPDATE - Updating a deal in the history. There may be cases when a previously executed deal is changed on a server. For example, a deal has been changed in an external trading system (exchange) where it was previously transferred by a broker.";
         break;

      case TRADE_TRANSACTION_DEAL_DELETE:
         ret = "TRADE_TRANSACTION_DEAL_DELETE - Deleting a deal from the history. There may be cases when a previously executed deal is deleted from a server. For example, a deal has been deleted in an external trading system (exchange) where it was previously transferred by a broker.";
         break;

      case TRADE_TRANSACTION_HISTORY_ADD:
         ret = "TRADE_TRANSACTION_HISTORY_ADD - Adding an order to the history as a result of execution or cancellation.";
         break;

      case TRADE_TRANSACTION_HISTORY_UPDATE:
         ret = "TRADE_TRANSACTION_HISTORY_UPDATE - Changing an order located in the orders history. This type is provided for enhancing functionality on a trade server side.";
         break;

      case TRADE_TRANSACTION_HISTORY_DELETE:
         ret = "TRADE_TRANSACTION_HISTORY_DELETE - Deleting an order from the orders history. This type is provided for enhancing functionality on a trade server side.";
         break;

      case TRADE_TRANSACTION_POSITION:
         ret = "TRADE_TRANSACTION_POSITION - Changing a position not related to a deal execution. This type of transaction shows that a position has been changed on a trade server side. Position volume, open price, Stop Loss and Take Profit levels can be changed. Data on changes are submitted in MqlTradeTransaction structure via OnTradeTransaction handler. Position change (adding, changing or closing), as a result of a deal execution, does not lead to the occurrence of TRADE_TRANSACTION_POSITION transaction.";
         break;

      case TRADE_TRANSACTION_REQUEST:
         ret = "TRADE_TRANSACTION_REQUEST - Notification of the fact that a trade request has been processed by a server and processing result has been received. Only type field (trade transaction type) must be analyzed for such transactions in MqlTradeTransaction structure. The second and third parameters of OnTradeTransaction (request and result) must be analyzed for additional data.";
			break;

		default:
			ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string ENUM_ACCOUNT_MARGIN_MODE_message(ENUM_ACCOUNT_MARGIN_MODE amm)
{
   string ret;
   
   switch(amm){
      case ACCOUNT_MARGIN_MODE_RETAIL_NETTING:
         ret = "ACCOUNT_MARGIN_MODE_RETAIL_NETTING - Used for the OTC markets to interpret positions in the \"netting\" mode (only one position can exist for one symbol).";
         break;
      
      case ACCOUNT_MARGIN_MODE_EXCHANGE:
         ret = "ACCOUNT_MARGIN_MODE_EXCHANGE - Used for the exchange markets. Margin is calculated based on the discounts specified in symbol settings.";
         break;
      
      case ACCOUNT_MARGIN_MODE_RETAIL_HEDGING:
         ret = "ACCOUNT_MARGIN_MODE_RETAIL_HEDGING - Used for the exchange markets where individual positions are possible (hedging, multiple positions can exist for one symbol).";
         break;
      
      default:
         ret = "UNDEF - UNDEF";
   }
   
   return(ret);
}

string ENUM_TRADE_REQUEST_ACTIONS_message(ENUM_TRADE_REQUEST_ACTIONS tra)
{
	string ret;

	switch(tra){
      case TRADE_ACTION_DEAL:
         ret = "TRADE_ACTION_DEAL - Place a trade order for an immediate execution with the specified parameters (market order)";
         break;

      case TRADE_ACTION_PENDING:
         ret = "TRADE_ACTION_PENDING - Place a trade order for the execution under specified conditions (pending order)";
         break;

      case TRADE_ACTION_SLTP:
         ret = "TRADE_ACTION_SLTP - Modify Stop Loss and Take Profit values of an opened position";
         break;

      case TRADE_ACTION_MODIFY:
         ret = "TRADE_ACTION_MODIFY - Modify the parameters of the order placed previously";
         break;

      case TRADE_ACTION_REMOVE:
         ret = "TRADE_ACTION_REMOVE - Delete the pending order placed previously";
         break;

      case TRADE_ACTION_CLOSE_BY:
         ret = "TRADE_ACTION_CLOSE_BY - Close a position by an opposite one";
         break;

      default:
         ret = "UNDEF - UNDEF";
	}

	return(ret);
}

string retcode_message(uint retcode)
{
	string ret;

	switch(retcode){
      case TRADE_RETCODE_REQUOTE:
         ret = "10004 TRADE_RETCODE_REQUOTE - Requote";
         break;

      case TRADE_RETCODE_REJECT:
         ret = "10006 TRADE_RETCODE_REJECT - Request rejected";
         break;

      case TRADE_RETCODE_CANCEL:
         ret = "10007 TRADE_RETCODE_CANCEL - Request canceled by trader";
         break;

      case TRADE_RETCODE_PLACED:
         ret = "10008 TRADE_RETCODE_PLACED - Order placed";
         break;

      case TRADE_RETCODE_DONE:
         ret = "10009 TRADE_RETCODE_DONE - Request completed";
         break;

      case TRADE_RETCODE_DONE_PARTIAL:
         ret = "10010 TRADE_RETCODE_DONE_PARTIAL - Only part of the request was completed";
         break;

      case TRADE_RETCODE_ERROR:
         ret = "10011 TRADE_RETCODE_ERROR - Request processing error";
         break;

      case TRADE_RETCODE_TIMEOUT:
         ret = "10012 TRADE_RETCODE_TIMEOUT - Request canceled by timeout";
         break;

      case TRADE_RETCODE_INVALID:
         ret = "10013 TRADE_RETCODE_INVALID - Invalid request";
         break;

      case TRADE_RETCODE_INVALID_VOLUME:
         ret = "10014 TRADE_RETCODE_INVALID_VOLUME - Invalid volume in the request";
         break;

      case TRADE_RETCODE_INVALID_PRICE:
         ret = "10015 TRADE_RETCODE_INVALID_PRICE - Invalid price in the request";
         break;

      case TRADE_RETCODE_INVALID_STOPS:
         ret = "10016 TRADE_RETCODE_INVALID_STOPS - Invalid stops in the request";
         break;

      case TRADE_RETCODE_TRADE_DISABLED:
         ret = "10017 TRADE_RETCODE_TRADE_DISABLED - Trade is disabled";
         break;

      case TRADE_RETCODE_MARKET_CLOSED:
         ret = "10018 TRADE_RETCODE_MARKET_CLOSED - Market is closed";
         break;

      case TRADE_RETCODE_NO_MONEY:
         ret = "10019 TRADE_RETCODE_NO_MONEY - There is not enough money to complete the request";
         break;

      case TRADE_RETCODE_PRICE_CHANGED:
         ret = "10020 TRADE_RETCODE_PRICE_CHANGED - Prices changed";
         break;

      case TRADE_RETCODE_PRICE_OFF:
         ret = "10021 TRADE_RETCODE_PRICE_OFF - There are no quotes to process the request";
         break;

      case TRADE_RETCODE_INVALID_EXPIRATION:
         ret = "10022 TRADE_RETCODE_INVALID_EXPIRATION - Invalid order expiration date in the request";
         break;

      case TRADE_RETCODE_ORDER_CHANGED:
         ret = "10023 TRADE_RETCODE_ORDER_CHANGED - Order state changed";
         break;

      case TRADE_RETCODE_TOO_MANY_REQUESTS:
         ret = "10024 TRADE_RETCODE_TOO_MANY_REQUESTS - Too frequent requests";
         break;

      case TRADE_RETCODE_NO_CHANGES:
         ret = "10025 TRADE_RETCODE_NO_CHANGES - No changes in request";
         break;

      case TRADE_RETCODE_SERVER_DISABLES_AT:
         ret = "10026 TRADE_RETCODE_SERVER_DISABLES_AT - Autotrading disabled by server";
         break;

      case TRADE_RETCODE_CLIENT_DISABLES_AT:
         ret = "10027 TRADE_RETCODE_CLIENT_DISABLES_AT - Autotrading disabled by client terminal";
         break;

      case TRADE_RETCODE_LOCKED:
         ret = "10028 TRADE_RETCODE_LOCKED - Request locked for processing";
         break;

      case TRADE_RETCODE_FROZEN:
         ret = "10029 TRADE_RETCODE_FROZEN - Order or position frozen";
         break;

      case TRADE_RETCODE_INVALID_FILL:
         ret = "10030 TRADE_RETCODE_INVALID_FILL - Invalid order filling type";
         break;

      case TRADE_RETCODE_CONNECTION:
         ret = "10031 TRADE_RETCODE_CONNECTION - No connection with the trade server";
         break;

      case TRADE_RETCODE_ONLY_REAL:
         ret = "10032 TRADE_RETCODE_ONLY_REAL - Operation is allowed only for live accounts";
         break;

      case TRADE_RETCODE_LIMIT_ORDERS:
         ret = "10033 TRADE_RETCODE_LIMIT_ORDERS - The number of pending orders has reached the limit";
         break;

      case TRADE_RETCODE_LIMIT_VOLUME:
         ret = "10034 TRADE_RETCODE_LIMIT_VOLUME - The volume of orders and positions for the symbol has reached the limit";
         break;

      case TRADE_RETCODE_INVALID_ORDER:
         ret = "10035 TRADE_RETCODE_INVALID_ORDER - Incorrect or prohibited order type";

      case TRADE_RETCODE_POSITION_CLOSED:
         ret = "10036 TRADE_RETCODE_POSITION_CLOSED - Position with the specified POSITION_IDENTIFIER has already been closed";

      case TRADE_RETCODE_INVALID_CLOSE_VOLUME:
         ret = "10038 TRADE_RETCODE_INVALID_CLOSE_VOLUME - A close volume exceeds the current position volume";

      case TRADE_RETCODE_CLOSE_ORDER_EXIST:
         ret = "10039 TRADE_RETCODE_CLOSE_ORDER_EXIST - A close order already exists for a specified position. This may happen when working in the hedging system: when attempting to close a position with an opposite one, while close orders for the position already exist or when attempting to fully or partially close a position if the total volume of the already present close orders and the newly placed one exceeds the current position volume";
         break;

      case TRADE_RETCODE_LIMIT_POSITIONS:
         ret = "10040 TRADE_RETCODE_LIMIT_POSITIONS - The number of open positions simultaneously present on an account can be limited by the server settings. After a limit is reached, the server returns the TRADE_RETCODE_LIMIT_POSITIONS error when attempting to place an order. The limitation operates differently depending on the position accounting type Netting or Hedging";
         break;
		 
      case TRADE_RETCODE_REJECT_CANCEL:
         ret = "10041 TRADE_RETCODE_REJECT_CANCEL - The pending order activation request is rejected, the order is canceled";
         break;

      case TRADE_RETCODE_LONG_ONLY:
         ret = "10042 TRADE_RETCODE_LONG_ONLY - The request is rejected, because the \"Only long positions are allowed\" rule is set for the symbol (POSITION_TYPE_BUY)";
         break;

      case TRADE_RETCODE_SHORT_ONLY:
         ret = "10043 TRADE_RETCODE_SHORT_ONLY - The request is rejected, because the \"Only short positions are allowed\" rule is set for the symbol (POSITION_TYPE_SELL)";
         break;

      case TRADE_RETCODE_CLOSE_ONLY:
         ret = "10044 TRADE_RETCODE_CLOSE_ONLY - The request is rejected, because the \"Only position closing is allowed\" rule is set for the symbol";
         break;

      case TRADE_RETCODE_FIFO_CLOSE:
         ret = "10045 TRADE_RETCODE_FIFO_CLOSE - The request is rejected, because \"Position closing is allowed only by FIFO rule\" flag is set for the trading account (ACCOUNT_FIFO_CLOSE=true)";
         break;

      default:
         ret = "Code [" + IntegerToString(retcode) + "] UNDEF - UNDEF";
	}

	return(ret);
}
