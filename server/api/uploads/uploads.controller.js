'use strict';

var gm = require('gm'),
  imageMagick = gm.subClass({ imageMagick: true }),
  fs = require('fs'),
  path = require('path'),
  http = require('http'),
  https = require('https'),
  formidable = require('formidable'),
  parse = require('csv-parse'),
  Q = require('q'),
  request = require("request"),
  aws = require('../aws'),
  AWS = require('aws-sdk'),
  mime = require('mime'),
  s3;

AWS.config.update(
  {
    "accessKeyId": "AKIAJAOJ5UR5U5ARJKNA",
    "secretAccessKey": "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",
    "region": "",
    "bucket": "month-reports"
  }
);

s3 = new AWS.S3();

// {
//   "accessKeyId": "AKIAJAOJ5UR5U5ARJKNA",
//   "secretAccessKey": "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",
//   "region": "us-west-2",
//   "bucket": "month-reports"
// }

var ReceiptRecord = require('../receipt_record/receiptRecord.model');
var OriginalImage = require('../original_image/originalImage.model');
var CroppedImage = require('../cropped_image/croppedImage.model');
var User = require('../user/user.model');

function handleError(res, err, line) {
  console.log(err);
  return res.send(500, {err: err, line: line});
}

function populateReceiptRecordsFromCSV (parsed, res) {
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

function saveCroppedImage (image, selection, url, res) {
  var croppedImage, name;
  name = url.split('/')
  croppedImage = {
    user: image.user._id,
    originalImage: image._id,
    selection: selection,
    name: name[name.length - 1],
    size: 0,
    aws: image.aws,
    url: url
  }
  CroppedImage.create(croppedImage, function (err, croppedImage) {
    if (err) { return handleError(res, err); }
    image.croppedImages.push(croppedImage._id)
    image.save(function (err, image) {
      if (err) { return handleError(res, err); }
      return res.json(201, croppedImage);
    })
  });
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

    console.log(fields.user);

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
                name: file_name + '.' + file_ext,
                size: file_size,
                aws: false,
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

exports.createCropedVersion = function (req, res) {
  var orignalId = req.body.imageId,
    selection = JSON.parse(req.body.coords),
    imgPath, newPath, processing, imageCropper, newName;

  OriginalImage.findOne({'_id': orignalId}, function (err, image) {
    if (err) { handleError(res, err); }
    if (image) {
      if (image.aws === true) {
        imgPath = request(image.url);
        imageCropper = gm(imgPath, image.name);
      } else {
        imgPath = path.join(process.env.PWD, '/client/uploads/', image.name);
        newName = Math.random()*9999 + '-crop-' + image.name
        newPath = path.join(process.env.PWD, '/client/uploads/',  newName);
        imageCropper = gm(imgPath);
      }
      processing = imageCropper.crop(selection.w, selection.h, selection.x, selection.y);
      if (image.aws === true) {
        processing.stream(function(err, stdout, stderr) {
          // console.log('ready crop');
          if (err) { handleError(res, err); }
          var buf = new Buffer('');
          stdout.on('data', function(data) {
             buf = Buffer.concat([buf, data]);
          });
          stdout.on('error', function (err) {
            handleError(res, err, 172);
          });
          stdout.on('end', function(data) {
            var imageData = {
              Bucket: "month-reports",
              Key: 'cropped/' + Math.random()*9999 + '-crop-' + image.name,
              ACL: 'public-read',
              Body: buf,
              ContentType: mime.lookup(image.name)
            };
            s3.putObject(imageData, function(err, data) {
              if (err) { handleError(res, err); }
              var url = "http://" + imageData.Bucket + ".s3.amazonaws.com/" + imageData.Key;
              saveCroppedImage(image, selection, url, res)
              // res.send(200, url)
              // create cropped image
            });
          });
        })
      } else {
        processing.write(newPath, function (err) {
          if (err) { handleError(res, err); }
          saveCroppedImage(image, selection, '/uploads/' + newName, res)
          // res.send(200, newPath)
        });
      }

    } else {
      res.send(404, 'no image')
    }
  })
};

exports.amazonCSVCallback = function (req, res) {
  var filePath = req.body.url,
    awsKey = req.body.key,
    parser = parse({comment: '#', auto_parse: true, delimiter: ','}),
    output = [];

  parser.on('readable', function () {
    var record;
    while (record = parser.read()) {
      output.push(record);
    }
  });

  parser.on('error', function (err) {
    handleError(res, err, 172);
  });

  parser.on('finish', function () {
    populateReceiptRecordsFromCSV(output, res);
    aws.removeFile(awsKey, function (err, data) {
      console.log('deleted temp csv', data);
    })
  });

  request(filePath).pipe(parser)
}
