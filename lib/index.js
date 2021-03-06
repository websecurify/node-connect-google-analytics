// Generated by CoffeeScript 1.6.3
(function() {
  var https;

  https = require('https');

  exports.post = function(query, callback) {
    var key, options, request, value;
    query = ((function() {
      var _results;
      _results = [];
      for (key in query) {
        value = query[key];
        if (value) {
          _results.push("" + key + "=" + (encodeURIComponent(value)));
        }
      }
      return _results;
    })()).join('&');
    options = {
      method: 'POST',
      host: 'www.google-analytics.com',
      path: '/collect',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': query.length,
        'User-Agent': 'CGA/0.0.4 (+http://github.com/websecurify/connect-google-analytics)'
      }
    };
    request = https.request(options, function(res) {
      if (res.statusCode !== 200) {
        return callback(new Error('cannot send for collection'));
      }
      return res.on('close', callback);
    });
    request.on('error', function(error) {
      return callback(error);
    });
    request.write(query);
    return request.end();
  };

  exports.event = function(options, callback) {
    var query;
    if (!options.trackingId) {
      return callback(new Error('no tracking id specified'));
    }
    if (!options.clientId) {
      return callback(new Error('no client id specified'));
    }
    if (!options.category) {
      return callback(new Error('no category specified'));
    }
    if (!options.action) {
      return callback(new Error('no action specified'));
    }
    if (callback == null) {
      callback = function() {};
    }
    query = {
      v: 1,
      tid: options.trackingId,
      cid: options.clientId,
      t: 'event',
      ec: options.category,
      ea: options.action,
      el: options.label,
      ev: options.value
    };
    if (options.debug) {
      console.log(query);
      return callback(null);
    } else {
      return exports.post(query, callback);
    }
  };

  exports.middleware = function(config) {
    if (config == null) {
      config = {};
    }
    return function(req, res, next) {
      var _base, _base1;
      if (res.ga == null) {
        res.ga = res.analytics != null ? res.analytics : res.analytics = {};
      }
      if ((_base = res.ga).collect == null) {
        _base.collect = (_base1 = res.analytics).collect != null ? (_base1 = res.analytics).collect : _base1.collect = {};
      }
      res.ga.collect.event = res.analytics.collect.event = function(query, callback) {
        if (query.debug == null) {
          query.debug = config.debug;
        }
        if (query.trackingId == null) {
          query.trackingId = config.trackingId;
        }
        return exports.event(query, callback);
      };
      return next();
    };
  };

}).call(this);
