'use strict'

angular.module('monthReportsApp')
  .config ($routeProvider) ->
    $routeProvider
    .when('/admin',
      templateUrl: 'app/admin/admin.html'
      controller: 'AdminCtrl'
    )