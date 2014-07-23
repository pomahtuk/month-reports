'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var CroppedImageSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  originalImage: { type: Schema.Types.ObjectId, ref: 'OriginalImage' },
  selection: String,
  name: String,
  size: Number,
  url: String
});

module.exports = mongoose.model('CroppedImage', CroppedImageSchema);
