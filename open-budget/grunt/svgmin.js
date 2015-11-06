module.exports = {
    dist: {
      files: [{
        expand: true,
        cwd: '<%= yeoman.app %>/styles/assets',
        src: '{,*/}*.svg',
        dest: '<%= yeoman.dist %>/styles/assets'
      }]
    }
};
