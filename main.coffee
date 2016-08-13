global.log = (message...) -> console.log message...
global.logError = (message...) -> console.error message...

initMongo = (next) ->
	log 'Подключение к базе данных...'
	require('./mongo').connect () ->
		log 'Подключение к базе данных завершено'
		next()

initCore = () ->
	log 'Запуск ядра...'
	require('./BTCE/btc_usd')
	log 'Ядро запущено, торги начались'

initMongo () -> initCore()