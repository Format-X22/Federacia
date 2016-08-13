// Generated by CoffeeScript 1.10.0
(function() {
  var initCore, initMongo,
    slice = [].slice;

  global.log = function() {
    var message;
    message = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return console.log.apply(console, message);
  };

  global.logError = function() {
    var message;
    message = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return console.error.apply(console, message);
  };

  initMongo = function(next) {
    log('Подключение к базе данных...');
    return require('./mongo').connect(function() {
      log('Подключение к базе данных завершено');
      return next();
    });
  };

  initCore = function() {
    log('Запуск ядра...');
    require('./BTCE/btc_usd');
    return log('Ядро запущено, торги начались');
  };

  initMongo(function() {
    return initCore();
  });

}).call(this);

//# sourceMappingURL=main.js.map
