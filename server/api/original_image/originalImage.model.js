'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var OriginalImageSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  croppedImages : [{ type: Schema.Types.ObjectId, ref: 'CroppedImage' }],
  awsKey: String,
  name: String,
  size: Number,
  aws: Boolean,
  url: String
});

module.exports = mongoose.model('OriginalImage', OriginalImageSchema);
