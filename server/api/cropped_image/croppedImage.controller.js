/**
 * Using Rails-like standard naming convention for endpoints.
 * GET     /croppedImages              ->  index
 * POST    /croppedImages              ->  create
 * GET     /croppedImages/:id          ->  show
 * PUT     /croppedImages/:id          ->  update
 * DELETE  /croppedImages/:id          ->  destroy
 */

'use strict';

var _ = require('lodash');
var fs = require('fs');
var path = require('path');
var CroppedImage = require('./croppedImage.model');
var aws = require('../aws');

function handleError(res, err) {
  return res.send(500, err);
}

// Get list of images
exports.index = function (req, res) {
  var findCriteria = {};

  if (req.query.user !== null) {
    findCriteria.user = req.query.user;
  }

  CroppedImage.find(findCriteria).populate('user').exec(function (err, images) {
    if (err) { return handleError(res, err); }
    return res.json(200, images);
  });
};

// Get a single image
exports.show = function (req, res) {
  CroppedImage.findById(req.params.id, function (err, image) {
    if (err) { return handleError(res, err); }
    if (!image) { return res.send(404); }
    return res.json(image);
  });
};

// Creates a new image in the DB.
exports.create = function (req, res) {
  CroppedImage.create(req.body, function (err, image) {
    if (err) { return handleError(res, err); }
    return res.json(201, image);
  });
};

// Updates an existing image in the DB.
exports.update = function (req, res) {
  if (req.body._id) { delete req.body._id; }
  CroppedImage.findById(req.params.id, function (err, image) {
    if (err) { return handleError(err); }
    if (!image) { return res.send(404); }
    var updated = _.merge(image, req.body);
    updated.save(function (err) {
      if (err) { return handleError(err); }
      return res.json(200, image);
    });
  });
};

// Deletes an image from the DB.
exports.destroy = function (req, res) {
  CroppedImage.findById(req.params.id, function (err, image) {
    if (err) { return handleError(res, err); }
    if (!image) { return res.send(404); }
    var new_path = path.join(process.env.PWD, '/client/', image.url);
    image.remove(function (err) {
      if (err) { return handleError(res, err); }
      aws.removeFile(image.awsKey, function (err, data) {
        console.log('deleted original image', data);
      })
      return res.send(204);
    });
  });
};
