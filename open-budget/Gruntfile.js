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
    'concurrent',
    'requirejs',
    'cssmin',
    'copy',
    'rev',
    'usemin'
  ]);

  grunt.registerTask('default', [
    'build'
  ]);
};
