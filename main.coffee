global.log = (message...) -> console.log message...
global.logError = (message...) -> console.error message...

initMongo = (next) ->
	log 'Подключение к базе данных...'
	require('./mongo').connect () ->
		log 'Подключение к базе данных завершено'
		next()

initCore = (next) ->
	log 'Запуск ядра...'
	require('./core/main').init () ->
		log 'Ядро запущено, торги начались'
		next()

require('./util').queue(
	initMongo
	initCore
)