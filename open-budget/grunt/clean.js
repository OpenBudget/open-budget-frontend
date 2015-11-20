module.exports = {
  dist: {
    files: [{
      dot: true,
      src: [
        '.tmp',
        '<%= yeoman.dist %>/*',
        '!<%= yeoman.dist %>/.git*'
      ]
    }]
  },
  server: '.tmp',

  generated_js: [
    '<%= yeoman.app %>/scripts/**/*.js',
    '<%= yeoman.app %>/scripts/**/*.js.map',
    '!<%= yeoman.app %>/scripts/templates.js',
    '!<%= yeoman.app %>/scripts/interval-query/**/*'
  ]
};
