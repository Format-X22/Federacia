request = require 'request'
querystring = require 'querystring'
sha = require 'crypto-js/hmac-sha512'
key = '09B5K4AX-PWF0M87C-EVAXIO8S-1E9BNZHZ-EFVWYUYY'
secret = '517b8dbf6af2783ad4e4e8aeb19af368a590d2c41987d49f74ccf23006caebd5'
url = 'https://btc-e.nz/tapi'
nonce = 0

info = () ->
	log '[BTCE] Запрос тикера'

	send {
		opt:
			method: 'getInfo'
	}

buy = (opt) ->
	log "[BTCE] Выставление на продажу #{JSON.stringify(opt)}"

	opt.type = 'buy'

	trade opt

sell = (opt) ->
	log "[BTCE] Выставление на покупку #{JSON.stringify(opt)}"

	opt.type = 'sell'

	trade opt

ticker = (pair) ->
	send {
		url: "https://btc-e.nz/api/2/#{pair}/ticker",
		method: 'GET'
	}

module.exports = {
	info
	buy
	sell
	ticker
}

trade = (opt) ->
	opt.method = 'Trade'

	send {
		opt
	}

send = (config) ->
	configureRequest config, (params) ->
		target = config.url or url

		request target, params, (error, response, body) ->
			body = parseBody body

			failure = error or body.success is 0

			if failure
				logError '[E][BTCE] Проблемы с драйвером', error, body
				config.failure? error, body
			else
				log "[BTCE] Тело результата: #{try JSON.stringify(body)}"
				config.success? body

			config.always? error, body

configureRequest = (config, next) ->
	getNonce config, (nonce) ->
		opt = config.opt or {}
		opt.param = 0
		opt.value = 0
		opt.nonce = nonce
		query = querystring.stringify opt
		
		next {
			method: config.method or 'POST',
			form: opt
			headers:
				key: key,
				sign: sha query, secret
		}

getNonce = (config, next) ->
	if config.url then next

	if nonce 
		next ++nonce
		# TODO nonce to mongo

	# TODO get nonce from mongo
	nonce = 11
	next nonce

parseBody = (body) ->
	try
		return JSON.parse(body)
	catch
		return {
			success: 0,
			robotDriverError: 'Can not parse body'
		}
