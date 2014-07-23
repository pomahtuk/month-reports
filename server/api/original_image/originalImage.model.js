'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var OriginalImageSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  croppedImages : [{ type: Schema.Types.ObjectId, ref: 'CroppedImage' }],
  name: String,
  size: Number,
  url: String
});

module.exports = mongoose.model('OriginalImage', OriginalImageSchema);
