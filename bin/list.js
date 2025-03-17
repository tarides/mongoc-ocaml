db.adminCommand({ listDatabases: 1 }).databases.forEach(function(dbInfo) {
  use(dbInfo.name);
  db.getCollectionNames().forEach(function(collectionName) {
    print(`${dbInfo.name}.${collectionName}`);
  });
});
