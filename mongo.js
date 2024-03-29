// Generated by CoffeeScript 1.10.0
(function() {
  var client, dataBaseLink, dbObject, driver, objectIdMaker, reconnectTime;

  dataBaseLink = cfg.mongo.dataBaseLink;

  reconnectTime = 60 * 1000;

  driver = require('mongodb');

  client = driver.MongoClient;

  objectIdMaker = driver.ObjectID;

  dbObject = null;

  exports.connect = function(callback) {
    return client.connect(dataBaseLink, function(error, database) {
      if (error) {
        logError(error);
        logError('Ошибка подключения к базе данных, попытка переподключения...');
        return reconnect(callback);
      } else {
        log('Успешное подключение к базе данных.');
        dbObject = database;
        return callback(database);
      }
    });
  };

  exports.reconnect = function(callback) {
    return setTimeout(function() {
      return connect(callback);
    }, reconnectTime);
  };

  exports.collection = function(name) {
    var error, error1;
    try {
      return dbObject.collection(name);
    } catch (error1) {
      error = error1;
      logError(error);
      logError('Невозможно получить коллекцию базы данных, попытка переподключения к базе данных...');
      return null;
    }
  };

  exports.makeId = function(value) {
    var error1;
    try {
      return objectIdMaker(value);
    } catch (error1) {
      return null;
    }
  };

}).call(this);

//# sourceMappingURL=mongo.js.map
