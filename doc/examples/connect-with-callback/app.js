var connect = require('connect');
var googleAnalytics = require('../../../lib/index');

// ---

connect().use(googleAnalytics.middleware()).use(function(req, res){
	res.ga.collect.event({trackingId: 'TID', clientId: 'CID', category: 'Request', action: 'get', label: req.url});
	
	res.end('<html><body><h1>Hello World</h1></body></html>\n');
}).listen(3000);
