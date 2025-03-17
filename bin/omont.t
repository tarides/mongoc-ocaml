  $ mongosh --eval 'use foo; db.dropDatabase()'
  switched to db foo;

  $ ./omong.exe list
  admin.system.version
  bitcoin.price_2017_2023
  config.system.sessions
  local.startup_log

  $ ./omong.exe import foo bar bitcoin_2017_to_2023.csv.head
  Collection bar has 9 documents

  $ ./omong.exe find foo bar | tail +2 | jq "del(._id)"
  {
    "timestamp": "2023-08-01 13:19:00",
    "open": 28902.479999999999563,
    "high": 28902.490000000001601,
    "low": 28902.479999999999563,
    "close": 28902.490000000001601,
    "volume": 4.6865800000000001901,
    "quote_asset_volume": 135453.79365750000579,
    "number_of_trades": 258,
    "taker_buy_base_asset_volume": 0.89390999999999998238,
    "taker_buy_quote_asset_volume": 25836.224835900000471
  }
  {
    "timestamp": "2023-08-01 13:18:00",
    "open": 28902.479999999999563,
    "high": 28902.490000000001601,
    "low": 28902.479999999999563,
    "close": 28902.490000000001601,
    "volume": 4.7758900000000004127,
    "quote_asset_volume": 138035.08766180000384,
    "number_of_trades": 317,
    "taker_buy_base_asset_volume": 2.2454600000000000115,
    "taker_buy_quote_asset_volume": 64899.385195399998338
  }
  {
    "timestamp": "2023-08-01 13:17:00",
    "open": 28908.520000000000437,
    "high": 28908.529999999998836,
    "low": 28902.479999999999563,
    "close": 28902.490000000001601,
    "volume": 11.522629999999999484,
    "quote_asset_volume": 333053.15091460000258,
    "number_of_trades": 451,
    "taker_buy_base_asset_volume": 2.7087300000000000821,
    "taker_buy_quote_asset_volume": 78290.170120700000552
  }
  {
    "timestamp": "2023-08-01 13:16:00",
    "open": 28907.409999999999854,
    "high": 28912.740000000001601,
    "low": 28907.409999999999854,
    "close": 28908.529999999998836,
    "volume": 15.896100000000000563,
    "quote_asset_volume": 459555.61986560001969,
    "number_of_trades": 483,
    "taker_buy_base_asset_volume": 10.229810000000000514,
    "taker_buy_quote_asset_volume": 295738.16691570001421
  }
  {
    "timestamp": "2023-08-01 13:15:00",
    "open": 28896.0,
    "high": 28907.419999999998254,
    "low": 28893.029999999998836,
    "close": 28907.409999999999854,
    "volume": 37.746569999999998402,
    "quote_asset_volume": 1090760.5222002000082,
    "number_of_trades": 686,
    "taker_buy_base_asset_volume": 16.504519999999999413,
    "taker_buy_quote_asset_volume": 476955.24661099998048
  }
  {
    "timestamp": "2023-08-01 13:14:00",
    "open": 28890.400000000001455,
    "high": 28896.0,
    "low": 28890.389999999999418,
    "close": 28895.990000000001601,
    "volume": 9.8886900000000004241,
    "quote_asset_volume": 285717.31710200000089,
    "number_of_trades": 389,
    "taker_buy_base_asset_volume": 5.4641700000000001936,
    "taker_buy_quote_asset_volume": 157873.63069029999315
  }
  {
    "timestamp": "2023-08-01 13:13:00",
    "open": 28889.630000000001019,
    "high": 28890.400000000001455,
    "low": 28889.630000000001019,
    "close": 28890.389999999999418,
    "volume": 17.878710000000001656,
    "quote_asset_volume": 516515.89253120002104,
    "number_of_trades": 266,
    "taker_buy_base_asset_volume": 16.193490000000000606,
    "taker_buy_quote_asset_volume": 467829.89169439999387
  }
  {
    "timestamp": "2023-08-01 13:12:00",
    "open": 28881.540000000000873,
    "high": 28889.639999999999418,
    "low": 28881.529999999998836,
    "close": 28889.639999999999418,
    "volume": 13.481529999999999347,
    "quote_asset_volume": 389423.48334839998279,
    "number_of_trades": 500,
    "taker_buy_base_asset_volume": 11.586909999999999599,
    "taker_buy_quote_asset_volume": 334697.03992900002049
  }
  {
    "timestamp": "2023-08-01 13:11:00",
    "open": 28876.0,
    "high": 28881.540000000000873,
    "low": 28875.990000000001601,
    "close": 28881.540000000000873,
    "volume": 6.8592399999999997817,
    "quote_asset_volume": 198082.9342459999898,
    "number_of_trades": 274,
    "taker_buy_base_asset_volume": 5.9331500000000003681,
    "taker_buy_quote_asset_volume": 171339.62757620000048
  }

  $ ./omong.exe drop foo bar

  $ mongosh list.js
  admin.system.version
  bitcoin.price_2017_2023
  config.system.sessions
  local.startup_log

