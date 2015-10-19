module.exports = {
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
};