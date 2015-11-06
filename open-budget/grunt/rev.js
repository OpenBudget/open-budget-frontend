module.exports = {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/scripts/{,*/}*.js',
            '<%= yeoman.dist %>/styles/{,*/}*.css',
            '<%= yeoman.dist %>/styles/assets/**/*.*',
            '!<%= yeoman.dist %>/styles/assets/**/*.svg'
          ]
        }
      }
};
