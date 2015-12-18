'use strict';

import gulp         from 'gulp';
import connect      from 'gulp-connect';
import del          from 'del';
import sequence     from 'run-sequence';
import postcss      from 'gulp-postcss';
import autoprefixer from 'autoprefixer';

let processors = [
  require('precss'),
  autoprefixer({
    browsers: [
      "Firefox >= 10",
      "Chrome >= 10",
      "IE >= 11",
      "Opera >= 15",
      "Safari >= 6"
    ]
  })
]

// Copy html
gulp.task("html", () => {
  return gulp.src("./*.html")
    .pipe(gulp.dest("./release/"))
    .pipe(connect.reload())
});

// Compile css
gulp.task("content_styles", () => {
  return gulp.src("./css/content_styles.css")
    .pipe(postcss(processors))
    .pipe(gulp.dest("./release/"))
    .pipe(connect.reload())
});

// Cleanup release directory
gulp.task("clean", (cb) => {
  return del(["release"], cb)
});

// Run server
gulp.task("connect", () => {
  return connect.server({
    root: "./release",
    livereload: true,
    port: 9000,
    middleware: (connect, opt) => {
      return [
        (req, res, next) => {
          res.setHeader("Access-Control-Allow-Origin", "*");
          res.setHeader("Access-Control-Allow-Methods", "*");
          next();
        }
      ]
    }
  });
});

// Rerun the task when a file changes
gulp.task("watch", () => {
  gulp.watch("./css/**/*.css", ["content_styles"]);
  return gulp.watch("./*.html", ["html"]);
});

gulp.task("default", () => {
  return sequence("clean", ["html", "content_styles", "connect", "watch"])//
});
