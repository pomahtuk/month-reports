'use strict';

var AWS = require('aws-sdk'),
  crypto = require('crypto'),
  createS3Policy,
  getExpiryTime,
  s3;

AWS.config.update(
  {
    "accessKeyId": "",
    "secretAccessKey": "",
    "region": "us-west-2",
    "bucket": "month-reports"
  }
);

s3 = new AWS.S3();

function handleError(res, err, line) {
  return res.send(500, 'bad');
}

getExpiryTime = function () {
  var _date = new Date();
  return '' + (_date.getFullYear()) + '-' + (_date.getMonth() + 1) + '-' +
    (_date.getDate() + 1) + 'T' + (_date.getHours() + 3) + ':' + '00:00.000Z';
};

createS3Policy = function(contentType, callback) {
  var date = new Date();
  var s3Policy = {
    'expiration': getExpiryTime(),
    'conditions': [
      ['starts-with', '$key', 's3UploadExample/'],
      {'bucket': "month-reports"},
      {'acl': 'public-read'},
      ['starts-with', '$Content-Type', contentType],
      {'success_action_status' : '201'}
    ]
  };

  // stringify and encode the policy
  var stringPolicy = JSON.stringify(s3Policy);
  var base64Policy = new Buffer(stringPolicy, 'utf-8').toString('base64');

  // sign the base64 encoded policy
  var signature = crypto.createHmac('sha1', "IaVwBB4Lds4foQ9SRSmaREtiZWOMl50yxcshb6xM")
    .update(new Buffer(base64Policy, 'utf-8')).digest('base64');

  // build the results object
  var s3Credentials = {
    s3Policy: base64Policy,
    s3Signature: signature,
    AWSAccessKeyId: "AKIAJAOJ5UR5U5ARJKNA"
  };

  // send it back
  callback(s3Credentials);
};

exports.getS3Policy = function(req, res) {
    createS3Policy(req.query.mimeType, function (creds, err) {
        if (!err) {
            return res.send(200, creds);
        } else {
            return res.send(500, err);
        }
    });
};

exports.getClientConfig = function (req, res, next) {
    return res.json(200, {
        awsConfig: {
            bucket: "month-reports"
        }
    });
};

exports.removeFile = function (key, callback) {
  var params = {
    Bucket: "month-reports",
    Key: key
  };
  s3.deleteObject(params, function(err, data) {
    if (err) callback(err);
    else callback(null, data);
  });
};

// call only like
// aws.putStream.bind({image: image, res: res, buf: buf})
exports.putStream = function(data) {
  // set stream length

  console.log('put file called');

  // stdout.length = this.image.size;
  var nameArr = this.image.awsKey.split('/'),
    buf = this.buf,
    name;

  name = nameArr[nameArr.length - 1];
  name = Math.random()*9999 + '-crop-' + name;

  console.log(name);

  var data = {
    Bucket: "month-reports",
    Key: name,
    Body: buf // error here
  };

  // // res.send(200, data);

  s3.putObject(data, function(err, data) {
    // if (err) { handleError(res, err); }
    // res.send(200, data);
    console.log("done", data);
  });
};
