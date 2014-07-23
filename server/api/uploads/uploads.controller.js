'use strict';

var gm = require('gm'),
  imageMagick = gm.subClass({ imageMagick: true }),
  fs = require('fs'),
  path = require('path'),
  http = require('http'),
  https = require('https'),
  formidable = require('formidable'),
  parse = require('csv-parse'),
  Q = require('q');

var ReceiptRecord = require('../receipt_record/receiptRecord.model');
var OriginalImage = require('../original_image/originalImage.model');
var User = require('../user/user.model');

function handleError(res, err, line) {
  return res.send(500, {err: err, line: line});
}

function populateReceiptRecordsFromCSV(parsed, res) {
  // get promise

  var i, report, receipt, scope, userTag, regex, deferred, promises = [];

  parsed.splice(0, 1);
  for (i = 0; i < parsed.length; i++) {
    report = parsed[i];
    deferred = Q.defer();

    receipt = {
      filled: false,
      Posted: new Date(report[0]),
      Occurred: new Date(report[1]),
      MerchantName: report[2],
      MerchantCity: report[3],
      MerchantState: report[4],
      MerchantZipCode: report[5],
      MCC_SICCode: report[6],
      MCCDescription: report[7],
      OriginalAmount: report[8],
      CurrencyDesc: report[9],
      ConversionRate: report[10],
      BilledAmount: report[11],
      Memo: report[12],
      DebitCredit: report[13],
      ReferenceNbr: report[14],
      StatementCycle: report[15],
      AccountName: report[16],
      AccountNumber: report[17]
    };

    scope = {
      deferred: deferred,
      receipt: receipt
    };

    userTag = report[16];

    if (userTag === undefined || userTag === 'undefined') {
      userTag = 'ExtraUnusualString';
    }

    regex = new RegExp(userTag, 'i');
    userTag = userTag.toString('utf8');

    User.findOne({ tagList: regex }, (function (err, user) {
      if (err) { this.deferred.reject(new Error(err)); }

      if (user !== null) {
        this.receipt.user = user._id;
      }

      ReceiptRecord.create(this.receipt, (function (err, receipt) {
        if (err) { this.deferred.reject(new Error(err)); }
        this.deferred.resolve(receipt);
      }).bind(this));

    }).bind(scope));

    promises.push(deferred.promise);

  }

  Q.all(promises).then(function () {
    res.json(200, {'status': 'ok', 'type': 'receipt'});
  }).fail(function (error) {
    handleError(res, error);
  })

}

exports.index = function (req, res) {
  var form = new formidable.IncomingForm();
  form.parse(req, function (err, fields, files) {
    if (err) { handleError(res, err, 96); }
    // `file` is the name of the <input> field of type `file`
    var old_path = files.file.path,
      file_size = files.file.size,
      file_ext = files.file.name.split('.').pop(),
      index = old_path.lastIndexOf('/') + 1,
      file_name = old_path.substr(index),
      new_path = path.join(process.env.PWD, '/client/uploads/', file_name + '.' + file_ext);
    var image;

    fs.readFile(old_path, function (err, data) {
      if (err) { handleError(res, err, 120); }
      fs.writeFile(new_path, data, function (err) {
        if (err) { handleError(res, err, 122); }
        fs.unlink(old_path, function (err) {
          if (err) {
            handleError(res, err, 125);
          } else {
            if (file_ext.toLowerCase() === 'csv' || file_ext.toLowerCase() === 'txt') {
              var input = fs.readFileSync(new_path);

              parse(input, {comment: '#', auto_parse: true, delimiter: ','}, function (err, output) {
                if (err) {
                  handleError(res, err, 133);
                } else {
                  fs.unlink(new_path, function () {
                    console.log('deleted csv', new_path);
                  });
                  // res.json(200, {'success': true, 'path': new_path, output: output});
                  populateReceiptRecordsFromCSV(output, res);
                }
              });

            } else {
              image = {
                user: fields.user,
                name: file_name,
                size: file_size,
                url: path.join('/uploads/', file_name + '.' + file_ext)
              };
              OriginalImage.create(image, function (err, image) {
                if (err) { handleError(res, err); }
                res.json(200, {'success': true, 'image': image, 'type': 'image'});
              });
            }
          }
        });
      });
    });

  });

};
