module.exports = (config) ->
	{
		stock,
		pair,
		tickTime,
		orderMargin,
		ticksToReset = tickTime * 10,
		dogMargin = 50,
		dogStop = 100
	} = config

	name = "[#{stock} #{pair}]"
	[leftName, rightName] = pair.split '_'

	orders = []
	waitTime = 0
	left = 0
	right = 0
	serverTime = 0

	lastTrade = null
	dogTime = tickTime * dogMargin
	dogCalls = 0

	trader = require "./#{stock}/trader"

	trade()
	setInterval dog, dogTime

	trade = () ->
		lastTradeTick()
		getAccount -> getDepth -> filterOrders -> action -> wait -> trade()

	getAccount = (next) ->
		trader.info {
			success: (value) ->
				data = value.return
				funds = data.funds
				left = funds[leftName]
				right = funds[rightName]
				serverTime = data.server_time

				next()
			failure: rise
		}

	getDepth = (next) ->
		trader.depth {
			success: (value) ->
				#
				next()
			failure: rise
		}

	filterOrders = (next) ->
		orders.filter
		next()

	action = (next) ->
		#
		next()

	wait = (next) ->
	    #
		next()

	lastTradeTick = () ->
		lastTrade = new Date

	rise = () ->
		wait -> trade()

	dog = () ->
		margin = new Date - dogTime

		if ++dogCalls > dogStop then return

		if lastTrade < margin
			log "#{name} Перезапуск ватчдогом"
			trade()