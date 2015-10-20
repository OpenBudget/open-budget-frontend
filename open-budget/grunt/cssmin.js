module.exports = {
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
};