/*jslint indent: 2, node: true*/
/*global process, require, console, exports, module*/

/**
 * Main application routes
 */

'use strict';

var errors = require('./components/errors');
var aws = require('./api/aws');

module.exports = function (app) {

  // Insert routes below
  app.use('/api/expenseArticles', require('./api/expenseArticle'));
  app.use('/api/projects', require('./api/project'));
  app.use('/api/receiptRecords', require('./api/receipt_record'));
  app.use('/api/croppedImages', require('./api/cropped_image'));
  app.use('/api/originalImages', require('./api/original_image'));
  app.use('/api/things', require('./api/thing'));
  app.use('/api/users', require('./api/user'));
  app.use('/api/uploads', require('./api/uploads'));

  app.get('/api/config', aws.getClientConfig);
  app.get('/api/s3Policy', aws.getS3Policy);

  app.use('/auth', require('./auth'));

  // All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*')
    .get(errors[404]);

  // All other routes should redirect to the index.html
  app.route('/*')
    .get(function (req, res) {
      res.sendfile(app.get('appPath') + '/index.html');
    });
};
