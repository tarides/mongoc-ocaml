Bitcoin Price Data from

https://www.kaggle.com/datasets/jkraak/bitcoin-price-dataset?resource=download

Tested in Ubuntu 24.04.2

Installed packages:

apt list --installed  | grep mongo

libmongoc-1.0-0t64/noble,now 1.26.0-1.1ubuntu2 amd64 [installed,automatic]
libmongoc-dev/noble,now 1.26.0-1.1ubuntu2 amd64 [installed]
libmongocrypt-dev/noble,now 1.8.4-1build3 amd64 [installed,automatic]
libmongocrypt0/noble,now 1.8.4-1build3 amd64 [installed,automatic]
mongodb-database-tools/noble/mongodb-org/8.0,now 100.11.0 amd64 [installed,automatic]
mongodb-mongosh/noble/mongodb-org/8.0,now 2.4.0 amd64 [installed,automatic]
mongodb-org-database-tools-extra/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed,automatic]
mongodb-org-database/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed,automatic]
mongodb-org-mongos/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed,automatic]
mongodb-org-server/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed,automatic]
mongodb-org-shell/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed,automatic]
mongodb-org-tools/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed,automatic]
mongodb-org/noble/mongodb-org/8.0,now 8.0.5 amd64 [installed]

Start mongo

sudo systemctl start mongod


Create database

mongoimport --db bitcoin --collection price_2017_2023 --file bitcoin_2017_to_2023.csv --type=csv --fields $(head -1 bitcoin_2017_to_2023.csv)
