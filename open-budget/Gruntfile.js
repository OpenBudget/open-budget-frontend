// Generated on 2014-01-15 using generator-bootstrap-less 3.2.0
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // load all grunt tasks
  require('load-grunt-tasks')(grunt);
  // show elapsed time at the end
  require('time-grunt')(grunt);

  // configurable paths
  var yeomanConfig = {
    app: require('./bower.json').appPath || 'app',
    dist: 'dist'
  };

  grunt.initConfig({
    yeoman: yeomanConfig,
    watch: {
      coffee: {
        files: ['<%= yeoman.app %>/scripts/{,*/}*.coffee'],
        tasks: ['coffee']
      },
      jst: {
        files: ['<%= yeoman.app %>/templates/*.html'],
        tasks: ['jst']
      },
      less: {
        files: ['<%= yeoman.app %>/styles/{,*/}*.less'],
        tasks: ['less']
      },
      gruntfile: {
        files: ['Gruntfile.js']
      },
      livereload: {
        options: {
          livereload: '<%= connect.options.livereload %>'
        },
        files: [
          '<%= yeoman.app %>/*.html',
          '{.tmp,<%= yeoman.app %>}/styles/{,*/}*.css',
          '{.tmp,<%= yeoman.app %>}/scripts/{,*/}*.js',
          '<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}'
        ]
      }
    },
    connect: {
      options: {
        port: 9000,
        // change this to '0.0.0.0' to access the server from outside
        hostname: '127.0.0.1',
        livereload: 35729
      },
      livereload: {
        options: {
          open: true,
          base: [
            '.tmp',
            '<%= yeoman.app %>'
          ]
        }
      },
      test: {
        options: {
          port: 9001,
          base: [
            '.tmp',
            'test',
            '<%= yeoman.app %>'
          ]
        }
      },
      dist: {
        options: {
          base: '<%= yeoman.dist %>'
        }
      }
    },
    clean: {
      dist: {
        files: [{
          dot: true,
          src: [
            '.tmp',
            '<%= yeoman.dist %>/*',
            '!<%= yeoman.dist %>/.git*'
          ]
        }]
      },
      server: '.tmp'
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: [
        'Gruntfile.js',
        '<%= yeoman.app %>/scripts/{,*/}*.js',
        '!<%= yeoman.app %>/scripts/vendor/*',
        'test/spec/{,*/}*.js'
      ]
    },
    mocha: {
      all: {
        options: {
          run: true,
          urls: ['http://localhost:<%= connect.options.port %>/index.html']
        }
      }
    },
    coffee: {
      dist: {
        options: {
          sourceMap: true
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/scripts',
          src: '{,*/}*.coffee',
          dest: '<%= yeoman.app %>/scripts',
          ext: '.js'
        }]
      }
    },
    less: {
      dist: {
        files: {
            '<%= yeoman.app %>/styles/main.css': ['<%= yeoman.app %>/styles/main.less'],
            '<%= yeoman.app %>/styles/spinner.css': ['<%= yeoman.app %>/styles/spinner.less']
        },
        options: {
          sourceMap: true,
          sourceMapFilename: '<%= yeoman.app %>/styles/main.css.map',
          sourceMapBasepath: '<%= yeoman.app %>/',
          sourceMapRootpath: '/'
        }
      }
    },
    'bower-install': {
      target: {
        src: '<%= yeoman.app %>/index.html',
	    exclude: [ "app/bower_components/bootstrap/dist/css/bootstrap.css" ]
      }
    },
    // not used since Uglify task does concat,
    // but still available if needed
    /*concat: {
      dist: {}
    },*/
    // not enabled since usemin task does concat and uglify
    // check index.html to edit your build targets
    // enable this task if you prefer defining your build targets here
    /*uglify: {
      dist: {}
    },*/
    rev: {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js',
            '<%= yeoman.dist %>/styles/{,*/}*.css',
            '<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}',
            '<%= yeoman.dist %>/fonts/{,*/}*.*'
          ]
        }
      }
    },
    useminPrepare: {
      html: '<%= yeoman.app %>/index.html',
      options: {
        dest: '<%= yeoman.dist %>'
      }
    },
    usemin: {
      html: ['<%= yeoman.dist %>/{,*/}*.html'],
      css: ['<%= yeoman.dist %>/styles/{,*/}*.css'],
      options: {
        dirs: ['<%= yeoman.dist %>']
      }
    },
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg}',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    svgmin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>/images',
          src: '{,*/}*.svg',
          dest: '<%= yeoman.dist %>/images'
        }]
      }
    },
    cssmin: {
      dist: {
        files: {
          '<%= yeoman.dist %>/styles/main.css': [
            '<%= yeoman.app %>/styles/main.css'
          ],
          '<%= yeoman.dist %>/styles/tour.css': [
            '<%= yeoman.app %>/bower_components/bootstrap-tour/build/css/bootstrap-tour.css'
          ]

        }
      }
    },
    htmlmin: {
      dist: {
        options: {
          /*removeCommentsFromCDATA: true,
          // https://github.com/yeoman/grunt-usemin/issues/44
          //collapseWhitespace: true,
          collapseBooleanAttributes: true,
          removeAttributeQuotes: true,
          removeRedundantAttributes: true,
          useShortDoctype: true,
          removeEmptyAttributes: true,
          removeOptionalTags: true*/
        },
        files: [{
          expand: true,
          cwd: '<%= yeoman.app %>',
          src: '*.html',
          dest: '<%= yeoman.dist %>'
        }]
      }
    },
    jst: {
	compile: {
	    options: {
		processName: function(name) {
		    name = name.split('/');
		    name = name[name.length-1];
		    name = name.substring(0,name.length-5);
		    name = name.replace(/-/g,"_");
		    return name;
		}
	    },
	    files: {
		"<%= yeoman.app %>/scripts/templates.js": ["<%= yeoman.app %>/templates/*.html"]
	    }
	}
    },
    copy: {
        dist: {
            files: [{
              expand: true,
              dot: true,
              cwd: '<%= yeoman.app %>',
              dest: '<%= yeoman.dist %>',
              src: [
                '*.{ico,png,txt}',
                '.htaccess',
                'styles/assets/*.png',
                'styles/assets/fonts/*.woff',
                'styles/assets/fonts/*.ttf',
                'bower_components/bootstrap-rtl/assets/fonts/*ttf',
                'bower_components/bootstrap-rtl/assets/fonts/*woff',
                'bower_components/requirejs/require.js',
                'images/{,*/}*.{webp,gif}',
                'site-map*.txt'
              ]
            }]
        },
        server: {
            files: [{
            }, {
                expand: true,
                dot: true,
                cwd: '<%= yeoman.app %>/bower_components/bootstrap/fonts/',
                dest: '<%= yeoman.app %>/fonts/glyphicons',
                src: ['*']
            }]
        },
        requirejs: {
            files: [
                { src:"target/scripts/main.js", dest:"dist/scripts/main.js" },
                { src:"target/scripts/main.js", dest:"dist/scripts/main.js" },
                { src:"target/scripts/main.js.map", dest:"dist/scripts/main.js.map" },
                { src:"target/styles/main.css", dest:"dist/styles/main.css" },
                { src:"target/styles/main.css.map", dest:"dist/styles/main.css.map" }
            ]
        }
    },
    concurrent: {
      dist: [
        'coffee',
        'less',
        'imagemin',
        'svgmin',
        'htmlmin',
	    'jst'
      ]
    },
    requirejs: {
      compile: {
        // !! You can drop your app.build.js config wholesale into 'options'
        options: {
          appDir: "app/",
          baseUrl: ".",
          dir: "target/",
          optimize: 'uglify2',
          // Uncomment to debug
          //optimize: 'none',
          mainConfigFile:'app/scripts/config.js',
          paths: {
              main: "scripts/main",
              "hasadna-notifications": 'empty:'
          },
          modules:[
              {
                  name: "main"
              }
          ],
          logLevel: 0,
          findNestedDependencies: true,
          // TODO there must be a better way to handle the ilegal charecters
          fileExclusionRegExp: /^run.js$|^release.+|^src$|^data$|^test$|^test.+/,
          inlineText: true,
          preserveLicenseComments: false,
          generateSourceMaps: true,
          useSourceUrl: true
        }
      }
    }
  });

  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:server',
      'coffee',
      'less',
      'jst',
      'copy:server',
      'connect:livereload',
      'watch'
    ]);
  });

  grunt.registerTask('server', function () {
    grunt.log.warn('The `server` task has been deprecated. Use `grunt serve` to start a server.');
    grunt.task.run(['serve']);
  });

  grunt.registerTask('test', [
    'clean:server',
    'coffee',
    'less',
    'copy:server',
    'connect:test',
    'mocha'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'copy:server',
    'useminPrepare',
    'concurrent',
    'requirejs',
    'copy',
    'rev',
    'usemin'
  ]);

  grunt.registerTask('default', [
    'build'
  ]);
};
