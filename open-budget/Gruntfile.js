// Generated on 2014-01-15 using generator-bootstrap-less 3.2.0
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  require('load-grunt-config')(grunt, {
      data: {

      }
  });

  // show elapsed time at the end
  require('time-grunt')(grunt);

  grunt.registerTask('serve', function (target) {
    if (target === 'dist') {
      grunt.task.run(['build', 'connect:dist:keepalive']);
    } else {
      grunt.task.run([
        'dev-workflow'
      ]);
    }
  });

  grunt.registerTask('server', function () {
    grunt.log.warn('The `server` task has been deprecated. Use `grunt serve` to start a server.');
    grunt.task.run(['serve']);
  });

  grunt.registerTask('build', [
    'clean:dist',
    'webpack:main',
    'copy',
    'rev',
    'usemin'
  ]);

  grunt.registerTask('dev-workflow', [
    'clean:dev',
    'open:dev',
    'webpack-dev-server:main'
  ]);

  grunt.registerTask('dev-workflow-noreload', [
    'clean:dev',
    'open:dev',
    'webpack-dev-server:mainNoReload'
  ]);

  grunt.registerTask('default', [
    'dev-workflow'
  ]);
};
