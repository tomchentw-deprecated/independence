!function exportedTasksDefinedBeginsHere
  gulp.task 'client' <[ client:html client:css client:js ]> !(done) ->
    if config.env.is 'production'
      gulp.start 'client:html' .on 'task_stop' !(event) ->
        done! if event.task is 'client:html'
    else
      livereload.listen config.port.livereload, done

      gulp.watch 'client/views/**/*', <[ client:html ]>
      gulp.watch <[ client/templates/**/* client/javascripts/**/* lib/javascripts/**/* ]>, <[ client:html client:js ]>
      gulp.watch 'client/stylesheets/**/*', <[ client:css ]>
/*
 * Implementation details
 */
require! {
  fs
  path
}
require! {
  hljs: 'highlight.js'
  gulp
  'gulp-livescript'
  'gulp-uglify'
  'gulp-angular-templatecache'
  'gulp-jade'
  'gulp-sass'
  'gulp-minify-css'
  'gulp-concat'
  'gulp-rev'
}
require! {
  '../config'
}
unless config.env.is 'production'
  require! {
    'tiny-lr'
    'gulp-livereload'
  }
  const livereload = tiny-lr!

function identity
  it

function valueOf
  @[it]

function prependTimestampFactory (filepath)
  if config.env.is 'production' and fs.existsSync filepath
    fs.readFileSync filepath, 'utf8'
    |> JSON.parse
    |> valueOf.bind
  else
    identity
/*
 * client tasks
 */
gulp.task 'client:html:partials' ->
  return gulp.src 'client/views/partials/*.jade'
  .pipe gulp-jade pretty: true
  .pipe gulp.dest 'tmp/.html-cache/partials'

gulp.task 'client:js:partials' ->
  return gulp.src 'client/javascripts/partials/*.ls'
  .pipe gulp-livescript bare: true
  .pipe gulp.dest 'tmp/.js-cache/partials'

gulp.task 'client:html' <[ client:html:partials client:js:partials ]> ->
  stream = gulp.src 'client/views/*.jade'
  .pipe gulp-jade do
    pretty: !config.env.is 'production'
    locals:
      highlight: ->
        hljs.highlight do
          path.extname it .substr 1
          fs.readFileSync it, 'utf8'
        .value
      javascriptIncludeTag: prependTimestampFactory './tmp/.js-manifest/rev-manifest.json'
      stylesheetLinkTag: prependTimestampFactory './tmp/.css-manifest/rev-manifest.json'

  .pipe gulp.dest 'tmp/public'
  stream.=pipe gulp-livereload(livereload) unless config.env.is 'production'
  return stream

gulp.task 'client:css:scss' ->
  return gulp.src 'client/stylesheets/application.scss'
  .pipe gulp-sass do
    includePaths: [
      path.join ...<[ bower_components twbs-bootstrap-sass vendor assets stylesheets ]>
    ]
    outputStyle: if config.env.is 'production' then 'compressed' else 'nested'
  .pipe gulp.dest 'tmp/.css-cache'

gulp.task 'client:css:bower_components' ->
  stream = gulp.src <[
    bower_components/angular/angular-csp.css
  ]>
  stream.=pipe gulp-minify-css! if config.env.is 'production'
  return stream.pipe gulp.dest 'tmp/.css-cache'

gulp.task 'client:css' <[ client:css:scss client:css:bower_components ]> ->
  stream = gulp.src 'tmp/.css-cache/*.css'
  .pipe gulp-concat 'application.css'
  if config.env.is 'production'
    stream.=pipe gulp-minify-css!
    .pipe gulp-rev!
  stream.=pipe gulp.dest 'tmp/public'
  if config.env.is 'production'
    stream.=pipe gulp-rev.manifest!
    .pipe gulp.dest 'tmp/.css-manifest'
  else
    stream.=pipe gulp-livereload(livereload)
  return stream

gulp.task 'client:templates' ->
  stream = gulp.src 'client/templates/**/*.jade'
  .pipe gulp-jade pretty: !config.env.is 'production'
  .pipe gulp-angular-templatecache do
    root: '/'
    module: 'application.templates'
    standalone: true
  stream.=pipe gulp-uglify! if config.env.is 'production'
  return stream.pipe gulp.dest 'tmp/.js-cache'

gulp.task 'client:js:ls' ->
  stream = gulp.src <[
    client/javascripts/application.ls
    client/javascripts/**/*.ls
  ]>
  .pipe gulp-concat 'application.js'
  .pipe gulp-livescript!
  stream.=pipe gulp-uglify! if config.env.is 'production'
  return stream.pipe gulp.dest 'tmp/.js-cache'

gulp.task 'client:js:bower_components' ->
  stream = gulp.src [
    'bower_components/angular-ga/ga.js'
    'bower_components/FileSaver/FileSaver.js'
  ]
  stream.=pipe gulp-uglify! if config.env.is 'production'
  return stream.pipe gulp.dest 'tmp/.js-cache'

gulp.task 'client:js' <[ client:templates client:js:ls client:js:bower_components ]> ->
  stream = gulp.src [
    'bower_components/angular/angular.min.js'
    'bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
    'bower_components/ng-form-data/ng-form-data.min.js'
    'bower_components/html2canvas/build/html2canvas.min.js'
    'bower_components/blueimp-canvas-to-blob/js/canvas-to-blob.min.js'
    'client/javascripts/vendor/angular-ui-router.min.js'
    'client/javascripts/vendor/angular-ujs.min.js'
    'tmp/.js-cache/*.js'
  ]
  .pipe gulp-concat 'application.js'
  stream.=pipe gulp-rev! if config.env.is 'production'
  stream.=pipe gulp.dest 'tmp/public'
  if config.env.is 'production'
    stream.=pipe gulp-rev.manifest!
    .pipe gulp.dest 'tmp/.js-manifest'
  else
    stream.=pipe gulp-livereload(livereload)
  return stream
# define!
exportedTasksDefinedBeginsHere!