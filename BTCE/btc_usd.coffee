pair = 'btc_usd'
name = "[BTCE #{pair}]"
trader = require './trader'
tickTime = 2500
buy = 0
sell = 0
lastBuy = 0
lastSell = 0
usd = 0
btc = 0
serverTime = 0

trade = () ->
	getAccountState () -> cleaner () -> getPairState () -> action()

getAccountState = (next) ->
	trader.info {
		success: (value) ->
			try
				data = value.return
				funds = data.funds
				usd = funds.usd
				btc = funds.btc
				serverTime = data.server_time
				next()
			catch
				logError "#{name} Ошибка формата состояния аккаунта"
		failure: ()	->
			logError "#{name} Ошибка получения текущей информации"
	}

cleaner = (next) ->
	trader.orders {
		pair
		success: (value) ->
			if not value then next()

			try
				for id, order of value.return
					created = order.timestamp_created
					buffer = serverTime - (tickTime * 30 / 1000)

					if created < buffer
						trader.cancel({id})
			catch
				logError "#{name} Ошибка формата списка ордеров"
					
			next()
		failure: () ->
			logError "#{name} Проблемы с получением списка ордеров"
	}

getPairState = (next) ->
	trader.ticker {
		pair
		success: (value) ->
			try
				ticker = value.ticker
				lastBuy = buy
				lastSell = sell
				buy = ticker.buy
				sell = ticker.sell
				next()
			catch
				logError "#{name} Ошибка формата тикера"
	}

action = () ->
	if not lastSell then return

	minBtc = 0.01	
		
	if btc and btc > minBtc
		trader.sell {
			pair
			rate: toFixed3(buy - (buy - sell) / 2.5),
			amount: btc
		}

	buyRate = toFixed3((buy + sell) / 2)
	buyAmount = toFixed5(usd / sell - 0.001)

	if buyAmount > minBtc and usd and buy > lastBuy
		trader.buy {
			pair
			rate: buyRate,
			amount: buyAmount
		}

toFixed3 = (value) ->
	toFixed(value, 3)

toFixed5 = (value) ->
	toFixed(value, 5)

toFixed = (value, dot)	->
	+(value.toFixed(dot))

trade()
setInterval trade, tickTime