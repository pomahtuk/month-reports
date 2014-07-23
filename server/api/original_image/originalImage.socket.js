/**
 * Broadcast updates to client when the model changes
 */

'use strict';

var originalImage = require('./originalImage.model');

exports.register = function(socket) {
  originalImage.schema.post('save', function (doc) {
    onSave(socket, doc);
  });
  originalImage.schema.post('remove', function (doc) {
    onRemove(socket, doc);
  });
}

function onSave(socket, doc, cb) {
  socket.emit('originalImage:save', doc);
}

function onRemove(socket, doc, cb) {
  socket.emit('originalImage:remove', doc);
}
