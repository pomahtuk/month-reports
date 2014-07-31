'use strict'

angular.module 'monthReportsApp'
.config ($routeProvider) ->
  $routeProvider.when '/project',
    templateUrl: 'app/project/project.html'
    controller: 'ProjectCtrl'
