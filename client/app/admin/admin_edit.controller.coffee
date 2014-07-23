'use strict'

angular.module('monthReportsApp').controller 'AdminEditCtrl', ($scope, $http, $routeParams, Auth, User) ->
  $scope.errors = {}

  userId = $routeParams.id

  $http.get("/api/users/#{userId}").success (user) ->
    $scope.user = user

  $scope.changeUser = (form) ->
    $scope.submitted = true

    if form.$valid
      $http.put("/api/users/#{userId}", $scope.user).success((user) ->
        $scope.message = 'User successfully updated.'
        $scope.user = user
      ).error (error) ->
        $scope.message = 'Failded to save user. Try again'
        console.log error
