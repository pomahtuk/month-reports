'use strict';

var _ = require('lodash');
var Expensearticle = require('./expenseArticle.model');

// Get list of expenseArticles
exports.index = function(req, res) {
  Expensearticle.find(function (err, expenseArticles) {
    if(err) { return handleError(res, err); }
    return res.json(200, expenseArticles);
  });
};

// Get a single expenseArticle
exports.show = function(req, res) {
  Expensearticle.findById(req.params.id, function (err, expenseArticle) {
    if(err) { return handleError(res, err); }
    if(!expenseArticle) { return res.send(404); }
    return res.json(expenseArticle);
  });
};

// Creates a new expenseArticle in the DB.
exports.create = function(req, res) {
  Expensearticle.create(req.body, function(err, expenseArticle) {
    if(err) { return handleError(res, err); }
    return res.json(201, expenseArticle);
  });
};

// Updates an existing expenseArticle in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Expensearticle.findById(req.params.id, function (err, expenseArticle) {
    if (err) { return handleError(err); }
    if(!expenseArticle) { return res.send(404); }
    var updated = _.merge(expenseArticle, req.body);
    updated.save(function (err) {
      if (err) { return handleError(err); }
      return res.json(200, expenseArticle);
    });
  });
};

// Deletes a expenseArticle from the DB.
exports.destroy = function(req, res) {
  Expensearticle.findById(req.params.id, function (err, expenseArticle) {
    if(err) { return handleError(res, err); }
    if(!expenseArticle) { return res.send(404); }
    expenseArticle.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}