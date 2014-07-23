/**
 * Main application file
 */

'use strict';

// Set default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

var express = require('express');
var mongoose = require('mongoose');
var config = require('./config/environment');
var session = require('express-session');
var cookieParser = require('cookie-parser');
var mongoStore  = require('connect-mongo')(session);

// Connect to database
mongoose.connect(config.mongo.uri, config.mongo.options);
// debug requests
mongoose.set('debug', true);

// Populate DB with sample data
if(config.seedDB) { require('./config/seed'); }

// Setup server
var app = express();
var server = require('http').createServer(app);
var socketio = require('socket.io').listen(server);
app.use(cookieParser());
app.use(session({
  secret: 'so much secret so manager',
  store: new mongoStore({
    url: config.mongo.uri,
    collection: 'managers_reposrts_auth'
  }, function() {
    console.log('session db connection open');
  })
}));
require('./config/socketio')(socketio);
require('./config/express')(app);
require('./routes')(app);

// Start server
server.listen(config.port, config.ip, function () {
  console.log('Express server listening on %d, in %s mode', config.port, app.get('env'));
});

// Expose app
exports = module.exports = app;
