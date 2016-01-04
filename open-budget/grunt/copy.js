module.exports = {
  dist: {
      files: [{
        expand: true,
        dot: true,
        cwd: '<%= yeoman.app %>',
        dest: '<%= yeoman.dist %>',
        src: [
          'index.html',
          'bundle.js',
          'bundle.js.map',
          'styles/main.css',
          'styles/main.css.map',
          '*.{ico,png,txt}',
          '.htaccess',
          'styles/assets/*.png',
          'styles/assets/*.svg',
          'styles/assets/fonts/*.woff',
          'styles/assets/fonts/*.ttf',
          'bower_components/bootstrap-rtl/assets/fonts/*ttf',
          'bower_components/bootstrap-rtl/assets/fonts/*woff',
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
