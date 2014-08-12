'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var ProjectSchema = new Schema({
  name_ru: String,
  name_en: String
});

module.exports = mongoose.model('Project', ProjectSchema);
