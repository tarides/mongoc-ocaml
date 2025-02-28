use bitcoin

db.price_2017_2023.find({
  "timestamp": {
    "$gt": "2022-07-28 10:00:00",
    "$lte": "2022-07-28 10:10:00"
  }
})
