/**
 * Broadcast updates to client when the model changes
 */

'use strict';

var receiptRecord = require('./receiptRecord.model');

exports.register = function(socket) {
  receiptRecord.schema.post('save', function (doc) {
    onSave(socket, doc);
  });
  receiptRecord.schema.post('remove', function (doc) {
    onRemove(socket, doc);
  });
}

function onSave(socket, doc, cb) {
  socket.emit('receiptRecord:save', doc);
}

function onRemove(socket, doc, cb) {
  socket.emit('receiptRecord:remove', doc);
}
