'use strict'

angular.module('monthReportsApp')
  .config [
    '$routeProvider'
    ($routeProvider) ->
      $routeProvider
      .when('/',
        templateUrl: 'app/main/main.html'
        controller: 'MainCtrl'
      )
    ]
