var config = require('../app/webpack.config.js');
var semver = require('semver');

/*
  inline: true enables live reload
  The livereload breaks if the npm install was made with npm < 3
  npm 3 packed with node => 5 so we will disable it for node < 5
  Hopefully its temporary
 */
var inline = semver.satisfies(process.version, '>=5.0.0');

module.exports = {
  main: {
    webpack: config,
    keepalive: true,
    colors: true,
    progress: true,
    port: 9000,
    host: 'localhost',
    'contentBase': 'app/',
    inline: inline
  },

  mainNoReload: {
    webpack: config,
    keepalive: true,
    colors: true,
    progress: true,
    port: 9000,
    host: 'localhost',
    'contentBase': 'app/',
    inline: inline
  }
};
