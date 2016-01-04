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
  }
};
