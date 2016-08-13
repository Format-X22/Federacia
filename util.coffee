exports.queue = (callbacks, defaultScope) ->
	index = 0

	if not (callbacks instanceof Array)
		callbacks = [].slice.call(arguments)

	self = () ->
		fn = callbacks[index++]
		fn && fn.call defaultScope, self

	self()