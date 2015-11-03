module.exports = {
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
  }
};
