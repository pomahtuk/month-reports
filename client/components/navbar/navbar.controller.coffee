'use strict'

angular.module('monthReportsApp').controller 'NavbarCtrl', [
  '$scope'
  '$location'
  'Auth'
  ($scope, $location, Auth) ->
    $scope.menu = [
      {
        title: 'Главная'
        link: '/'
      }
      {
        title: 'Проекты'
        link: '/project'
      }
      {
        title: 'Статьи'
        link: '/expenseArticle'
      }
    ]
    $scope.isCollapsed = true
    $scope.isLoggedIn = Auth.isLoggedIn
    $scope.isAdmin = Auth.isAdmin
    $scope.getCurrentUser = Auth.getCurrentUser

    $scope.logout = ->
      Auth.logout()
      $location.path '/login'

    $scope.isActive = (route) ->
      route is $location.path()
  ]
