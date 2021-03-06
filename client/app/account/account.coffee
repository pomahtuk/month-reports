'use strict'

angular.module('monthReportsApp')
  .config [
    '$routeProvider'
    ($routeProvider) ->
      $routeProvider
      .when('/login',
        templateUrl: 'app/account/login/login.html'
        controller: 'LoginCtrl'
      )
      .when('/signup',
        templateUrl: 'app/account/signup/signup.html'
        controller: 'SignupCtrl'
      )
      .when('/settings',
        templateUrl: 'app/account/settings/settings.html'
        controller: 'SettingsCtrl'
      )
    ]
