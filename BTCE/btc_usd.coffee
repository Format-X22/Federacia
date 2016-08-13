pair = 'btc_usd'
name = "[BTCE #{pair}]"
trader = require './trader'
tickTime = 3000
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
					buffer = serverTime - (tickTime * 15 / 1000)

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

	if btc and sell < lastSell
		trader.sell {
			pair
			rate: +((sell * 1.00001).toFixed(3)),
			amount: btc
		}
		return

	buyAmount = +(((usd / sell) - 0.001).toFixed(5))

	if buyAmount and usd and buy > lastBuy
		trader.buy {
			pair
			rate: sell,
			amount: buyAmount
		}
		return

trade()
setInterval trade, tickTime