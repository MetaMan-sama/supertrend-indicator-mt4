//+------------------------------------------------------------------+
//|                     SuperTrendIndicator.mq4                      |
//|  Alerts for buy/sell signals when price crosses SuperTrend line  |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string TradeSymbol = "EURUSD";        // Symbol for analysis
input ENUM_TIMEFRAMES Timeframe = PERIOD_H1; // Timeframe for analysis
input int ATRPeriod = 10;                   // Period for ATR calculation
input double Multiplier = 3.0;              // Multiplier for ATR
input bool EnableAlerts = true;             // Enable sound alerts
input bool EnableEmail = false;             // Enable email notifications
input bool EnablePush = false;              // Enable push notifications

// Global variables
double PrevSuperTrend = 0.0;
bool IsBullish = true;

//+------------------------------------------------------------------+
//| Main Function                                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("SuperTrend Indicator Script Started.");

   while (!IsStopped()) {
      // Get the current SuperTrend line value
      double currentSuperTrend = CalculateSuperTrend();
      double currentPrice = iClose(TradeSymbol, Timeframe, 0);

      // Determine if a buy/sell signal is generated
      if (IsBullish && currentPrice < currentSuperTrend) {
         AlertSuperTrendSignal("Sell Signal", currentSuperTrend);
         IsBullish = false;
      } else if (!IsBullish && currentPrice > currentSuperTrend) {
         AlertSuperTrendSignal("Buy Signal", currentSuperTrend);
         IsBullish = true;
      }

      PrevSuperTrend = currentSuperTrend;
      Sleep(60000); // Wait 1 minute before checking again
   }
}

//+------------------------------------------------------------------+
//| Calculate SuperTrend value                                       |
//+------------------------------------------------------------------+
double CalculateSuperTrend()
{
   double atr = iATR(TradeSymbol, Timeframe, ATRPeriod, 0);
   double high = iHigh(TradeSymbol, Timeframe, 0);
   double low = iLow(TradeSymbol, Timeframe, 0);

   // SuperTrend calculations
   double basicUpperBand = (high + low) / 2 + Multiplier * atr;
   double basicLowerBand = (high + low) / 2 - Multiplier * atr;

   double finalUpperBand = MathMin(basicUpperBand, PrevSuperTrend);
   double finalLowerBand = MathMax(basicLowerBand, PrevSuperTrend);

   return IsBullish ? finalLowerBand : finalUpperBand;
}

//+------------------------------------------------------------------+
//| Send alert notifications                                         |
//+------------------------------------------------------------------+
void AlertSuperTrendSignal(string signalType, double superTrendValue)
{
   string message = StringFormat(
      "%s detected on %s (Timeframe: %s)\nSuperTrend Value: %.5f",
      signalType, TradeSymbol, EnumToString(Timeframe), superTrendValue
   );

   if (EnableAlerts) Alert(message);
   if (EnableEmail) SendMail("SuperTrend Signal Alert", message);
   if (EnablePush) SendNotification(message);

   Print(message);
}
