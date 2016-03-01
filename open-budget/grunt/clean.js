module.exports = {
  options: {
    force: true,
  },
  dist: ['dist/**'],
  server: '.tmp',
  dev: [
    'app/bundle.js',
    'app/bundle.js.map',
    'app/styles/main.css',
    'app/styles/main.css.map',
  ],
};
