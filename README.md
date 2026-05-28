# supertrend-indicator-mt4# SuperTrend Indicator Alert — MQL4 Script

A MetaTrader 4 script that computes the **SuperTrend line** via a dedicated `CalculateSuperTrend()` function using `iATR()`, `iHigh()`, and `iLow()` to construct both the upper and lower ATR bands and selects the active band via the `IsBullish` persistent boolean state variable, and fires buy or sell signal alerts when the `IsBullish` state changes — comparing the current close against the computed SuperTrend value each minute cycle.

---

## Overview

The SuperTrend indicator derives its signal from a straightforward but powerful premise: define a volatility envelope using ATR, then select which side of the envelope price is tracking based on prior directional state. When price is in a bullish phase, the SuperTrend trails below price at `MathMin(basicUpperBand, PrevSuperTrend)` — only moving lower, never higher, to tighten the trail as the trend matures. When price is in a bearish phase, it trails above price at `MathMax(basicLowerBand, PrevSuperTrend)` — only moving higher. This ratchet behavior means the SuperTrend line can only move in ways that benefit the trend follower: tightening the stop in the trend's direction and flipping only when price definitively crosses through it. This second implementation encapsulates the computation in a `CalculateSuperTrend()` function that uses `iHigh` and `iLow` for midpoint calculation (an alternative to close-based bands), and uses the `IsBullish` boolean for both band selection and signal classification.

---

## Features

- **`CalculateSuperTrend()` encapsulated computation** — `atr = iATR(...)`, `high = iHigh(...)`, `low = iLow(...)`; `basicUpperBand = (high + low) / 2 + Multiplier × atr`; `basicLowerBand = (high + low) / 2 − Multiplier × atr` — uses HL midpoint rather than close for band anchoring
- **`IsBullish`-gated band selection** — `finalUpperBand = MathMin(basicUpperBand, PrevSuperTrend)`; `finalLowerBand = MathMax(basicLowerBand, PrevSuperTrend)`; returns `IsBullish ? finalLowerBand : finalUpperBand`
- **Signal type classification** — `IsBullish && currentPrice < currentSuperTrend` → **Sell Signal** (bullish phase ending); `!IsBullish && currentPrice > currentSuperTrend` → **Buy Signal** (bearish phase ending); `IsBullish` updated accordingly after signal fire
- **`PrevSuperTrend` continuity persistence** — global double updated to `currentSuperTrend` at cycle end, maintaining band ratchet across the full session loop
- **Three notification channels:** sound alert, email, and mobile push
- **Lightweight loop** — polls once per minute (`Sleep(60000)`)

---

## How It Works

1. Every minute, `CalculateSuperTrend()` computes both bands using HL midpoint + ATR; returns active band based on `IsBullish`
2. Flip conditions evaluated:
   - `IsBullish && currentPrice < currentSuperTrend` → **Sell Signal**; `IsBullish = false`
   - `!IsBullish && currentPrice > currentSuperTrend` → **Buy Signal**; `IsBullish = true`
3. `PrevSuperTrend = currentSuperTrend` updated at cycle end

---

## Input Parameters

| Parameter       | Type            | Default     | Description                                     |
|-----------------|-----------------|-------------|-------------------------------------------------|
| `TradeSymbol`   | string          | `EURUSD`    | Symbol for analysis                             |
| `Timeframe`     | ENUM_TIMEFRAMES | `PERIOD_H1` | Timeframe for analysis                          |
| `ATRPeriod`     | int             | `10`        | ATR period for band width calculation           |
| `Multiplier`    | double          | `3.0`       | Multiplier applied to ATR for band width        |
| `EnableAlerts`  | bool            | `true`      | Fire an on-screen/sound alert                   |
| `EnableEmail`   | bool            | `false`     | Send an email notification                      |
| `EnablePush`    | bool            | `false`     | Send a mobile push notification                 |

---

## Alert Message Format

```
Buy Signal detected on EURUSD (Timeframe: PERIOD_H1)
SuperTrend Value: 1.08145
```

---

## Installation

1. Copy `SuperTrend_Indicator_001.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Drag onto any chart from Navigator → Scripts
4. Configure inputs and click **OK**

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
