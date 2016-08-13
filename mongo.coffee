dataBaseLink = cfg.mongo.dataBaseLink
reconnectTime = 60 * 1000
driver = require('mongodb')
client = driver.MongoClient
objectIdMaker = driver.ObjectID
dbObject = null

exports.connect = (callback) ->
	client.connect dataBaseLink, (error, database) ->
		if error
			logError error
			logError 'Ошибка подключения к базе данных, попытка переподключения...'
			reconnect(callback)
		else
			log 'Успешное подключение к базе данных.'
			dbObject = database
			callback database

exports.reconnect = (callback)	->
	setTimeout(
		() -> connect(callback),
		reconnectTime
	)

exports.collection = (name) ->
	try
		return dbObject.collection(name)
	catch error
		logError error
		logError 'Невозможно получить коллекцию базы данных, попытка переподключения к базе данных...'
		return null

exports.makeId = (value) ->
	try
		return objectIdMaker value
	catch
		return null