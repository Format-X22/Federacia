name = '[BTCE]'
request = require 'request'
querystring = require 'querystring'
sha = require 'crypto-js/hmac-sha512'
key = '09B5K4AX-PWF0M87C-EVAXIO8S-1E9BNZHZ-EFVWYUYY'
secret = '517b8dbf6af2783ad4e4e8aeb19af368a590d2c41987d49f74ccf23006caebd5'
url = 'https://btc-e.nz/tapi'
nonce = 0

info = (config) ->
	config.opt = {
		method: 'getInfo'
	}

	send config

buy = (opt) ->
	log "#{name} Покупка #{JSON.stringify opt}"

	opt.type = 'buy'

	trade opt

sell = (opt) ->
	log "#{name} Продажа #{JSON.stringify opt}"

	opt.type = 'sell'

	trade opt

ticker = (config) ->	
	config.url = "https://btc-e.nz/api/2/#{config.pair}/ticker"
	config.method = 'GET'

	send config

orders = (config)	->
	config.opt = {
		method: 'ActiveOrders'
	}

	send config

cancel = (config) ->
	log "#{name} Отмена #{JSON.stringify config.id}"

	config.opt = {
		order_id: +config.id
		method: 'CancelOrder'
	}

	send config

module.exports = {
	info
	buy
	sell
	ticker
	orders
	cancel
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

			failure = error or (body.success is 0 and body.error isnt 'no orders')

			if failure
				logError "#{name} Проблемы с трейдером", error, body
				config.failure? error, body
			else
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
	if config.url 
		next()
		return

	if nonce
		next ++nonce
		return
		# TODO nonce to mongo

	# TODO get nonce from mongo
	next nonce = 38738

parseBody = (body) ->
	try
		return JSON.parse body
	catch
		return {
			success: 0,
			robotDriverError: 'Не возможно распарсить тело'
		}
