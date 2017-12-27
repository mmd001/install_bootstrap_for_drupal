var gulp = require('gulp');
var sass = require('gulp-sass');
var watch = require('gulp-watch');
var autoprefixer = require('gulp-autoprefixer');

var config = {
  source: './scss/**/*.scss',
  dest: './css'
};

gulp.task('sass', function () {
  return gulp.src(config.source)
      .pipe(sass().on('error', sass.logError))
      .pipe(autoprefixer({
        browsers: ['last 2 versions', "ie 11"],
        cascade: false
      }))
      .pipe(gulp.dest(config.dest));
});

gulp.task('sass:watch', function () {
  gulp.watch(config.source, ['sass']);
});
