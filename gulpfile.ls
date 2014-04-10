!function exportedTasksDefinedBeginsHere
  gulp.task 'publish' <[ publish:changelog ]>
/*
 * Implementation details
 */
require! {
  gulp
  'gulp-bump'
  'gulp-conventional-changelog'
}
/*
 * publish tasks
 */
gulp.task 'publish:bump' ->
  return gulp.src  <[
    package.json
    bower.json
  ]>
  .pipe gulp-bump process.env{TYPE or 'patch'}
  .pipe gulp.dest '.'

gulp.task 'publish:changelog' <[ publish:bump ]> ->
  return gulp.src <[ package.json CHANGELOG.md ]>
  .pipe gulp-conventional-changelog!
  .pipe gulp.dest '.'
# define!
exportedTasksDefinedBeginsHere!
