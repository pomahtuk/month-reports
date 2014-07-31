'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var CroppedImageSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  originalImage: { type: Schema.Types.ObjectId, ref: 'OriginalImage' },
  receiptRecord: { type: Schema.Types.ObjectId, ref: 'ReceiptRecord' },
  selection: Schema.Types.Mixed,
  name: String,
  size: Number,
  aws: Boolean,
  url: String
});

module.exports = mongoose.model('CroppedImage', CroppedImageSchema);
