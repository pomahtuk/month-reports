'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var ExpensearticleSchema = new Schema({
  name_ru: String,
  name_en: String
});

module.exports = mongoose.model('Expensearticle', ExpensearticleSchema);
