'use strict'

# Break up an array into even sized chunks.
chunk = (a, s) ->
    if a.length == 0
        []
    else
        ( a[i..i+s-1] for i in [0..a.length - 1 ] by s)

angular.module('monthReportsApp').controller 'MainCtrl', ($scope, $http, socket, $fileUploader, Auth) ->
  $scope.receiptRecords = []
  $scope.originalImages = []

  $scope.isLoggedIn = Auth.isLoggedIn
  $scope.isAdmin = Auth.isAdmin
  $scope.user = Auth.getCurrentUser()

  window.sc = $scope

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
    $scope.user.$promise.then ->
      admin = $scope.isAdmin()
      dataParams = formDateParams()
      if admin is true
        $http.get('/api/receiptRecords?'+dataParams).success (receiptRecords) ->
          $scope.receiptRecords = receiptRecords
      else
        $http.get('/api/receiptRecords?user='+$scope.user._id+'&'+dataParams).success (receiptRecords) ->
          $scope.receiptRecords = receiptRecords

    # socket.syncUpdates 'receiptRecord', $scope.receiptRecords

  $scope.getOriginlaImages = ->
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
      angular.forEach $scope.originalImages, (r, i) ->
        $scope.originalImages.splice i, 1  if r is image

  $scope.getReceipts()
  $scope.getOriginlaImages()

  $scope.$on '$destroy', ->
    socket.unsyncUpdates 'receiptRecord'

  $scope.$watch "originalImages", (newVal, oldVal) ->
    if newVal?
      $scope.rows = chunk newVal, 4

  # Creates a uploader
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
    if response.type is 'receipt'
      $scope.getReceipts()
    else
      $scope.getOriginlaImages()

  uploader.bind "error", (event, xhr, item, response) ->
    console.error "Error", xhr, item, response
