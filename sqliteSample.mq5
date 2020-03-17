//+------------------------------------------------------------------+
//|                                                 sqliteSample.mq5 |
//|                                    André Augusto Giannotti Scotá |
//|                              https://sites.google.com/view/a2gs/ |
//+------------------------------------------------------------------+

/* https://www.mql5.com/en/articles/7463 */

const string dbFile = "database.sqlite";
int dbHandle = INVALID_HANDLE;

bool createTables(void)
{
   if(createTableTradeTransaction() == false) return(false);
   if(createTableTradeResult()      == false) return(false);
   if(createTableTradeRequest()     == false) return(false);

   DatabaseTransactionCommit(dbHandle);

   return(true);
}

bool createDBFile(void)
{
   ResetLastError();

   dbHandle = DatabaseOpen(dbFile, DATABASE_OPEN_READWRITE|DATABASE_OPEN_CREATE|DATABASE_OPEN_COMMON);
   
   if(dbHandle == INVALID_HANDLE){
      printf("Erro opening and creating DB [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }
   
   return(true);
}

bool openDB(void)
{
   ResetLastError();

   dbHandle = DatabaseOpen(dbFile, DATABASE_OPEN_READWRITE|DATABASE_OPEN_COMMON);
   
   if(dbHandle == INVALID_HANDLE){
      printf("Erro opening DB [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }
   
   return(true);
}

bool createTableTradeTransaction(void)
{
/*
https://www.mql5.com/en/docs/constants/structures/mqltradetransaction
struct MqlTradeTransaction
{
   ulong                         deal;             // Deal ticket
   ulong                         order;            // Order ticket
   string                        symbol;           // Trade symbol name
   ENUM_TRADE_TRANSACTION_TYPE   type;             // Trade transaction type
   ENUM_ORDER_TYPE               order_type;       // Order type
   ENUM_ORDER_STATE              order_state;      // Order state
   ENUM_DEAL_TYPE                deal_type;        // Deal type
   ENUM_ORDER_TYPE_TIME          time_type;        // Order type by action period
   datetime                      time_expiration;  // Order expiration time
   double                        price;            // Price 
   double                        price_trigger;    // Stop limit order activation price
   double                        price_sl;         // Stop Loss level
   double                        price_tp;         // Take Profit level
   double                        volume;           // Volume in lots
   ulong                         position;         // Position ticket
   ulong                         position_by;      // Ticket of an opposite position
};
*/
      ResetLastError();

      if(DatabaseExecute(dbHandle,
                         "CREATE TABLE TRADETRANS ("
                         "DATETIME      INTEGER NOT NULL," // DB Register inserted (8bytes Unix time 1970-01-01 00:00:00)
                         "DEAL          INTEGER,"
                         "TICKET        INTEGER," // Order
                         "SYMBOL        TEXT,"
                         "TYPEREQ       INTEGER,"
                         "ORDERTYPE     INTEGER,"
                         "ORDERSTATE    INTEGER,"
                         "DEALTYPE      INTEGER,"
                         "TIMETYPE      INTEGER,"
                         "EXDATETIME    INTEGER,"
                         "PRICE         REAL,"
                         "PRICETRIGGER  REAL,"
                         "PRICESL       REAL,"
                         "PRICETP       REAL,"
                         "VOLUME        REAL,"
                         "POSITION      INTEGER,"
                         "POSITIONBY    INTEGER,"
                         "STATUS        CHAR(1));" // DB Register status
                         ) == false){
      printf("Erro creating table TRADETRANS [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();
   
   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx1 ON TRADETRANS(DATETIME);") == false){
      printf("Erro creating index TTIdx1 (DATETIME) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx2 ON TRADETRANS(TICKET);") == false){
      printf("Erro creating index TTIdx2 (TICKET) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx3 ON TRADETRANS(SYMBOL);") == false){
      printf("Erro creating index TTIdx3 (SYMBOL) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx4 ON TRADETRANS(TYPEREQ);") == false){
      printf("Erro creating index TTIdx4 (TYPEREQ) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx5 ON TRADETRANS(POSITION);") == false){
      printf("Erro creating index TTIdx5 (POSITION) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx6 ON TRADETRANS(POSITIONBY);") == false){
      printf("Erro creating index TTIdx6 (POSITIONBY) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TTIdx7 ON TRADETRANS(STATUS);") == false){
      printf("Erro creating index TTIdx7 (STATUS) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   return(true);
}

bool createTableTradeResult(void)
{
/*
https://www.mql5.com/en/docs/constants/structures/mqltraderesult
struct MqlTradeResult
{
   uint     retcode;          // Operation return code
   ulong    deal;             // Deal ticket, if it is performed
   ulong    order;            // Order ticket, if it is placed
   double   volume;           // Deal volume, confirmed by broker
   double   price;            // Deal price, confirmed by broker
   double   bid;              // Current Bid price
   double   ask;              // Current Ask price
   string   comment;          // Broker comment to operation (by default it is filled by description of trade server return code)
   uint     request_id;       // Request ID set by the terminal during the dispatch 
   uint     retcode_external; // Return code of an external trading system
};
*/
      ResetLastError();

      if(DatabaseExecute(dbHandle,
                         "CREATE TABLE TRADERESULT ("
                         "DATETIME   INTEGER NOT NULL," // DB Register inserted (8bytes Unix time 1970-01-01 00:00:00)                      
                         "RETCODE    INTEGER,"
                         "DEAL       INTEGER,"
                         "TICKET     INTEGER," // Order
                         "VOLUME     REAL,"
                         "PRICE      REAL,"
                         "BID        REAL,"
                         "ASK        REAL,"
                         "COMMENT    TEXT,"
                         "REQUESTID  INTEGER,"
                         "RETCODEEXT INTEGER,"
                         "STATUS     CHAR(1));" // DB Register status
                         ) == false){
      printf("Erro creating table TRADERESULT [%s]: [%s]", dbFile, GetLastError());
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRIdx1 ON TRADERESULT(DATETIME);") == false){
      printf("Erro creating index TRIdx1 (DATETIME) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRIdx2 ON TRADERESULT(TICKET);") == false){
      printf("Erro creating index TRIdx2 (TICKET) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRIdx3 ON TRADERESULT(RETCODEEXT);") == false){
      printf("Erro creating index TRIdx3 (RETCODEEXT) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRIdx4 ON TRADERESULT(STATUS);") == false){
      printf("Erro creating index TRIdx4 (STATUS) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   return(true);
}

bool createTableTradeRequest(void)
{
/*
https://www.mql5.com/en/docs/constants/structures/mqltraderequest
struct MqlTradeRequest
{
   ENUM_TRADE_REQUEST_ACTIONS    action;           // Trade operation type
   ulong                         magic;            // Expert Advisor ID (magic number)
   ulong                         order;            // Order ticket
   string                        symbol;           // Trade symbol
   double                        volume;           // Requested volume for a deal in lots
   double                        price;            // Price
   double                        stoplimit;        // StopLimit level of the order
   double                        sl;               // Stop Loss level of the order
   double                        tp;               // Take Profit level of the order
   ulong                         deviation;        // Maximal possible deviation from the requested price
   ENUM_ORDER_TYPE               type;             // Order type
   ENUM_ORDER_TYPE_FILLING       type_filling;     // Order execution type
   ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type
   datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type)
   string                        comment;          // Order comment
   ulong                         position;         // Position ticket
   ulong                         position_by;      // The ticket of an opposite position
};
*/
      ResetLastError();

      if(DatabaseExecute(dbHandle,
                         "CREATE TABLE TRADEREQUEST ("
                         "DATETIME   INTEGER NOT NULL," // DB Register inserted (8bytes Unix time 1970-01-01 00:00:00)                      
                         "ACTION     INTEGER,"
                         "MAGIC      INTEGER,"
                         "TICKET     INTEGER,"
                         "SYMBOL     TEXT," // Order
                         "VOLUME     REAL,"
                         "PRICE      REAL,"
                         "STOPLIMIT  REAL,"
                         "SL         REAL,"
                         "TP         REAL,"
                         "DERIVATION INTEGER,"
                         "TYPEORD    INTEGER,"
                         "TYPEFILL   INTEGER,"
                         "TYPETIME   INTEGER,"
                         "EXPIRATION INTEGER,"
                         "COMMENT    TEXT,"
                         "POSITION   INTEGER,"
                         "POSITIONBY INTEGER,"
                         "STATUS     CHAR(1));" // DB Register status
                         ) == false){
      printf("Erro creating table TRADEREQUEST [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRQIdx1 ON TRADEREQUEST(DATETIME);") == false){
      printf("Erro creating index TRQIdx1 (DATETIME) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRQIdx2 ON TRADEREQUEST(TICKET);") == false){
      printf("Erro creating index TRQIdx2 (TICKET) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRQIdx3 ON TRADEREQUEST(SYMBOL);") == false){
      printf("Erro creating index TRQIdx3 (SYMBOL) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();
   
   if(DatabaseExecute(dbHandle, "CREATE INDEX TRQIdx4 ON TRADEREQUEST(POSITION);") == false){
      printf("Erro creating index TRQIdx4 (POSITION) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRQIdx5 ON TRADEREQUEST(POSITIONBY);") == false){
      printf("Erro creating index TRQIdx5 (POSITIONBY) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   ResetLastError();

   if(DatabaseExecute(dbHandle, "CREATE INDEX TRQIdx6 ON TRADEREQUEST(STATUS);") == false){
      printf("Erro creating index TRQIdx6 (STATUS) [%s]: [%s]", dbFile, sqlMsgError(GetLastError()));
      return(false);
   }

   return(true);
}

int OnInit(void)
{
   if(FileIsExist(dbFile, FILE_COMMON) == false){
      if(createDBFile() == false){
         Print("Init createDBFile error.");
         return(INIT_FAILED);
      }
      
      if(createTables() == false){
         Print("Init createTables error.");
         return(INIT_FAILED);
      }
      
      DatabaseTransactionCommit(dbHandle);

   }else{
      if(openDB() == false){
         Print("Init openDB error.");
         return(INIT_FAILED);
      }

      if(DatabaseTableExists(dbHandle, "TRADETRANS") == false){
         createTableTradeTransaction();
         DatabaseTransactionCommit(dbHandle);
      }

      if(DatabaseTableExists(dbHandle, "TRADERESULT") == false){
         createTableTradeResult();
         DatabaseTransactionCommit(dbHandle);
      }

      if(DatabaseTableExists(dbHandle, "TRADEREQUEST") == false){
         createTableTradeRequest();
         DatabaseTransactionCommit(dbHandle);
      }

   }

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   DatabaseClose(dbHandle);
}

bool insertTradeTransaction(const MqlTradeTransaction &trans, datetime dbtime)
{
   string query = StringFormat("INSERT INTO TRADETRANS"
                               "(DATETIME, DEAL, TICKET, SYMBOL, TYPEREQ, ORDERTYPE, ORDERSTATE, DEALTYPE,"
                               "TIMETYPE, EXDATETIME, PRICE, PRICETRIGGER, PRICESL, PRICETP, VOLUME, POSITION,"
                               "POSITIONBY, STATUS)"
                               "VALUES (%lu, %lu, %lu, '%s', %lu, %lu, %lu, %lu, %lu, %lu, %f, %f, %f, %f, %f, "
                               "%lu, %lu, '%c');",
                               dbtime, trans.deal, trans.order, trans.symbol, trans.type, trans.order_type,
                               trans.order_state, trans.deal_type, trans.time_type, trans.time_expiration,
                               trans.price, trans.price_trigger, trans.price_sl, trans.price_tp, trans.volume,
                               trans.position, trans.position_by, 'I');

   ResetLastError();
   if(DatabaseExecute(dbHandle, query) == false){
      printf("Insert error: [%s]", query);
      return(false);
   }

   return(true);
}

bool insertTradeRequest(const MqlTradeRequest &request, datetime dbtime)
{
   string query = StringFormat("INSERT INTO TRADEREQUEST"
                               "(DATETIME, ACTION, MAGIC, TICKET, SYMBOL, VOLUME, PRICE,"
                               "STOPLIMIT, SL, TP, DERIVATION, TYPEORD, TYPEFILL, TYPETIME,"
                               "EXPIRATION, COMMENT, POSITION, POSITIONBY, STATUS)"
                               "VALUES (%lu, %lu, %lu, %lu, '%s', %f, %f, %f, %f, %f, %lu, %lu,"
                               "%lu, %lu, %lu, '%s', %lu, %lu, '%c');",
                               dbtime, request.action, request.magic, request.order, request.symbol,
                               request.volume, request.price, request.stoplimit, request.sl,
                               request.tp, request.deviation, request.type, request.type_filling,
                               request.type_time, request.expiration, request.comment, request.position,
                               request.position_by, 'I');

   ResetLastError();
   if(DatabaseExecute(dbHandle, query) == false){
      printf("Insert error: [%s]", query);
      return(false);
   }

   return(true);
}

bool insertTradeResult(const MqlTradeResult &result, datetime dbtime)
{
   string query = StringFormat("INSERT INTO TRADERESULT"
                               "(DATETIME, RETCODE, DEAL, TICKET, VOLUME, PRICE, BID, ASK, COMMENT,"
                               "REQUESTID, RETCODEEXT, STATUS)"
                               "VALUES (%lu, %lu, %lu, %lu, %f, %f, %f, %f, '%s', %lu, %lu, '%c');",
                               dbtime, result.retcode, result.deal,
                               result.order, result.volume, result.price,
                               result.bid, result.ask,
                               result.comment, result.request_id,
                               result.retcode_external, 'I');

   ResetLastError();
   if(DatabaseExecute(dbHandle, query) == false){
      printf("Insert error: [%s]", query);
      return(false);
   }

   return(true);
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest     &request,
                        const MqlTradeResult      &result)
{
   datetime dbtime = TimeLocal();

   DatabaseTransactionBegin(dbHandle);

   if(insertTradeTransaction(trans, dbtime) == false){
      DatabaseTransactionRollback(dbHandle);
      Print("Rollback TradeTransaction!");
      //return;
   }

   if(insertTradeRequest(request, dbtime) == false){
      DatabaseTransactionRollback(dbHandle);
      Print("Rollback TradeRequest!");
      //return;
   }

   if(insertTradeResult(result, dbtime) == false){
      DatabaseTransactionRollback(dbHandle);
      Print("Rollback TradeResult!");
      //return;
   }

   DatabaseTransactionCommit(dbHandle);
}

void printTradeTransaction(void)
{  /*                                           0       1      2       3        4        5       6      7  */
   string selectQuery = StringFormat("SELECT DATETIME, DEAL, TICKET, VOLUME, PRICESL, PRICETP, PRICE, STATUS FROM TRADETRANS WHERE TYPEREQ IN (%d, %d);", TRADE_TRANSACTION_ORDER_ADD, TRADE_TRANSACTION_ORDER_DELETE);

   printf("(%s)", selectQuery);

   ResetLastError();
   int request = DatabasePrepare(dbHandle, selectQuery);
   if(request == INVALID_HANDLE){
      printf("Error querying [%s] [%s]", selectQuery, sqlMsgError(GetLastError()));
      return;
   }

   double price;
   double volume;
   long dttrans;
   string status;
   long deal;
   long ticket;

   unsigned int i;

   ResetLastError();
   for(i = 0; DatabaseRead(request) == true; i++){
      price = volume = 0.0;
      dttrans = deal = ticket = 0;
      status = "";

      ResetLastError();
      if(DatabaseColumnLong(request, 0, dttrans) == false){
         printf("Error tradetrans.dttrans[%s]", sqlMsgError(GetLastError()));
         return;
      }

      ResetLastError();
      if(DatabaseColumnLong(request, 1, deal) == false){
         printf("Error tradetrans.deal[%s]", sqlMsgError(GetLastError()));
         return;
      }

      ResetLastError();
      if(DatabaseColumnLong(request, 2, ticket) == false){
         printf("Error tradetrans.ticket[%s]", sqlMsgError(GetLastError()));
         return;
      }

      ResetLastError();
      if(DatabaseColumnDouble(request, 3, volume) == false){
         printf("Error tradetrans.volume[%s]", sqlMsgError(GetLastError()));
         return;
      }

      ResetLastError();
      if(DatabaseColumnDouble(request, 6, price) == false){
         printf("Error tradetrans.price[%s]", sqlMsgError(GetLastError()));
         return;
      }

      ResetLastError();
      if(DatabaseColumnText(request, 7, status) == false){
         printf("Error tradetrans.status[%s]", sqlMsgError(GetLastError()));
         return;
      }

      printf("Date[%s] Deal[%lu] Ticket[%lu] Vol[%f] Price[%f] Status[%s]",
             TimeToString((datetime)dttrans, TIME_DATE|TIME_SECONDS),
             deal, ticket, volume, price, status);

      ResetLastError();
   }
   
   printf("Total registers: [%u] Error (if happened): [%s]", i, sqlMsgError(GetLastError()));
   DatabaseFinalize(request);
}

struct traderet_t{
   long dttrans;
   long retcode;
   long deal;
   long ticket;
   string status;
};

void printTradeRequest(void)
{
   string selectQuery = "SELECT DATETIME, RETCODE, DEAL, TICKET, STATUS FROM TRADERESULT WHERE RETCODE <> 0;";

   printf("(%s)", selectQuery);

   ResetLastError();
   int request = DatabasePrepare(dbHandle, selectQuery);
   if(request == INVALID_HANDLE){
      printf("Error querying [%s] [%s]", selectQuery, sqlMsgError(GetLastError()));
      return;
   }

   unsigned int i;
   traderet_t reg;

   ResetLastError();
   for(i = 0; DatabaseReadBind(request, reg); i++){
      printf("Date[%s] Deal[%lu] Ticket[%lu] Return[%lu] Status[%s]",
             TimeToString((datetime)reg.dttrans, TIME_DATE|TIME_SECONDS),
             reg.deal, reg.ticket, reg.retcode, reg.status);
      ResetLastError();
   }

   printf("Total registers: [%u] Error (if happened): [%s]", i, sqlMsgError(GetLastError()));
   DatabaseFinalize(request);
}

void OnChartEvent(const int EventID,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

   if(EventID == CHARTEVENT_KEYDOWN){
      short KeyThatWasPressed = TranslateKey((int) lparam);
      
       switch(KeyThatWasPressed){
         case 'p':
            printf("Current symbol [%s] trade transactions:", Symbol());
            printTradeTransaction();

            printf("\nCurrent symbol [%s] trade request:", Symbol());
            printTradeRequest();

            break;
         
         default:
         break;
      }
   }
   
   return;
}

string sqlMsgError(int sqlErr)
{
   switch(sqlErr){
      case ERR_INTERNAL_ERROR:
         return("4001 - Critical runtime error");
         break;
      
      case ERR_WRONG_INTERNAL_PARAMETER:
         return("4002 - Internal error, while accessing the \"MQL5\\Files\" folder");
         break;
      
      case ERR_INVALID_PARAMETER:
         return("4003 - SQL parameter contains an empty string");
         break;
      
      case ERR_NOT_ENOUGH_MEMORY:
         return("4004 - Insufficient memory");
         break;
      
      case ERR_FUNCTION_NOT_ALLOWED:
         return("4014 - Specified pipe is not allowed");
         break;
      
      case ERR_PROGRAM_STOPPED:
         return("4022 - Operation canceled (MQL program stopped)");
         break;
      
      case ERR_WRONG_FILENAME:
         return("5002 - Wrong database file name");
         break;
      
      case ERR_TOO_LONG_FILENAME:
         return("5003 - Absolute path to the database file exceeds the maximum length");
         break;
      
      case ERR_CANNOT_OPEN_FILE:
         return("5004 - Unable to open the file for writing");
         break;
      
      case ERR_FILE_WRITEERROR:
         return("5026 - Unable to write to the file");
         break;
      
      case ERR_WRONG_STRING_PARAMETER:
         return("5040 - Error converting a request into a UTF-8 string");
         break;
      
      case ERR_DATABASE_INTERNAL:
         return("5120 - Internal database error");
         break;
      
      case ERR_DATABASE_INVALID_HANDLE:
         return("5121 - Invalid database handle");
         break;
      
      case ERR_DATABASE_TOO_MANY_OBJECTS:
         return("5122 - Exceeded the maximum acceptable number of Database objects");
         break;
      
      case ERR_DATABASE_CONNECT:
         return("5123 - Database connection error");
         break;
      
      case ERR_DATABASE_EXECUTE:
         return("5124 - Request execution error");
         break;
      
      case ERR_DATABASE_PREPARE:
         return("5125 - Request generation error");
         break;
      
      case ERR_DATABASE_NO_MORE_DATA:
         return("5126 - No table exists (not an error, normal completion)");
         break;
      
      case ERR_DATABASE_QUERY_NOT_READONLY:
         return("read-only request is allowed");
         break;
   }
   
   return(StringFormat("%d - Unknow code", sqlErr));
}
