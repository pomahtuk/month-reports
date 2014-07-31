'use strict'

angular.module('monthReportsApp')
  .config [
    '$routeProvider'
    ($routeProvider) ->
      $routeProvider
      .when('/users',
        templateUrl: 'app/admin/admin.html'
        controller: 'AdminCtrl'
      )
      .when('/users/:id',
        templateUrl: 'app/admin/user_edit.html'
        controller: 'AdminEditCtrl'
      )
    ]
