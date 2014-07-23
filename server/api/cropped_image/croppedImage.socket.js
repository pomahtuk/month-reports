/**
 * Broadcast updates to client when the model changes
 */

'use strict';

var croppedImage = require('./croppedImage.model');

exports.register = function(socket) {
  croppedImage.schema.post('save', function (doc) {
    onSave(socket, doc);
  });
  croppedImage.schema.post('remove', function (doc) {
    onRemove(socket, doc);
  });
}

function onSave(socket, doc, cb) {
  socket.emit('croppedImage:save', doc);
}

function onRemove(socket, doc, cb) {
  socket.emit('croppedImage:remove', doc);
}
