angular.module 'application' <[
  ngAnimate
  ngResource
  ngSanitize
  ui.bootstrap
  ui.router
  angular.ujs
  ng-form-data
  application.templates
]>
.directive 'html2canvas' <[
       $window  $q
]> ++ ($window, $q) ->

  function render ($element)
    const deferred = $q.defer!
    const options = do
      chinese: true
      useCORS: true
      onrendered: deferred.resolve

    $window.html2canvas $element, options
    deferred.promise

  !($scope, $element, $attrs) ->
    $scope[$attrs.html2canvas] = do
      render: angular.bind void, render, $element.0

.config <[
        $locationProvider  $stateProvider
]> ++ !($locationProvider, $stateProvider) ->
  $locationProvider.html5Mode true

  $stateProvider
  .state 'Index' do
    url: '/'
    templateUrl: '/index.html'
    controller: 'IndexCtrl as index'

.filter 'independence' ->
  (name || '') ->
    "我叫做#{ name }，我主張台灣獨立"

.controller 'IndexCtrl' class

  const TOKEN = '555f740f05a1accbcaee818de2a0edb494eb6a4670614606bbdc614209e1ec68'

  submit: ->
    <~! @$scope.preview.render!then
    it.toBlob @_blobGet, 'image/png', 100

  const _blobGet = !->
    @$window.saveAs it, 'poster.png'
    return unless @$scope.shouldUpload

    const newImg = do
      image: it
      album: TOKEN
      title: @$filter('independence')(@$scope.name)
      description: 'http://independence.tomchentw.com/'

    @$http do
      method: 'POST'
      url: 'http://putimgur.tomchentw.com/3/image'
      data: newImg
      headers: do
        'Authorization': 'Client-ID 4635a09fd1260a1'
        'Replacement': "Token #{ TOKEN }"

  @$inject = <[
     $scope   $window   $http   $filter ]>
  !(@$scope, @$window, @$http, @$filter) ->

    @_blobGet = angular.bind @, _blobGet

    $scope <<< {
      name: '鄭南榕'
      textStyle: do
        fontSize: '32px'
      birthday: '1947'
      deathday: '1989'
      shouldUpload: true
    }

    $scope.$watch 'name' !-> $scope.$root.name = it
