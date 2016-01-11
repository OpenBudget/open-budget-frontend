var config = require('../app/webpack.config.js');
module.exports = {
  main: {
    webpack: config,
    keepalive: true,
    colors: true,
    progress: true,
    port: 9000,
    host: 'localhost',
    'contentBase': 'app/',
    inline: true
  },

  mainNoReload: {
    webpack: config,
    keepalive: true,
    colors: true,
    progress: true,
    port: 9000,
    host: 'localhost',
    'contentBase': 'app/',
    inline: true
  }
};
