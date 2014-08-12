'use strict'

angular.module 'monthReportsApp'
.controller 'ExpensearticleCtrl', [
  '$scope'
  '$http'
  ($scope, $http) ->
    $scope.articles = []
    $scope.newArticle = {}
    $scope.saveChanges = false

    $http.get('/api/expenseArticles').success (articles) ->
      $scope.articles = articles
    .error (data) ->
      console.log data

    $scope.gridOptions =
      data: 'articles'
      enableCellSelection: true
      enableRowSelection: false
      enableCellEdit: true
      columnDefs: [
        {
          field:'name_ru',
          displayName:'Russian name'
          enableCellEdit: true
        }
        {
          field:'name_en',
          displayName:'English name'
          enableCellEdit: true
        }
        {
          displayName: ''
          width: 50
          enableCellEdit: false
          cellTemplate: '
            <div class="ngCellText" ng-class="col.colIndex()">
              <span class="trash" ng-click="delete(row.entity)">
                <span class="glyphicon glyphicon-trash"></span>
              </span>
            </div>
          '
        }
      ]

    $scope.$on 'ngGridEventEndCellEdit', ->
      $scope.saveChanges = true

    $scope.$watch 'articles', (newVal, oldVal) ->
      setTimeout ->
        if $scope.saveChanges is true
          if newVal?
            if newVal.length is oldVal.length
              for item, index in newVal
                oldItem = oldVal[index]
                for key, value of item
                  oldFieldVal = oldItem[key]
                  if oldFieldVal isnt value
                    $scope.saveChanges = false
                    $http.put('/api/expenseArticles/' + item._id, item).success (data) ->
                      console.log 'ok'
                    .error ((data) ->
                      item = oldItem
                    ).bind {
                      item: item
                      oldItem: oldItem
                    }
                    break
      , 200
    , true

    $scope.delete = (article) ->
      ##
      ## TODO: confirm!
      ##
      if confirm 'Are you sure you want to delete this record?'
        $http.delete('/api/expenseArticles/' + project._id).success (data) ->
          for proj, index in $scope.articles
            $scope.articles.splice index, 1  if proj._id is project._id
        .error (data) ->
          console.log data

    $scope.resetFrom = ->
      $scope.newArticle = {}

    $scope.createArticle = ->
      if $scope.newArticle.name_ru? and $scope.newArticle.name_en?
        $http.post('/api/expenseArticles', $scope.newArticle).success (article) ->
          $scope.articles.push article
          $scope.addArticle = false
          $scope.newArticle = {}
        .error (data) ->
          console.log data

]
