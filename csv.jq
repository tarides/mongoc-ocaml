inputs
| split(",")
| {
    "timestamp": .[0],
    "open": .[1] | tonumber,
    "high": .[2] | tonumber,
    "low": .[3] | tonumber,
    "close": .[4] | tonumber,
    "volume": .[5] | tonumber,
    "quote_asset_volume": .[6] | tonumber,
    "number_of_trades": .[7] | tonumber,
    "taker_buy_base_asset_volume": .[8] | tonumber,
    "taker_buy_quote_asset_volume": .[9] | tonumber
  }
