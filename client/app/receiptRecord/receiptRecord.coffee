'use strict'

angular.module 'monthReportsApp'
.config ($routeProvider) ->
  $routeProvider.when '/receiptRecord/:id',
    templateUrl: 'app/receiptRecord/receiptRecord.html'
    controller: 'ReceiptrecordCtrl'
