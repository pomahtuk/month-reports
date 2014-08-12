/**
 * Using Rails-like standard naming convention for endpoints.
 * GET     /receiptRecords              ->  index
 * POST    /receiptRecords              ->  create
 * GET     /receiptRecords/:id          ->  show
 * PUT     /receiptRecords/:id          ->  update
 * DELETE  /receiptRecords/:id          ->  destroy
 */

'use strict';

var _ = require('lodash');
var ReceiptRecord = require('./receiptRecord.model');
require('date-utils');

function handleError(res, err) {
  return res.send(500, err);
}

// Get list of receipts
exports.index = function (req, res) {
  // TODO: add search params?
  var start, end, days,
    findCriteria = {},
    queryString = {},
    user = req.query.user,
    month = req.query.month,
    year = req.query.year;

  if ((typeof month !== "undefined" && month !== null) && (typeof year !== "undefined" && year !== null)) {
    month = parseInt(month, 10);
    year = parseInt(year, 10);
    days = Date.getDaysInMonth(year, month);
    start = new Date(month + ".01." + year);
    end = new Date(month + "." + days + "." + year);
    queryString = {
      'Posted': { '$gt' : start, '$lt' : end }
    };
    // console.log(queryString);
  }

  if (typeof user !== "undefined" && user !== null)  {
    findCriteria.user = req.query.user;
  }

  _.merge(findCriteria, queryString);

  // console.log(findCriteria);

  ReceiptRecord.find(findCriteria)
    .populate('user')
    .populate('image')
    .populate('Project')
    .populate('Article')
    .exec(function (err, receipts) {
      if (err) { return handleError(res, err); }
      return res.json(200, receipts);
    });
};

// Get a single receipt
exports.show = function (req, res) {
  ReceiptRecord.findById(req.params.id)
    .populate('user')
    .populate('image')
    .populate('Project')
    .populate('Article')
    .exec(function (err, receipt) {
      if (err) { return handleError(res, err); }
      if (!receipt) { return res.send(404); }
      return res.json(receipt);
    });
};

// Creates a new receipt in the DB.
exports.create = function (req, res) {
  ReceiptRecord.create(req.body, function (err, receipt) {
    if (err) { return handleError(res, err); }
    return res.json(201, receipt);
  });
};

// Updates an existing receipt in the DB.
exports.update = function (req, res) {
  if (req.body._id) { delete req.body._id; }
  ReceiptRecord.findById(req.params.id, function (err, receipt) {
    if (err) { return handleError(res, err); }
    if (!receipt) { return res.send(404); }
    var updated = _.merge(receipt, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, receipt);
    });
  });
};

// Deletes a receipt from the DB.
exports.destroy = function (req, res) {
  ReceiptRecord.findById(req.params.id, function (err, receipt) {
    if (err) { return handleError(res, err); }
    if (!receipt) { return res.send(404); }
    receipt.remove(function (err) {
      if (err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};
