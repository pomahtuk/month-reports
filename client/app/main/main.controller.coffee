'use strict'

# Break up an array into even sized chunks.
chunk = (a, s) ->
    if a.length == 0
        []
    else
        ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)

angular.module('monthReportsApp').controller 'MainCtrl', [
  '$scope'
  '$http'
  '$filter'
  'socket'
  '$fileUploader'
  '$modal'
  'Auth'
  ($scope, $http, $filter, socket, $fileUploader, $modal, Auth) ->
    ##
    ## Either use AWS or not. Remove before heroku deploy
    ##
    $scope.AWS = false
    # $scope.AWS = true

    window.sc = $scope

    ##
    ## TODO:
    ## Unify grid options - may be a servce?
    ## move uploader out of controller
    ## may be move modals to seperate files
    ##
    $scope.receiptRecords = []
    $scope.originalImages = []

    $scope.isLoggedIn = Auth.isLoggedIn
    $scope.isAdmin = Auth.isAdmin
    $scope.user = Auth.getCurrentUser()

    columnDefs =
      filled:
        field: 'filled'
        displayName: '✓'
        width: 20
        cellTemplate: '
          <div class="ngCellText" ng-class="col.colIndex()">
            <span ng-cell-text>
              <span ng-if=row.entity.filled>✓</span>
            </span>
          </div>'
      image:
        field: 'image'
        displayName: 'Чек'
        width: 70
        cellTemplate: '
          <div class="ngCellText" ng-class="col.colIndex()">
            <span ng-cell-text>
              <a href="{{row.entity.image.url}}"  target="_blank" ng-if="row.entity.image">чек</a>
              <span ng-if="!row.entity.image"> нет чека</span>
            </span>
          </div>
        '
      Posted:
        field: 'Posted'
        displayName: 'Дата'
        width: 100
        cellTemplate: '
          <div class="ngCellText" ng-class="col.colIndex()">
            <span ng-cell-text>{{row.getProperty(col.field) | date: "mediumDate"}}</span>
          </div>'
      BilledAmount:
        field: 'BilledAmount'
        displayName: 'Сумма'
        width: 90
      MCCDescription:
        field: 'MCCDescription'
        displayName: 'Описание'
      AccountName:
        field: 'AccountName'
        displayName: 'Имя карты'
      AccountNumber:
        field: 'AccountNumber'
        displayName: 'Номер карты'
      actions:
        displayName: ''
        width: 50
        cellTemplate: '
          <div class="ngCellText" ng-class="col.colIndex()">
            <span class="trash" ng-click="delete(row.entity)">
              <span class="glyphicon glyphicon-trash"></span>
            </span>&nbsp;
            <a class="edit" href="/receipts/{{row.entity._id}}">
              <span class="glyphicon glyphicon-pencil"></span>
            </a>
          </div>
        '

    rowTemplate = """
        <div style="height: 100%" ng-class="{'success': row.entity.filled}">
          <div ng-style="{ \'cursor\': row.cursor }" ng-repeat="col in renderedColumns" ng-class="col.colIndex()" class="ngCell ">
            <div class="ngVerticalBar" ng-style="{height: rowHeight}" ng-class="{ ngVerticalBarVisible: !$last }"> </div>
            <div ng-cell></div>
          </div>
        </div>'
      """

    date = new Date

    $scope.months = [
      {
        name: 'Январь'
        value: 1
      }
      {
        name: 'Февраль'
        value: 2
      }
      {
        name: 'Март'
        value: 3
      }
      {
        name: 'Апрель'
        value: 4
      }
      {
        name: 'Май'
        value: 5
      }
      {
        name: 'Июнь'
        value: 6
      }
      {
        name: 'Июль'
        value: 7
      }
      {
        name: 'Август'
        value: 8
      }
      {
        name: 'Сентябрь'
        value: 9
      }
      {
        name: 'Октябрь'
        value: 10
      }
      {
        name: 'Ноябрь'
        value: 11
      }
      {
        name: 'Декабрь'
        value: 12
      }
    ]

    $scope.years = [
      {
        name: 2014
      }
      {
        name: 2015
      }
      {
        name: 2016
      }
      {
        name: 2017
      }
    ]

    $scope.gridOptionsUser =
      data: 'filteredReceiptRecords'
      showGroupPanel: true
      enableColumnResize: true
      rowTemplate: rowTemplate
      columnDefs: [
        columnDefs.filled
        columnDefs.image
        columnDefs.Posted
        columnDefs.BilledAmount
        columnDefs.MCCDescription
        columnDefs.actions
      ]

    $scope.selectedMonth = $scope.months[date.getMonth()]
    $scope.selectedYear = $scope.years[date.getFullYear() - 2014]

    $scope.update = (month = $scope.selectedMonth, year = $scope.selectedYear) ->
      # console.log month, year
      $scope.selectedMonth = month
      $scope.selectedYear = year
      $scope.getReceipts()

    formDateParams = ->
      "year=#{$scope.selectedYear.name}&month=#{$scope.selectedMonth.value}"

    $scope.getReceipts = ->
      if $scope.user?
        if $scope.user.$promise?
          $scope.user.$promise.then ->
            admin = $scope.isAdmin()
            dataParams = formDateParams()
            if admin is true
              $http.get('/api/receiptRecords?'+dataParams).success (receiptRecords) ->
                $scope.receiptRecords = receiptRecords
                $scope.filteredReceiptRecords = receiptRecords
            else
              $http.get('/api/receiptRecords?user='+$scope.user._id+'&'+dataParams).success (receiptRecords) ->
                $scope.receiptRecords = receiptRecords
                $scope.filteredReceiptRecords = receiptRecords

      # socket.syncUpdates 'receiptRecord', $scope.receiptRecords

    $scope.getOriginlaImages = ->
      if $scope.user?
        if $scope.user.$promise?
          $scope.user.$promise.then ->
            admin = $scope.isAdmin()
            unless admin is true
              $http.get('/api/originalImages?user='+$scope.user._id).success (originalImages) ->
                $scope.originalImages = originalImages

      # socket.syncUpdates 'originalImage', $scope.originalImages

    $scope.delete = (receipt) ->
      $http.delete("/api/receiptRecords/#{receipt._id}").success (data) ->
        angular.forEach $scope.receiptRecords, (r, i) ->
          $scope.receiptRecords.splice i, 1  if r is receipt

    $scope.deleteImage = (image) ->
      $http.delete("/api/originalImages/#{image._id}").success (data) ->
        $scope.getOriginlaImages()

    $scope.getReceipts()
    $scope.getOriginlaImages()

    $scope.$on '$destroy', ->
      socket.unsyncUpdates 'receiptRecord'

    $scope.$watch "originalImages", (newVal, oldVal) ->
      if newVal?
        $scope.rows = chunk newVal, 4

    $scope.open = (image) ->
      modalInstance = $modal.open
        templateUrl: 'cropModal.html'
        controller: ModalInstanceCtrl
        size: 'lg'
        resolve:
          image: () ->
            image
          receipts: () ->
            $scope.receiptRecords

      modalInstance.result.then (selectedItem) ->
        console.log selectedItem
      , ->
        console.log 'Modal dismissed at: ' + new Date()

      true

    ModalInstanceCtrl = [
      '$scope'
      '$modalInstance'
      'image'
      'receipts'
      ($scope, $modalInstance, image, receipts) ->
        $scope.receipts = receipts
        $scope.image = image

        $scope.ok =  ->
          $modalInstance.close $scope.image

        $scope.cancel = ->
          $modalInstance.dismiss('cancel')
    ]

    $scope.afterCrop = (image) ->
      modalInstance = $modal.open
        templateUrl: 'afterCropModal.html'
        controller: AfterCropModalInstanceCtrl
        size: 'lg'
        resolve:
          image: () ->
            image
          receipts: () ->
            $scope.receiptRecords

      modalInstance.result.then (data) ->
        # console.log selectedItem, image
        selectedItem = data.receipt
        image = data.image

        selectedItem.filled = true
        selectedItem.image = image._id
        selectedItem.user = selectedItem.user._id
        image.receiptRecord = selectedItem._id

        if data.prevReceipt?
          if data.prevReceipt._id isnt selectedItem._id
            data.prevReceipt.filled = false
            data.prevReceipt.user = data.prevReceipt.user._id
            data.prevReceipt.image = null

            $http.put('/api/receiptRecords/' + data.prevReceipt._id, data.prevReceipt).success (data) ->
              console.log data
            .error (data) ->
              console.log data

        $http.put('/api/receiptRecords/' + selectedItem._id, selectedItem).success (data) ->
          # console.log data
          $http.put('/api/croppedImages/' + image._id, image).success (data) ->
            # console.log data
            selectedItem.image = data
          .error (data) ->
            console.log data

        .error (data) ->
          console.log data

      , ->
        console.log 'Modal dismissed at: ' + new Date()

      true

    AfterCropModalInstanceCtrl = [
      '$scope'
      '$filter'
      '$modalInstance'
      'image'
      'receipts'
      ($scope, $filter, $modalInstance, image, receipts) ->
        $scope.image = image
        $scope.receipts = receipts
        $scope.filteredReceipts = receipts
        $scope.dt = new Date

        $scope.ok =  ->
          data =
            prevReceipt: $scope.prevReceipt
            receipt: $scope.gridOptionsFull.selectedItems[0]
            image: image
          $modalInstance.close data

        $scope.cancel = ->
          $modalInstance.dismiss('cancel')

        $scope.gridOptionsFull =
          data: 'filteredReceipts'
          showGroupPanel: true
          enableColumnResize: true
          multiSelect: false
          selectedItems: []
          rowTemplate: rowTemplate
          showFilter: true
          columnDefs: [
            columnDefs.image
            columnDefs.Posted
            columnDefs.BilledAmount
            columnDefs.MCCDescription
            columnDefs.AccountName
            columnDefs.AccountNumber
          ]

        if image.receiptRecord?
          currentReceipt = $scope.filteredReceipts.filter (element) ->
            if element.image?
              return element.image._id is image._id
            return false
          currentReceipt = currentReceipt[0]
          $scope.prevReceipt = currentReceipt
        else
          currentReceipt = $scope.filteredReceipts[0]

        $scope.gridOptionsFull.selectedItems.push currentReceipt

        $scope.resetFilters = ->
          $scope.filteredReceipts = $scope.receipts

        $scope.applyFilters = ->
          dateText = $('[data-role=resultingDate]').text()
          looking = new Date dateText
          $scope.scopeDate = looking
          $scope.scopeDate.setHours 0
          $scope.scopeDate.setMinutes 0
          $scope.scopeDate.setSeconds 0

          $scope.filteredReceipts = $filter('filter')($scope.receipts, (item) ->
            posted = new Date(item.Posted)
            posted.setHours 0
            posted.setMinutes 0
            posted.setSeconds 0
            return true if posted.getTime() is $scope.scopeDate.getTime()
            return false
          )


    ]

    $scope.$on 'croppedImage:created', (event, image) ->
      $scope.afterCrop image

    # Creates a uploader
    if $scope.AWS is true
      uploader = $scope.uploader = $fileUploader.create
        scope: $scope
        autoUpload: true
        removeAfterUpload: true
        url: 'https://month-reports.s3.amazonaws.com/'
        formData: []

      uploader.filters.push (item, options) ->
        $.ajax
          url: "/api/s3Policy?mimeType=" + item.type
          type: 'GET'
          dataType: 'json'
          data:
            doc:
              title: item.name
          async: false
          success: (data) ->
            item.s3data =
              'key' : 's3UploadExample/'+ Math.round(Math.random()*10000) + '$$' + item.name
              'acl' : 'public-read'
              'Content-Type' : item.type
              'AWSAccessKeyId': data.AWSAccessKeyId
              'success_action_status' : '201'
              'Policy' : data.s3Policy
              'Signature' : data.s3Signature
        return true

      uploader.bind "afteraddingfile", (event, item) ->
        item.formData[0] = item.file.s3data

    else
      uploader = $scope.uploader = $fileUploader.create
        scope: $scope
        autoUpload: true
        removeAfterUpload: true
        url: "/api/uploads"
        formData: [
          {
            user: $scope.user._id
          }
        ]

    uploader.bind "success", (event, xhr, item, response) ->
      typeArr = item.file.type.split('/')
      type = item.file.type.split('/')[0]
      subType = item.file.type.split('/')[1]
      if $scope.AWS is true
        xml = $.parseXML response
        xml = $ xml
        url = xml.find('Location').text()

        if subType.toLowerCase() is 'csv'
          $http.post('/api/uploads/csv', {url: url, key: item.file.s3data.key}).success (data) ->
            $scope.getReceipts()
          .error (error) ->
            console.log error

        else if type.toLowerCase() is 'image'
          image =
            user: $scope.user._id
            name: item.file.name
            size: item.file.size
            awsKey: item.file.s3data.key
            aws: true
            url: url

          $http.post('/api/originalImages', image).success (data) ->
            $scope.getOriginlaImages()
          .error (error) ->
            console.log error

      else
        if subType.toLowerCase() is 'csv'
          $scope.getReceipts()
        else if type.toLowerCase() is 'image'
          $scope.getOriginlaImages()

    uploader.bind "error", (event, xhr, item, response) ->
      console.error "Error", xhr, item, response
  ]
