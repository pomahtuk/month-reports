'use strict';

var express = require('express');
var controller = require('./uploads.controller');

var router = express.Router();

router.post('/', controller.index);
router.post('/csv', controller.amazonCSVCallback);
router.post('/crop', controller.createCropedVersion);

module.exports = router;
