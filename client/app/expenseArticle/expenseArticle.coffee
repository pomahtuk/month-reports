'use strict'

angular.module 'monthReportsApp'
.config ($routeProvider) ->
  $routeProvider.when '/expenseArticle',
    templateUrl: 'app/expenseArticle/expenseArticle.html'
    controller: 'ExpensearticleCtrl'
