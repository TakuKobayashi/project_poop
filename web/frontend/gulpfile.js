var gulp = require("gulp");

var sass = require("gulp-sass"),
    pleeease = require("gulp-pleeease"),
    browser = require("browser-sync"),
    minifyCss  = require('gulp-minify-css'),
    typescript = require('gulp-tsc'), // TypeScript Compiler
    plumber = require('gulp-plumber') // 自動復帰

var DEV = "source",
    PUBLIC = "build";

//style
gulp.task("style", function() {
    gulp.src(DEV + "/sass/**/*.scss")
        .pipe(sass({
            style:"nested",
            includePaths:DEV+"/sass/common",
            compass : true,
            "sourcemap=none": true,
            minifier: false,
        }))
        .pipe(pleeease({
            fallbacks: {
                autoprefixer: ["last 2 version", "ie 9"],
            },
            minifier: true//圧縮を有効
        }))
        .pipe(gulp.dest(PUBLIC + "/css"))
        .pipe(browser.reload({stream:true}));
});

//copy
gulp.task("js", function() {
    return gulp.src(DEV + "/js/**/*.js")
        .pipe(gulp.dest(PUBLIC + "/js"))
        .pipe(browser.reload({stream:true}));
});



// gulp.task("typescript", function(){
//   // 対象となるファイルを全部指定
//   gulp.src(DEV + "/ts/*.ts")
//     // 1対1でコンパイル
//     .pipe(typescript({ target: "ES5", removeComments: true, noExternalResolve: false }))
//     // jsプロパティを参照
//     .js
//     .pipe(concat("webmdk.js"))
//     .pipe(gulp.dest(PUBLIC + "/js"))
// });

//lib
gulp.task("lib", function() {
    return gulp.src(DEV + "/lib/**/*.js")
        .pipe(gulp.dest(PUBLIC + "/lib"));
});

//lib
gulp.task("images", function() {
    return gulp.src(DEV + "/images/**/*")
        .pipe(gulp.dest(PUBLIC + "/images"));
});

//Fonts
gulp.task("fonts", function() {
    return gulp.src(DEV + "/fonts/**/*")
        .pipe(gulp.dest(PUBLIC + "/fonts"));
});

//browser sync
gulp.task("server", function() {
    browser({
        server: {
            baseDir: PUBLIC
        },
        port: 5000
        ,ui:{port:5001}
    });
});

//Just reload
gulp.task("reload", function() { browser.reload() });

//TypeScript
gulp.task('typescript', function(){
	gulp.src([DEV +'/ts/webmdk.ts'])
	.pipe(plumber())
	.pipe(typescript({
		sourceMap: true,
		sourceRoot: '/ts/',
		declaration: true ,
		removeComments: true,
		out: "webmdk.js"}))
	.pipe(gulp.dest((PUBLIC + "/js")))
});



//watch
gulp.task("default",["style","js","lib","images","server"], function() {
    gulp.watch(DEV + "/sass/**/*.scss",["style"]);
    gulp.watch(DEV + "/js/**/*.js",["js"]);
    gulp.watch(PUBLIC + "/js/**/*.js",["reload"]);
    gulp.watch(DEV + "/ts/**/*.ts",["typescript"]);
    gulp.watch(DEV + "/lib/**/*.js",["lib"]);
    gulp.watch(DEV + "/images/**/*",["images"]);
});