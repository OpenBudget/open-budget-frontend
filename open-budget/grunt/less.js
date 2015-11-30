module.exports = {
  dist: {
    files: {
        '<%= yeoman.app %>/styles/main.css': ['<%= yeoman.app %>/styles/main.less'],
    },
    options: {
      sourceMap: true,
      sourceMapFilename: '<%= yeoman.app %>/styles/main.css.map',
      sourceMapBasepath: '<%= yeoman.app %>/',
      sourceMapRootpath: '/'
    }
  },

  spinner: {
    files: {
        '<%= yeoman.app %>/styles/spinner.css': ['<%= yeoman.app %>/styles/spinner.less']
    },
    options: {
      sourceMap: true,
      sourceMapFilename: '<%= yeoman.app %>/styles/spinner.css.map',
      sourceMapBasepath: '<%= yeoman.app %>/',
      sourceMapRootpath: '/'
    }
  }
};
