/**
 * Broadcast updates to client when the model changes
 */

'use strict';

var Expensearticle = require('./expenseArticle.model');

exports.register = function(socket) {
  Expensearticle.schema.post('save', function (doc) {
    onSave(socket, doc);
  });
  Expensearticle.schema.post('remove', function (doc) {
    onRemove(socket, doc);
  });
}

function onSave(socket, doc, cb) {
  socket.emit('expenseArticle:save', doc);
}

function onRemove(socket, doc, cb) {
  socket.emit('expenseArticle:remove', doc);
}