// Generated by CoffeeScript 1.10.0
(function() {
  var buy, cancel, configureRequest, depth, getNonce, info, key, name, nonce, orders, parseBody, querystring, request, resultParser, secret, sell, send, sha, ticker, trade, url;

  name = '[BTCE]';

  request = require('request');

  querystring = require('querystring');

  sha = require('crypto-js/hmac-sha512');

  key = '09B5K4AX-PWF0M87C-EVAXIO8S-1E9BNZHZ-EFVWYUYY';

  secret = '517b8dbf6af2783ad4e4e8aeb19af368a590d2c41987d49f74ccf23006caebd5';

  url = 'https://btc-e.nz/tapi';

  nonce = 0;

  info = function(config) {
    config.opt = {
      method: 'getInfo'
    };
    return send(config);
  };

  depth = function(config) {
    config.api = 3;
    config.opt = {
      method: 'depth'
    };
    return send(config);
  };

  buy = function(opt) {
    log(name + " >> Покупка " + (JSON.stringify(opt)));
    opt.type = 'buy';
    return trade(opt);
  };

  sell = function(opt) {
    log(name + " << Продажа " + (JSON.stringify(opt)));
    opt.type = 'sell';
    return trade(opt);
  };

  ticker = function(config) {
    var api;
    api = config.api || 2;
    config.url = "https://btc-e.nz/api/" + api + "/" + config.pair + "/ticker";
    config.method = 'GET';
    return send(config);
  };

  orders = function(config) {
    config.opt = {
      method: 'ActiveOrders'
    };
    return send(config);
  };

  cancel = function(config) {
    log(name + " Отмена " + (JSON.stringify(config.id)));
    config.opt = {
      order_id: +config.id,
      method: 'CancelOrder'
    };
    return send(config);
  };

  module.exports = {
    info: info,
    depth: depth,
    buy: buy,
    sell: sell,
    ticker: ticker,
    orders: orders,
    cancel: cancel
  };

  trade = function(opt) {
    opt.method = 'Trade';
    return send({
      opt: opt
    });
  };

  send = function(config) {
    return configureRequest(config, function(params) {
      var target;
      target = config.url || url;
      return request(target, params, resultParser(config));
    });
  };

  resultParser = function(config) {
    return function(error, response, body) {
      var error1, failure;
      body = parseBody(body);
      failure = error || (body.success === 0 && body.error !== 'no orders');
      try {
        if (failure) {
          logError(name + " Проблемы", error, config, body);
          if (typeof config.failure === "function") {
            config.failure(error, body);
          }
        } else {
          if (typeof config.success === "function") {
            config.success(body);
          }
        }
        return typeof config.always === "function" ? config.always(error, body) : void 0;
      } catch (error1) {
        error = error1;
        return logError(name + " Ошибка колбека", error, config, body);
      }
    };
  };

  configureRequest = function(config, next) {
    return getNonce(config, function(nonce) {
      var opt, query;
      opt = config.opt || {};
      opt.param = 0;
      opt.value = 0;
      opt.nonce = nonce;
      query = querystring.stringify(opt);
      return next({
        method: config.method || 'POST',
        form: opt,
        headers: {
          key: key,
          sign: sha(query, secret)
        }
      });
    });
  };

  getNonce = function(config, next) {
    if (config.url) {
      next();
      return;
    }
    if (nonce) {
      next(++nonce);
      return;
    }
    return next(nonce = 51325);
  };

  parseBody = function(body) {
    var error1;
    try {
      return JSON.parse(body);
    } catch (error1) {
      return {
        success: 0,
        robotDriverError: 'Не возможно распарсить тело'
      };
    }
  };

}).call(this);

//# sourceMappingURL=trader.js.map
