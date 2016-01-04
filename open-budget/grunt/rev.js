module.exports = {
      dist: {
        files: {
          src: [
            '<%= yeoman.dist %>/bundle.js',
            '<%= yeoman.dist %>/styles/main.css',
            '<%= yeoman.dist %>/styles/assets/**/*.*',
            '!<%= yeoman.dist %>/styles/assets/**/*.svg'
          ]
        }
      }
};
