'use strict'

angular.module 'monthReportsApp'
.controller 'ReceiptrecordCtrl', [
  '$scope'
  '$http'
  '$routeParams'
  ($scope, $http, $routeParams) ->
    $scope.errors = {}

    receiptId = $routeParams.id
    $scope.receipt = {}

    window.sc = $scope

    $scope.person  = {}
    $scope.project = {}
    $scope.article = {}

    $scope.people = []
    $scope.expenseArticles = []
    $scope.projects = []

    $http.get("/api/users").success (users) ->
      $scope.people = users
    .error (data) ->
      console.log data

    $http.get("/api/expenseArticles").success (expenseArticles) ->
      $scope.expenseArticles = expenseArticles
    .error (data) ->
      console.log data

    $http.get("/api/projects").success (projects) ->
      $scope.projects = projects
    .error (data) ->
      console.log data

    $http.get("/api/receiptRecords/#{receiptId}").success (receipt) ->
      $scope.receipt = receipt
      $scope.person.selected = $scope.receipt.user
      $scope.project.selected = $scope.receipt.Project
      $scope.article.selected = $scope.receipt.Article
    .error (data) ->
      console.log data

    $scope.open = ($event, type) ->
      $event.preventDefault()
      $event.stopPropagation()
      $scope['opened_' + type] = true

    $scope.changeReceipt = (form) ->
      $scope.receipt.user     = $scope.person.selected._id
      $scope.receipt.Project  = $scope.project.selected._id
      $scope.receipt.Article  = $scope.article.selected._id
      $scope.receipt.image    = $scope.receipt.image._id if $scope.receipt.image?

      $http.put("/api/receiptRecords/#{receiptId}", $scope.receipt).success((receipt) ->
        $scope.message = 'Receipt successfully updated.'
        $scope.receipt = receipt
      ).error (error) ->
        $scope.message = 'Failded to save receipt. Try again'
        console.log error


]
