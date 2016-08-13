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

trade = () ->
	getAccountState () -> getPairState () -> action()

getAccountState = (next) ->
	trader.info {
		success: (value) ->
			try
				funds = value.return.funds
				usd = funds.usd
				btc = funds.btc
				next()
			catch
				logError "#{name} Ошибка формата состояния аккаунта"
		failure: ()	->
			logError "#{name} Ошибка получения текущей информации"
	}

getPairState = (next) ->
	trader.ticker {
		pair,
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