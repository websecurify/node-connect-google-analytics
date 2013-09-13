https = require 'https'

# ---

post = (query, callback) ->
	query = ("#{key}=#{encodeURIComponent(value)}" for key, value of query when value).join '&'
	options =
		host: 'www.google-analytics.com'
		path: '/collect'
		headers:
			'Content-Type': 'application/x-www-form-urlencoded',
			'Content-Length': query.length
			
	request = https.request options, (res) ->
		return callback new Error 'cannot send for collection' if res.statusCode != 200
		
		res.on 'close', callback
		
	request.on 'error', (error) ->
		return callback error
		
	request.write(query)
	request.end()
	
# ---

exports.middleware = (config={}) ->
	(req, res, next) ->
		res.ga ?= res.analytics ?= {}
		res.ga.collect ?= res.analytics.collect ?= {}
		
		res.ga.collect.event = res.analytics.collect.event = (options, callback) ->
			options ?= {}
			callback ?= () ->
			
			query =
				v: 1
				tid: options.trackingId or config.trackingId or null
				cid: options.clientId or null
				t: 'event',
				ec: options.category or null
				ea: options.action or null
				el: options.label or null
				ev: options.value or null
				
			return callback new Error 'no tracking id specified' if not query.tid
			return callback new Error 'no client id specified' if not query.cid
			return callback new Error 'no category specified' if not query.ec
			return callback new Error 'no action specified' if not query.ea
			
			if config.debug or options.debug
				console.log query if config.debug or options.debug
			else
				post query, callback
				
		return next()
		
