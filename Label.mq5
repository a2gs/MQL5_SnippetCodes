//+------------------------------------------------------------------+
//|                                                        Label.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // get the Ask price
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
   
   // set Object Properties for a Label
   ObjectCreate(0, "Label1", OBJ_LABEL, 0, 0, 0);
   
   // set Object Font
   ObjectSetString(0, "Label1", OBJPROP_FONT, "Arial");
   
   // set font Size
   ObjectSetInteger(0, "Label1", OBJPROP_FONTSIZE, 25);
   
   // set Label Text
   ObjectSetString(0, "Label1", OBJPROP_TEXT, _Symbol + " Ask Price: " + Ask);
   
   // set distance from left border
   ObjectSetInteger(0, "Label1", OBJPROP_XDISTANCE, 5);

   // set distance from upper border
   ObjectSetInteger(0, "Label1", OBJPROP_YDISTANCE, 10);
   
}
//+------------------------------------------------------------------+
