https = require 'https'

# ---

exports.post = (query, callback) ->
	query = ("#{key}=#{encodeURIComponent(value)}" for key, value of query when value).join '&'
	
	options =
		method: 'POST'
		host: 'www.google-analytics.com'
		path: '/collect'
		headers:
			'Content-Type': 'application/x-www-form-urlencoded'
			'Content-Length': query.length
			'User-Agent': 'CGA/0.0.4 (+http://github.com/websecurify/connect-google-analytics)'
			
	request = https.request options, (res) ->
		return callback new Error 'cannot send for collection' if res.statusCode != 200
		
		res.on 'close', callback
		
	request.on 'error', (error) ->
		return callback error
		
	request.write(query)
	request.end()
	
# ---

exports.event = (options, callback) ->
	return callback new Error 'no tracking id specified' if not options.trackingId
	return callback new Error 'no client id specified' if not options.clientId
	return callback new Error 'no category specified' if not options.category
	return callback new Error 'no action specified' if not options.action
	
	callback ?= () ->
	
	query =
		v: 1
		tid: options.trackingId
		cid: options.clientId
		t: 'event'
		ec: options.category
		ea: options.action
		el: options.label
		ev: options.value
		
	if options.debug
		console.log query
		
		return callback null
	else
		exports.post query, callback
		
# ---

exports.middleware = (config={}) ->
	(req, res, next) ->
		res.ga ?= res.analytics ?= {}
		res.ga.collect ?= res.analytics.collect ?= {}
		
		res.ga.collect.event = res.analytics.collect.event = (options, callback) ->
			options.trackingId ?= config.trackingId
			
			exports.event callback
			
		return do next
		
