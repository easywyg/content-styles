gulp         = require("gulp")
sass         = require("gulp-sass")
csso         = require("gulp-csso")
autoprefixer = require("gulp-autoprefixer")
connect      = require("gulp-connect")
del          = require("del")
sequence     = require("run-sequence")

# Copy html
gulp.task "html", ->
  gulp.src("./*.html")
       .pipe(gulp.dest("./release/"))
       .pipe(connect.reload())

# Compile scss
gulp.task "content_styles", ->
  gulp.src("./scss/content_styles.scss")
      .pipe(sass())
      .pipe(autoprefixer(
        browsers : [
          "Firefox >= 10",
          "Chrome >= 10",
          "IE >= 11",
          "Opera >= 15",
          "Safari >= 6"
        ]
      ))
      .pipe(gulp.dest("./release/"))
      .pipe(connect.reload())

# Cleanup release directory
gulp.task "clean", (cb) ->
  del(["release"], cb)

# Run server
gulp.task "connect", ->
  connect.server(
    root       : "./release"
    livereload : true
    port       : 9000
    middleware : (connect, opt) ->
      [
        (req, res, next) ->
          res.setHeader("Access-Control-Allow-Origin", "*")
          res.setHeader("Access-Control-Allow-Methods", "*")
          next()
      ]
  )

# Rerun the task when a file changes
gulp.task "watch", ->
  gulp.watch("./scss/**/*.scss", ["content_styles"])
  gulp.watch("./*.html", ["html"])

gulp.task "default", ->
  sequence("clean", ["html", "content_styles", "connect", "watch"])
