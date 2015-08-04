gulp          = require("gulp")
csso          = require("gulp-csso")
connect       = require("gulp-connect")
del           = require("del")
sequence      = require("run-sequence")
postcss       = require('gulp-postcss')
corepostcss   = require('postcss')
simplevars    = require('postcss-simple-vars')
nestedcss     = require('postcss-nested')
autoprefixer  = require('autoprefixer-core')
hexrgba       = require('postcss-hexrgba')
postcssimport = require('postcss-import')

browsers = [
  "Firefox >= 10",
  "Chrome >= 10",
  "IE >= 11",
  "Opera >= 15",
  "Safari >= 6"
]

processors = [
  autoprefixer(browsers: browsers),
  simplevars,
  nestedcss,
  hexrgba,
  postcssimport(plugins: [
    nestedcss,
    autoprefixer(browsers: browsers),
    simplevars,
    nestedcss,
    hexrgba
  ])
]

# Copy html
gulp.task "html", ->
  gulp.src("./*.html")
      .pipe(gulp.dest("./release/"))
      .pipe(connect.reload())

# Compile css
gulp.task "content_styles", ->
  gulp.src("./css/content_styles.css")
      .pipe(postcss(processors))
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
  gulp.watch("./css/**/*.css", ["content_styles"])
  gulp.watch("./*.html", ["html"])

gulp.task "default", ->
  sequence("clean", ["html", "content_styles", "connect", "watch"])
