//+------------------------------------------------------------------+
//|                                                     KeyEvent.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+

void OnChartEvent(const int EventID,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

   if(EventID == CHARTEVENT_KEYDOWN){
      // translate key code to letter
      short KeyThatWasPressed = TranslateKey((int) lparam);
      
      MessageBox("The key was: " + ShortToString(KeyThatWasPressed), "Key was pressed", MB_OK);
   }

}