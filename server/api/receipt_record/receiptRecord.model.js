'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var ReceiptRecordSchema = new Schema({
  user: { type: Schema.Types.ObjectId, ref: 'User' },
  image: { type: Schema.Types.ObjectId, ref: 'CroppedImage' },
  created: { type: Date, default: Date.now },
  updated: { type: Date, default: Date.now },
  filled: Boolean,
  Posted: { type: Date, default: Date.now },
  Occurred: { type: Date, default: Date.now },
  MerchantName: String,
  MerchantCity: String,
  MerchantState: String,
  MerchantZipCode: String,
  MCC_SICCode: String,
  MCCDescription: String,
  OriginalAmount: String,
  CurrencyDesc: String,
  ConversionRate: String,
  BilledAmount: String,
  Memo: String,
  DebitCredit: String,
  ReferenceNbr: String,
  StatementCycle: String,
  AccountName: String,
  AccountNumber: String
});

module.exports = mongoose.model('ReceiptRecord', ReceiptRecordSchema);
